"""Exports a small attention block from JAX as StableHLO, for
`examples/jax.rs` to compile with Epitome, with an input and JAX's own
output to check against.

The block, for 64 positions of 32 features:

    h = gelu(x @ w_in)                      # [64, 64], tanh's approximation
    h = where(h > 0, h, 0.1 h)              # leaky ReLU
    q = h as 4 heads of 16, heads first     # [4, 64, 16]
    a = softmax(q q^T / 4, causal)          # [4, 64, 64]
    o = (a q) as [64, 64], then @ w_out     # [64, 32]
    return o / mean(o^2 + 1) per row        # [64, 32]

Written to the directory given (default target/jax):

- block.mlir: the function `block`, as StableHLO in MLIR's generic form,
  its weights constants in it;
- input.txt and expected.txt: the input and JAX's output, as numbers.

Run it with JAX installed (`pip install jax`):

    python examples/jax/export.py target/jax
"""

import os
import sys

import jax
import jax.numpy as jnp
import numpy as np


def weights(shape, seed):
    n = int(np.prod(shape))
    return np.array([((i * seed % 101) - 50) / 200.0 for i in range(n)], dtype=np.float32).reshape(shape)


W_IN = weights((32, 64), 37)
W_OUT = weights((64, 32), 53)


def block(x):
    h = jax.nn.gelu(x @ W_IN, approximate=True)
    h = jnp.where(h > 0, h, 0.1 * h)
    q = h.reshape(64, 4, 16).transpose(1, 0, 2)
    s = jnp.einsum("hqd,hkd->hqk", q, q) / 4.0
    causal = jnp.arange(64)[:, None] >= jnp.arange(64)[None, :]
    s = jnp.where(causal, s, -1e9)
    a = jax.nn.softmax(s, axis=-1)
    o = jnp.einsum("hqk,hkd->hqd", a, q).transpose(1, 0, 2).reshape(64, 64) @ W_OUT
    return o / jnp.mean(o * o + 1.0, axis=1, keepdims=True)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "target/jax"
    os.makedirs(out, exist_ok=True)
    x = np.array([((i * 13 % 29) - 14) / 10.0 for i in range(64 * 32)], dtype=np.float32).reshape(64, 32)
    lowered = jax.jit(block).lower(jax.ShapeDtypeStruct(x.shape, jnp.float32))
    text = lowered.compiler_ir("stablehlo").operation.get_asm(print_generic_op_form=True, large_elements_limit=None)
    # JAX names the function `main`; a C program has one of its own.
    text = text.replace('sym_name = "main"', 'sym_name = "block"', 1)
    with open(os.path.join(out, "block.mlir"), "w") as f:
        f.write(text)
    np.savetxt(os.path.join(out, "input.txt"), x.reshape(-1), fmt="%.9g")
    np.savetxt(os.path.join(out, "expected.txt"), np.asarray(jax.jit(block)(x)).reshape(-1), fmt="%.9g")
    print(f"wrote {out}/block.mlir, input.txt, expected.txt")


if __name__ == "__main__":
    main()
