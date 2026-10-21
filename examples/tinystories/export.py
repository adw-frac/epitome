"""Exports TinyStories-1M, a small language model from Hugging Face, as MLIR
for `examples/tinystories.rs` to compile with Epitome.

TinyStories-1M (roneneldan/TinyStories-1M) is a GPT-Neo model of 8 layers,
16 heads and a hidden size of 64, trained to write short stories. It is
exported by torch.export and torch-mlir as `linalg` on tensors, in the
generic form, for a fixed window of WINDOW tokens: one function,

    forward(tensor<1xWINDOWxi64>) -> tensor<1xWINDOWx50257xf32>

from token ids to the logits at each position. With a causal mask, the
logits at position t depend only on tokens 0 to t, so the window can be
filled from the left and the rest left as padding.

Also written, to the same directory:

- tokens.txt: token i's bytes, in hex, on line i;
- merges.txt: the tokenizer's merges, in order, each two tokens in hex;
- reference.txt: a prompt, its token ids, and the ids PyTorch's own model
  chooses greedily after it in the same window, to check against.

Run it with torch-mlir's Python environment (see
docs/mlir/04-from-pytorch.md), with transformers installed:

    python examples/tinystories/export.py target/tinystories
"""

import os
import sys

import torch
from torch_mlir import fx
from transformers import AutoModelForCausalLM, AutoTokenizer

NAME = "roneneldan/TinyStories-1M"
WINDOW = 64
PROMPT = "Once upon a time, there was a little dog called"


class Forward(torch.nn.Module):
    """The model's logits for a window of token ids."""

    def __init__(self, model):
        super().__init__()
        self.model = model

    def forward(self, ids):
        return self.model(input_ids=ids, use_cache=False).logits


def byte_decoder():
    """GPT-2's map from the characters its vocabulary is written in back to
    bytes: printable bytes stand for themselves, the rest for characters
    from 256 up."""
    keep = list(range(ord("!"), ord("~") + 1)) + list(range(ord("¡"), ord("¬") + 1)) + list(range(ord("®"), ord("ÿ") + 1))
    chars = keep[:]
    n = 0
    for b in range(256):
        if b not in keep:
            keep.append(b)
            chars.append(256 + n)
            n += 1
    return {chr(c): b for b, c in zip(keep, chars)}


def main(out):
    os.makedirs(out, exist_ok=True)
    tokenizer = AutoTokenizer.from_pretrained(NAME)
    model = AutoModelForCausalLM.from_pretrained(NAME, attn_implementation="eager").eval()
    # torch-mlir's importer needs every buffer in the state dict, the causal
    # masks included.
    for module in model.modules():
        module._non_persistent_buffers_set.clear()

    ids = torch.zeros(1, WINDOW, dtype=torch.int64)
    module = fx.export_and_import(Forward(model), ids, output_type="linalg-on-tensors", func_name="forward")
    with open(os.path.join(out, "model.mlir"), "w") as f:
        f.write(module.operation.get_asm(print_generic_op_form=True, large_elements_limit=None))

    # The tokenizer, as bytes.
    decode = byte_decoder()
    vocab = tokenizer.get_vocab()
    by_id = sorted(vocab.items(), key=lambda kv: kv[1])
    assert [i for _, i in by_id] == list(range(len(by_id)))
    as_hex = lambda token: bytes(decode[c] for c in token).hex()
    with open(os.path.join(out, "tokens.txt"), "w") as f:
        for token, _ in by_id:
            f.write(as_hex(token) + "\n")
    merges = tokenizer.backend_tokenizer.model.get_merges() if hasattr(tokenizer.backend_tokenizer.model, "get_merges") else None
    if merges is None:
        import json
        merges = json.loads(tokenizer.backend_tokenizer.to_str())["model"]["merges"]
    with open(os.path.join(out, "merges.txt"), "w") as f:
        for m in merges:
            a, b = m if isinstance(m, (list, tuple)) else m.split(" ")
            f.write(f"{as_hex(a)} {as_hex(b)}\n")

    # PyTorch's own greedy choices, a window at a time, as the driver makes them.
    prompt = tokenizer(PROMPT)["input_ids"]
    window = torch.zeros(1, WINDOW, dtype=torch.int64)
    window[0, : len(prompt)] = torch.tensor(prompt)
    chosen = []
    with torch.no_grad():
        for t in range(len(prompt), WINDOW):
            logits = Forward(model)(window)
            nxt = int(logits[0, t - 1].argmax())
            window[0, t] = nxt
            chosen.append(nxt)
    with open(os.path.join(out, "reference.txt"), "w") as f:
        f.write(PROMPT + "\n")
        f.write(" ".join(map(str, prompt)) + "\n")
        f.write(" ".join(map(str, chosen)) + "\n")
    print(PROMPT + tokenizer.decode(chosen))


if __name__ == "__main__":
    main(sys.argv[1])
