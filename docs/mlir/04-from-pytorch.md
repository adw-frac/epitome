# From PyTorch to MLIR

This chapter describes how a PyTorch model becomes MLIR, and how that MLIR
becomes LLVM IR. It covers `torch.export`, the torch-mlir importer, the
`torch` dialect, the three backends torch-mlir offers (linalg-on-tensors,
TOSA and StableHLO), and the passes from linalg down to the `llvm`
dialect. Chapters [02](02-core-dialects.md) and [03](03-llvm-dialect.md)
describe the dialects used on the way down.

The chapter is written from published documentation and from running the
tools on our own small models. No torch-mlir or MLIR source code, TableGen
or test file was read. Documentation was read on 2026-10-20.

Every worked example in section 9 was produced by the tools, not written by
hand. The scripts and full outputs are in
[`examples/pytorch/`](examples/pytorch/). Section 10 lists the files.

**Observed:** tool versions for every **Observed** note in this chapter.

| Tool | Version |
| --- | --- |
| Python | 3.12.13 (macOS 26.7.1, arm64) |
| `torch` | 2.16.0.dev20261020 (CPU nightly) |
| `torchvision` | 0.30.0.dev20261020 |
| `torch-mlir` | 20261001 (nightly wheel from `torch-mlir-release` `dev-wheels`) |
| `torch-mlir-opt --version` | LLVM version 24.0.0git |
| `clang` (to check the `.ll` files) | Apple clang 21.0.0 (clang-2100.3.34.2) |

The wheel was installed with the command from the torch-mlir README:

```
pip install --pre torch-mlir torchvision \
  --extra-index-url https://download.pytorch.org/whl/nightly/cpu \
  -f https://github.com/llvm/torch-mlir-release/releases/expanded_assets/dev-wheels
```

The README says snapshots exist for Python 3.10 and 3.11. **Observed:** a
wheel for Python 3.12 was also available and installed without trouble.

## 1. The paths

There are several ways from a PyTorch model to MLIR. The current one is:

```
nn.Module
  -> torch.export.export()            ExportedProgram (ATen IR, FX graph)
  -> torch_mlir.fx.export_and_import  torch dialect (!torch.vtensor, torch.aten.*)
  -> torch-mlir lowering              linalg-on-tensors | tosa | stablehlo
  -> upstream MLIR passes             bufferize, loops, llvm dialect
  -> translation                      LLVM IR (.ll)
```

| Path | Entry point | Status |
| --- | --- | --- |
| FX importer | `torch_mlir.fx.export_and_import` | Current. "Aligned with PyTorch's roadmap, but ... not fully functional yet" (roadmap.md) |
| ONNX importer | `torch-mlir-import-onnx`, `torch-onnx-to-torch-backend-pipeline` | Current, separate route from ONNX files |
| TorchScript | `torch_mlir.torchscript.compile` | **Deprecated.** "Tied to the old Torchscript path" |
| LazyTensorCore | LTC backend | Needs the full PyTorch runtime, so not ahead-of-time |
| iree-turbine | `iree.turbine.aot.export` | Separate consumer that uses torch-mlir to feed IREE |

Source: https://github.com/llvm/torch-mlir/blob/main/README.md,
https://github.com/llvm/torch-mlir/blob/main/docs/roadmap.md,
https://github.com/llvm/torch-mlir/blob/main/docs/architecture.md

**Observed:** the nightly wheel has no `torch_mlir.torchscript` module.
Importing it fails with `ModuleNotFoundError`. The deprecated path now lives
only in the source tree (`projects/pt1`). The wheel does ship
`torch_mlir.fx`, `torch_mlir.extras.fx_importer`,
`torch_mlir.extras.onnx_importer`, and the commands `torch-mlir-opt` and
`torch-mlir-import-onnx`.

**Epitome note:** Epitome reads LLVM IR, so it sits at the end of this
chain. What matters to us is the shape of the LLVM IR that comes out
(section 8), and which steps decide that shape. The earlier steps matter
only if Epitome ever reads MLIR directly.

## 2. torch.export and ExportedProgram

### 2.1 What it does

`torch.export.export(module, args)` traces a module ahead of time and returns
an `ExportedProgram`. It captures only the tensor computation. The graph is
flat: submodules are inlined and no Python semantics remain. Each node keeps
metadata such as shape, dtype and a stack trace into the user's code.

Unlike `torch.compile`, export does not fall back to Python when it cannot
trace something. It raises an error instead. Data-dependent control flow,
such as `if x.shape[0] > 2`, must be rewritten with control-flow operators
such as `torch.cond`. Operators without a fake-tensor (meta) kernel cannot be
traced.

`strict=True` traces with TorchDynamo. `strict=False` (non-strict) traces in
Python and gets past some failures. **Observed:** `export_and_import` in
torch-mlir defaults to `strict=False`.

Source: https://docs.pytorch.org/docs/2.14/user_guide/torch_compiler/export.html

**Not documented:** the PyTorch page did not say which value of `strict` is
the default for `torch.export.export` itself.

### 2.2 The graph

An `ExportedProgram` holds a `torch.fx` graph (`graph_module`), a
`graph_signature`, a `state_dict` and `range_constraints`. The graph is a
valid FX graph with these restrictions:

| Node `op` | Use |
| --- | --- |
| `placeholder` | One per input. They come first. `target` is the input name |
| `call_function` | Calls an ATen operator, a custom operator or a control-flow operator |
| `get_attr` | Only to read submodules (such as the branches of `cond`) |
| `output` | Exactly one, at the end |

There are no `call_module` or `call_method` nodes. Constant arguments are
written into the graph. `call_function` nodes carry `meta` entries
`stack_trace`, `val` (a fake tensor, a `SymInt`, a list of them, or `None`),
`nn_module_stack` and `source_fn_stack`.

Source: https://docs.pytorch.org/docs/2.14/user_guide/torch_compiler/export/ir_spec.html

### 2.3 Parameters and buffers are inputs

Export lifts parameters and buffers out of the module and makes them graph
inputs. The `graph_signature` says which input is which.

**Observed:** for the MLP of section 9.1, `print(ep)` shows:

```
def forward(self, p_fc1_weight: "f32[8, 4]", p_fc1_bias: "f32[8]",
            p_fc2_weight: "f32[2, 8]", p_fc2_bias: "f32[2]", x: "f32[1, 4]"):
    linear: "f32[1, 8]" = torch.ops.aten.linear.default(x, p_fc1_weight, p_fc1_bias)
    relu: "f32[1, 8]" = torch.ops.aten.relu.default(linear)
    linear_1: "f32[1, 2]" = torch.ops.aten.linear.default(relu, p_fc2_weight, p_fc2_bias)
    return (linear_1,)

Graph signature:
    # inputs
    p_fc1_weight: PARAMETER target='fc1.weight'
    ...
    x: USER_INPUT
    # outputs
    linear_1: USER_OUTPUT
```

Parameters come first, then user inputs. A module with a buffer prints
`b_count: BUFFER target='count' persistent=True`.

**Not documented:** the pages read do not list the input and output kind
names (`PARAMETER`, `BUFFER`, `USER_INPUT`, `USER_OUTPUT` above are what
`print` shows), nor the order of inputs in the signature.

### 2.4 IR levels

Export can produce three levels of IR:

| IR | How to get it | Properties | Ops (about) |
| --- | --- | --- | --- |
| Training IR | `torch.export.export()` | May contain mutation; works with eager autograd | 3000 |
| Inference IR | `ep.run_decompositions(decomp_table={})` | Purely functional | 2000 |
| Core ATen IR | `ep.run_decompositions(decomp_table=None)` | Purely functional, highly decomposed | 180 |

Core ATen IR is "fully functional, and there is no inplace or _out variants
in this opset". It reuses ATen operators from `native_functions.yaml` and
does not make type promotion or broadcasting explicit. Prims IR goes further:
it makes them explicit with `prims.convert_element_type` and
`prims.broadcast_in_dim`, and has about 120 primitives.

Examples of Core ATen ops: `aten.add.Tensor`, `aten.addmm`, `aten.bmm`,
`aten.cat`, `aten.convolution`, `aten.div.Tensor`, `aten.embedding`,
`aten.exp`, `aten.expand`, `aten.gather`, `aten.index.Tensor`,
`aten.max.dim`, `aten.mean`, `aten.mm`, `aten.mul.Tensor`,
`aten.native_layer_norm`, `aten.permute`, `aten.relu`, `aten.rsqrt`,
`aten.sum.dim_IntList`, `aten.tanh`, `aten.view`, `aten.where.self`.

Source: https://docs.pytorch.org/docs/2.14/user_guide/torch_compiler/torch.compiler_ir.html

**Observed:** for the MLP, `aten.linear` survives `torch.export.export`.
After `run_decompositions()` it becomes `aten.permute` and `aten.addmm`
(`extra_mlp.core_aten.txt`).

### 2.5 Dynamic shapes

By default shapes are static, and the program is specialised to the example
inputs. `torch.export.Dim("batch")` names a symbolic size, optionally with
bounds. `Dim.DYNAMIC` infers ranges and complains if a dimension turns out
static. `Dim.AUTO` does the same without complaining. `range_constraints`
reports each symbol's range. Export assumes sizes 0 and 1 do not occur for
dynamic dimensions ("not a bug").

**Observed:** marking dimension 0 dynamic with an example batch of 1 fails:
"You marked batch as dynamic but your code specialized it to be a constant
(1)". With an example batch of 2 it works (section 9.5).

## 3. The torch-mlir FX importer

### 3.1 export_and_import

`torch_mlir.fx.export_and_import(f, *args, output_type=...)` calls
`torch.export.export` (unless `f` is already an `ExportedProgram`), imports
the graph into the `torch` dialect, and optionally lowers it to a backend.

**Observed:** the signature, from `inspect.signature`:

```
export_and_import(f, *args, output_type=OutputType.RAW, fx_importer=None,
    dynamic_shapes=None, strict=False, experimental_support_mutation=False,
    import_symbolic_shape_expressions=False, hooks=None,
    decomposition_table=None, func_name='main', enable_graph_printing=False,
    verbose=False, enable_ir_printing=False, backend_legal_ops=None,
    allow_non_finites=True, **kwargs)
```

`output_type` takes an `OutputType` or its string:

| `OutputType` | String | Result |
| --- | --- | --- |
| `RAW` | `"raw"` | `torch` dialect as imported |
| `TORCH` | `"torch"` | `torch` dialect satisfying the backend contract (section 4.6) |
| `LINALG_ON_TENSORS` | `"linalg-on-tensors"` | `linalg`, `tensor`, `arith`, `math` on builtin tensors |
| `TOSA` | `"tosa"` | `tosa` on builtin tensors |
| `STABLEHLO` | `"stablehlo"` | `stablehlo` on builtin tensors |

The returned object is an MLIR module from torch-mlir's own copy of the MLIR
Python bindings (`torch_mlir.ir`). `str(module)` prints it.

**Not documented:** the README and docs do not describe `export_and_import`
beyond naming it. The signature above is what the tool reports.

### 3.2 What the importer does to the graph

**Observed** (section 9):

- **Parameters become constants.** The ExportedProgram passes weights as
  inputs, but the imported `func.func` takes only user inputs. Each weight
  becomes a `torch.vtensor.literal` holding a `dense_resource` blob.
- **It decomposes.** `aten.linear` became `aten.permute`, `aten.mm`,
  `aten.mul.Scalar` (by 1), `aten.expand` and `aten.add.Tensor`. This is a
  different decomposition from PyTorch's Core ATen (`addmm`).
- **The function name** is `func_name` (default `main`).
- **A mutated buffer becomes an extra result.** See section 9.6.

### 3.3 Other importers and consumers

- **ONNX.** `torch-mlir-import-onnx` reads an ONNX file into `torch`
  dialect ops named `torch.operator "onnx.*"`, and
  `torch-onnx-to-torch-backend-pipeline` lowers them. Not explored here.
- **TorchScript (deprecated).** `torch_mlir.torchscript.compile(model,
  example, output_type=...)` took the same output types. It needed shape and
  dtype annotations on arguments, lowered the `nn.Module` object graph with
  `torch-globalize-object-graph`, and functionalised the program itself.
  The docs say it "doesn't give access to the current generation work".
- **iree-turbine** (`pip install iree-turbine`) is IREE's PyTorch frontend.
  `aot.export(module, example_arg)` produces MLIR that `.compile(save_to=...)`
  turns into an IREE `.vmfb`. `aot.externalize_module_parameters()` keeps
  weights out of the IR, to be supplied at run time (for example from a
  Safetensors file). `torch.compile(..., backend="turbine_cpu")` is the JIT
  route. IREE then takes over from MLIR to its own runtime, so this path
  does not produce a plain `.ll`.

Source: https://iree.dev/guides/ml-frameworks/pytorch/

## 4. The torch dialect

The `torch` dialect models PyTorch's program and types "almost all 1:1".
Most ops are generated from PyTorch's operator registry. Some are written by
hand: object-graph ops, `torch.global_slot`, interpreter constructs such as
`torch.prim.If`, `torch.prim.ListConstruct` and `torch.constant.*`, and the
generic `torch.operator` for ops with no generated definition.

Source: https://github.com/llvm/torch-mlir/blob/main/docs/architecture.md

### 4.1 Tensor types

| Type | Meaning |
| --- | --- |
| `!torch.vtensor<[d0,d1,...],dtype>` | Value-semantic tensor. "Immutable and non-aliased" |
| `!torch.tensor<[d0,...],dtype>` | Non-value tensor. Models `torch.Tensor` with mutation and aliasing |
| `!torch.vtensor` / `!torch.tensor` | Same, with unknown shape and dtype |

Both carry an optional list of optional sizes and an optional dtype. A
dynamic size is `?`. A rank-0 tensor has `[]`.

**Observed** spellings: `!torch.vtensor<[1,4],f32>`,
`!torch.vtensor<[?,4],f32>`, `!torch.vtensor<[],f64>`.

### 4.2 Dtypes

**Observed** (`dtypes.raw.mlir`, `dtypes.linalg.mlir`):

| PyTorch dtype | `torch` dialect | After lowering to builtin tensors |
| --- | --- | --- |
| `torch.bool` | `i1` | `i1` |
| `torch.uint8` | `ui8` | `i8` |
| `torch.int8` | `si8` | `i8` |
| `torch.int32` | `si32` | `i32` |
| `torch.int64` | `si64` | `i64` |
| `torch.float16` | `f16` | `f16` |
| `torch.bfloat16` | `bf16` | `bf16` |
| `torch.float32` | `f32` | `f32` |
| `torch.float64` | `f64` | `f64` |

The `torch` dialect uses signed and unsigned integer types. The backends use
signless ones, so the signedness moves from the type into the ops (for
example `arith.extsi` versus `arith.extui`).

**Epitome note:** by the time the program is LLVM IR, `ui8` and `si8` are
both `i8`. Whether a load is treated as signed or unsigned is visible only
in the extension instructions that follow it.

### 4.3 Scalar and other types

| Type | PyTorch equivalent |
| --- | --- |
| `!torch.int` | Python `int` (64-bit) |
| `!torch.float` | Python `float` (64-bit) |
| `!torch.bool` | Python `bool` |
| `!torch.none` | `None` |
| `!torch.list<T>` | `List[T]`, for example `!torch.list<int>` |
| `!torch.nn.Module<"name">` | TorchScript module object (old path only) |

**Not documented:** architecture.md shows only `!torch.bool`, `!torch.int`,
`!torch.float`, `!torch.tensor` and `!torch.nn.Module`. `!torch.none` and
`!torch.list<int>` are from the observed output. No published page lists
the full set of torch types (optional, string, device and others).

### 4.4 Op naming

| Prefix | Meaning | Example |
| --- | --- | --- |
| `torch.aten.<name>[.<overload>]` | ATen operator, overload after a dot | `torch.aten.add.Tensor`, `torch.aten.mm`, `torch.aten.sum.dim_IntList` |
| `torch.aten.<name>_` | In-place variant (non-value tensors) | `torch.aten.add_.Tensor` |
| `torch.prim.*` | TorchScript primitives | `torch.prim.ListConstruct`, `torch.prim.If` |
| `torch.constant.*` | Constants | `torch.constant.int 1`, `torch.constant.float 5.0e-02`, `torch.constant.bool false`, `torch.constant.none` |
| `torch.vtensor.literal` | Tensor constant | `torch.vtensor.literal(dense_resource<...> : tensor<8x4xf32>)` |
| `torch.quantized_decomposed.*` | PT2E quantise/dequantise ops | `torch.quantized_decomposed.quantize_per_tensor` |
| `torch.operator "<name>"` | Any op without a generated definition | `torch.operator "onnx.Add"` |
| `torch.symbolic_int`, `torch.bind_symbolic_shape` | Symbolic shapes from export | section 9.5 |

The overload name is the one PyTorch uses (`.default` is dropped).
Operands are SSA values of torch types; even scalar arguments such as
`alpha` are `!torch.int` values made by `torch.constant.int`.

**Observed:** the printer names constant results after their value:
`%int1`, `%int-128`, `%false`, `%none`, `%float5.000000e-02`. Repeats get
suffixes (`%int1_0`).

**Epitome note:** these are SSA names chosen by MLIR's printer, the same
way LLVM's printer chooses `%0`. They carry no meaning.

### 4.5 Functions

Functions are ordinary `func.func` with torch types in their signatures
(section 9.2 shows one). Each op is printed in the form
`%r = torch.aten.mm %a, %b : <operand types> -> <result type>`.

### 4.6 The backend contract

The backend contract is a normalised subset of the `torch` dialect. It is
the boundary between torch-mlir's frontend and its backends. In it:

- all tensors have value semantics (`!torch.vtensor`);
- all tensors have a known rank, and ideally known sizes;
- all tensors have a known dtype;
- certain ops have been decomposed (configurable).

The precise definition is a function in torch-mlir's C++ code
(`satisfiesBackendContract`). The pass `torch-lower-to-backend-contract`
repeats a simplification pipeline (canonicalisation, shape and dtype
refinement, `torch-decompose-complex-ops`) until the contract holds.

**Observed:** `output_type="torch"` gives this form. Compared with `raw`, the
MLP's constants were hoisted to the top and de-duplicated, `aten.expand`
became `aten.broadcast_to`, and the IR otherwise kept the same ops.

`backend_legal_ops` lists ops that `torch-decompose-complex-ops` should leave
alone, so a backend can lower them itself.

**Not documented:** the exact set of ops decomposed by default.

### 4.7 Pipelines and passes

**Observed:** `torch-mlir-opt --help` lists these pipelines:

| Pipeline | From | To |
| --- | --- | --- |
| `torch-function-to-torch-backend-pipeline` | `torch` dialect function | backend contract |
| `torch-onnx-to-torch-backend-pipeline` | `torch.operator "onnx.*"` | backend contract |
| `torch-backend-to-linalg-on-tensors-backend-pipeline` | backend contract | linalg-on-tensors |
| `torch-backend-to-tosa-backend-pipeline` | backend contract | TOSA |
| `torch-backend-to-stablehlo-backend-pipeline` | backend contract | StableHLO |
| `torch-shape-refinement-pipeline`, `torch-simplification-pipeline` | helpers | |

Other passes include `torch-maximize-value-semantics`,
`torch-reduce-op-variants`, `torch-decompose-complex-ops`,
`torch-fuse-quantized-ops`, `torch-func-backend-type-conversion`,
`torch-finalizing-backend-type-conversion`, and the verifiers
`torch-verify-linalg-on-tensors-backend-contract`,
`torch-verify-tosa-backend-contract` and
`torch-verify-stablehlo-backend-contract`. The `refback-*` passes belong to
torch-mlir's test-only reference backend.

The backend pipelines also convert the types. `!torch.vtensor<[2,3],f32>`
becomes `tensor<2x3xf32>`, and the torch scalar types become builtin types.

**Observed:** the wheel's `torch-mlir-opt` registers only torch-mlir's own
passes. It has no `one-shot-bufferize`, `convert-linalg-to-loops` or
`convert-*-to-llvm`. Those upstream passes are available through the
wheel's Python bindings (`torch_mlir.passmanager.PassManager`), which is
how section 8 runs them.

## 5. Backend: linalg-on-tensors

linalg-on-tensors is torch-mlir's oldest and most complete backend. It
"fully supports dynamic shapes (known number of dimensions but arbitrary
dynamic dimension sizes)". Its output mixes several upstream dialects:

| Dialect | Ops seen in our examples |
| --- | --- |
| `linalg` | `linalg.matmul`, `linalg.conv_2d_nchw_fchw`, `linalg.fill`, `linalg.transpose`, `linalg.broadcast`, `linalg.generic`, `linalg.yield` |
| `tensor` | `tensor.empty`, `tensor.pad`, `tensor.dim`, `tensor.yield` |
| `arith` | `arith.constant`, `arith.addf`, `arith.mulf`, `arith.cmpf`, `arith.select`, `arith.extsi`, `arith.extui`, `arith.trunci`, `arith.fptosi`, `arith.sitofp`, `arith.index_cast`, `arith.cmpi` |
| `math` | `math.roundeven` |
| `cf` | `cf.assert` (dynamic shape checks) |

Weights become `arith.constant dense_resource<...>`. Elementwise ops become
`linalg.generic` with `"parallel"` iterators, and reductions use
`"reduction"`. Every linalg op is in destination-passing style: it takes an
`outs` tensor (usually from `tensor.empty`, or `linalg.fill` for an
accumulator) and returns the updated tensor.

**Observed:** for an `int8 x int8 -> int32` matmul (`torch._int_mm`),
`linalg.matmul` takes `i8` operands and an `i32` accumulator directly. The
widening is implicit in the named op. For `bool` summed to `int64`, the body
of the `linalg.generic` used `arith.extui`; for `int8` to `int32`,
`arith.extsi`.

**Not documented** (in the part of the Linalg page read): which extension a
mixed-type `linalg.matmul` applies by default. The observed TOSA and torch
semantics imply signed.

Source: https://mlir.llvm.org/docs/Dialects/Linalg/,
https://github.com/llvm/torch-mlir/blob/main/docs/architecture.md

## 6. Backend: TOSA

### 6.1 Why TOSA

TOSA (Tensor Operator Set Architecture) is a small set of whole-tensor
operators with an "ISA-like" specification. The torch-mlir docs say it is
preferred by "hardware or hardware-adjacent folks": it has good support for
quantisation and integer types, clear versioning of op semantics, and is
"extremely solid with static shapes". It limits some operators to fewer
dimensions than StableHLO does.

The MLIR `tosa` dialect implements the spec. The spec's design aims are
completeness (cover what frameworks need), minimality (leave fusion to the
backend), and numerical precision (quantisation details are part of each
operator's definition).

Source: https://mlir.llvm.org/docs/Dialects/TOSA/,
https://www.mlplatform.org/tosa/tosa_spec_1_0_2.html

### 6.2 Op summary

| Group | Ops |
| --- | --- |
| Tensor compute | `tosa.matmul`, `tosa.conv2d`, `tosa.conv3d`, `tosa.depthwise_conv2d`, `tosa.transpose_conv2d`, `tosa.fft2d`, `tosa.rfft2d`, `tosa.avg_pool2d`, `tosa.max_pool2d`, `tosa.argmax`, `tosa.argmin` |
| Elementwise binary | `tosa.add`, `tosa.sub`, `tosa.mul`, `tosa.intdiv`, `tosa.pow`, `tosa.maximum`, `tosa.minimum`, `tosa.arithmetic_right_shift`, `tosa.logical_left_shift`, `tosa.logical_right_shift`, `tosa.bitwise_and`/`or`/`xor`, `tosa.logical_and`/`or`/`xor` |
| Elementwise unary | `tosa.abs`, `tosa.ceil`, `tosa.floor`, `tosa.clz`, `tosa.cos`, `tosa.sin`, `tosa.exp`, `tosa.log`, `tosa.erf`, `tosa.negate`, `tosa.reciprocal`, `tosa.rsqrt`, `tosa.sigmoid`, `tosa.tanh`, `tosa.bitwise_not`, `tosa.logical_not` |
| Comparison and selection | `tosa.equal`, `tosa.greater`, `tosa.greater_equal`, `tosa.select`, `tosa.clamp` |
| Reduction | `tosa.reduce_all`, `tosa.reduce_any`, `tosa.reduce_max`, `tosa.reduce_min`, `tosa.reduce_product`, `tosa.reduce_sum` |
| Data movement | `tosa.concat`, `tosa.pad`, `tosa.reshape`, `tosa.reverse`, `tosa.slice`, `tosa.tile`, `tosa.transpose`, `tosa.gather`, `tosa.scatter`, `tosa.resize` |
| Type conversion | `tosa.cast`, `tosa.rescale`, `tosa.table`, `tosa.apply_scale` |
| Shapes | `tosa.const_shape`, `tosa.dim`, `tosa.add_shape` and other `*_shape` ops; type `!tosa.shape<N>` |
| Control flow | `tosa.cond_if`, `tosa.while_loop`, `tosa.yield` |
| Constants and state | `tosa.const`, `tosa.identity`, `tosa.variable`, `tosa.variable_read`, `tosa.variable_write`, `tosa.custom` |

The dialect page also lists newer block-scaled ops (`tosa.matmul_t_block_scaled`,
`tosa.conv2d_block_scaled`, `tosa.cast_to_block_scaled` and others) and
`tosa.matmul_t`. These are not in TOSA 1.0.2.

Operands and attributes of the ops seen in our output:

| Op | Operands | Attributes |
| --- | --- | --- |
| `tosa.matmul` | `a`, `b`, `a_zp`, `b_zp` | none |
| `tosa.conv2d` | `input` (NHWC), `weight` (OHWI), `bias`, `input_zp`, `weight_zp` | `pad` (4), `stride` (2), `dilation` (2), `acc_type`, `local_bound` |
| `tosa.rescale` | `input`, `multiplier`, `shift`, `input_zp`, `output_zp` | `scale32`, `rounding_mode`, `per_channel`, `input_unsigned`, `output_unsigned` |
| `tosa.mul` | `input1`, `input2`, `shift` (i8 tensor) | none |
| `tosa.clamp` | `input` | `min_val`, `max_val`, optional `nan_mode` |
| `tosa.const` | none | `values` |
| `tosa.reshape` | `input1`, `shape` (`!tosa.shape`) | none |

Zero points and shifts are operands, normally from `tosa.const`, not
attributes. **Observed:** a zero point is a one-element tensor such as
`"tosa.const"() <{values = dense<0> : tensor<1xi8>}>`, and for float ops
it is a float zero (`tensor<1xf32>`).

**Not documented** (in the dialect page read): which TOSA spec version the
dialect implements. It links to TOSA 1.0.0.

### 6.3 Points for integer and quantised accelerators

From TOSA 1.0.2:

- **Profiles.** `PRO-INT` (integer, "primarily 8- and 32-bit values") and
  `PRO-FP` (fp16 and fp32). A conformant implementation supports at least
  one profile, and any extension it claims, in full.
- **Extensions.** `EXT-INT16`, `EXT-INT4`, `EXT-DOUBLEROUND`,
  `EXT-INEXACTROUND` (experimental), `EXT-BF16`, `EXT-FP8E4M3`,
  `EXT-FP8E5M2`, `EXT-FFT`, `EXT-VARIABLE`, `EXT-CONTROLFLOW`,
  `EXT-DYNAMIC`.
- **Accumulators.** `MATMUL`: `i8 x i8 -> i32` (PRO-INT), `i16 x i16 -> i48`
  (EXT-INT16). Convolutions: `i8 x i8 -> i32`, `i16 x i8 -> i48`
  (EXT-INT16), `i8 x i4 -> i32` (EXT-INT4). `int4` is -7 to +7.
- **No implicit scaling.** Every change of scale is an explicit `RESCALE`.
  Operands of an elementwise `ADD` with different scales must first be
  rescaled to a common 32-bit range.
- **Zero points.** `input_zp` and `weight_zp` must be zero for non-int8
  types. In PRO-INT and PRO-FP they are compile-time constants.
- **RESCALE.** Per element: subtract `input_zp` (widened to 48 bits), apply
  `apply_scale_32` (if `scale32`) or `apply_scale_16`, add `output_zp`,
  clip to the output type. `per_channel` uses one multiplier and shift per
  element of the last dimension. Allowed pairs in PRO-INT are any of
  `i8`, `i16`, `i32` to any of them; EXT-INT16 adds `i48` inputs. Unsigned
  `uint8` and `uint16` appear only in `RESCALE`.
- **apply_scale_32(value, multiplier, shift, double_round).** Requires
  `multiplier >= 0` and `2 <= shift <= 62`. Computes
  `(value * multiplier + (1 << (shift-1))) >> shift` arithmetically. With
  `double_round` and `shift > 31`, the rounding constant gets `+(1<<30)`
  for non-negative values and `-(1<<30)` for negative ones.
- **Rounding modes.** `SINGLE_ROUND` and `DOUBLE_ROUND` must be exact.
  `INEXACT_ROUND` has an error bound instead.
- **MUL.** For `i32` inputs a `shift` (0 to 63) gives a rounded right shift
  of the 64-bit product; otherwise the shift must be 0 and the result is the
  low 32 bits.
- **TABLE.** `i8`: 256-entry table indexed by value + 128. `i16`: 513
  entries, top 9 bits index, low 7 bits interpolate, result in `i32` (16.7
  format) for a following `RESCALE`.
- **INTDIV.** `i32` only, truncates toward zero, divisor must be non-zero.
- **CAST.** Float to integer rounds to nearest, ties to even, and saturates.
  Integer narrowing keeps the low bits (no saturation). NaN to integer is
  unpredictable.
- **Overflow and errors.** A graph is `tosa_valid`, `tosa_error` or
  `tosa_unpredictable`. Integer overflow is unpredictable; an
  unpredictable graph may give any result but must not write out of
  bounds. In PRO-INT every integer operation must match the reference
  exactly.
- **Levels.** Level `8K` caps `MAX_RANK` at 6, `MAX_KERNEL` and
  `MAX_STRIDE` at 8192, `MAX_SCALE` at 256 and `MAX_LOG2_SIZE` at 31.

**Epitome note:** TOSA's integer rules are bit-exact and written as
pseudocode. If Epitome ever has to check a lowering of a quantised model,
`apply_scale_32` is the function to match: it appears in LLVM IR as a
64-bit multiply, add and arithmetic shift right, not as an intrinsic.

### 6.4 What torch-mlir emits

**Observed** (section 9):

- `tosa.matmul` is used with rank-3 operands. A 2-D `aten.mm` is wrapped in
  `tosa.reshape` to `1xMxK` and back.
- `aten.convolution` (NCHW) becomes `tosa.transpose`/`tosa.reshape` to NHWC,
  `tosa.conv2d`, then `tosa.transpose` back. The weight is transposed to
  OHWI at compile time and written as an inline `dense<...>` constant.
- ReLU becomes `tosa.clamp` with `min_val = 0.0` and
  `max_val = 3.40282347E+38` (the largest `f32`).
- `torch._int_mm` (`i8 x i8 -> i32`) becomes `tosa.matmul` on `i8` with
  `i8` zero points of 0, giving `i32` directly.
- QDQ patterns are **not** turned into integer TOSA. The quantise op became
  float arithmetic that emulates round-half-to-even (`tosa.floor`,
  `tosa.ceil`, `tosa.equal`, `tosa.select`), then `tosa.clamp` and
  `tosa.cast` to `i8`. Dequantise became `tosa.cast`, `tosa.sub`,
  `tosa.cast`, `tosa.mul`. The matmul stayed `f32`. No `tosa.rescale`
  appeared.

**Epitome note:** a torch-mlir TOSA module for a model quantised with the
PT2E flow is still a float model with fake-quantisation around it. Getting
integer `tosa.matmul` plus `tosa.rescale` needs integer ops in the graph
(for example `_int_mm`) or a fusion pass such as `torch-fuse-quantized-ops`,
which `export_and_import` did not apply in our run.

## 7. Backend: StableHLO

StableHLO is an operation set for high-level ML operations, used as a
portability layer between frameworks (TensorFlow, JAX, PyTorch) and
compilers (XLA, IREE). Tensors are ranked; dynamic sizes are `?`.
Quantised tensors use `!quant.uniform` element types, per tensor or per
axis. Older versions of the spec are kept at tagged releases, and
compatibility is handled by the versioned `vhlo` dialect.

torch-mlir describes it as "a coarse-grained named-op approach" with
functional dynamic-shape support, between linalg and TOSA.

**Observed** ops in our output: `stablehlo.constant`,
`stablehlo.dot_general` (`contracting_dims = [1] x [0]`),
`stablehlo.convolution` (with `dim_numbers = [b, f, 0, 1]x[o, i, 0, 1]->[b, f, 0, 1]`,
so NCHW is kept), `stablehlo.broadcast_in_dim`, `stablehlo.add`,
`stablehlo.multiply`, `stablehlo.maximum`, `stablehlo.transpose`,
`stablehlo.reshape`, `stablehlo.convert`. One `arith.constant` was left in
the MLP output. The `mul.Scalar` by 1 from the importer's decomposition was
not folded away (it is in linalg).

Source: https://openxla.org/stablehlo/spec

**Not documented** (in the part of the spec read): the compatibility
window. The spec page links to a separate compatibility document.

## 8. From linalg-on-tensors to LLVM IR

torch-mlir's own test backend ("RefBackend") takes linalg-on-tensors,
bufferises it and lowers it to loops. The docs say it is "absolutely not
suitable for any production use case". Our script `lower.py` uses upstream
passes for the same steps. The dialects involved are described in
[chapter 02](02-core-dialects.md) (`tensor`, `memref`, `scf`, `cf`,
`arith`, `bufferization`) and [chapter 03](03-llvm-dialect.md) (`llvm`).

### 8.1 The pipeline

| Stage | Passes | Output file |
| --- | --- | --- |
| Bufferise | `one-shot-bufferize{bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map}`, `canonicalize` | `*.bufferized.mlir` |
| Loops | `convert-linalg-to-loops` | `*.loops.mlir` |
| LLVM dialect | `lower-affine`, `convert-scf-to-cf`, `expand-strided-metadata`, `finalize-memref-to-llvm`, `convert-arith-to-llvm`, `convert-math-to-llvm`, `convert-func-to-llvm`, `convert-cf-to-llvm`, `reconcile-unrealized-casts` | `*.llvm.mlir` |
| LLVM IR | `torch_mlir.dialects.llvm.translate_module_to_llvmir` (the work `mlir-translate --mlir-to-llvmir` does) | `*.ll` |

Before lowering, the script sets the unit attribute `llvm.emit_c_interface`
on every `func.func`, so a C-callable wrapper is generated (section 8.4).

**Observed:** without `lower-affine`, conv2d failed to translate with "LLVM
Translation failed for operation: builtin.unrealized_conversion_cast". The
loops for the padded convolution use `affine.apply` for `h + kh`, and
`affine.apply` is not converted to `llvm` by any of the other passes.

**Observed:** with function-boundary bufferisation and the default layout,
memref arguments get a fully dynamic layout
(`memref<2x3xf32, strided<[?, ?], offset: ?>>`). With
`function-boundary-type-conversion=identity-layout-map` they are plain
`memref<2x3xf32>`.

### 8.2 Bufferisation

One-Shot Bufferize turns ops on `tensor` values into ops on `memref`
buffers. It analyses a whole function, then rewrites. Destination-passing
ops (`outs`) may write into the buffer of their destination in place when
nothing else reads it. Function boundaries are bufferised only with
`bufferize-function-boundaries`. One-Shot Bufferize does not free buffers;
the ownership-based deallocation passes do that.

Source: https://mlir.llvm.org/docs/Bufferization/

**Observed:**

- `tensor.empty` became `memref.alloc() {alignment = 64 : i64}`.
- Constants became `memref.global "private" constant @__constant_8x4xf32`
  read with `memref.get_global`.
- `tensor.pad` became an `alloc`, a `linalg.map` that fills it with the
  pad value, a `memref.subview` of the interior and a `memref.copy` into it.
- Results are returned as newly allocated memrefs. We ran no deallocation
  pass, so the caller owns the result buffer.

### 8.3 Loops

`convert-linalg-to-loops` turns each linalg op into a nest of `scf.for`
loops with `memref.load` and `memref.store`. The matmul in
`matmul_bias.loops.mlir`:

```mlir
scf.for %arg3 = %c0 to %c2 step %c1 {
  scf.for %arg4 = %c0 to %c4 step %c1 {
    scf.for %arg5 = %c0 to %c3 step %c1 {
      %0 = memref.load %arg0[%arg3, %arg5] : memref<2x3xf32>
      %1 = memref.load %arg1[%arg5, %arg4] : memref<3x4xf32>
      %2 = memref.load %alloc[%arg3, %arg4] : memref<2x4xf32>
      %3 = arith.mulf %0, %1 : f32
      %4 = arith.addf %2, %3 : f32
      memref.store %4, %alloc[%arg3, %arg4] : memref<2x4xf32>
    }
  }
}
```

No tiling, vectorisation or fusion was applied. The bias add is a separate
loop nest over the same buffer.

### 8.4 The LLVM IR that comes out

A memref becomes a descriptor struct. For rank N:

```
{ ptr allocated, ptr aligned, i64 offset, [N x i64] sizes, [N x i64] strides }
```

The allocated pointer is only for freeing. Indexing uses the aligned
pointer plus `offset`. `index` becomes `i64` on our targets.

At a function boundary, by default, each memref argument is split into its
fields: two pointers, the offset, N sizes and N strides. A memref result is
returned as the descriptor struct by value. Several results are packed into
one struct.

With `llvm.emit_c_interface`, a wrapper `_mlir_ciface_<name>` is also
emitted. It takes a pointer to each argument's descriptor. A struct result
is written through an extra pointer that comes first.

Source: https://mlir.llvm.org/docs/TargetLLVMIR/

**Observed** in `matmul_bias.ll`:

```llvm
; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare ptr @malloc(i64)

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul_bias(
    ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6,        ; a: 2 ptrs, offset, 2 sizes, 2 strides
    ptr %7, ptr %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13,    ; b
    ptr %14, ptr %15, i64 %16, i64 %17, i64 %18) {                 ; bias (rank 1)
  ...
  %39 = call ptr @malloc(i64 96)          ; 8 floats + 64 bytes for alignment
  %40 = ptrtoint ptr %39 to i64
  %41 = add i64 %40, 63
  %42 = urem i64 %41, 64
  %43 = sub i64 %41, %42
  %44 = inttoptr i64 %43 to ptr          ; aligned pointer
  ...
79:
  %80 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %81 = mul nuw nsw i64 %69, 3
  %82 = add nuw nsw i64 %81, %77
  %83 = getelementptr inbounds nuw float, ptr %80, i64 %82
  %84 = load float, ptr %83, align 4
  ...
  %95 = fmul float %84, %89
  %96 = fadd float %94, %95
  ...
}

define void @_mlir_ciface_matmul_bias(ptr %0, ptr %1, ptr %2, ptr %3) {
  %5 = load { ptr, ptr, i64, [2 x i64], [2 x i64] }, ptr %1, align 8
  ...
  %27 = call { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul_bias(ptr %6, ...)
  store { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, ptr %0, align 8
  ret void
}

!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
```

Points to note:

- **No target triple or data layout.** Clang warns "overriding the module
  target triple" and uses its own.
- **Aligned allocation by hand.** `memref.alloc` with alignment 64 becomes
  `malloc(size + 64)` and a round-up with `ptrtoint`, `urem`, `inttoptr`.
- **Strides are folded** to constants (`3`, `4`) because the layouts are
  static; the descriptor's stride fields are passed but unused.
- **Loops** are header blocks with `phi`, `icmp slt` and `br`. Index
  arithmetic has `nuw nsw`; GEPs are `getelementptr inbounds nuw`.
- **ReLU** became `fcmp ugt` and `select`.
- **No `free`.** Nothing frees intermediate buffers or the result.
- **Runtime calls.** `malloc` always. conv2d also calls
  `memrefCopy(i64 elemsize, ptr, ptr)` for `memref.copy` on a strided
  subview, passing two `alloca`'d unranked descriptors `{ i64 rank, ptr }`
  between `llvm.stacksave.p0` and `llvm.stackrestore.p0`. `memrefCopy` is in
  MLIR's C runner utilities library, not libc.
- **Constants** are `private constant` globals with `align 64`.

**Observed: float constants use the `f0x` bit-pattern syntax.** The
weights print as, for example, `float f0xBDEED1D0`. A value that converts
exactly to a short decimal is printed in decimal instead
(`float -3.743410e-03` beside `float f0x3E89545E` in the same array). See
chapter `../llvm-ir/02-types-and-constants.md`, which documents
`f0x3c00` as an exact bit pattern. Apple clang 21 rejects these files:

```
conv2d.ll:4:57: error: expected value token
@__constant_2xf32 = private constant [2 x float] [float f0xBDEED1D0, ...
```

`matmul_bias.ll`, which has no float constants, compiles with Apple clang
21.

**Epitome note:** Epitome's reader must accept `f0x` float literals,
mixed with decimal ones in one constant. It must not assume a target
triple or data layout is present. It should expect `ptrtoint`/`inttoptr`
alignment arithmetic, and calls to `memrefCopy` and `malloc` as external
declarations.

**Observed: calling convention.** We linked `matmul_bias.ll` with a C
harness (`harness_matmul_bias.c`). Calling `@matmul_bias` directly from C,
declared as returning a C struct, gave garbage: in LLVM IR the 56-byte
struct is returned by value, which the AArch64 back end returns in
registers, while C returns such a struct through a hidden pointer. Calling
`_mlir_ciface_matmul_bias` worked and printed the same values as PyTorch:

```
sizes 2 4 strides 4 1
11 22 33 46
14 25 36 55
```

**Epitome note:** an aggregate return in LLVM IR is not the C ABI. The
`_mlir_ciface_` wrapper is the C-compatible entry point. This matters if
Epitome generates calls into MLIR-produced code.

## 9. Worked examples

All outputs below are **Observed**, made by `export.py`, `export_extra.py`,
`export_dtypes.py` and `lower.py` with the versions at the top of this
chapter. Constant blobs and long lines are trimmed; the files are complete.

### 9.1 MLP: Linear(4,8) -> ReLU -> Linear(8,2)

The model is `Linear(4, 8)`, `ReLU`, `Linear(8, 2)`, exported with
`fx.export_and_import(MLP().eval(), torch.randn(1, 4), output_type=..., func_name="mlp")`.

`torch` dialect (`mlp.torch.mlir`), first layer:

```mlir
func.func @mlp(%arg0: !torch.vtensor<[1,4],f32>) -> !torch.vtensor<[1,2],f32> {
  %int8 = torch.constant.int 8
  %2 = torch.vtensor.literal(dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>) : !torch.vtensor<[8],f32>
  %3 = torch.vtensor.literal(dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>) : !torch.vtensor<[8,4],f32>
  %int1 = torch.constant.int 1
  %int0 = torch.constant.int 0
  %4 = torch.prim.ListConstruct %int1, %int0 : (!torch.int, !torch.int) -> !torch.list<int>
  %5 = torch.aten.permute %3, %4 : !torch.vtensor<[8,4],f32>, !torch.list<int> -> !torch.vtensor<[4,8],f32>
  %6 = torch.aten.mm %arg0, %5 : !torch.vtensor<[1,4],f32>, !torch.vtensor<[4,8],f32> -> !torch.vtensor<[1,8],f32>
  %7 = torch.aten.mul.Scalar %6, %int1 : !torch.vtensor<[1,8],f32>, !torch.int -> !torch.vtensor<[1,8],f32>
  %8 = torch.prim.ListConstruct %int1, %int8 : (!torch.int, !torch.int) -> !torch.list<int>
  %9 = torch.aten.broadcast_to %2, %8 : !torch.vtensor<[8],f32>, !torch.list<int> -> !torch.vtensor<[1,8],f32>
  %10 = torch.aten.mul.Scalar %9, %int1 : !torch.vtensor<[1,8],f32>, !torch.int -> !torch.vtensor<[1,8],f32>
  %11 = torch.aten.add.Tensor %7, %10, %int1 : ... -> !torch.vtensor<[1,8],f32>
  %12 = torch.aten.relu %11 : !torch.vtensor<[1,8],f32> -> !torch.vtensor<[1,8],f32>
  ...
}
```

The weights are in a `{-# dialect_resources: { builtin: { NAME: "0x..." } } #-}`
section at the end of the file, keyed by the name used in
`dense_resource<NAME>`, as a hex string.

**Observed:** each blob starts with `04000000` before the data. The rest is
the tensor's bytes in little-endian order (`8x4xf32` is 4 + 128 bytes).
The leading word appears to be the blob's alignment (4).

**Not documented** (in the sources read for this chapter): the blob
encoding. Chapter 02 may cover it from the MLIR language reference.

linalg-on-tensors (`mlp.linalg.mlir`), first layer:

```mlir
#map = affine_map<(d0, d1) -> (d1)>
#map1 = affine_map<(d0, d1) -> (d0, d1)>
func.func @mlp(%arg0: tensor<1x4xf32>) -> tensor<1x2xf32> {
  %cst = arith.constant 0.000000e+00 : f32
  %cst_2 = arith.constant dense_resource<torch_tensor_8_torch.float32> : tensor<8xf32>
  %cst_3 = arith.constant dense_resource<torch_tensor_8_4_torch.float32> : tensor<8x4xf32>
  %0 = tensor.empty() : tensor<4x8xf32>
  %transposed = linalg.transpose ins(%cst_3 : tensor<8x4xf32>) outs(%0 : tensor<4x8xf32>) permutation = [1, 0]
  %1 = tensor.empty() : tensor<1x8xf32>
  %2 = linalg.fill ins(%cst : f32) outs(%1 : tensor<1x8xf32>) -> tensor<1x8xf32>
  %3 = linalg.matmul ins(%arg0, %transposed : tensor<1x4xf32>, tensor<4x8xf32>) outs(%2 : tensor<1x8xf32>) -> tensor<1x8xf32>
  // %4: linalg.generic broadcasting the bias to 1x8; %5: linalg.generic with arith.addf
  %6 = linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel"]}
         ins(%5 : tensor<1x8xf32>) outs(%1 : tensor<1x8xf32>) {
  ^bb0(%in: f32, %out: f32):
    %13 = arith.cmpf ugt, %in, %cst : f32
    %14 = arith.select %13, %in, %cst : f32
    linalg.yield %14 : f32
  } -> tensor<1x8xf32>
  ...
}
```

The multiplications by 1 are gone. The transpose of the weight is still a
run-time `linalg.transpose`; nothing folded it into the constant.

TOSA (`mlp.tosa.mlir`):

```mlir
func.func @mlp(%arg0: tensor<1x4xf32>) -> tensor<1x2xf32> {
  %0 = "tosa.const"() <{values = dense<0.000000e+00> : tensor<1xf32>}> : () -> tensor<1xf32>
  %1 = tosa.const_shape {values = dense<[1, 1, 4]> : tensor<3xindex>} : () -> !tosa.shape<3>
  %2 = tosa.const_shape {values = dense<[1, 8]> : tensor<2xindex>} : () -> !tosa.shape<2>
  %5 = "tosa.const"() <{values = dense<[[[-3.743410e-03, ...]]]> : tensor<1x4x8xf32>}> : () -> tensor<1x4x8xf32>
  %6 = "tosa.const"() <{values = dense_resource<torch_tensor_8_torch.float32> : tensor<1x8xf32>}> : () -> tensor<1x8xf32>
  %9 = tosa.reshape %arg0, %1 : (tensor<1x4xf32>, !tosa.shape<3>) -> tensor<1x1x4xf32>
  %10 = tosa.matmul %9, %5, %0, %0 : (tensor<1x1x4xf32>, tensor<1x4x8xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x1x8xf32>
  %11 = tosa.reshape %10, %2 : (tensor<1x1x8xf32>, !tosa.shape<2>) -> tensor<1x8xf32>
  %12 = tosa.add %11, %6 : (tensor<1x8xf32>, tensor<1x8xf32>) -> tensor<1x8xf32>
  %13 = tosa.clamp %12 {max_val = 3.40282347E+38 : f32, min_val = 0.000000e+00 : f32} : (tensor<1x8xf32>) -> tensor<1x8xf32>
  ...
}
```

Here the transpose was folded: the weight is an inline `1x4x8` constant,
already transposed. The bias kept its resource but was given a new shape
(`tensor<1x8xf32>` over the `8xf32` blob).

StableHLO (`mlp.stablehlo.mlir`) uses `stablehlo.transpose`,
`stablehlo.dot_general`, `stablehlo.broadcast_in_dim`, `stablehlo.multiply`
(by the leftover 1), `stablehlo.add` and `stablehlo.maximum` for ReLU.

The MLP lowers to `mlp.llvm.mlir` (626 lines) and `mlp.ll` (534 lines).

### 9.2 Matmul plus bias

The model is `torch.matmul(a, b) + bias` with `a: 2x3`, `b: 3x4`,
`bias: 4`.

```mlir
// torch
%0 = torch.aten.mm %arg0, %arg1 : !torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32> -> !torch.vtensor<[2,4],f32>
%int1 = torch.constant.int 1
%1 = torch.aten.add.Tensor %0, %arg2, %int1 : !torch.vtensor<[2,4],f32>, !torch.vtensor<[4],f32>, !torch.int -> !torch.vtensor<[2,4],f32>

// linalg-on-tensors
%0 = tensor.empty() : tensor<2x4xf32>
%1 = linalg.fill ins(%cst : f32) outs(%0 : tensor<2x4xf32>) -> tensor<2x4xf32>
%2 = linalg.matmul ins(%arg0, %arg1 : tensor<2x3xf32>, tensor<3x4xf32>) outs(%1 : tensor<2x4xf32>) -> tensor<2x4xf32>
%3 = linalg.generic {indexing_maps = [#map, #map1, #map], iterator_types = ["parallel", "parallel"]}
       ins(%2, %arg2 : tensor<2x4xf32>, tensor<4xf32>) outs(%0 : tensor<2x4xf32>) {
^bb0(%in: f32, %in_0: f32, %out: f32):
  %4 = arith.addf %in, %in_0 : f32
  linalg.yield %4 : f32
} -> tensor<2x4xf32>

// TOSA
%5 = tosa.reshape %arg0, %1 : (tensor<2x3xf32>, !tosa.shape<3>) -> tensor<1x2x3xf32>
%6 = tosa.reshape %arg1, %2 : (tensor<3x4xf32>, !tosa.shape<3>) -> tensor<1x3x4xf32>
%7 = tosa.matmul %5, %6, %0, %0 : (tensor<1x2x3xf32>, tensor<1x3x4xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x2x4xf32>
%8 = tosa.reshape %7, %3 : (tensor<1x2x4xf32>, !tosa.shape<2>) -> tensor<2x4xf32>
%9 = tosa.reshape %arg2, %4 : (tensor<4xf32>, !tosa.shape<2>) -> tensor<1x4xf32>
%10 = tosa.add %8, %9 : (tensor<2x4xf32>, tensor<1x4xf32>) -> tensor<2x4xf32>

// StableHLO
%0 = stablehlo.dot_general %arg0, %arg1, contracting_dims = [1] x [0] : (tensor<2x3xf32>, tensor<3x4xf32>) -> tensor<2x4xf32>
%1 = stablehlo.broadcast_in_dim %arg2, dims = [1] : (tensor<4xf32>) -> tensor<2x4xf32>
%2 = stablehlo.add %0, %1 : tensor<2x4xf32>
```

TOSA broadcasting needs equal ranks, so the bias is reshaped to `1x4`
first; `tosa.add` then broadcasts the size-1 dimension.

After bufferisation the function is
`func.func @matmul_bias(%arg0: memref<2x3xf32>, %arg1: memref<3x4xf32>, %arg2: memref<4xf32>) -> memref<2x4xf32>`.
The loops are in section 8.3 and the LLVM IR in section 8.4. This example
was compiled with clang and run (section 8.4).

### 9.3 Conv2d

The model is `Conv2d(1, 2, kernel_size=3, padding=1)` on a `1x1x5x5` input.

`torch` dialect:

```mlir
%6 = torch.aten.convolution %arg0, %0, %1, %2, %3, %4, %false, %5, %int1
     : !torch.vtensor<[1,1,5,5],f32>, !torch.vtensor<[2,1,3,3],f32>, !torch.vtensor<[2],f32>,
       !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.bool, !torch.list<int>, !torch.int
     -> !torch.vtensor<[1,2,5,5],f32>
```

The operands are input, weight, bias, stride, padding, dilation,
`transposed`, output padding and groups, as in ATen's `convolution`.

linalg-on-tensors:

```mlir
%padded = tensor.pad %arg0 low[0, 0, 1, 1] high[0, 0, 1, 1] {
^bb0(%arg1: index, %arg2: index, %arg3: index, %arg4: index):
  tensor.yield %cst : f32
} : tensor<1x1x5x5xf32> to tensor<1x1x7x7xf32>
%0 = tensor.empty() : tensor<1x2x5x5xf32>
%broadcasted = linalg.broadcast ins(%cst_1 : tensor<2xf32>) outs(%0 : tensor<1x2x5x5xf32>) dimensions = [0, 2, 3]
%1 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>}
       ins(%padded, %cst_0 : tensor<1x1x7x7xf32>, tensor<2x1x3x3xf32>)
       outs(%broadcasted : tensor<1x2x5x5xf32>) -> tensor<1x2x5x5xf32>
```

The bias is broadcast into the accumulator before the convolution, so no
separate add is needed.

TOSA:

```mlir
%4 = tosa.reshape %arg0, %2 : (tensor<1x1x5x5xf32>, !tosa.shape<4>) -> tensor<1x5x5x1xf32>
%5 = tosa.conv2d %4, %3, %0, %1, %1 {acc_type = f32, dilation = array<i64: 1, 1>,
       pad = array<i64: 1, 1, 1, 1>, stride = array<i64: 1, 1>}
     : (tensor<1x5x5x1xf32>, tensor<2x3x3x1xf32>, tensor<2xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x5x5x2xf32>
%6 = tosa.transpose %5 {perms = array<i32: 0, 3, 1, 2>} : (tensor<1x5x5x2xf32>) -> tensor<1x2x5x5xf32>
```

With one input channel, NCHW to NHWC is a pure reshape, so torch-mlir used
`tosa.reshape` instead of `tosa.transpose` on the way in. Padding is an
attribute of `tosa.conv2d`, not a separate op.

The loops for `linalg.conv_2d_nchw_fchw` are a seven-deep `scf.for` nest
(`n, f, oh, ow, c, kh, kw`) that indexes the input with
`affine.apply affine_map<(d0, d1) -> (d0 + d1)>`. In LLVM IR
(`conv2d.ll`, 353 lines) the padding copy is a call to `memrefCopy`
(section 8.4).

### 9.4 Integer and quantised matmul

`torch._int_mm` (`int8 x int8 -> int32`, 32x8 times 8x8):

```mlir
// torch
%0 = torch.aten.mm %arg0, %arg1 : !torch.vtensor<[32,8],si8>, !torch.vtensor<[8,8],si8> -> !torch.vtensor<[32,8],si32>

// TOSA
%0 = "tosa.const"() <{values = dense<0> : tensor<1xi8>}> : () -> tensor<1xi8>
%6 = tosa.matmul %4, %5, %0, %0 : (tensor<1x32x8xi8>, tensor<1x8x8xi8>, tensor<1xi8>, tensor<1xi8>) -> tensor<1x32x8xi32>

// linalg-on-tensors
%1 = linalg.fill ins(%c0_i32 : i32) outs(%0 : tensor<32x8xi32>) -> tensor<32x8xi32>
%2 = linalg.matmul ins(%arg0, %arg1 : tensor<32x8xi8>, tensor<8x8xi8>) outs(%1 : tensor<32x8xi32>) -> tensor<32x8xi32>
```

Note that this `torch.aten.mm` has `si8` operands and an `si32` result:
the importer mapped `_int_mm` onto `aten.mm` with a wider result type.

A QDQ matmul quantises both inputs with
`torch.ops.quantized_decomposed.quantize_per_tensor(a, 0.05, 3, -128, 127, torch.int8)`
(and `0.1, 0` for `b`), dequantises them, and multiplies in `f32`. `torch` dialect:

```mlir
%0 = torch.quantized_decomposed.quantize_per_tensor %arg0, %float5.000000e-02, %int3, %int-128, %int127, %int1
     : !torch.vtensor<[2,3],f32>, !torch.float, !torch.int, !torch.int, !torch.int, !torch.int -> !torch.vtensor<[2,3],si8>
%2 = torch.quantized_decomposed.dequantize_per_tensor %0, %float5.000000e-02, %int3, %int-128, %int127, %int1, %none
     : !torch.vtensor<[2,3],si8>, ... -> !torch.vtensor<[2,3],f32>
%4 = torch.aten.mm %2, %3 : !torch.vtensor<[2,3],f32>, !torch.vtensor<[3,4],f32> -> !torch.vtensor<[2,4],f32>
```

The dtype argument is an integer code (`%int1` for `torch.int8`). In TOSA
(`extra_qmatmul.tosa.mlir`) this became float arithmetic with
`tosa.floor`, `tosa.ceil`, `tosa.select`, `tosa.clamp` and `tosa.cast`,
around an `f32` `tosa.matmul` (section 6.4). In linalg it used
`math.roundeven`, `arith.fptosi`, `arith.sitofp` and an `f32`
`linalg.matmul`.

**Observed:** the older `torch.quantize_per_tensor`, which makes a
`torch.qint8` tensor, failed in `export_and_import` with
`KeyError: torch.qint8` (not kept in the example files).

### 9.5 Dynamic batch

The MLP was exported with an example input of shape `2x4`,
`dynamic_shapes={"x": {0: Dim("batch")}}` and
`import_symbolic_shape_expressions=True`.

```mlir
func.func @mlp_dyn(%arg0: !torch.vtensor<[?,4],f32>) -> !torch.vtensor<[?,2],f32> {
  %4 = torch.symbolic_int "s77" {min_val = 0, max_val = 9223372036854775807} : !torch.int
  torch.bind_symbolic_shape %arg0, [%4], affine_map<()[s0] -> (s0, 4)> : !torch.vtensor<[?,4],f32>
  %5 = torch.aten.size.int %arg0, %int0 : !torch.vtensor<[?,4],f32>, !torch.int -> !torch.int
  ...
  %8 = torch.aten.mm %arg0, %7 : !torch.vtensor<[?,4],f32>, !torch.vtensor<[4,8],f32> -> !torch.vtensor<[?,8],f32>
  torch.bind_symbolic_shape %8, [%4], affine_map<()[s0] -> (s0, 8)> : !torch.vtensor<[?,8],f32>
```

`torch.symbolic_int` declares the export symbol (here `s77`) with its
range. `torch.bind_symbolic_shape` ties each tensor's shape to the symbols
with an affine map. In linalg-on-tensors the symbol is gone; the size is
read with `tensor.dim`, allocations become `tensor.empty(%dim)`, and
run-time checks appear:

```mlir
%dim = tensor.dim %arg0, %c0 : tensor<?x4xf32>
%2 = tensor.empty(%dim) : tensor<?x8xf32>
%5 = arith.cmpi sge, %0, %c0_i64 : i64
cf.assert %5, "negative values not allowed in new dimensions"
cf.assert %true, "mismatched size for broadcast"
```

**Epitome note:** we did not lower the dynamic example to LLVM IR. The
`cf.assert` ops mean a dynamic model carries run-time failure paths that a
static one does not; chapter 02 describes how `cf.assert` is lowered.

### 9.6 A mutated buffer

The module registers a buffer `count` (`torch.zeros(1)`), and `forward`
does `self.count.add_(1)` then returns `x * self.count`.

`torch.export` keeps the in-place op: `torch.ops.aten.add_.Tensor(b_count, 1)`,
with `b_count: BUFFER`. The importer (default settings) gives:

```mlir
func.func @counter(%arg0: !torch.vtensor<[3],f32>) -> (!torch.vtensor<[1],f32>, !torch.vtensor<[3],f32>) {
  %0 = torch.vtensor.literal(dense<0.000000e+00> : tensor<1xf32>) : !torch.vtensor<[1],f32>
  %int1 = torch.constant.int 1
  %int1_0 = torch.constant.int 1
  %1 = torch.aten.add.Scalar %0, %int1, %int1_0 : ... -> !torch.vtensor<[1],f32>
  %2 = torch.aten.mul.Tensor %arg0, %1 : ... -> !torch.vtensor<[3],f32>
  return %1, %2 : !torch.vtensor<[1],f32>, !torch.vtensor<[3],f32>
}
```

The buffer's initial value is baked in as a constant, and its new value is
returned as an extra first result. Nothing stores it back, so a second call
gives the same answer. With `experimental_support_mutation=True` the import
failed: `NotImplementedError: Store of a mutation to InputInfo(...)`.

**Not documented:** how torch-mlir means mutable state to be represented.
The `ml_program` dialect has the pieces (`ml_program.global` with
`mutable`, `ml_program.global_load`, `ml_program.global_store`), and
torch-mlir has a `refback-mlprogram-bufferize` pass, but we did not
produce such output.

Source: https://mlir.llvm.org/docs/Dialects/MLProgramOps/

## 10. Example files

All in [`examples/pytorch/`](examples/pytorch/). Local paths in the
stack-trace comments of the `.txt` files were replaced.

| Files | Contents |
| --- | --- |
| `export.py`, `export_extra.py`, `export_dtypes.py`, `lower.py` | The scripts. Each takes an output directory (`lower.py`: input file and output prefix) |
| `harness_matmul_bias.c` | C program that calls `_mlir_ciface_matmul_bias` |
| `NAME.exported.txt` | `print(torch.export.export(...))` |
| `NAME.{raw,torch,linalg,tosa,stablehlo}.mlir` | The five output types of `export_and_import` |
| `NAME.{bufferized,loops,llvm}.mlir`, `NAME.ll` | The stages of `lower.py` |
| `extra_mlp.core_aten.txt`, `extra_mlp_dynamic.*` | Core ATen; dynamic batch |
| `extra_counter.*` | Buffer mutation (`mut1` holds the error) |
| `extra_qmatmul.*`, `extra_int8matmul.*` | QDQ matmul; `_int_mm` |
| `dtypes.{raw,linalg}.mlir` | Dtype spellings |

`NAME` is `mlp`, `matmul_bias` or `conv2d`. To reproduce, from a directory
outside the package: `python -I export.py OUT`, then
`python -I lower.py OUT/matmul_bias.linalg.mlir OUT/matmul_bias`, then
`clang -c -x ir OUT/matmul_bias.ll` and link with the harness. Weights come
from `torch.manual_seed(0)`.

## Still to read

| Gap | Document |
| --- | --- |
| Full `torch.export` API: `ExportGraphSignature`, `InputKind`, `OutputKind`, `strict` default | https://docs.pytorch.org/docs/2.14/user_guide/torch_compiler/export/api_reference.html |
| Export programming model (what is traced, what specialises) | https://docs.pytorch.org/docs/2.14/user_guide/torch_compiler/export/programming_model.html |
| Dynamic shapes, 0/1 specialisation | https://docs.pytorch.org/docs/2.14/user_guide/torch_compiler/torch.compiler_dynamic_shapes.html |
| Control-flow operators (`cond`, `while_loop`, `map`) and how torch-mlir imports them | https://docs.pytorch.org/docs/2.14/higher_order_ops/index.html |
| PT2E quantisation flow, which produces the QDQ ops | pytorch.org / torchao quantisation docs |
| Shape and dtype refinement in torch-mlir | https://github.com/llvm/torch-mlir/blob/main/docs/abstract_interp_lib.md |
| ONNX importer | https://github.com/llvm/torch-mlir/blob/main/docs/importers/onnx_importer.md |
| Rest of the Linalg page: `cast` semantics on mixed-type named ops, `linalg.reduce`, `linalg.elementwise` | https://mlir.llvm.org/docs/Dialects/Linalg/ |
| Rest of the TOSA spec: per-operator pseudocode, `tosa.target_env`, profile checking in the dialect | https://www.mlplatform.org/tosa/tosa_spec_1_0_2.html, https://mlir.llvm.org/docs/Dialects/TOSA/ |
| StableHLO compatibility and dynamism | https://openxla.org/stablehlo/compatibility, https://openxla.org/stablehlo/dynamism |
| Ownership-based buffer deallocation | https://mlir.llvm.org/docs/OwnershipBasedBufferDeallocation/ |
| `dense_resource` blob encoding | https://mlir.llvm.org/docs/LangRef/ (builtin dialect, resources) |
| iree-turbine internals (which torch-mlir importer it uses) | https://iree.dev/guides/ml-frameworks/pytorch/, iree-turbine README |
