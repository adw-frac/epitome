"""Exports a causal language model from Hugging Face as MLIR, for
`examples/llm.rs` to compile with Epitome.

The model is exported by torch.export and torch-mlir as `linalg` on
tensors, in the generic form, for a fixed window of tokens: one function,

    forward(tensor<1xWINDOWxi64>) -> tensor<1xWINDOWxVOCABxf32>

from token ids to the logits at each position. With a causal mask, the
logits at position t depend only on tokens 0 to t, so the window can be
filled from the left and the rest left as padding.

Also written, to the same directory:

- config.txt: the window, the vocabulary's size and the token that ends a
  text, for the driver;
- tokens.txt: token i's bytes, in hex, on line i;
- merges.txt: the tokenizer's merges, in order, each two tokens in hex
  (a byte-level BPE tokenizer, as GPT-2's, is assumed);
- reference.txt: the prompt, its token ids, and the ids PyTorch's own model
  chooses greedily after it in the same window, to check against.

Tried with roneneldan/TinyStories-1M (GPT-Neo, 8 layers) and
HuggingFaceTB/SmolLM2-135M (Llama, 30 layers). Run it with torch-mlir's
Python environment (see docs/mlir/04-from-pytorch.md), with transformers:

    python examples/llm/export.py --model HuggingFaceTB/SmolLM2-135M target/smollm2
"""

import argparse
import json
import os

import torch
from torch_mlir import fx
from transformers import AutoModelForCausalLM, AutoTokenizer


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


def main():
    args = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    args.add_argument("out", help="the directory to write to")
    args.add_argument("--model", default="roneneldan/TinyStories-1M")
    args.add_argument("--window", type=int, default=64)
    args.add_argument("--prompt", default="Once upon a time, there was a little dog called")
    args.add_argument("--layers", type=int, help="only the first this many layers, to try the shapes quickly")
    a = args.parse_args()
    os.makedirs(a.out, exist_ok=True)

    tokenizer = AutoTokenizer.from_pretrained(a.model)
    more = {"num_hidden_layers": a.layers} if a.layers else {}
    model = AutoModelForCausalLM.from_pretrained(a.model, attn_implementation="eager", dtype=torch.float32, **more).eval()
    # torch-mlir's importer needs every buffer in the state dict (causal
    # masks, rotary frequencies).
    for module in model.modules():
        module._non_persistent_buffers_set.clear()

    ids = torch.zeros(1, a.window, dtype=torch.int64)
    module = fx.export_and_import(Forward(model), ids, output_type="linalg-on-tensors", func_name="forward")
    with open(os.path.join(a.out, "model.mlir"), "w") as f:
        f.write(module.operation.get_asm(print_generic_op_form=True, large_elements_limit=None))

    vocab = model.config.vocab_size
    end = tokenizer.eos_token_id if tokenizer.eos_token_id is not None else -1
    with open(os.path.join(a.out, "config.txt"), "w") as f:
        f.write(f"window {a.window}\nvocab {vocab}\nend {end}\n")

    # The tokenizer, as bytes; ids past the tokenizer's are empty.
    decode = byte_decoder()
    by_id = {i: t for t, i in tokenizer.get_vocab().items()}
    as_hex = lambda token: bytes(decode.get(c, ord("?")) for c in token).hex()
    with open(os.path.join(a.out, "tokens.txt"), "w") as f:
        for i in range(vocab):
            f.write((as_hex(by_id[i]) if i in by_id else "") + "\n")
    merges = json.loads(tokenizer.backend_tokenizer.to_str())["model"]["merges"]
    with open(os.path.join(a.out, "merges.txt"), "w") as f:
        for m in merges:
            x, y = m if isinstance(m, (list, tuple)) else m.split(" ")
            f.write(f"{as_hex(x)} {as_hex(y)}\n")

    # PyTorch's own greedy choices, a window at a time, as the driver makes them.
    prompt = tokenizer(a.prompt)["input_ids"]
    window = torch.zeros(1, a.window, dtype=torch.int64)
    window[0, : len(prompt)] = torch.tensor(prompt)
    chosen = []
    with torch.no_grad():
        for t in range(len(prompt), a.window):
            nxt = int(Forward(model)(window)[0, t - 1].argmax())
            if nxt == end:
                break
            window[0, t] = nxt
            chosen.append(nxt)
    with open(os.path.join(a.out, "reference.txt"), "w") as f:
        f.write(a.prompt + "\n")
        f.write(" ".join(map(str, prompt)) + "\n")
        f.write(" ".join(map(str, chosen)) + "\n")
    print(a.prompt + tokenizer.decode(chosen))


if __name__ == "__main__":
    main()
