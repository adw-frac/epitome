# Hardware Dialects: FIRRTL, CIRCT and Arcilator

Source: CIRCT documentation at circt.llvm.org/docs, the FIRRTL
specification (github.com/chipsalliance/firrtl-spec, `spec.md` on its main
branch, after release 6.0.0), and chisel-lang.org/docs. All read on
2026-10-20. Each section names the pages it uses. The CIRCT site tracks
CIRCT's development branch, not a numbered release.

This chapter covers the path from a hardware design to native code: Chisel,
FIRRTL, the `firrtl` dialect, the core hardware dialects (`hw`, `comb`,
`seq`), the output dialects (`sv`, `emit`), and the `arc` dialect that
arcilator uses to turn a whole design into one `eval` function. That
function is the very large basic block Epitome is built for.

It is written only from published documentation and from the output of the
released tools on our own inputs. No CIRCT source, TableGen file or `.mlir`
test file was read. The release tarball ships C++ headers and `.td` files
under `include/`. They were not extracted.

---

## 1. The flows

Source: https://circt.llvm.org/docs/Dialects/FIRRTL/RationaleFIRRTL/,
https://circt.llvm.org/docs/Dialects/HW/RationaleHW/,
https://circt.llvm.org/docs/Dialects/Arc/,
https://circt.llvm.org/docs/Tools/circt-verilog/,
https://www.chisel-lang.org/docs/appendix/versioning. Read 2026-10-20.

### 1.1 Overview

```text
 Chisel (Scala) ── ChiselStage.emitCHIRRTL ──► .fir text (CHIRRTL / FIRRTL)
                                                  │ firtool: FIR parser
                                                  ▼
                                          firrtl dialect
                      infer widths, infer resets, expand whens, lower types, ...
                                                  │ LowerToHW
                                                  ▼
                     hw + comb + seq  (+ sv, emit, om, verif for side parts)
                    │                                        │
   firtool: lower-seq-to-sv, ExportVerilog         arcilator │
                    ▼                                        ▼
             sv dialect ─► SystemVerilog text        arc dialect (arcs, states)
                                                     │  state lowering, allocation
                                                     ▼
                                              llvm dialect ─► LLVM IR (.ll)
                                                     │  llc / JIT / Epitome
                                                     ▼
                                                native code: <Model>_eval

 SystemVerilog ── circt-verilog (slang) ──► moore ─► llhd + hw/comb/seq ─► hw/comb/seq
```

| Step | Tool | Input | Output |
| --- | --- | --- | --- |
| Elaborate Chisel | Chisel library, run as a Scala program | Scala | `.fir` text (`ChiselStage.emitCHIRRTL`), or SystemVerilog (`ChiselStage.emitSystemVerilog`, which calls firtool) |
| Parse FIRRTL | `firtool --parse-only` | `.fir` | `firrtl` dialect, as written |
| FIRRTL passes | `firtool --ir-fir` | `.fir` | `firrtl` dialect, ground types only, no `when` |
| LowerToHW | `firtool --ir-hw` | `.fir` | `hw`, `comb`, `seq`, `sv` declarations, `emit`, `om` |
| Lower to SV | `firtool --ir-sv` | `.fir` | `sv` dialect: `sv.reg`, `sv.always`, `sv.initial` |
| Print | `firtool --verilog` (default) or `--split-verilog -o dir` | `.fir` | SystemVerilog text |
| Simulate | `arcilator` | `hw`/`comb`/`seq` `.mlir` | `arc` (`--until-before=llvm-lowering`), `llvm` dialect (`--emit-mlir`), LLVM IR (`--emit-llvm`), or a JIT run (`--run`) |
| Verilog front end | `circt-verilog` | `.sv` | `moore` (`--ir-moore`), `llhd` (`--ir-llhd`), `hw`/`comb`/`seq` (`--ir-hw`, the default) |

Chisel releases are tied to a firtool version. The versioning page lists
Chisel 7.16.0 with firtool 1.160.0. Chisel fetches that firtool itself.
`CHISEL_FIRTOOL_PATH` names a directory holding a different `firtool`. The
documentation also suggests emitting `.fir` and running an installed
firtool separately, which is what section 10 does.

### 1.2 The dialects

| Dialect | Role | Sections |
| --- | --- | --- |
| `firrtl` | FIRRTL as written by Chisel, with its types, `when`, last-connect semantics, bundles and memories | 2, 3 |
| `chirrtl` | Chisel's memory ports (`smem`, `cmem`, `mport`) before they become `firrtl.mem` | 3 |
| `hw` | Modules, instances, ports, constants, arrays, structs, `inout` | 4 |
| `comb` | Combinational operations on signless integers | 5 |
| `seq` | Registers, clocks, memories | 6 |
| `sv` | SystemVerilog statements and declarations, for printing | 7 |
| `emit` | Output files and file lists | 7 |
| `om` | Object model: metadata classes (firtool emits an empty `om.class` per module) | 7 |
| `llhd`, `moore` | Event-driven simulation, and SystemVerilog after parsing | 8 |
| `verif`, `ltl`, `sim` | Assertions, temporal properties, simulator hooks such as `printf` and plusargs | 8 |
| `arc` | Simulation: state transfer functions, state storage, models | 9 |

---

## 2. FIRRTL, the language

Source: https://github.com/chipsalliance/firrtl-spec, `spec.md` and
`revision-history.yaml` (main branch). Read 2026-10-20.

### 2.1 Versions and structure

A `.fir` file starts with a version line, then one `circuit`. The latest
release of the spec is 6.0.0 (2026-05-12). The main branch has changes
since then, unreleased.

**Observed:** Chisel 7.16.0 writes `FIRRTL version 7.0.0`, a version
the published spec has not released. firtool 1.162.0 reads it.

```firrtl
FIRRTL version 7.0.0
circuit Counter :%[[ ...annotations as JSON... ]]
  layer Verification, bind, "verification" :
    ...
  public module Counter : @[Counter.scala 10:7]
    input clock : Clock
    input reset : UInt<1>
    output io : { flip en : UInt<1>, count : UInt<8>}

    regreset reg : UInt<8>, clock, reset, UInt<8>(0h0)
    when io.en :
      node _reg_T = add(reg, UInt<1>(0h1))
      node _reg_T_1 = tail(_reg_T, 1)
      connect reg, _reg_T_1
    connect io.count, reg
```

- Indentation marks blocks, as in Python. `@[file line:col]` is a source
  locator. `%[[ ... ]]` after the circuit name holds inline annotations as
  JSON.
- A **public** module is a root of the design and keeps its interface.
  A private module may be changed or removed.
- **Observed:** a public module's ports must have known widths. firtool
  rejects `output o : UInt` with `public module port must have known
  width`.
- `extmodule` declares a module defined elsewhere (Verilog). `intmodule`
  declares a compiler intrinsic. `layer` and `layerblock` hold optional
  verification logic that is bound in or inlined.

### 2.2 Types

| Type | Meaning |
| --- | --- |
| `UInt<n>`, `SInt<n>` | Unsigned and signed integers of `n` bits. `n` may be 0: a zero-width value is zero. |
| `UInt`, `SInt` | The same with the width left to inference. |
| `Clock` | A clock. Every register names one. |
| `Reset` | An abstract reset, inferred to `UInt<1>` (synchronous) or `AsyncReset`. |
| `AsyncReset` | An asynchronous reset. A register reset by it takes the reset value at once, and the value must be constant. |
| `Analog<n>` | A wire with many drivers, like a Verilog `inout`. It is joined with `attach`, never `connect`. It cannot be the type of a node, register or memory. |
| `T[n]` | A vector of `n` elements. `n` may be 0. |
| `{ a : T, flip b : U }` | A bundle. `flip` reverses the direction of a field. |
| `{\|a : T, b\|}` | An enumeration: a tagged union. A variant with no type is `UInt<0>`. |
| `Probe<T>`, `RWProbe<T>` | References to a signal inside a module, for verification. A probe port may make no hardware. `RWProbe` can also be forced. |
| `const T` | A value fixed at elaboration. |
| `Integer`, `String`, `Bool`, `Double`, `Path`, `List<T>`, `AnyRef`, `Inst<C>` | Property types: metadata, not hardware. |

A **passive** type has no flipped fields. Nodes, registers and memory data
must be passive. A **ground** type is an integer, clock, reset or analog
type.

### 2.3 Width and reset inference

- An integer type without a width is given the smallest width that holds
  every value connected to it. It is an error if no such width can be
  found. A `mux` has the larger of its two input widths. Each primitive
  operation has a result width (section 2.6).
- `Reset` becomes synchronous or asynchronous from what drives it.
  `asReset` turns a `UInt<1>` into `Reset` without affecting inference.

**Observed:** in the GCD example (section 10.3) Chisel writes `reg x :
UInt, clock`. firtool infers `UInt<16>` from the 16-bit values connected
to it.

### 2.4 Connections and conditionals

- `connect sink, source` drives a sink. The last connect wins. A later
  connect to one field of an aggregate overrides only that field.
- `invalidate x` gives `x` an indeterminate value.
- `when c : ... else : ...` makes the connects inside conditional. The
  last-connect rule then applies per path, so a `when` becomes a `mux` on
  the condition. A register connected only under `when` keeps its value
  otherwise.
- `node n = e` names an expression. It cannot be connected to.
- `wire w : T` is a value that must be connected before use.

### 2.5 Registers and memories

- `reg r : T, clk` and `regreset r : T, clk, rst, init`. Reads return the
  current value. A write is seen after the next rising edge of `clk`. A
  register starts with an indeterminate value.
- `mem` declares a memory with a data type, a depth, read, write and
  read-write ports, a read latency (0 for combinational), a write latency
  (at least 1), and a read-under-write policy: `old`, `new` or `undefined`.
- A read port is a bundle `{addr: UInt<N>, en: UInt<1>, clk: Clock, flip
  data: T}`, where the depth is at most `2^N`. A write port adds `data`
  and a `mask` whose shape mirrors `T` with `UInt<1>` leaves. A read-write
  port has `rdata`, `wmode`, `wdata` and `wmask`.
- Two writes to one address in one cycle leave the stored value undefined.
- Chisel writes memories in the **CHIRRTL** form: `smem`/`cmem` and `read
  mport`/`write mport` statements inside `when` blocks. firtool turns these
  into `mem` (section 10.5).

### 2.6 Primitive operations

`w(e)` is the width of argument `e`. Arguments are ground types,
parameters are integer literals. If every argument is `const`, so is the
result.

| Operation | Arguments | Result type | Result width | Meaning |
| --- | --- | --- | --- | --- |
| `add` | (e1, e2) | same as arguments | max(w(e1), w(e2)) + 1 | Sum, no overflow |
| `sub` | (e1, e2) | same | max(w(e1), w(e2)) + 1 | e1 - e2, no overflow |
| `mul` | (e1, e2) | same | w(e1) + w(e2) | Product, no overflow |
| `div` | (num, den) | same | UInt: w(num); SInt: w(num) + 1 | Truncates towards zero. Undefined if den is 0. |
| `rem` | (num, den) | same | min(w(num), w(den)) | Remainder with the sign of num |
| `lt`, `leq`, `gt`, `geq`, `eq`, `neq` | (e1, e2) | UInt | 1 | Comparison, signed for SInt |
| `pad` | (e), n | same | max(w(e), n) | Zero- or sign-extend to n |
| `asUInt`, `asSInt` | (e) | UInt / SInt | w(e); 1 for Clock and resets | Reinterpret the bits |
| `asClock`, `asAsyncReset` | (e) | Clock / AsyncReset | n/a | Reinterpret a 1-bit value |
| `asReset` | (UInt<1>) | Reset | n/a | Mark a reset as abstract |
| `shl` | (e), n | same | w(e) + n | Append n zero bits |
| `shr` | (e), n | same | UInt: max(w(e) - n, 0); SInt: max(w(e) - n, 1) | Drop the n low bits |
| `dshl` | (e1, e2: UInt) | type of e1 | w(e1) + 2^w(e2) - 1 | Shift left by e2, no loss |
| `dshr` | (e1, e2: UInt) | type of e1 | w(e1) | Shift right by e2, logical for UInt, arithmetic for SInt |
| `cvt` | (e) | SInt | UInt: w(e) + 1; SInt: w(e) | Same value as signed |
| `neg` | (e) | SInt | w(e) + 1 | Negated value |
| `not` | (e) | UInt | w(e) | Bitwise complement |
| `and`, `or`, `xor` | (e1, e2) | UInt | max(w(e1), w(e2)) | Bitwise. The narrower argument is extended first (zero for UInt, sign for SInt). |
| `andr`, `orr`, `xorr` | (e) | UInt | 1 | Reduction. On a zero-width value `andr` is 1, the others 0. |
| `cat` | (e*) | UInt | sum of widths | First argument at the most significant end. No arguments gives a zero-width zero. Variadic since 6.0.0. |
| `bits` | (e), hi, lo | UInt | hi - lo + 1 | Bits lo to hi inclusive |
| `head` | (e), n | UInt | n | The n most significant bits |
| `tail` | (e), n | UInt | w(e) - n | Drop the n most significant bits |
| `mux` | (sel, a, b) | type of a and b | max of the two | `a` if sel is 1. sel is `UInt<1>` or `UInt<0>`. |

**Observed:** firtool's parser gives these widths for every row of the
table (example `firrtl/primops/PrimOps.fir`, read back with
`--parse-only`). `mux(c, a, b)` with `UInt<8>` and `UInt<4>` inputs is
accepted, and the narrower input is padded.

Chisel's `+` and `-` keep the width of the wider argument. It writes
`add` then `tail(_, 1)`. `+&` keeps the carry.

### 2.7 Two-state values

FIRRTL is defined for two-state logic. A compiler need only respect the
two-state behaviour. An indeterminate value (uninitialised register,
`invalidate`, out-of-range index, division by zero) may be given any value,
provided:

- every reader of one instance of the expression sees the same value;
- a register holding one keeps it until written;
- the value depends only on the expression's inputs;
- register initialisation is done the same way for all registers.

**Epitome note:** this is exactly the freedom of LLVM's `freeze`: pick a
value, use it consistently. It is not `poison`. A simulator compiled by
Epitome must not let an indeterminate value become undefined behaviour.

---

## 3. The `firrtl` dialect

Source: https://circt.llvm.org/docs/Dialects/FIRRTL/,
https://circt.llvm.org/docs/Dialects/FIRRTL/RationaleFIRRTL/,
https://circt.llvm.org/docs/Dialects/CHIRRTL/,
https://circt.llvm.org/docs/Passes/. Read 2026-10-20.

The dialect follows the spec "almost exactly", and copies the behaviour of
the old Scala FIRRTL Compiler (SFC) where the spec leaves things
undefined. Annotations from Chisel become attributes.

### 3.1 Types

FIRRTL types are written `!firrtl.uint<8>`, `!firrtl.sint<4>`,
`!firrtl.uint` (no width yet), `!firrtl.clock`, `!firrtl.reset`,
`!firrtl.asyncreset`, `!firrtl.analog<1>`,
`!firrtl.vector<uint<8>, 4>`, `!firrtl.bundle<en flip: uint<1>, count:
uint<8>>`, `!firrtl.probe<...>`. **Observed:** constants have
`!firrtl.const.uint<8>` before the passes run, and plain types after.

### 3.2 Operations

The page lists about 190 operations. The ones Chisel output uses most:

| Operation | Meaning |
| --- | --- |
| `firrtl.circuit "Top" { ... }` | The design. The name is the top module. |
| `firrtl.module @M(in %clock: !firrtl.clock, out %io: ...)` | A module. Ports are block arguments with a direction. Attribute `convention` is `scalarized` or `internal`. |
| `firrtl.extmodule`, `firrtl.intmodule`, `firrtl.memmodule` | External, intrinsic and memory modules |
| `firrtl.layer`, `firrtl.layerblock` | Optional verification layers |
| `%w = firrtl.wire : T` | A wire |
| `%r = firrtl.reg %clock : !firrtl.clock, T` | A register without reset |
| `%r = firrtl.regreset %clock, %reset, %init : ...` | A register with reset |
| `%n = firrtl.node %v : T` | A named value |
| `firrtl.connect %dst, %src` | A connect, which may extend or truncate |
| `firrtl.matchingconnect %dst, %src : T` | A connect whose two types match exactly. The passes turn connects into this. |
| `firrtl.when %c : !firrtl.uint<1> { ... } else { ... }` | Conditional connects |
| `%a, %b = firrtl.instance name @M(in a: ..., out b: ...)` | An instance. Results are its ports. |
| `%p0, %p1 = firrtl.mem Undefined {depth = 16, readLatency = 1, writeLatency = 1, portNames = [...]} : ...` | A memory. Each result is a port bundle. |
| `firrtl.subfield %b[f]`, `firrtl.subindex %v[3]`, `firrtl.subaccess %v[%i]` | Parts of aggregates |
| `firrtl.constant 5 : !firrtl.uint<8>` | A constant |
| `firrtl.add`, `firrtl.bits %x 7 to 0`, `firrtl.mux(%c, %a, %b)`, ... | One operation per primitive operation |
| `firrtl.printf`, `firrtl.stop`, `firrtl.assert`, `firrtl.cover` | Commands |
| `firrtl.ref.send`, `firrtl.ref.resolve`, `firrtl.ref.define` | Probes |

### 3.3 The firtool pipeline

The passes page describes, among others:

| Pass | Effect |
| --- | --- |
| `firrtl-infer-widths` | Gives every integer type a width |
| `firrtl-infer-resets` | Resolves `Reset` |
| `firrtl-expand-whens` | Applies last-connect semantics and removes every `when`. Conditional connects become muxes. |
| `firrtl-lower-types` | Splits bundles and vectors into ground-type values. Field names join with `_` (`io.count` becomes `io_count`). Memory data is split too. |
| `lower-firrtl-to-hw` | Lowers the `firrtl` dialect to `hw`, `comb`, `seq` and `sv` |
| `lower-seq-to-sv` | Turns `seq.firreg` into `sv.reg` and `sv.always`. Options disable register and memory randomisation. |
| `export-verilog` | Prints SystemVerilog |

Name preservation: `-O=release` (or `--preserve-values=none`) may delete
any component, `-O=debug` (or `--preserve-values=named`) keeps components
whose names do not begin with `_`, and `--preserve-values=all` keeps all.

**Observed** (`counter/Counter.parse.mlir` against `Counter.fir.mlir`):
after `--ir-fir` the `io` bundle is split into `%io_en` and `%io_count`,
the `when` has become `firrtl.mux(%io_en, %_reg_T_1, %reg)`, `tail` has
become `firrtl.bits %_reg_T 7 to 0`, and every connect is a
`matchingconnect`.

### 3.4 What LowerToHW produces

**Observed** from `firrtl/primops/PrimOps.fir` with `--ir-hw`. Every
`comb` operation firtool writes carries the `bin` flag (two-state, section
5.2).

| FIRRTL | `hw` / `comb` / `seq` |
| --- | --- |
| `UInt<n>`, `SInt<n>` | Signless integer `i<n>`. The sign is dropped. |
| `Clock` | `!seq.clock` |
| `add(a: UInt<8>, b: UInt<4>)` | `comb.concat` zero bits onto both to 9 bits, then `comb.add bin` |
| Signed extension | `comb.concat (comb.replicate (comb.extract x from msb)), x` |
| `mul`, `sub` | widen both arguments to the result width, then `comb.mul` / `comb.sub` |
| `div`, `rem` (UInt) | `comb.divu`, `comb.modu`, then `comb.extract` to the result width |
| `div`, `rem` (SInt) | `comb.divs`, `comb.mods` on sign-extended arguments |
| `lt` etc. | `comb.icmp bin ult` / `slt` / ... |
| `pad` | `comb.concat` of zeros or replicated sign bits |
| `asUInt`, `asSInt` | nothing: the same `i<n>` value |
| `shl(e, n)` | `comb.concat e, 0:i<n>` |
| `shr(e, n)`, `bits`, `head`, `tail` | `comb.extract` |
| `dshl` | widen, then `comb.shl` |
| `dshr` | `comb.shru` (UInt) or `comb.shrs` (SInt) |
| `cvt` (UInt) | `comb.concat false, e` |
| `neg` | `comb.sub 0, (widened e)` |
| `not` | `comb.xor e, -1` |
| `and`, `or`, `xor` | `comb.and`, `comb.or`, `comb.xor` (here narrowed to the 4 live bits, then re-widened) |
| `andr`, `orr`, `xorr` | `comb.icmp eq e, -1`; `comb.icmp ne e, 0`; `comb.parity` |
| `cat` | one variadic `comb.concat` |
| `mux` | `comb.mux bin` |
| `regreset` with `UInt<1>` reset | `seq.firreg %next clock %clock reset sync %reset, %init` |
| `reg` | `seq.firreg %next clock %clock` |
| `mem` | `seq.firmem` with `seq.firmem.read_port` / `write_port` |
| module | `hw.module`, results through `hw.output` |

Around the module, `--ir-hw` output also holds `sv.macro.decl`,
`emit.file` blocks for the layer files, and an empty `om.class` per
module. A consumer that only simulates can skip them.

---

## 4. The `hw` dialect

Source: https://circt.llvm.org/docs/Dialects/HW/,
https://circt.llvm.org/docs/Dialects/HW/RationaleHW/,
https://circt.llvm.org/docs/Dialects/Comb/RationaleComb/ (endianness and
bitcasts). Read 2026-10-20.

`hw` is the common structure: modules, instances, types and constants. It
has no combinational or sequential operations, and no "connect": values
flow through SSA, and outputs are given by `hw.output`.

### 4.1 Modules and instances

```mlir
hw.module @Counter(in %clock : !seq.clock, in %reset : i1, in %io_en : i1,
                   out io_count : i8) {
  ...
  hw.output %reg : i8
}
```

- Inputs are block arguments of the body. Outputs are named, not SSA
  values, and given in order by `hw.output`.
- **Observed:** the printed form today is `in %name : T` and `out name :
  T` in one list, in port order, as above. The rationale page still shows
  the older `(%in: i4) -> (twoX: i4)` form.
- An `inout` port is an input of type `!hw.inout<T>`.
- Port types are open: any type is allowed, though the Verilog printer
  supports only some. Zero-width ports are allowed and are printed as
  comments.
- Parameters are written `<p1: i42 = 17, p2: i1>` after the name. Each
  instance lists every parameter in the same order. Parameter expressions
  are attributes (`#hw.param.decl.ref`, `#hw.param.expr`,
  `#hw.param.verbatim`).
- `hw.module.extern` declares a module whose body is elsewhere.
  `hw.module.generated` declares one an outside tool will make, with a
  schema from `hw.generator.schema`.
- `%r = hw.instance "name" @Mod(a: %x: i8) -> (out: i8)` instantiates a
  module. The rationale stresses that an instance tree is a compression of
  hardware: each instance becomes its own gates.
- `hw.hierpath` names a path through the instance tree.

### 4.2 Values

| Operation | Meaning |
| --- | --- |
| `hw.constant 42 : i8` | An integer constant. Printed `%c42_i8`, `%true`, `%false`. |
| `hw.aggregate_constant [...] : T` | A constant array or struct |
| `hw.wire %v name "n" sym @s : T` | Gives an SSA edge a name or symbol. Users always read through it, so a forced value reaches them. |
| `hw.bitcast %v : (T1) -> T2` | Reinterpret bits between types of equal width |
| `hw.array_create %a, %b, %c : i4` | Make an array. The **first operand is the highest index**. |
| `hw.array_get %arr[%i]` | Read one element. The index has exactly ceil(log2(n)) bits. |
| `hw.array_slice`, `hw.array_concat`, `hw.array_inject` | Sub-range, join, replace one element. Out-of-range is undefined. |
| `hw.struct_create`, `hw.struct_extract %s["f"]`, `hw.struct_inject`, `hw.struct_explode` | Struct values |
| `hw.union_create`, `hw.union_extract` | Unions. Uncovered bits are undefined. |
| `hw.enum.constant`, `hw.enum.cmp` | Enumerations. The width is the minimum that holds the tags. |
| `hw.param.value` | A parameter expression as a value |
| `hw.triggered` | A procedural region run on an event |
| `hw.type_scope`, `hw.typedecl` | Named types |

### 4.3 Bit layout

All `hw` types are packed: no padding, no alignment.

- **Arrays:** element 0 sits at the least significant bits. In the text,
  the first operand of `hw.array_create` is element `n-1`. So
  `hw.array_create %1, %2, %3` gives `[0] = %3`, `[2] = %1`.
- **Structs:** the first field is at the most significant bits, the last
  field shares the struct's least significant bit.
- **Unions:** every member starts at bit 0 and is padded to the widest.

**Epitome note:** a struct or array becomes one integer of the summed width
for `hw.bitcast`. Epitome's lowering of `hw` aggregates must follow these
two opposite orders exactly.

**Not documented:** the rationale's type-system section, including the
full rules for `inout`, is marked TODO.

---

## 5. The `comb` dialect

Source: https://circt.llvm.org/docs/Dialects/Comb/,
https://circt.llvm.org/docs/Dialects/Comb/RationaleComb/. Read 2026-10-20.

### 5.1 Principles

- Values are signless integers `i<n>`, as in LLVM. Operations that differ
  by sign come in pairs (`divu`/`divs`).
- **No implicit extension.** Every operand and the result of `comb.add`
  have one width.
- **No `not`, `neg`, `zext` or `sext`.** Use `xor x, -1`, `sub 0, x`,
  `concat 0, x`, and `concat (replicate (extract x msb)), x`.
- **Variadic:** `add`, `mul`, `and`, `or`, `xor` take any number of
  operands. `concat` too.
- **No multi-bit mux.** Use `hw.array_create` and `hw.array_get`.
- **Zero width** is allowed. An `i0` value is zero. Division on `i0` is
  undefined.
- **Undefined values** (from division by zero) are a fixed, opaque, pure
  function of the operands, chosen per operation: the same inputs always
  give the same result.
- Cost model: constants, `concat`, `extract`, and `and`/`or` with a
  constant are free. Narrowing arithmetic is always worth it.

### 5.2 The `bin` flag

Every operation where it matters has an optional `bin` unit attribute
(`twoState`). With it, the operation is defined for two-state logic only.
Without it, transformations must also preserve the four-state (Verilog)
and nine-state (VHDL) truth tables. **Observed:** firtool writes `bin` on
all its `comb` operations. `circt-verilog` writes `bin` on some and not on
others.

**Epitome note:** Epitome simulates two-state values only, so the flag can
be ignored when reading. Writing `comb` back without it is always safe.

### 5.3 Operations and their LLVM IR

The LLVM IR column is **observed**: `examples/comb/comb-ops.mlir` holds one
output per operation on `i8` inputs `%a`, `%b`, and was lowered by
`arcilator --emit-llvm --no-runtime`. The loads from the state buffer are
left out.

| Operation | Syntax | Semantics | LLVM IR from arcilator |
| --- | --- | --- | --- |
| `comb.add` | `comb.add %a, %b : i8` | Sum mod 2^n, variadic | `add i8` |
| `comb.sub` | `comb.sub %a, %b : i8` | Difference mod 2^n | `sub i8` |
| `comb.mul` | `comb.mul %a, %b : i8` | Product mod 2^n, variadic | `mul i8` |
| `comb.divu` | `comb.divu %a, %b : i8` | Unsigned quotient. Undefined if `%b` is 0. | `%z = icmp eq %b, 0`; `%d = select %z, 1, %b`; `udiv %a, %d` |
| `comb.divs` | `comb.divs %a, %b : i8` | Signed quotient | as above, and also for `INT_MIN / -1`: divide by 1, then `select` the result `-128` |
| `comb.modu` | `comb.modu %a, %b : i8` | Unsigned remainder | divisor 0 replaced by 1, then `urem` |
| `comb.mods` | `comb.mods %a, %b : i8` | Signed remainder, sign of `%a` | divisor 0 or `INT_MIN % -1` replaced by 1, `srem`, result 0 for `INT_MIN % -1` |
| `comb.shl` | `comb.shl %a, %b : i8` | Shift left by `%b`; one width for both | `shl`, then `select (icmp uge %b, 8), 0, ...` |
| `comb.shru` | `comb.shru %a, %b : i8` | Logical shift right | `lshr`, then the same `select` to 0 |
| `comb.shrs` | `comb.shrs %a, %b : i8` | Arithmetic shift right | `ashr %a, (llvm.umin.i8 %b, 7)` |
| `comb.and`, `comb.or`, `comb.xor` | `comb.and %a, %b, %c : i8` | Bitwise, variadic | `and`, `or`, `xor` (a three-operand `and` of `%a, %b, %a` folded to one `and`) |
| `comb.icmp` | `comb.icmp ult %a, %b : i8` | Compare, result `i1` | `icmp ult` etc. |
| `comb.parity` | `comb.parity %a : i8` | XOR of all bits, `i1` | `trunc (llvm.ctpop.i8 %a) to i1` |
| `comb.extract` | `comb.extract %a from 2 : (i8) -> i4` | Bits from `lowBit` up | `lshr %a, 2`, `trunc to i4` |
| `comb.concat` | `comb.concat %a, %w : i8, i12` | First operand most significant | `zext` each to `i20`, `shl` the high part by 12, `or` |
| `comb.replicate` | `comb.replicate %a : (i8) -> i24` | Repeat the operand | `zext`, `shl` by 8 and 16, `or` |
| `comb.mux` | `comb.mux %c, %a, %b : i8` | `%a` if `%c`, any non-token type | `select i1 %c, %a, %b` |
| `comb.reverse` | `comb.reverse %a : i8` | Reverse the bit order | `llvm.bitreverse.i8` |
| `comb.truth_table` | `comb.truth_table %a, %b -> [false, true, true, false]` | Look up 2^n entries, inputs MSB first | **Observed:** arcilator fails: `failed to legalize operation 'comb.truth_table'` |

The `icmp` predicates are:

| Predicate | Value | Meaning | Lowered to |
| --- | --- | --- | --- |
| `eq`, `ne` | 0, 1 | Equal, not equal | `icmp eq`, `icmp ne` |
| `slt`, `sle`, `sgt`, `sge` | 2-5 | Signed order | `icmp slt` etc. |
| `ult`, `ule`, `ugt`, `uge` | 6-9 | Unsigned order | `icmp ult` etc. |
| `ceq`, `cne` | 10, 11 | Case equality (`===`): X and Z compare as themselves | **Observed:** `icmp eq` / `ne` |
| `weq`, `wne` | 12, 13 | Wildcard equality (`==?`) | **Observed:** `icmp eq` / `ne` |

**Not documented:** the dialect pages do not say what `shl`, `shru` and
`shrs` give when the shift amount is at least the width. **Observed:**
arcilator gives 0 for `shl` and `shru`, and all sign bits for `shrs`. This
matches Verilog, and avoids LLVM's `poison` for over-wide shifts.

**Not documented:** what a division by zero returns. **Observed:**
arcilator divides by 1 instead, so `divu x, 0` gives `x` and `modu x, 0`
gives 0. Any value is allowed (section 5.1).

**Epitome note:** these guards are cheap in a large basic block, but they
must be kept. LLVM's `udiv` by zero and `shl` by the width are undefined
behaviour or `poison`, which `comb` never is. When Epitome lowers `comb`
itself, it must add the same guards or prove them unneeded.

**Epitome note:** `comb` freely uses widths such as `i5`, `i13` and `i23`,
and LLVM IR from arcilator keeps them. Epitome's code generator must
legalise integers of any width up to at least the widest signal (section
10.7).

---

## 6. The `seq` dialect

Source: https://circt.llvm.org/docs/Dialects/Seq/,
https://circt.llvm.org/docs/Dialects/Seq/RationaleSeq/. Read 2026-10-20.

### 6.1 Clocks

| Item | Meaning |
| --- | --- |
| `!seq.clock` | A clock-carrying signal |
| `seq.to_clock %b` / `seq.from_clock %c` | Convert between `i1` and `!seq.clock` |
| `seq.const_clock low` | A constant clock |
| `seq.clock_gate %clk, %en [, %test_en]` | Glitch-free gate. `%en` is sampled at the rising edge. |
| `seq.clock_mux %c, %a, %b` | Select a clock |
| `seq.clock_inv %c` | Inverted clock |
| `seq.clock_div %c by n` | Clock divided by 2^n, phase-aligned |

### 6.2 Registers

| Operation | Syntax | Meaning |
| --- | --- | --- |
| `seq.compreg` | `%q = seq.compreg %d, %clk [reset %r, %v] [initial %i] : T` | An abstract register for "reset-agnostic" logic. Captures `%d` on the rising edge. Starts uninitialised unless `initial` is given. |
| `seq.compreg.ce` | `%q = seq.compreg.ce %d, %clk, %en ...` | The same with a clock enable |
| `seq.firreg` | `%q = seq.firreg %next clock %clk [sym @s] [reset sync\|async %r, %v] [preset c] : T` | A FIRRTL register. Takes `%next` on the rising edge; a sync reset acts at the edge, an async one at once and needs a constant value. Without `preset` it starts random. |
| `seq.shiftreg` | `seq.shiftreg [n] %d, %clk, %en ...` | A shift register of `n` entries |
| `seq.initial` | `seq.initial (...) { ... seq.yield ... }` | Computes initial values, of type `!seq.immutable<T>` |

`seq.firreg` uses SSA form: its `%next` may be computed from its own
result, as in the counter (`%reg = seq.firreg %1 ...; %1 = comb.mux ...
%reg`). This is legal because `hw.module` bodies are graph regions. The
lowering to SV prints one `always @(posedge clock)` block.

**Epitome note:** a `seq` register splits each cycle into "read the old
value" and "write the new value". All reads must see the old value. This
is what arcilator's state lowering does (section 9.3), and what any direct
lowering by Epitome must do.

### 6.3 Memories

| Operation | Meaning |
| --- | --- |
| `%m = seq.firmem rdLat, wrLat, ruw, wuw : <depth x width[, mask]>` | A FIRRTL memory. Type `!seq.firmem<16 x 32>`. |
| `seq.firmem.read_port %m[%addr], clock %clk [enable %en]` | Read port. No enable means always enabled. |
| `seq.firmem.write_port %m[%addr] = %data, clock %clk [enable %en] [mask %m]` | Write port |
| `seq.firmem.read_write_port %m[%addr] = %wdata if %mode, clock %clk ...` | Read-write port; `mode` 1 writes |
| `#seq.firmem.init<"file", isBinary, isInline>` | Initial contents from a `$readmemh`/`$readmemb` file |
| `%m = seq.hlmem @name %clk, %rst : <4xi32>` | A high-level memory with any number of dimensions |
| `seq.read %m[%i] rden %en {latency = 0}`, `seq.write %m[%i] %v wren %en {latency = 1}` | Its ports. Conflicting writes are undefined. |
| `seq.fifo depth n ...` | A high-level FIFO |

---

## 7. Output dialects: `sv`, `emit`, `om`

Source: https://circt.llvm.org/docs/Dialects/SV/,
https://circt.llvm.org/docs/Dialects/SV/RationaleSV/,
https://circt.llvm.org/docs/Dialects/Emit/,
https://circt.llvm.org/docs/Dialects/Emit/RationaleEmit/. Read 2026-10-20.

The `sv` dialect models SystemVerilog syntax for printing. It is "not
focused primarily on being easy to analyse and transform". It has about 90
operations:

| Group | Operations |
| --- | --- |
| Declarations | `sv.reg`, `sv.wire`, `sv.logic`, `sv.var`, `sv.localparam`, `sv.interface*` |
| Inout access | `sv.read_inout`, `sv.array_index_inout`, `sv.struct_field_inout`, `sv.indexed_part_select_inout` |
| Blocks | `sv.always` (`always @`), `sv.alwaysff` (`always_ff`, with optional reset), `sv.alwayscomb`, `sv.initial`, `sv.ordered`, `sv.generate*`, `sv.for` |
| Statements | `sv.if`, `sv.case`, `sv.ifdef`, `sv.ifdef.procedural`, `sv.assign` (continuous), `sv.passign` (`<=`), `sv.bpassign` (`=`), `sv.force`, `sv.release` |
| Verification | `sv.assert`, `sv.assume`, `sv.cover` and their `.concurrent` and `_property` forms |
| System tasks | `sv.finish`, `sv.stop`, `sv.fatal`, `sv.error`, `sv.fwrite`, `sv.readmem`, `sv.system.time` |
| Macros and text | `sv.macro.decl`, `sv.macro.def`, `sv.macro.ref*`, `sv.verbatim` (a statement, with `{{0}}` substitutions), `sv.verbatim.expr`, `sv.include`, `sv.bind` |
| Values | `sv.constantX`, `sv.constantZ`, `sv.constantStr`, `sv.xmr` |

**Observed** (`counter/Counter.sv.mlir`): after `--ir-sv` the register is
`%reg = sv.reg : !hw.inout<i8>`, read with `sv.read_inout`, written by
`sv.passign` inside `sv.always posedge %clock { sv.if %reset {...} else
{...} }`. Random initialisation is an `sv.initial` inside `sv.ifdef
@ENABLE_INITIAL_REG_`, with ``sv.verbatim "`FIRRTL_BEFORE_INITIAL"``.
Clocks are plain `i1` again.

The `emit` dialect describes the output files:

| Operation | Meaning |
| --- | --- |
| `emit.file "path" { ... }` | The contents of one output file |
| `emit.file_list "name", [@files]` | A file listing other files |
| `emit.fragment @F { ... }` | Text emitted once before the operations that name it in an `emit.fragments` attribute |
| `emit.ref @sym` | Print a referenced SV operation here |
| `emit.verbatim "text"` | Raw text |

**Epitome note:** for simulation, Epitome needs none of `sv`, `emit` or
`om`. It should read `--ir-hw` output, where they appear only around the
modules, and skip them.

---

## 8. Other dialects, briefly

Source: the dialect pages for LLHD, Moore, Verif, LTL, Sim, Calyx,
Handshake, and https://circt.llvm.org/docs/HLS/,
https://circt.llvm.org/docs/Tools/circt-verilog/. Read 2026-10-20.

| Dialect | Purpose |
| --- | --- |
| `moore` | SystemVerilog after parsing and elaboration by slang. Types `!moore.iN` (two-state) and `!moore.lN` (four-state). Procedures, `moore.wait_event`, `moore.nonblocking_assign`. |
| `llhd` | Event-queue simulation: signals (`llhd.sig`, `llhd.prb`, `llhd.drv ... after <time>`), `llhd.process` with `llhd.wait`, and `llhd.coroutine`. |
| `verif`, `ltl` | Assertions, assumptions, covers, contracts (`verif.require`, `verif.ensure`), formal tests, and SVA-style sequences and properties. |
| `sim` | Simulator hooks: plusargs, DPI calls, formatted printing. |
| `calyx`, `handshake`, `dc`, `pipeline`, `loopschedule` | High-level synthesis flows driven by `hlstool`. Handshake models dataflow processes joined by FIFOs. These lower to `hw` too. |

`circt-verilog` reads SystemVerilog with the slang parser. **Observed** on
a hand-written counter (`examples/verilog/counter/`):

1. `--ir-moore`: `moore.module` with `moore.procedure always_ff`, CFG
   blocks, `moore.nonblocking_assign`.
2. `--ir-llhd`: `llhd.process` with explicit edge detection
   (`comb.xor %old, true; comb.and ..., %new`) and `llhd.drv ... after
   <0ns, 1d, 0e>` (one delta step).
3. `--ir-hw` (default): the process has become `seq.firreg %5 clock %clk`
   with a mux for reset and enable: the same shape firtool produces.

arcilator reads that last form directly. So a Verilog design reaches LLVM
IR by `circt-verilog | arcilator`, without Chisel.

---

## 9. The `arc` dialect and arcilator

Source: https://circt.llvm.org/docs/Dialects/Arc/ (rationale, operations,
passes). Read 2026-10-20. There is no arcilator page in the CIRCT
documentation index. The behaviour of the tool is **observed** from
`arcilator --help` and its output.

### 9.1 What it is for

Arc is an IR "optimised for simulation". The module hierarchy is
flattened. Combinational logic becomes callable **arcs** (state transfer
functions). Registers become explicit **state**. The result is compiled
through LLVM. Instead of an event queue, the whole design is evaluated in
one fixed order each time the model is stepped: a cycle-based simulator.

### 9.2 Operations

| Operation | Meaning |
| --- | --- |
| `arc.define @A(%x: i8, ...) -> i8 { ... arc.output %r : i8 }` | A state transfer function: pure combinational logic |
| `%r = arc.state @A(%args) clock %clk [enable %e] [reset %r] latency 1 : (...) -> T` | A state element: the result is the arc's output, delayed by `latency` cycles of `%clk`. A register is an `arc.state` with latency 1. |
| `%r = arc.call @A(%args)` | Call an arc with no delay |
| `arc.model @M io !hw.modty<...> storageBytes N { ^bb0(%s: !arc.storage): ... }` | The whole flattened design, as one region over one storage block |
| `arc.root_input "name", %s`, `arc.root_output "name", %s` | Port slots in the storage |
| `arc.alloc_state %s : -> !arc.state<T>` | A slot for internal state |
| `arc.alloc_memory %s : -> !arc.memory<n x iW, iA>` | A memory: `n` words of type `iW`, address type `iA` |
| `arc.alloc_storage`, `arc.storage.get %s[off]` | Sub-ranges of storage, and access by byte offset |
| `arc.state_read %st`, `arc.state_write %st = %v` | Load and store a slot |
| `arc.memory_read %m[%a]`, `arc.memory_write %m[%a], %v` | Load and store a memory word |
| `arc.memory`, `arc.memory_read_port`, `arc.memory_write_port` | Memories before state lowering. Read ports are combinational. All writes are moved to the end of the cycle. |
| `arc.initial`, `arc.final` | Regions run at the start and end of simulation |
| `arc.lut` | A lookup table built from combinational logic |
| `arc.vectorize` | A group of identical operations to be packed into one wider integer or a SIMD vector |
| `arc.tap` | Keep a value observable under a name |
| `arc.zero_count` | Leading or trailing zero count |
| `arc.current_time`, `arc.set_next_wakeup`, `arc.get_next_wakeup` | Time, in femtoseconds, as `i64`. `UINT64_MAX` means no wakeup is pending. |
| `arc.terminate %ctx, success` | Writes 1 (success) or 2 (failure) to a termination flag |
| `arc.coroutine.*` | LLHD processes, lowered to state machines (section 9.6) |
| `arc.sim.instantiate`, `arc.sim.set_input`, `arc.sim.step`, `arc.sim.get_port`, `arc.sim.emit` | A test driver written in MLIR |
| `arc.runtime.model` | Static metadata for the runtime library: name, `numStateBytes`, trace taps |

### 9.3 The pipeline

`arcilator --until-after=<stage>` (or `--until-before`) stops at a named
stage. The stages are `preproc`, `arc-conv`, `arc-opt`, `state-lowering`,
`state-alloc`, `llvm-lowering`. **Observed** on GCD:

1. **arc-conv** (`convert-to-arcs`): the logic between registers is
   outlined into `arc.define`s. Each `seq.firreg` becomes `arc.state ...
   latency 1`, and logic that feeds only outputs becomes `arc.call`. The
   `hw.module` stays, now holding arc operations only.

   ```mlir
   arc.define @GCD_arc(%arg0: i16, %arg1: i16, %arg2: i1, %arg3: i1, %arg4: i16) -> i16 {
     %0 = comb.sub bin %arg0, %arg1 : i16
     %1 = comb.mux bin %arg2, %0, %arg0 : i16
     %2 = comb.mux bin %arg3, %arg4, %1 : i16
     arc.output %2 : i16
   }
   hw.module @GCD(in %clock : !seq.clock, ...) {
     %0 = arc.state @GCD_arc(%0, %1, %2, %io_loadingValues, %io_value1) clock %clock latency 1 : (i16, i16, i1, i1, i16) -> i16
     %1 = arc.state @GCD_arc_0(%1, %0, %2, %io_loadingValues, %io_value2) clock %clock latency 1 : ...
     %2 = arc.call @GCD_arc_1(%0, %1) : (i16, i16) -> i1
     %3 = arc.call @GCD_arc_2(%1) : (i16) -> i1
     hw.output %0, %3 : i16, i1
   }
   ```

2. **arc-opt**: dedup, inlining, enable and reset detection (options
   `--dedup`, `--inline`, `--detect-enables`, `--detect-resets`,
   `--lookup-tables`). In the FIR example the three tap registers share
   one `@Fir_arc`.

3. **state-lowering** (`arc-lower-state`): the module becomes an
   `arc.model`. Each state gets an `arc.alloc_state`. The body reads the
   clock, detects a rising edge, and inside `scf.if` reads the old states,
   computes the new ones and writes them. After the `scf.if` it computes
   the outputs from the new state. Arcs are inlined.

4. **state-alloc** (`arc-allocate-state`): every slot gets a byte `offset`
   and the model gets `storageBytes`.

5. **llvm-lowering** (`lower-arc-to-llvm`): to the `llvm` dialect, then
   to LLVM IR with `--emit-llvm`.

### 9.4 The state storage model

**Observed** from `--state-file=<file>.json` and the offsets in the
lowered IR, for GCD (`storageBytes 41`):

| Bytes | Contents |
| --- | --- |
| 0-7 | `i64`: current simulation time. The driver stores it before each `eval`. |
| 8-15 | Not seen used in these examples |
| 16-23 | `i64`: next wakeup time. `eval` stores `-1` (`UINT64_MAX`) on entry. |
| 24 | input `clock` (`i1`, one byte) |
| 25 | input `reset` |
| 26, 28 | inputs `io_value1`, `io_value2` (`i16`, aligned to 2) |
| 30 | input `io_loadingValues` |
| 32, 34 | registers `x`, `y` |
| 36 | the clock's value at the previous `eval`, for edge detection |
| 38, 40 | outputs `io_outputGCD`, `io_outputValid` |

The state file lists the model name, `numStateBytes`, `initialFnSym`,
`finalFnSym`, and for each port its `name`, `offset`, `numBits` and `type`
(`input`, `output`; also `register`, `wire`, `memory` with the
`--observe-*` options).

In the memory example a `16 x i32` memory is `arc.alloc_memory {offset =
48, stride = 4}`: 16 words of 4 bytes at bytes 48-111.

- Inputs come first, in port order, then internal state, then outputs.
- Each value is stored in the smallest whole number of bytes, at its
  natural alignment. `i1` and `i4` take one byte, `i16` two.
- Loads and stores in the LLVM IR use the value's own type: `load i1`,
  `store i4`, `load i16`.

**Not documented:** the layout of bytes 0-23, the alignment rules, the
order of states, and whether the high bits of a byte holding an `i1` or
`i4` must be zero. The Arc page documents the time and wakeup slots only
as operations, and the termination flag of `arc.terminate` only by its
values (1, 2). Epitome takes the layout from the state file.

### 9.5 The eval function and the driver

`--emit-llvm` writes, for a model `M`:

| Symbol | What it is |
| --- | --- |
| `define void @M_eval(ptr %state)` | One simulation step on the state buffer |
| `define void @M_main()` | A driver (omitted with `--no-generate-driver`) |
| `@arcRuntimeModel_M = global { i64, i64, ptr, ptr } { i64 1, i64 <storageBytes>, ptr @_arc_mod_name_M, ptr null }` | Model metadata for the runtime: the fields of `arc.runtime.model` |
| `declare ptr @arcRuntimeIR_allocInstance(ptr, ptr)`, `@arcRuntimeIR_onInitialized`, `@arcRuntimeIR_onEval`, `@arcRuntimeIR_deleteInstance` | The runtime library. With `--no-runtime`, `allocInstance` becomes `malloc` plus `llvm.memset` to zero, `deleteInstance` becomes `free`, and the other calls go. |
| `@M_initial`, `@M_final` | Only when the design has initial or final regions |

The generated `@M_main` (pass `arc-generate-driver`) allocates an
instance, then loops while the next-wakeup slot (offset 16) is not `-1`:
it stores the wakeup time into the time slot (offset 0), calls
`arcRuntimeIR_onEval` and `M_eval`, and reads the slot again. A design
with no timed processes sets no wakeup, so `M_main` evaluates once.

A user driver does what the C file in section 10.3 does: allocate
`storageBytes` zeroed bytes, write inputs at their offsets, call
`M_eval`, read outputs. A clock edge needs two calls: one with the clock
low, one with it high. `eval` itself works out the edge:

```llvm
define void @GCD_eval(ptr %0) {
  %2 = getelementptr i8, ptr %0, i32 16
  store i64 -1, ptr %2, align 8            ; no wakeup pending
  %3 = getelementptr i8, ptr %0, i32 24
  %4 = load i1, ptr %3, align 1            ; clock now
  %5 = getelementptr i8, ptr %0, i32 36
  %6 = load i1, ptr %5, align 1            ; clock last time
  store i1 %4, ptr %5, align 1
  %7 = xor i1 %6, %4
  %8 = and i1 %7, %4                       ; rising edge
  br i1 %8, label %9, label %29
9:                                         ; all register updates
  ...
29:                                        ; all outputs
  ...
  ret void
}
```

**Not documented:** the runtime library's C interface
(`arcRuntimeIR_*`), the meaning of the first field (`i64 1`) and the last
(`ptr null`) of the model global. The release tarball for macOS has no
runtime header or header generator in `bin/`.

### 9.6 Processes

An `llhd.process` (from `circt-verilog`) is outlined into
`arc.coroutine.define` plus an `arc.coroutine.instance` in the module.
`arc-lower-coroutines` turns it into a function with a program counter
(`START` = 0, so zeroed state is a fresh start) and a state union, one
struct per resume block. An instance runs when `now >= wakeup` and the PC
is not `HALT`. Each instance lowers the model's next-wakeup slot to its own
wakeup time.

### 9.7 Why this is Epitome's case

The `eval` function is a straight line: load inputs, compute, store
state, compute outputs. Its only branches are per-clock-domain `if`s and
the reset and enable `if`s that state lowering creates. In a real design,
each block holds the logic of a whole clock domain.

**Observed** on the 64-tap FIR (section 10.4): `@Fir64_eval` has 8 basic
blocks and 690 instructions. The block computing the output holds 354
instructions, and the block updating the 63 tap registers holds 191. Both
grow linearly with the design. A large SoC gives blocks of hundreds of
thousands of instructions, where LLVM's quadratic passes and register
allocation are slow.

Options that matter for Epitome:

| Option | Effect |
| --- | --- |
| `--emit-llvm` | Write LLVM IR for Epitome to compile |
| `--no-runtime` | No calls to the runtime library, so the `.ll` links alone (with `malloc`, `free`) |
| `--no-generate-driver` | No `M_main` |
| `--state-file=f.json` | The storage layout, for writing a driver |
| `--split-funcs-threshold=N` | Split functions above N operations (pass `arc-split-funcs`). The very large blocks exist because this is off by default. |
| `--observe-ports`, `--observe-registers`, `--observe-wires`, `--observe-memories` | Keep more state visible in storage |
| `--async-resets-as-sync` | Treat async resets as sync |
| `--target-triple`, `--add-data-layout-information` | The data layout written into the module. **Observed:** without them it is the host's: `e-m:o-...` on macOS. |
| `--run`, `--jit-entry=M_main`, `--jit-vcd-file` | Run in arcilator's own JIT |

---

## 10. Worked examples

All files are in `docs/mlir/examples/`. Long outputs are cut here. The
files on disk are complete.

### 10.1 Tools

| Tool | Version | Where from |
| --- | --- | --- |
| firtool, arcilator, circt-verilog | `CIRCT firtool-1.162.0`, `LLVM version 24.0.0git` | `circt-full-static-macos-arm64.tar.gz` from github.com/llvm/circt/releases tag `firtool-1.162.0` (2026-10-15), SHA-256 `ba723176...6065a` checked. Only `bin/` was extracted. |
| Chisel | 7.16.0 (Scala 2.13.18, `chisel-plugin` 7.16.0) | Maven Central, through scala-cli |
| scala-cli | 1.18.0 | `scala-cli-aarch64-apple-darwin.gz` from github.com/VirtusLab/scala-cli releases |
| JVM | OpenJDK 64-Bit Server VM 17.0.20 | fetched by scala-cli (`--jvm 17`) |
| Host | macOS on Apple silicon (arm64) | |

Chisel 7.16.0 is paired with firtool 1.160.0. We used 1.162.0 directly on
the `.fir` files.

Commands, for a design `X`:

```sh
scala-cli run --server=false --jvm 17 X.scala > X.fir   # Main prints emitCHIRRTL
firtool X.fir --parse-only -o X.parse.mlir   # firrtl dialect as written
firtool X.fir --ir-fir     -o X.fir.mlir     # after the FIRRTL passes
firtool X.fir --ir-hw      -o X.hw.mlir      # hw / comb / seq
firtool X.fir --ir-sv      -o X.sv.mlir      # sv dialect
firtool X.fir --verilog    -o X.sv           # SystemVerilog
arcilator X.hw.mlir --until-after=arc-conv --emit-mlir -o X.after-arc-conv.mlir
arcilator X.hw.mlir --until-before=llvm-lowering --state-file=X.state.json -o X.arc.mlir
arcilator X.hw.mlir --emit-mlir -o X.llvm.mlir   # llvm dialect
arcilator X.hw.mlir --emit-llvm -o X.ll          # LLVM IR
```

| Directory | Design | Files |
| --- | --- | --- |
| `chisel/counter/` | 8-bit counter with enable | all stages, `Counter.epitome.s` |
| `chisel/gcd/` | GCD by subtraction | all stages, `GCD.epitome.s`, `gcd_driver.c` |
| `chisel/fir/` | 4-tap FIR filter, coefficients 1, 3, 3, 1 | all stages |
| `chisel/fir64/` | The same with 64 taps | `.fir`, `.hw.mlir`, `.sv`, `.arc.mlir`, `.ll`, state file |
| `chisel/mem/` | 16 x 32-bit memory, one sync read port, one write port | `.fir`, `.fir.mlir`, `.hw.mlir`, `.sv`, `.arc.mlir`, `.ll` |
| `firrtl/primops/` | Every primitive operation, hand-written FIRRTL | `.fir`, `.parse.mlir`, `.hw.mlir`, `.ll` |
| `comb/` | Every `comb` operation, hand-written | `comb-ops.mlir`, `comb-ops.ll` (`--no-runtime`) |
| `verilog/counter/` | Hand-written SystemVerilog counter | `.moore.mlir`, `.llhd.mlir`, `.hw.mlir`, `.ll`, `.epitome.s` |

### 10.2 Counter

```scala
class Counter extends Module {
  val io = IO(new Bundle {
    val en    = Input(Bool())
    val count = Output(UInt(8.W))
  })
  val reg = RegInit(0.U(8.W))
  when(io.en) { reg := reg + 1.U }
  io.count := reg
}
```

The FIRRTL is in section 2.1. Chisel adds an implicit `clock` and a
`reset : UInt<1>` to every `Module`.

`--ir-fir` is described in section 3.3.

`--ir-hw`:

```mlir
hw.module @Counter(in %clock : !seq.clock, in %reset : i1, in %io_en : i1, out io_count : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %reg = seq.firreg %1 clock %clock reset sync %reset, %c0_i8 {firrtl.random_init_start = 0 : ui64, sv.namehint = "reg"} : i8
  %0 = comb.add bin %reg, %c1_i8 {sv.namehint = "_reg_T"} : i8
  %1 = comb.mux bin %io_en, %0, %reg : i8
  hw.output %reg : i8
}
```

The 9-bit add and the `bits` have been narrowed to one 8-bit add.
`firrtl.random_init_start` gives the register's bit offset in the random
initialisation vector. `--disable-all-randomization` removes it.

SystemVerilog (the 40 lines of randomisation macros cut):

```systemverilog
module Counter(	// Counter.scala:10:7
  input        clock,
               reset,
               io_en,
  output [7:0] io_count
);
  reg [7:0] reg_0;	// Counter.scala:15:20
  always @(posedge clock) begin
    if (reset)
      reg_0 <= 8'h0;
    else if (io_en)
      reg_0 <= reg_0 + 8'h1;
  end // always @(posedge)
  `ifdef ENABLE_INITIAL_REG_
    ... random initialisation ...
  `endif // ENABLE_INITIAL_REG_
  assign io_count = reg_0;
endmodule
```

`reg` is a SystemVerilog keyword, so the register is renamed `reg_0`.
`--verilog` writes the layer files after the module, separated by
`// ----- 8< ----- FILE "..." ----- 8< -----` lines.

The `arc` and LLVM IR for the counter have the shape of section 9.5, with
a nested `if` for reset and enable: `Counter_eval` has 8 blocks and 31
instructions.

### 10.3 GCD

```scala
class GCD extends Module {
  val io = IO(new Bundle {
    val value1        = Input(UInt(16.W))
    val value2        = Input(UInt(16.W))
    val loadingValues = Input(Bool())
    val outputGCD     = Output(UInt(16.W))
    val outputValid   = Output(Bool())
  })
  val x = Reg(UInt())
  val y = Reg(UInt())
  when(x > y) { x := x - y }
    .otherwise { y := y - x }
  when(io.loadingValues) {
    x := io.value1
    y := io.value2
  }
  io.outputGCD   := x
  io.outputValid := y === 0.U
}
```

`--ir-hw`:

```mlir
hw.module @GCD(in %clock : !seq.clock, in %reset : i1, in %io_value1 : i16,
    in %io_value2 : i16, in %io_loadingValues : i1,
    out io_outputGCD : i16, out io_outputValid : i1) {
  %c0_i16 = hw.constant 0 : i16
  %x = seq.firreg %5 clock %clock {firrtl.random_init_start = 0 : ui64, sv.namehint = "x"} : i16
  %y = seq.firreg %6 clock %clock {firrtl.random_init_start = 16 : ui64} : i16
  %0 = comb.icmp bin ugt %x, %y : i16
  %1 = comb.sub bin %x, %y {sv.namehint = "_x_T"} : i16
  %2 = comb.mux bin %0, %1, %x : i16
  %3 = comb.sub bin %y, %x {sv.namehint = "_y_T"} : i16
  %4 = comb.mux bin %0, %y, %3 : i16
  %5 = comb.mux bin %io_loadingValues, %io_value1, %2 : i16
  %6 = comb.mux bin %io_loadingValues, %io_value2, %4 : i16
  %7 = comb.icmp bin eq %y, %c0_i16 {sv.namehint = "io_outputValid"} : i16
  hw.output %x, %7 : i16, i1
}
```

`x` and `y` have no reset, so their `seq.firreg`s have none. The two
`when`s have become two levels of `comb.mux`. The `arc` stages are shown
in section 9.3, the eval function in section 9.5. `GCD_eval` has 3 blocks
and 42 instructions.

**Observed run.** `gcd_driver.c` stores `1071` and `462` at offsets 26
and 28, sets `loadingValues` (offset 30) for one clock, then clocks until
`outputValid` (offset 40) is set. Linked with `GCD.epitome.s`, the
assembly Epitome wrote for `GCD.ll`:

```text
$ clang -O1 gcd_driver.c GCD.epitome.s -o gcd-epitome && ./gcd-epitome
gcd(1071, 462) = 21 after 12 cycles
```

The same driver with `GCD.ll` compiled by clang gives the same line.

### 10.4 FIR filter

```scala
class Fir(coeffs: Seq[Int] = Seq(1, 3, 3, 1)) extends Module {
  val io = IO(new Bundle {
    val in    = Input(UInt(8.W))
    val valid = Input(Bool())
    val out   = Output(UInt(16.W))
  })
  val taps = Seq(io.in) ++ Seq.fill(coeffs.length - 1)(RegInit(0.U(8.W)))
  when(io.valid) {
    for (i <- 1 until taps.length) taps(i) := taps(i - 1)
  }
  val products = taps.zip(coeffs).map { case (t, c) => t * c.U }
  io.out := products.reduce(_ +& _)
}
```

The `hw` form shows firtool's width handling: the multiplications by 1
are gone, the multiplications by 3 are done in 10 bits, and each `+&`
adds one bit (`i11`, `i12`, `i13`) before a final zero-extension to
`i16`:

```mlir
%3 = comb.concat %c0_i2, %taps_1 : i2, i8
%4 = comb.mul bin %3, %c3_i10 {sv.namehint = "products_1"} : i10
...
%15 = comb.add bin %13, %14 {sv.namehint = "_io_out_T_2"} : i13
%16 = comb.concat %c0_i3, %15 {sv.namehint = "io_out"} : i3, i13
hw.output %16 : i16
```

In LLVM IR these become `zext i8 ... to i13`, `mul i10`, `add i11`,
`add i12`, `add i13`, `zext i13 ... to i16`. In `arc` form, after
`arc-opt`, the three tap registers are one deduplicated arc used three
times, with an explicit reset:

```mlir
%0 = arc.state @Fir_arc(%io_valid, %io_in, %0) clock %clock reset %reset latency 1 : (i1, i8, i8) -> i8
%1 = arc.state @Fir_arc(%io_valid, %0, %1) clock %clock reset %reset latency 1 : (i1, i8, i8) -> i8
%2 = arc.state @Fir_arc(%io_valid, %1, %2) clock %clock reset %reset latency 1 : (i1, i8, i8) -> i8
%3 = arc.call @Fir_arc_2(%2, %1, %0, %io_in) : (i8, i8, i8, i8) -> i16
```

`Fir64` is the same Scala class with 64 coefficients `(i * 37 + 11) % 251`.
Its `eval` has 8 blocks and 690 instructions, with blocks of 354 and 191
instructions (section 9.7).

### 10.5 Memory

`SyncReadMem(16, UInt(32.W))` with one read and one conditional write.
Chisel writes CHIRRTL: `smem mem : UInt<32>[16]`, a `read mport` and,
inside `when io.wen`, a `write mport`.

`--ir-fir` has a `firrtl.mem Undefined {depth = 16, readLatency = 1,
writeLatency = 1, ...}` with two port bundles. `--ir-hw`:

```mlir
%mem = seq.firmem 1, 1, undefined, port_order : <16 x 32>
seq.firmem.write_port %mem[%io_waddr] = %io_wdata, clock %clock enable %io_wen : <16 x 32>
%0 = seq.firmem.read_port %mem[%io_raddr], clock %clock {sv.namehint = "io_rdata"} : <16 x 32>
```

In `arc` form the memory is `arc.alloc_memory {offset = 48, stride = 4} :
!arc.memory<16 x i32, i4>`. On a clock edge, `eval` writes the memory if
`wen` is set, then latches the read address (`i4` at offset 112) and a
"read happened" flag (offset 114). After the edge it computes `rdata =
mux(flag, mem[latched address], 0)`. In LLVM IR the address is widened to
`i5` and bounds-checked before the store:

```llvm
%18 = zext i4 %14 to i5
%19 = icmp ult i5 %18, -16           ; 16 as an unsigned i5
%20 = getelementptr i32, ptr %17, i5 %18
br i1 %19, label %21, label %22      ; store only if in range
```

### 10.6 Primitive operations and `comb`

The results of `firrtl/primops/` are the tables of sections 2.6 and 3.4.
The results of `comb/comb-ops.mlir` are the table of section 5.3.

### 10.7 Reading the results with Epitome

Epitome was built with `cargo build --release --workspace` at commit
`268a5ad`. `epitome <file>.ll` parses, verifies and prints the module.
`epitome-llc <file>.ll -o <file>.s` compiles it for AArch64 Mach-O.

| File | `epitome` (read) | `epitome-llc` (compile) |
| --- | --- | --- |
| `chisel/counter/Counter.ll` | reads | compiles |
| `chisel/gcd/GCD.ll` | reads | compiles; the result runs correctly (section 10.3) |
| `verilog/counter/counter.ll` | reads | compiles |
| `chisel/fir/Fir.ll` | reads | `` epitome-llc: @Fir_eval: no instruction for `Cast { op: ZExt, flags: IntFlags(0), fmf: FastMath(0), value: Local(LocalId(66)) }` `` |
| `chisel/fir64/Fir64.ll` | reads | `` epitome-llc: @Fir64_eval: no instruction for `Cast { op: ZExt, flags: IntFlags(0), fmf: FastMath(0), value: Local(LocalId(603)) }` `` |
| `chisel/mem/Scratchpad.ll` | reads | `epitome-llc: loads and stores of odd-sized integers are not supported yet` |
| `firrtl/primops/PrimOps.ll` | reads | `epitome-llc: loads and stores of odd-sized integers are not supported yet` |
| `comb/comb-ops.ll` | reads | `epitome-llc: loads and stores of odd-sized integers are not supported yet` |

**Epitome note:** every file reads. The two failures are both about
integer widths that are not 8, 16, 32 or 64 bits: `zext` to `i10`-`i13`
in arithmetic, and `load`/`store` of `i4`, `i12`, `i20`, `i24`. These are
everywhere in hardware designs. Legalising odd widths (promote to the
next machine width, with masking or extension where the high bits are
seen) is the first thing Epitome needs for arcilator output.

---

## 11. Summary for Epitome

- **Two entry points.** Epitome can read arcilator's `.ll` today, or read
  `hw`/`comb`/`seq` and do the work of section 9.3 itself. The first needs
  only odd-width legalisation. The second is the plan in
  `docs/design/mlir.md`.
- **What a direct reader needs.** From `--ir-hw` output: `hw.module`,
  `hw.output`, `hw.instance`, `hw.constant`, all of `comb`,
  `seq.firreg`, `seq.firmem*`, `!seq.clock`, `seq.to_clock`,
  `seq.from_clock`, and arrays and structs if the design keeps them
  (`--preserve-aggregate`). `sv`, `emit` and `om` operations can be
  skipped.
- **Semantics to keep.** Two-state values. Registers read their old value
  for the whole cycle. Shifts by the width or more give 0 or sign bits.
  Division by zero gives some fixed value, never undefined behaviour.
- **Schedule.** Flatten the instance tree, detect each clock's rising
  edge, update all its registers from old values, then recompute outputs.
  The result is a few very large basic blocks per clock domain.
- **Storage.** Use arcilator's layout (section 9.4) so drivers and state
  files written for arcilator work with Epitome's output.

---

## Still to read

| Gap | Where to look |
| --- | --- |
| The FIRRTL ABI: port lowering, naming, file layout | `abi.md` in github.com/chipsalliance/firrtl-spec |
| FIRRTL annotations: which ones change simulation (`DontTouch`, memory initialisation, `Dedup`) | https://circt.llvm.org/docs/Dialects/FIRRTL/FIRRTLAnnotations/ |
| FIRRTL intrinsics (`circt_clock_gate`, `circt_plusargs_value`, ...) | https://circt.llvm.org/docs/Dialects/FIRRTL/FIRRTLIntrinsics/ |
| The rest of the FIRRTL spec: layers, probes and forcing, enumerations and `match`, the scalarized convention | `spec.md`: Layers, Layer Blocks, Probes, Match Statements, Module Conventions |
| `hw` parameterised types and parameter canonicalisation | HW rationale, sections after "Parameterized Modules" |
| `seq.firreg` preset and async reset in arcilator | Run arcilator on `preset` and `AsyncReset` registers |
| arcilator's runtime library (`arcRuntimeIR_*`) and the C++ header generator | No published page found. Learn from tool output. |
| Storage bytes 0-23, alignment of states, high bits of `i1`/`i4` slots | Run arcilator with `--observe-*` and several clock domains |
| Multiple clocks and clock gating in `arc` | Run arcilator on a two-clock Chisel design |
| `--split-funcs-threshold` and `--lookup-tables` output | Run arcilator with them on `Fir64` |
| `llhd` and `moore` in full, for designs from `circt-verilog` | https://circt.llvm.org/docs/Dialects/LLHD/, https://circt.llvm.org/docs/Dialects/Moore/ |
| `verif`, `ltl`, `sim` operations in simulation (asserts, `printf`) | Their dialect pages; run arcilator on a design with `printf` and `assert` |
| Chisel's `firtoolOpts` and `args` for `emitSystemVerilog` | chisel-lang.org API docs (the explanation pages did not cover them) |
| Verilog generation options and lowering options | https://circt.llvm.org/docs/VerilogGeneration/ |

## Conventions

As in the [LLVM IR reference](../llvm-ir/README.md):

- **Epitome note:** something the documentation implies for our
  implementation.
- **Not documented:** a question the documentation does not answer.
- **Observed:** found by running the tools in section 10.1 on our own
  inputs.

Exact names, keywords and syntax are copied from the documentation and
the tools' output because Epitome must read them. Explanations are in our
own words.
