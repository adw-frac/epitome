# Module Structure, Attributes and Memory Semantics

Source: LLVM Language Reference, sections Abstract to Source Filename.

This chapter covers the lexical rules of LLVM IR text (`.ll` files), the top-level objects a module may contain, every keyword that can decorate those objects, and the module-wide semantic rules (memory model, aliasing, floating point) that the rest of the IR relies on.

---

## 1. Overview

LLVM IR is a Static Single Assignment (SSA) representation. SSA means each value is assigned exactly once. The IR exists in three equivalent forms:

- an in-memory data structure used by the compiler,
- on-disk bitcode (a compact binary form),
- human-readable assembly text (the `.ll` form).

This reference describes the text form. All three forms carry the same information.

**Draconian note:** Draconian must be able to round-trip the text form. Anything parsed from text must be printable back to equivalent text.

### 1.1 Well-formedness

The parser accepts more than is "well formed". A well-formed module also satisfies semantic rules checked by a separate verifier. Example: `%x = add i32 1, %x` parses, but is not well formed because `%x` is used where its definition does not dominate the use.

The reference states that the verifier runs automatically after parsing text and before writing bitcode. Verifier errors indicate a bug in a transformation pass or in the input.

**Draconian note:** Keep parsing and verification as separate phases. Run the verifier after parsing by default.

---

## 2. Lexical Syntax

### 2.1 Identifiers

There are two scopes of identifier:

| Prefix | Scope | Used for |
|---|---|---|
| `@` | global | functions, global variables, aliases, ifuncs |
| `%` | local | registers (SSA values), basic block labels, and type names |

Identifiers come in three formats:

1. **Named values.** Prefix followed by a name matching the regular expression
   `[%@][-a-zA-Z$._][-a-zA-Z$._0-9]*`.
   Examples: `%foo`, `@DivisionByZero`, `%a.really.long.identifier`.
   A name containing other characters can be written in double quotes, e.g. `@"my name"`. Inside the quotes, `\xx` (two hex digits) encodes any byte, including a quote.
   A global name beginning with byte `\01` tells the backend not to mangle the name.
2. **Unnamed values.** Prefix followed by an unsigned decimal number, e.g. `%12`, `@2`, `%44`.
3. **Constants.** Covered in the Constants chapter.

Other sigils used at module level (defined in later sections): `$name` for comdats, `!name` / `!N` for metadata, `#N` for attribute groups.

Reserved words (opcodes such as `add`, `bitcast`, `ret`; type names such as `void`, `i32`; and others) never carry a prefix, so they can never clash with value names.

### 2.2 Unnamed value numbering

- Unnamed temporaries are numbered by a per-function counter starting at 0.
- Basic blocks without a label and unnamed function parameters share this same counter.
- When numbers are written explicitly, gaps are allowed (numbers may be skipped).
- If the entry block has no label and all parameters are named, the entry block is `%0`.

**Draconian note:** The counter is shared by unnamed parameters, unnamed blocks and unnamed instruction results, in textual order. When printing, Draconian must assign numbers in this order. When parsing, an explicit number must not be lower than the next expected number (gaps forward are allowed). For block labels specifically, see section 5.3: an explicit numeric block label must equal the number that would have been assigned implicitly.

### 2.3 Comments

- `;` starts a comment that runs to the end of the line.
- `/*` ... `*/` is a block comment.

### 2.4 String constants

- Delimited by `"`.
- All bytes are literal except `\`, which starts an escape, and the first unescaped `"`, which ends the string.
- Escapes:
  - `\\` is a single backslash.
  - `\` followed by exactly two hex digits (`0-9`, `a-f`, `A-F`) is the byte with that value, e.g. `\00`.
- A literal `"` must be written `\22`. Writing `\"` does **not** escape the quote; it produces a backslash and then ends the string.
- Newlines do not end a string; strings may span lines.
- The meaning of the bytes (encoding etc.) depends on context.

**Draconian note:** Store strings as raw bytes, not as Rust `String`. When printing, escape `"`, `\` and non-printable bytes as `\xx`.

---

## 3. Module Structure

A module is one translation unit. It contains global values (functions, global variables, aliases, ifuncs), plus other module-level entities. Modules can be linked together: the linker merges definitions, resolves forward declarations and merges symbol tables.

Example:

```llvm
@.str = private unnamed_addr constant [13 x i8] c"hello world\0A\00"

declare i32 @puts(ptr captures(none)) nounwind

define i32 @main() {
  call i32 @puts(ptr @.str)
  ret i32 0
}

!0 = !{i32 42, null, !"string"}
!foo = !{!0}
```

Every global value is represented by a pointer to its memory location.

Top-level entities that can appear in a module (all described in this chapter):

| Entity | Leading syntax |
|---|---|
| Source filename | `source_filename = "..."` |
| Data layout | `target datalayout = "..."` |
| Target triple | `target triple = "..."` |
| Module inline asm | `module asm "..."` |
| Named type definition | `%name = type ...` |
| Comdat | `$name = comdat <kind>` |
| Global variable | `@name = ... global|constant ...` |
| Function definition | `define ...` |
| Function declaration | `declare ...` |
| Alias | `@name = ... alias ...` |
| IFunc | `@name = ... ifunc ...` |
| Attribute group | `attributes #N = { ... }` |
| Named metadata | `!name = !{...}` |
| Unnamed metadata | `!N = ...` |
| Use-list order | `uselistorder ...` |

**Not documented:** The reference does not give a required ordering for top-level entities, apart from the rules for use-list directives inside functions.

---

## 4. Properties of Global Values

### 4.1 Linkage types

Every global variable and function has exactly one linkage. If no keyword is written, the linkage is `external`.

| Keyword | Meaning |
|---|---|
| `private` | Only directly accessible inside this module. May be renamed during linking to avoid clashes. Never appears in the object file's symbol table. |
| `internal` | Like `private`, but appears as a local symbol in the object file (`STB_LOCAL` on ELF). Matches C `static`. |
| `available_externally` | Never emitted into the object file. To the linker it is just an external declaration. The body exists so optimisers can inline or fold it; the real definition lives elsewhere. May be discarded at will. Allowed only on definitions. |
| `linkonce` | Merged with other globals of the same name at link time. Unreferenced ones may be discarded. Because a stronger definition might replace it, the optimiser may **not** inline its body. |
| `weak` | Same merging as `linkonce`, but unreferenced globals may **not** be discarded. Used for C `weak` declarations. |
| `common` | For C tentative definitions such as `int X;` at file scope. Merged like `weak`, never deleted if unreferenced. |
| `appending` | Only for global variables of array type (the reference says "pointer to array type"). Linking two such arrays concatenates them. Used for special variables such as `llvm.global_ctors`. |
| `extern_weak` | ELF-style weak reference: if no definition is linked in, the symbol becomes null instead of an undefined reference. |
| `linkonce_odr` | Like `linkonce`, plus the "one definition rule": all definitions are equivalent, so inlining and constant folding are allowed. |
| `weak_odr` | Like `weak`, plus the one definition rule. |
| `external` | Default when no keyword is given. Externally visible and used to resolve references from other modules. |

Formal meaning of the `_odr` suffix:
- Calling an `odr` function runs a non-deterministically chosen definition.
- For an `odr` variable, any byte that differs between initializers is poison.
- For aliases and ifuncs, apply the rule of the underlying function or variable.

Verifier rules stated in the reference:
- A global variable or function **declaration** may only have `external` or `extern_weak` linkage.
- `available_externally` is allowed only on definitions.
- `common` symbols: must have a zero initializer, may not have an explicit section, may not be `constant`. Functions and aliases may not be `common`.
- `appending` is only for global variables of array type.
- A symbol with `internal` or `private` linkage must have `default` visibility.
- A symbol with `internal` or `private` linkage cannot have a DLL storage class.

**Draconian note:** `external` is the default. The printer should omit it on definitions. (The reference shows `@G = external global i32` for a variable declaration, so `external` is printed there to mark the declaration.)

### 4.2 Calling conventions

Functions, `call` and `invoke` may name a calling convention. If caller and callee disagree at run time, the behaviour is undefined. The default is `ccc`.

| Keyword | Meaning |
|---|---|
| `ccc` | The target's C calling convention. Default. Supports varargs and tolerates some prototype mismatch, as C does. |
| `fastcc` | Fast convention. The target may use any non-ABI tricks. Supports tail call optimisation. No varargs; callee prototypes must match exactly. A target with several implementations must not use it across implementations (via the TTI hook `useFastCCForInternalCall`). |
| `coldcc` | For rarely executed calls. Usually preserves all registers so the caller's live ranges are not disturbed. No varargs; exact prototypes required. The inliner ignores such calls. |
| `ghccc` | Glasgow Haskell Compiler convention. Everything passed in registers; no callee-saved registers. Supports tail calls; caller and callee must both use it. Supported on X86, AArch64, RISCV only, with limits on parameter counts (see below). |
| `cc 11` | HiPE (High-Performance Erlang) convention. More argument registers than C, no callee-saved registers, register pinning. Supports tail calls; caller and callee must both use it. X86 only (32 and 64 bit). Written only by number. |
| `anyregcc` | For code patching. Forces arguments into registers but lets them be allocated dynamically. Only usable with calls to `llvm.experimental.patchpoint`. |
| `preserve_mostcc` | Passes arguments and returns like C, but the callee saves most general purpose registers. Intended for hot-path runtime calls. Does not block inlining. |
| `preserve_allcc` | Like `preserve_mostcc` but the callee also preserves floating-point registers (on X86-64, all XMM/YMM; on AArch64, low 128 bits of V8-V31). Considered experimental. |
| `preserve_nonecc` | No general registers are preserved; all general registers are caller-saved and used for argument passing. Non-general registers follow the C convention. x86_64, AArch64 and LoongArch only. |
| `cxx_fast_tlscc` | For C++ thread-local access functions. Passes like C but preserves as many registers as possible. On X86-64 preserves all GPRs except RDI and RAX. |
| `tailcc` | Same as `fastcc` but guarantees calls in tail position are tail-call optimised. No varargs; exact prototypes required. |
| `swiftcc` | Swift language convention. On X86-64, RCX and R8 give extra integer returns and XMM2/XMM3 extra FP/vector returns. On iOS uses AAPCS-VFP. |
| `swifttailcc` | Like `swiftcc`, but the callee pops the argument area so mandatory tail calls work, as in `tailcc`. |
| `cfguard_checkcc` | Windows Control Flow Guard check function. No return value. Target address passed in ECX (X86), R0 (ARM), X15 (AArch64). |
| `cc <n>` | Any convention by number. Target-specific conventions start at 64. |

Tail calls can only be optimised for `fastcc`, `tailcc`, `ghccc` and HiPE (`cc 11`). (`swifttailcc` also supports mandatory tail calls.)

GHC parameter limits:
- X86-32: up to 4 "bit type" parameters; no floating point.
- X86-64: up to 10 bit-type and 6 floating-point parameters.
- AArch64: up to 4 f32, 4 f64 and 10 bit-type parameters.
- RISCV64: up to 11 bit-type, 4 f32 and 4 f64 parameters.

Register preservation for `preserve_mostcc`:
- X86-64: all GPRs except R11 and return registers. FP registers follow the OS C convention (Windows preserves xmm6-xmm15).
- AArch64: all GPRs except X0-X8 and X16-X18. Not allowed with `nest`.
- RISC-V: x5-x31 except x6, x7, x28.
- LoongArch: r4-r31 except r12-r15 and r20-r21.

`preserve_allcc`: X86-64 preserves all GPRs except R11, plus all XMM/YMM. AArch64 preserves all GPRs except X0-X8 and X16-X18, plus the low 128 bits of V8-V31; not allowed with `nest`.

**Not documented:** The numeric IDs of the named conventions (other than HiPE = 11, and that target conventions start at 64) are not given. Draconian needs these for bitcode and to decide when `cc <n>` should be printed by name.

### 4.3 Visibility styles

Applies to global variables and functions (and, per the grammars, aliases and ifuncs).

| Keyword | Meaning |
|---|---|
| `default` | ELF: visible to other modules and, in a shared library, may be overridden. Darwin: visible to other modules. XCOFF: no visibility bit set; export depends on linker export lists. This is the default when nothing is written. |
| `hidden` | Two hidden declarations refer to the same object if in the same shared object. Usually not in the dynamic symbol table. |
| `protected` | ELF: in the dynamic symbol table, but references inside the defining module bind locally, so it cannot be overridden. |

**Draconian note:** `default` is implied when omitted; the printer should omit it.

### 4.4 DLL storage classes

Applies to global variables, functions and aliases.

| Keyword | Meaning |
|---|---|
| `dllimport` | Reference the symbol through a pointer set up by the exporting DLL. On Windows the pointer is named `__imp_` + symbol name. |
| `dllexport` | Windows: provide the `__imp_` pointer so others can `dllimport` it. XCOFF: export the symbol into the loader section symbol table. The symbol must not be deleted. |

A symbol with `internal` or `private` linkage cannot have a DLL storage class.

### 4.5 Thread-local storage models

Syntax: `thread_local` or `thread_local(<model>)`.

| Model keyword | Meaning |
|---|---|
| (none, plain `thread_local`) | General dynamic model. |
| `localdynamic` | Variable used only within the current shared library. |
| `initialexec` | Variable in a module that will not be loaded dynamically. |
| `localexec` | Variable defined in the executable and used only there. |

These match the ELF TLS models. The target may pick a different model if the requested one is unsupported or if a better one exists. On an alias, the model only controls how the alias is accessed, not the aliasee. Not all targets support TLS.

**Not documented:** There is no explicit keyword for general dynamic; it is expressed by omitting the model.

### 4.6 Runtime preemption specifiers

Applies to global variables, functions and aliases.

| Keyword | Meaning |
|---|---|
| `dso_preemptable` | The symbol may be replaced at run time by one from outside the linkage unit. Default when nothing is written. |
| `dso_local` | The compiler may assume the symbol resolves within the same linkage unit, and may use direct access even if the definition is in another compilation unit. |

### 4.7 `unnamed_addr` and `local_unnamed_addr`

- `unnamed_addr`: the address is not significant, only the content. Constants with this mark may be merged with equal constants, and may be duplicated. Identical functions may be merged.
- `local_unnamed_addr`: the address is not significant within this module.

Merging a significant-address constant with an `unnamed_addr` one gives a constant whose address is significant.

**Warning (from the reference):** Because duplication is allowed, comparing pointers is unsound if either may be `unnamed_addr`.

### 4.8 Address spaces

Written `addrspace(N)`. The default address space for globals is 0. For functions the default is the program address space from the data layout (`P` specifier).

---

## 5. Global Objects

### 5.1 Structure types (brief)

- **Identified** struct types have a name, e.g. `%mytype = type { ptr, i32 }`, and are never uniqued (two identically shaped identified types are distinct).
- **Literal** struct types are uniqued structurally.
- An **opaque** struct type can forward-declare a type.

(Full type syntax is in the type system chapter.) Before LLVM 3.0 identified types were also structurally uniqued; this is no longer so.

**Draconian note:** Intern literal structs by structure. Intern identified structs by name only.

### 5.2 Global variables

A global variable is a region of memory allocated at compile time.

Rules:
- A **definition** has an initializer, which must be of a sized type.
- A **declaration** has no initializer and refers to a variable in another translation unit.
- `constant` instead of `global` means the contents never change. A variable needing run-time initialisation cannot be `constant`.
- A declaration may be marked `constant` even if the final definition is not; this is a language-level promise.
- The global's SSA value is a pointer to its content and dominates every basic block in the module.
- Explicit sections and alignment are allowed on both definitions and declarations. A mismatch between the section of a declaration and its definition is undefined behaviour.
- `align` must be a power of 2. Missing or `align 0` lets the target choose. If given, the global has exactly that alignment. A global with an explicit section must not be over-aligned. For TLS variables, the module flag `MaxTLSAlign` caps the alignment. The maximum is `1 << 32`.
- For declarations and replaceable definitions (`linkonce`, `weak`, `extern_weak`, `common`), the size and alignment of the definition finally chosen must be at least those of the declaration, otherwise UB.
- `code_model "<model>"`: one of `"tiny"`, `"small"`, `"kernel"`, `"medium"`, `"large"`. Overrides the translation unit's code model for this global.
- `externally_initialized`: by default the optimiser assumes globals are unmodified before the program's global initialisers start (even `external` ones). This keyword removes that assumption.
- `section "name"`: emit into that section. On an external declaration it asserts the definition is in that section.
- `comdat` / `comdat($name)`: place in a comdat (section 5.6).
- `partition "name"`: **Not documented** in this part of the reference beyond the grammar.
- Globals cannot be, or contain, scalable vectors, because their size is unknown at compile time.
- Globals with the `toc-data` attribute live in the XCOFF TOC. Their alignment must not exceed a TOC entry, and optimisers must not increase it.

Note on scalable vectors in structs (given in this section): structs may contain scalable vectors, but such structs are generally unsized. The exception is a struct whose members are all the same scalable vector type (a "homogeneous scalable vector struct"); that is sized and may be loaded, stored and alloca'd, but not used in GEPs.

**Syntax:**

```
@<GlobalVarName> = [Linkage] [PreemptionSpecifier] [Visibility]
                   [DLLStorageClass] [ThreadLocal]
                   [(unnamed_addr|local_unnamed_addr)] [AddrSpace]
                   [ExternallyInitialized]
                   <global | constant> <Type> [<InitializerConstant>]
                   [, section "name"] [, partition "name"]
                   [, comdat [($name)]] [, align <Alignment>]
                   [, code_model "model"]
                   [, no_sanitize_address] [, no_sanitize_hwaddress]
                   [, sanitize_address_dyninit] [, sanitize_memtag]
                   (, !name !N)*
```

Where:
- `ThreadLocal` is `thread_local` or `thread_local(<model>)`.
- `AddrSpace` is `addrspace(N)`.
- `ExternallyInitialized` is `externally_initialized`.
- `(, !name !N)*` attaches metadata.

Examples:

```llvm
@G = addrspace(5) constant float 1.0, section "foo", align 4
@G = external global i32
@G = internal global i32 0, code_model "large"
@G = thread_local(initialexec) global i32 0, align 4
```

**Draconian note:** The prose says "the address space qualifier must precede any other attributes", but the grammar places `addrspace` after `unnamed_addr`. Follow the grammar order for printing.

**Draconian note:** A global with no initializer is a declaration. The parser must handle the declaration form `@G = external global i32` (linkage `external` written explicitly, no initializer).

### 5.3 Functions

#### Definition syntax

```
define [linkage] [PreemptionSpecifier] [visibility] [DLLStorageClass]
       [cconv] [ret attrs]
       <ResultType> @<FunctionName> ([argument list])
       [(unnamed_addr|local_unnamed_addr)] [AddrSpace] [fn Attrs]
       [section "name"] [partition "name"] [comdat [($name)]] [align N]
       [prefalign(N)] [gc] [prefix Constant] [prologue Constant]
       [personality Constant] (!name !N)* { ... }
```

Each argument in the list:

```
<type> [parameter Attrs] [name]
```

A trailing `...` in the list marks a varargs function (see the `printf` example in section 6.1).

`[fn Attrs]` may be attribute keywords, string attributes, or attribute-group references `#N`.
`[gc]` is `gc "name"`.

#### Declaration syntax

```
declare [linkage] [visibility] [DLLStorageClass]
        [cconv] [ret attrs]
        <ResultType> @<FunctionName> ([argument list])
        [(unnamed_addr|local_unnamed_addr)] [align N] [gc]
        [prefix Constant] [prologue Constant]
```

**Not documented / inconsistent:** The declaration grammar omits several things the rest of the reference uses:
- function attributes (the module example has `declare i32 @puts(ptr captures(none)) nounwind`),
- the address space (the prose lists "an optional address space" after `unnamed_addr`),
- the preemption specifier,
- metadata attachments.
Draconian should accept the definition header grammar for declarations too, minus the body (and minus `prefalign`, `personality`, `section`, `partition`, `comdat` unless confirmed elsewhere).

#### Body

- The body is a list of basic blocks forming the control flow graph (CFG).
- Each block may start with a label, contains instructions and debug records, and ends with a terminator (branch, return, etc.).
- An unlabeled block takes the next number from the unnamed-value counter. If the entry block is unlabeled it is `%0`, and the first unnamed instruction in it is `%1`.
- An explicit numeric label must equal the number it would get implicitly.
- The entry block (the first block) runs on entry and must have no predecessors. So no branch may target it and it cannot contain PHI nodes.

#### Other function properties

- `section "name"` and `comdat` work as for globals.
- `align N`: minimum alignment, power of 2. Missing or 0 means use the preferred-alignment rules.
- `prefalign(N)`: preferred alignment, power of 2, definitions only. A hint; final alignment lies between minimum and preferred. If absent, target-specific.
- `unnamed_addr`: two identical functions may be merged.
- If no `addrspace` is given, the program address space from the data layout is used.

**Draconian note (verifier):** entry block has no predecessors and no PHIs; `align` and `prefalign` are powers of 2; `prefalign` only on definitions.

### 5.4 Aliases

An alias is a new symbol for an existing location. It creates no new data. The aliasee is a global value or a constant expression.

**Syntax:**

```
@<Name> = [Linkage] [PreemptionSpecifier] [Visibility] [DLLStorageClass] [ThreadLocal] [(unnamed_addr|local_unnamed_addr)] alias <AliaseeTy>, <AliaseeTy>* @<Aliasee>
          [, partition "name"]
```

**Not documented / outdated:** The grammar shows the second type as `<AliaseeTy>*`, a typed-pointer spelling. With opaque pointers this is a `ptr` (or `ptr addrspace(N)`) typed constant. Draconian should parse `alias <ValueTy>, <pointer type> <constant>`.

Allowed linkages: `private`, `internal`, `linkonce`, `weak`, `linkonce_odr`, `weak_odr`, `external`, `available_externally`.

Semantics and restrictions:
- Without `unnamed_addr`, the alias has the same address as the aliasee. With `unnamed_addr`, only the same content is guaranteed.
- The aliasee expression must be computable at assembly time (no relocations).
- No alias inside the aliasee expression may be weak.
- If the alias is `available_externally`, the aliasee must be an `available_externally` global value. Otherwise, no global value in the aliasee expression may be a declaration.
- If either side may be replaced at link or run time, optimisers may not replace the alias with the aliasee.
- Some system linkers mishandle dropping a weak symbol that has an alias.

**Draconian note (verifier):** check the linkage list and the declaration/weak restrictions above.

### 5.5 IFuncs

An ifunc is a symbol resolved at run time by calling a resolver function. ELF: resolved by the dynamic linker at load time. Mach-O: lowered to `.symbol_resolver` functions that resolve lazily on first call.

**Syntax:**

```
@<Name> = [Linkage] [PreemptionSpecifier] [Visibility] ifunc <IFuncTy>, <ResolverTy>* @<Resolver>
          [, partition "name"] (, !name !N)*
```

As with aliases, `<ResolverTy>*` is the old typed-pointer spelling; in practice it is a pointer type.

**Not documented:** Allowed linkages for ifuncs, and the required type of the resolver.

### 5.6 Comdats

A comdat is a COMDAT / section group in the object file: a set of sections kept or discarded together. Each has a name (the key) and a selection kind telling the linker how to deduplicate.

**Syntax:**

```
$<Name> = comdat SelectionKind
```

| Selection kind | Meaning |
|---|---|
| `any` | Linker may pick any duplicate. |
| `exactmatch` | Linker may pick any, but all must contain the same data. |
| `largest` | Linker picks the one with the largest key section. |
| `nodeduplicate` | No deduplication; all are kept. |
| `samesize` | Linker may pick any, but all must have the same size. |

Rules:
- A comdat is kept or dropped as a whole, never partially.
- A global object belongs to at most one comdat. An alias belongs to the comdat of its aliasee, if any.
- Globals and functions join a comdat with `comdat($name)`. Plain `comdat` (no name) means the comdat whose name equals the global's name.
- COFF: the object, or an alias to it, must have the same name as the comdat, and so must not have local linkage. Non-`nodeduplicate` kinds need a non-local comdat symbol.

Object format support:

| Format | Supported kinds |
|---|---|
| COFF | all |
| ELF | `any`, `nodeduplicate` |
| WebAssembly | `any` |
| XCOFF, Mach-O | none (no COMDAT support) |

Example:

```llvm
$foo = comdat largest
@foo = global i32 2, comdat($foo)
define void @bar() comdat($foo) { ret void }

$foo = comdat any
@foo = global i32 2, comdat        ; same as comdat($foo)
@bar = global i32 3, comdat($foo)
```

Combining sections and comdats can create multiple object-file sections with the same name. Code generation options (e.g. separate sections per function/data) can also create comdats not present in IR.

### 5.7 Named metadata

A named metadata is a module-level list of metadata nodes.

- Operands must be metadata nodes (`!N` or `!{...}`), not metadata strings.
- Name rules match identifiers but with prefix `!`. Quoted names are not allowed, but `\xx` escapes are.

```llvm
!0 = !{!"zero"}
!1 = !{!"one"}
!2 = !{!"two"}
!name = !{!0, !1, !2}
```

---

## 6. Parameter Attributes

### 6.1 Placement

Parameter attributes belong to the function or call site, not to the function type. Functions with different parameter attributes can share a type.

- Return attributes go **before** the result type: `declare signext i8 @f()`.
- Parameter attributes go **after** the parameter type: `i8 zeroext %x`.
- Multiple attributes are separated by spaces.
- They may appear on declarations, definitions and call sites.
- String attributes are allowed: `"key"="value"`, e.g. `i32 "amdgpu-flat-work-group-size"="1,256" %x`.

```llvm
declare i32 @printf(ptr noalias captures(none), ...)
declare i32 @atoi(i8 zeroext)
declare signext i8 @returns_signed_char()
define void @baz(i32 "amdgpu-flat-work-group-size"="1,256" %x)
call i32 @atoi(i8 zeroext %x)
call signext i8 @returns_signed_char()
```

Two kinds:
- **ABI attributes** (e.g. `zeroext`, `inreg`, `byval`, `sret`) change how values are passed. They must match on both declaration and call site, and may not be dropped.
- **Optimisation attributes** (e.g. `noalias`, `nonnull`, `dereferenceable`) add guarantees. They need not match; the intersection applies. They may be dropped freely.

If an integer argument has none of `signext`/`zeroext`/`noext`, the extension is target-specific.

### 6.2 Attribute table

"Ret" = valid on return values. "One" = may be applied to only one parameter.

| Attribute | Meaning |
|---|---|
| `zeroext` | Zero-extend to the ABI width; caller does it for parameters, callee for return values. |
| `signext` | Sign-extend to the ABI width (usually 32 bits); same split of responsibility. |
| `noext` | High bits undefined; no extension needed. Same as default; some targets use it to check that an extension attribute is always present. |
| `inreg` | Target-specific special handling, usually "pass in a register". |
| `byval(<ty>)` | Pointer argument is really passed by value: a hidden copy of `<ty>`'s allocation size is made (like memcpy, padding included). Copy belongs to the caller. Pointer args only; not on return values. Combine with `align` to set the stack slot alignment. |
| `byref(<ty>)` | Gives the pointee type of a pointer arg without implying a copy or stack passing. Pointer is dereferenceable for the type's size. Writes may not be introduced. Not on return values. May use `align`. For ABI only, not to be inferred. |
| `preallocated(<ty>)` | Pass by value where the pointee was already initialised before the call. Argument must come from `llvm.call.preallocated.arg` (non-`musttail`) or be the caller's matching parameter (`musttail`). A non-`musttail` call with this attribute must carry a `"preallocated"` operand bundle; a `musttail` call must not. Type required. May use `align`. |
| `inalloca(<ty>)` | Caller takes the address of outgoing stack arguments. Must be a pointer from an `alloca` marked `inalloca`. Only the last argument; always passed in memory. Not combinable with `inreg`, `nest`, `sret`, `byval`. The allocation must be the most recent live stack allocation when the call is reached. Type required. |
| `sret(<ty>)` | Pointer to the struct that is the source-level return value. Caller guarantees it is valid and aligned. The function must return `void`. Not on return values. |
| `elementtype(<ty>)` | Records a pointer element type for intrinsics. Only on pointer arguments or returns of **intrinsic calls**; not on non-intrinsic calls or on declaration parameters. |
| `align <n>` / `align(<n>)` | Pointer (or every element of a vector of pointers) has this alignment; otherwise poison. Combine with `noundef` for UB instead. `align 1` has no effect except with `byval`/`preallocated`. |
| `noalias` | Memory modified during the call and accessed through this pointer is not accessed through pointers not based on it (like C99 `restrict`). Applies across threads too. On a return value: the function acts like an allocator returning storage disjoint from anything the caller can see. Ret. |
| `captures(...)` | Limits how the callee may capture the pointer (see 6.3 and section 13). Not on return values. |
| `nofree` | The callee cannot free the object through pointers based on this argument. Not on return values. |
| `nofreeobj` | The underlying object cannot be freed during the call by any pointer. On return values: cannot be freed from now on. Implies `nofree` on arguments. Ret. |
| `nest` | Pointer can be removed by trampoline intrinsics. Not on return values. One. |
| `returned` | The function always returns this argument. A hint, not checked. Argument and return types must be valid `bitcast` operands. Not on return values. One. |
| `nonnull` | Pointer is not null (address bits only); otherwise poison. Pointer types only. Combine with `noundef` for UB. Ret. |
| `dereferenceable(<n>)` | Pointer is dereferenceable for `n` bytes at that point (entry, or the call for returns). `n` positive. Implies `noundef`, and implies `nonnull` in addrspace 0 unless `null_pointer_is_valid`. Ret. |
| `dereferenceable_or_null(<n>)` | Either null or dereferenceable for `n` bytes. In addrspace 0 exactly one holds; elsewhere at least one. Pointer types only. Ret. |
| `swiftself` | The Swift self/context parameter. Not on return values. One. |
| `swiftasync` | The Swift async context parameter; creates a target-specific extended frame record. Not on return values. One. |
| `swifterror` | Swift error handling. On pointer-to-pointer parameters or pointer-sized allocas. Argument must come from a `swifterror` alloca or the caller's `swifterror` parameter. Such values may only be loaded, stored, or passed as `swifterror`. Changes the ABI. Not on return values. One. |
| `immarg` | Parameter must be an immediate integer or FP constant (no `undef`, no constant expressions). Only on intrinsic declarations; not on call sites. |
| `noundef` | Value contains no undef or poison bits (padding excluded), otherwise UB. Becomes an ABI attribute under memory sanitizer. Ret. |
| `nofpclass(<mask>)` | Value is not in the listed FP classes; otherwise poison. For FP scalars, vectors, and supported aggregates. Independent of the FP environment. Ret. |
| `alignstack(<n>)` | Alignment for the stack slot during calling-convention lowering. Target rules may override. Ret. |
| `allocalign` | This integer parameter is the alignment of the block returned. Result is aligned to at least this or null. Non-power-of-2 allowed only if result is null. |
| `allocptr` | This parameter is the pointer the allocator works on (realloc-like: invalidated on success; free-like: always invalidated). |
| `readnone` | The function does not dereference this pointer argument. UB if it does. |
| `readonly` | The function does not write through this pointer argument. UB if it does. |
| `writeonly` | The function may write but not read through this pointer (understood like `memory(write)`: unobservable reads are fine). |
| `writable` | With a dereferenceability attribute, the first N bytes are as-if loaded and stored back on entry, so spurious stores on entry are allowed. Not combinable with `readnone`, `readonly`, or a `memory` attribute lacking `argmem: write`. |
| `initializes((Lo1, Hi1), ...)` | The function writes every byte in `[%p+Lo, %p+Hi)` before returning normally and does not read them before writing. Ranges are 64-bit signed, ascending, non-overlapping, non-adjacent; list non-empty. |
| `dead_on_unwind` | If the call unwinds, the caller does not care about memory written through this pointer. Not on return values. |
| `dead_on_return` / `dead_on_return(<n>)` | Memory pointed to is dead after the call returns or unwinds (optionally only the first `n` bytes). Implies `dead_on_unwind` (for the same range). Not on return values. |
| `range(<ty> <a>, <b>)` | Value lies in `[a, b)` (wrapping allowed); otherwise poison. `<ty>` must match the scalar type. Integers and integer vectors (element-wise). `0,0` is the empty range; otherwise `a != b`. Ret. |

Example of `range`: `range(i32 0, 10)`.

#### `initializes` formal semantics

Each byte in the range starts "not initialised" on entry. On an access through a pointer based on the argument to an uninitialised byte:
- non-volatile, non-atomic store: mark it initialised;
- volatile or atomic store: UB;
- load: returns poison.
On normal return, any byte still not initialised is written with `undef`. On `byval` arguments it refers to the callee's copy. `writable` and `dereferenceable` do not imply `initializes`; `initializes` does not imply `writeonly`.

#### `nofree`, `noalias`, `nofreeobj` relationships

- `nofree` + `noalias` does not imply `nofreeobj`.
- `nofree` + `noalias` + `dereferenceable` does imply `nofreeobj`.

### 6.3 `captures(...)` grammar

Components:

| Component | Meaning |
|---|---|
| `none` | Nothing captured. |
| `address` | The integer address. |
| `address_is_null` | Only whether the address is null (subset of `address`). |
| `provenance` | Ability to read and write through the pointer after the call. |
| `read_provenance` | Ability to only read through it after the call (subset of `provenance`). |

Components may be restricted to a location. Supported locations: `ret` (the return value) and the default (everything else). Syntax inferred from the examples:

```
captures(none)
captures(address, provenance)          ; same as omitting the attribute
captures(address)
captures(address_is_null)
captures(address, read_provenance)
captures(ret: address, provenance)
captures(address_is_null, ret: address, provenance)
```

**Not documented:** A formal grammar for `captures`. From the examples: an optional list of default components, then optionally `ret:` followed by components for the return location.

### 6.4 `nofpclass` mask names

Names may be combined, space-separated, e.g. `nofpclass(nan pinf nzero)` = mask 547.

| Name | Class | Bits |
|---|---|---|
| `nan` | any NaN | 3 |
| `inf` | +/- infinity | 516 |
| `norm` | +/- normal | 264 |
| `sub` | +/- subnormal | 144 |
| `zero` | +/- 0 | 96 |
| `all` | all values | 1023 |
| `snan` | signaling NaN | 1 |
| `qnan` | quiet NaN | 2 |
| `ninf` | negative infinity | 4 |
| `nnorm` | negative normal | 8 |
| `nsub` | negative subnormal | 16 |
| `nzero` | negative zero | 32 |
| `pzero` | positive zero | 64 |
| `psub` | positive subnormal | 128 |
| `pnorm` | positive normal | 256 |
| `pinf` | positive infinity | 512 |

Invariants: `is.fpclass(nofpclass(m) %x, m)` is false; with `~m` it is true; `nofpclass(all)` is always poison.

**Not documented:** Whether a raw integer mask may be written. The canonical printing form for combined masks is also not stated.

---

## 7. Function-Level Properties

### 7.1 Garbage collector name

```llvm
define void @f() gc "name" { ... }
```

A string naming a GC strategy (built-in or from a plugin). LLVM contains no collector; this only changes code generation.

### 7.2 Prefix data

`prefix <Constant>`: data emitted immediately before the function entry point. The function symbol points just past it, so it can be read at index -1:

```llvm
define void @f() prefix i32 123 { ... }
%a = getelementptr inbounds i32, ptr @f, i32 -1
%b = load i32, ptr %a
```

Laid out like a global initializer of that type. The start of the prefix data is aligned, so the entry point may not be. A function may have prefix data and no body; this acts like `available_externally` (data visible to optimisers, not emitted).

### 7.3 Prologue data

`prologue <Constant>`: bytes inserted before the function body (for hot-patching and instrumentation). They must decode, for the target, to instructions that jump to just after the prologue data with no other visible effect.

```llvm
define void @f() prologue i8 144 { ... }            ; x86 nop
%0 = type <{ i8, i8, ptr }>
define void @f() prologue %0 <{ i8 235, i8 8, ptr @md}> { ... }   ; jmp .+10
```

A function may have prologue data and no body, with `available_externally`-like meaning.

### 7.4 Personality function

`personality <Constant>` names the function used for exception handling.

**Not documented:** This section gives no further detail (allowed constant forms, required type).

### 7.5 Attribute groups

Module-level sets of attributes, referenced by `#N`. An object may reference several groups; their attributes are merged.

```llvm
attributes #0 = { alwaysinline alignstack=4 }
attributes #1 = { "no-sse" }
define void @f() #0 #1 { ... }
```

**Draconian note:** Inside an attribute group, `alignstack` is written `alignstack=4`, whereas on a function it is written `alignstack(4)`. The parser must accept both depending on context. **Not documented:** whether other integer attributes also use `=` in groups.

**Draconian note:** String attributes take the forms `"key"` and `"key"="value"`.

---

## 8. Function Attributes

Function attributes belong to the function, not its type. They are keywords or strings written after the parameter list, separated by spaces. Many may also appear on call sites.

```llvm
define void @f() noinline { ... }
define void @f() alwaysinline optsize { ... }
define void @f() "no-sse" { ... }
```

### 8.1 Keyword attributes

| Attribute | Meaning |
|---|---|
| `alignstack(<n>)` | Force-align the stack pointer in prologue/epilogue. `n` is a power of two. |
| `allockind("KIND")` | Describes an allocator. KIND is a comma-separated list (see 8.3). |
| `allocsize(<EltSizeParam>[, <NumEltsParam>])` | Returns at least `arg[a]` (or `arg[a] * arg[b]`) bytes, or null. Zero-based parameter indices; referenced params must be integers. |
| `alwaysinline` | Inliner should inline whenever possible, ignoring size thresholds. |
| `builtin` | At a call site: treat the callee as a builtin even if declared `nobuiltin`. Only on direct calls to `nobuiltin` functions. |
| `cold` | Rarely called. Blocks post-dominated by a call to it are cold. |
| `convergent` | Function is convergent (see the convergence document). On a call, treat the call as convergent. Calling `llvm.experimental.convergence.entry` from a non-convergent function is an error. |
| `disable_sanitizer_instrumentation` | No sanitizer instrumentation at all; overrides `sanitize_*`. |
| `fn_ret_thunk_extern` | Replace returns with jumps to an external thunk (on X86, `__x86_return_thunk`). |
| `hot` | Hot spot; optimise harder and place in a hot text subsection. Overrides profile data. |
| `hybrid_patchable` | ARM64EC only: may be patched at run time; an x86-64 thunk is generated. |
| `inlinehint` | Source asked for inlining (e.g. C `inline`). Hint only. |
| `jumptable` | Add to a jump-instruction table; address-taken uses refer to the table entry. Must also be `unnamed_addr`. |
| `memory(...)` | Memory effects (see 8.2). |
| `minsize` | Minimise code size even at a speed cost. Incompatible with `optdebug` and `optnone`. |
| `naked` | No prologue/epilogue. Arguments cannot be referenced via IR values. |
| `nobuiltin` | Do not treat the callee as a builtin (no replacement by known semantics) unless the call site has `builtin`. Valid on call sites, declarations and definitions. |
| `nocallback` | The function only re-enters the caller's module by return or exception, never by callback, external call, `longjmp` etc. A module-level hint dropped during linking; no effect on functions defined in this module. |
| `nodivergencesource` | A call to it is not a source of divergence for uniformity analysis. |
| `noduplicate` | Calls to it may move within the function but not be duplicated. |
| `nofree` | Does not free any allocation that existed before the call (directly or via synchronisation). May free its own allocations. |
| `noimplicitfloat` | No implicit floating-point or SIMD code (no vectorisation, no FP/vector memcpy/memset lowering). Explicit FP/vector IR still produces such code. |
| `noinline` | Never inline. Not allowed with `alwaysinline`. |
| `noipa` | No interprocedural analysis of the body (as if in an opaque module). Attributes still respected. Does not stop inlining/outlining; add `noinline` and `nooutline` for that. |
| `nomerge` | Calls must not be merged (e.g. by tail merging). |
| `nonlazybind` | Suppress lazy symbol binding. |
| `noprofile` | No instrumentation-based profiling. Also blocks inlining between functions that differ in this attribute. |
| `skipprofile` | No instrumentation-based profiling, but does not restrict inlining. |
| `noredzone` | Do not use a red zone. |
| `noreturn` | Never returns normally. Returning is UB. May still unwind. |
| `norecurse` | Never appears in a cycle of the dynamic call graph. |
| `willreturn` | Either UB, or returns control to the existing call stack. May still unwind. Implies `mustprogress`. |
| `nosync` | Introduces no synchronizes-with edges (no ordered atomics stronger than `monotonic`, no convergent synchronisation). Synchronising is UB. May be combined with `convergent`. |
| `nounwind` | Never raises an exception (UB if it does). May still trap or raise asynchronous exceptions (e.g. SEH). |
| `nosanitize_bounds` | No bounds-checking sanitizer instrumentation. |
| `nosanitize_coverage` | No SanitizerCoverage instrumentation. |
| `null_pointer_is_valid` | Address 0 in addrspace 0 is a valid address in this function. |
| `optdebug` | Optimise while preserving debug info. Incompatible with `minsize`, `optsize`, `optnone`. |
| `optforfuzzing` | Optimise for maximum fuzzing signal. |
| `optnone` | Most passes skip it (IPO may still analyse, but not change the signature). Requires `noinline`. Not with `alwaysinline`, `minsize`, `optsize`, `optdebug`. Only `alwaysinline` callees may be inlined into it. |
| `optsize` | Keep size low without much speed cost. Incompatible with `optdebug` and `optnone`. |
| `returns_twice` | May return twice (like `setjmp`). Disables some caller optimisations. |
| `safestack` | SafeStack protection. Sticky when inlined into a function without it or with `ssp`/`sspstrong`/`sspreq`. |
| `sanitize_address` | AddressSanitizer enabled. |
| `sanitize_memory` | MemorySanitizer enabled. |
| `sanitize_thread` | ThreadSanitizer enabled. |
| `sanitize_hwaddress` | HWAddressSanitizer enabled. |
| `sanitize_memtag` | MemTagSanitizer (Armv8 MTE) enabled. |
| `sanitize_realtime` | RealtimeSanitizer enabled. |
| `sanitize_realtime_blocking` | RealtimeSanitizer errors if this is called from a `sanitize_realtime` function. Incompatible with `sanitize_realtime`. |
| `sanitize_alloc_token` | Implicit allocation token instrumentation enabled. |
| `speculative_load_hardening` | Enable Speculative Load Hardening (Spectre v1). Sticky: inlining it into a caller gives the caller the attribute. |
| `speculatable` | No effects besides computing the result, and no UB. Only on functions and declarations, not call sites. |
| `ssp` | Stack protector using the default heuristic (char arrays > `ssp-buffer-size`, default 8; aggregates containing them; variable or large `alloca`). Not carried over when inlined. |
| `sspstrong` | Stack protector with the strong heuristic (any array, aggregate containing an array, any `alloca`, address-taken locals). Overrides `ssp`. Upgrades an `ssp` caller when inlined. |
| `sspreq` | Always emit a stack protector. Overrides `ssp` and `sspstrong`. Upgrades `ssp`/`sspstrong` callers when inlined. |
| `strictfp` | Called from a strict-FP scope: no assumptions about rounding mode or FP status flags; no new trapping FP instructions. |
| `denormal_fpenv(...)` | Denormal handling for the default FP environment (see 8.4). |
| `uwtable` / `uwtable(sync)` / `uwtable(async)` | An unwind table entry is required. `sync` = normal tables, `async` = instruction-precise. Plain `uwtable` = `uwtable(async)`. |
| `nocf_check` | No control-flow protection check for this entity (disables `-fcf-protection`). |
| `shadowcallstack` | ShadowCallStack enabled. x86_64 only per the reference. |
| `mustprogress` | Must return, unwind, or interact with the environment observably. Side-effect-free loops may be assumed to terminate. |
| `vscale_range(<min>[, <max>])` | `vscale` is a power of two in `[min, max]`. `min` > 0 and power of two; `max` power of two >= min, or 0 for unbounded. `vscale_range(<v>)` sets both. |
| `nooutline` | Outlining passes must not modify the function. |
| `nocreateundeforpoison` | If no argument is undef/poison, the result (before return attributes) is not undef/poison; otherwise UB. |

Incompatibility and requirement rules for the verifier:
- `noinline` and `alwaysinline` are exclusive.
- `optnone` requires `noinline`; excludes `alwaysinline`, `minsize`, `optsize`, `optdebug`.
- `minsize` and `optsize` each exclude `optdebug` and `optnone`.
- `jumptable` requires `unnamed_addr`.
- `sanitize_realtime_blocking` excludes `sanitize_realtime`.
- `speculatable` is not valid on call sites.
- `builtin` only on call sites (direct calls to `nobuiltin` functions).

### 8.2 `memory(...)`

Specifies the possible memory effects of a function or call.

Access kinds:

| Kind | Meaning |
|---|---|
| `none` | No reads or writes observable outside. Allocas and constant globals are always accessible. |
| `read` | Only reads. Writing is immediate UB, even writing back the same value. |
| `write` | Only writes are observable. Internal reads after writes are fine; reading before writing gives poison. |
| `readwrite` | Any access. |

Locations:

| Location | Meaning |
|---|---|
| `argmem` | Accesses based on pointer arguments. |
| `inaccessiblemem` | Memory not accessible from the current module. |
| `errnomem` | The `errno` variable. |
| `target_mem0`, `target_mem1` | Target-specific state (AArch64: ZT0 and ZA of SME; X86: `target_mem0` is AMX tiles and config). |
| (default) | A kind with no location prefix applies to every location not listed explicitly, including globals and captured pointers. |

Syntax: `memory(<default kind>?, <loc>: <kind>, ...)`. Examples:

```
memory(none)
memory(read)
memory(write)
memory(readwrite)
memory(argmem: read)
memory(argmem: read, inaccessiblemem: write)
memory(argmem: read, errnomem: write)
memory(read, argmem: readwrite)
memory(readwrite, argmem: none)
```

- If absent, `memory(readwrite)` is implied.
- Effects of a call = `CallSiteEffects & (FunctionEffects | OperandBundleEffects)`.

### 8.3 `allockind` values

| Value | Meaning |
|---|---|
| `"alloc"` | Returns a new block or null. |
| `"realloc"` | Returns a new block or null; contents up to the smaller size are copied from the `allocptr` argument, which is invalidated even if the address is unchanged. |
| `"free"` | Frees the `allocptr` block. Must return `void`. |
| `"uninitialized"` | New memory is uninitialised. |
| `"zeroed"` | New memory is zeroed. |
| `"aligned"` | Result aligned per the `allocalign` parameter. |

`alloc`, `realloc` and `free` are mutually exclusive. The other options are invalid for `free`. Example: `allockind("alloc,zeroed")`.

Calls to `allockind` functions may be elided (served from a virtual allocator) even if they have side effects. When several calls touch the same allocation, only `alloc`/`free` pairs with the same `"alloc-family"` may be elided.

### 8.4 `denormal_fpenv(...)`

Mode values: `ieee`, `preservesign`, `positivezero`, `dynamic`.

- Base form: `<output>|<input>`. The first is how results are flushed; the second is how denormal inputs are treated.
- If only one value is given, it applies to both (compatibility with old bitcode).
- An optional second pair prefixed `float:` overrides the mode for `float` and vectors of `float`.
- Default when absent: `ieee|ieee`.
- Output `preservesign`/`positivezero`: denormal results may (not must) be flushed to zero with the given sign treatment.
- Input `preservesign`/`positivezero`: denormal inputs must be treated as zero.
- `dynamic`: determined by the run-time FP environment; avoid transformations relying on denormal behaviour.
- The attribute does not set the mode; platform code must.
- Per the reference, honoured by AMDGPU and NVPTX for the per-type override.

Examples:

```
denormal_fpenv(preservesign)
denormal_fpenv(float: preservesign)
denormal_fpenv(dynamic, float: preservesign|ieee)
denormal_fpenv(ieee|ieee, float: preservesign|preservesign)
denormal_fpenv(ieee|dynamic, float: preservesign|ieee)
```

### 8.5 String function attributes

| Attribute | Meaning |
|---|---|
| `"alloc-family"="FAMILY"` | The allocator family, e.g. `"malloc"`, `"_Znwm"`, `"_ZnwmSt11align_val_t"`. Matching calls in a family may be optimised together. |
| `"alloc-variant-zeroed"="FUNCTION"` | Names an equivalent function returning zeroed memory (same family, same arguments, `zeroed` kind). |
| `"dontcall-error"` | Emit an error if a call survives optimisation. Optional string value is a note. Call sites may carry `srcloc` metadata. |
| `"dontcall-warn"` | Same, but a warning. |
| `"frame-pointer"` | `"none"` (default; may be eliminated), `"reserved"` (register either holds a valid frame record or is untouched), `"non-leaf"` (keep if the function calls others), `"all"` (always keep). |
| `"no-inline-line-tables"` | When true, inlined code takes the call site's source location. |
| `no-jump-tables` | When true, disable jump/lookup tables from switch lowering. |
| `indirect-tls-seg-refs` | Do not use direct TLS access via segment registers. |
| `"patchable-function"` | Only legal value: `"prologue-short-redirect"` (first instruction large and aligned enough to be replaced atomically by a short jump; x86-64 only). |
| `"patchable-function-prefix"` | Number of NOPs before the entry label. |
| `"patchable-function-entry"` | Number of NOPs after the entry label, before the prologue. |
| `"patchable-function-entry-section"` | Section recording patchable entries. Default `__patchable_function_entries`. |
| `"tail-pad-to-size"` | Minimum function size in bytes; pad at the end. |
| `"tail-pad-value"` | Byte used for tail padding; default 0. |
| `"probe-stack"` | Name of the stack probe function. On inlining, the caller's value wins; if the caller has none, the callee's is used. |
| `"stack-probe-size"` | Guard region size; default 4096. On inlining, the lower value wins; if the caller has none, the callee's is used. |
| `"no-stack-arg-probe"` | Disable ABI-required stack probes. |
| `"thunk"` | Delegates to another function via a tail call. Its prototype must not be used for optimisation. |
| `"warn-stack-size"="<threshold>"` | Warn if the frame exceeds this many bytes. Non-negative, below `UINT_MAX`. **Not documented:** which value wins when linking definitions that differ. |
| `"modular-format"="<type>,<string_idx>,<first_arg_idx>,<modular_impl_fn>,<impl_name>,<aspects...>"` | The implementation is modular on a format-string argument; the compiler may redirect to `<modular_impl_fn>` and reference `<impl_name>_<aspect>` for needed aspects. First three fields as in C's `format` attribute. Aspects: `fixed` (ISO 18037 fixed-point argument), `float` (floating-point argument). |

Other string attributes are mentioned without definition: `"target-features"` and `"target-cpu"` (referenced by module asm), and `"no-sse"` (an example of a target-dependent attribute).

**Not documented:** The reference lists `no-jump-tables` and `indirect-tls-seg-refs` without quotes, but `no-jump-tables` is "set to true" and both contain hyphens, which a bare keyword cannot. Draconian should treat them as string attributes (`"no-jump-tables"="true"`, `"indirect-tls-seg-refs"`). Similarly, the value forms of `"no-inline-line-tables"`, `"patchable-function-prefix"`, `"patchable-function-entry"`, `"tail-pad-to-size"`, `"tail-pad-value"` and `"no-stack-arg-probe"` are not spelled out; values are presumably decimal strings.

**Draconian note:** Unknown string attributes must be preserved verbatim; they carry target-specific meaning.

---

## 9. Call-Site-Only Attributes

| Attribute | Meaning |
|---|---|
| `vector-function-abi-variant` | On a `call` only (not `invoke` or `callbr`). A comma-separated set of mangled vector-variant names. The compiler may use any of them. Each named variant must be declared in the module. |
| `preallocated(<ty>)` | Required on calls to `llvm.call.preallocated.arg`; not allowed on other calls. |

Mangled name grammar for vector variants:

```
_ZGV<isa><mask><vlen><parameters>_<scalar_name>[(<vector_redirection>)]

<isa>        := b | c | d | e      ; X86 SSE, AVX, AVX2, AVX512
              | n | s              ; Armv8 Advanced SIMD, SVE
              | __LLVM__           ; internal LLVM vector ISA
<mask>       := M | N              ; mask | no mask
<vlen>       := number | x         ; lanes | vector-length agnostic
<parameters> := v                  ; vector
              | l | l <number>     ; linear
              | R | R <number>     ; linear, ref modifier
              | L | L <number>     ; linear, val modifier
              | U | U <number>     ; linear, uval modifier
              | ls <pos> | Rs <pos> | Ls <pos> | Us <pos>  ; runtime linear variants
              | u                  ; uniform
<scalar_name>        := name of the scalar function
<vector_redirection> := optional custom vector function name
```

**Not documented:** How `vector-function-abi-variant` is spelled as an attribute (it contains hyphens, so presumably a string attribute `"vector-function-abi-variant"="..."`).

---

## 10. Global Variable Attributes

Attributes on a global variable are grouped into a single attribute group. In the global variable grammar they appear as comma-prefixed keywords.

| Attribute | Meaning |
|---|---|
| `no_sanitize_address` | No AddressSanitizer instrumentation for this global. |
| `no_sanitize_hwaddress` | No HWAddressSanitizer instrumentation. |
| `sanitize_memtag` | Apply AArch64 MTE tagging. Suppresses some optimisations such as GlobalMerge. May be removed if tagging is impossible (e.g. TLS). |
| `sanitize_address_dyninit` | With AddressSanitizer, check for ODR violations; for dynamically initialised C++ globals. |

`toc-data` (XCOFF) is also mentioned in the global variables section.

**Not documented:** How a global's attribute group is spelled in text (e.g. whether `#N` is allowed after a global), and the textual form of `toc-data`.

---

## 11. Operand Bundles

Operand bundles are tagged lists of SSA values (or metadata strings) attached to `call` and `invoke`. Unlike metadata, dropping them changes meaning. They are part of the call, not the callee's signature.

**Syntax:**

```
operand bundle set ::= '[' operand bundle (, operand bundle )* ']'
operand bundle     ::= tag '(' [ bundle operand ] (, bundle operand )* ')'
bundle operand     ::= SSA value | metadata string
tag                ::= string constant
```

Example: `call void @y() [ "deopt"(i32 10), "unknown"(ptr null) ]`

Semantics of an unknown bundle tag (the most any bundle may do):
- Its operands escape in unknown ways before control reaches the callee.
- The call has unknown read/write effects on the heap on entry and exit, even if the callee has a `memory` attribute, unless call-site attributes say otherwise.
- It cannot change the callee's implementation.

Known tags:

| Tag | Rules |
|---|---|
| `"deopt"` | Alternate "safe" continuation for deoptimisation. At most one per call. Makes the call at least read-only; reads all pointer operands and the whole heap. Does not capture operands except during deoptimisation. When inlining, the caller's deopt operands are prepended to each inlined call's deopt operands. |
| `"funclet"` | Call is inside a given funclet EH pad. At most one; exactly one operand. If funclet pads are entered but not exited, a call/invoke with no funclet bundle (other than to a `nounwind` intrinsic) or with the wrong pad is UB. With no pad entered, any funclet bundle is UB. |
| `"gc-transition"` | Transition between GC strategies. Arbitrary values passed to transition code; available before and after the callee. |
| assume bundles | On `llvm.assume`, whose condition must be `i1 true`. See table below. |
| `"preallocated"` | At most one; exactly one operand, a token from `@llvm.call.preallocated.setup`. The call must not adjust the stack itself. |
| `"gc-live"` | Only on `gc.statepoint`. Must list every GC pointer that may need relocating. |
| `"clang.arc.attachedcall"` | The call is followed by a marker and an ObjC runtime call. Operand: pointer to `@objc_retainAutoreleasedReturnValue` or `@objc_unsafeClaimAutoreleasedReturnValue`. Ignored if the return type is `void`. |
| `"ptrauth"` | Pointer authentication. Defined in a separate document. |
| `"kcfi"` | On an indirect call: precede with a type check against the target's type identifier, e.g. `["kcfi"(i32 1234)]`. |
| `"convergencectrl"` | Only on convergent operations; exactly one token operand. |
| `"deactivation-symbol"` | AArch64 only. On a call to a normal function with `notail` and a `ptr` first argument and return, or to `llvm.ptrauth.sign`/`llvm.ptrauth.auth`. If the symbol is defined, the instruction returns its first argument instead. |

Assume bundle tags (on `llvm.assume`):

| Tag | Meaning |
|---|---|
| `"align"(ptr %p, i64 %align)` / `"align"(ptr %p, i64 %align, i64 %offset)` | Like `align(%align)` on `%p` (or `%p - %offset`). `%align` may be non-power-of-2 or zero; then `%p` must be all-zero. |
| `"cold"()` | Like `cold`. |
| `"dereferenceable"(ptr %p, i64 %size)` | Like `dereferenceable`; size 0 allowed (then no `nonnull`). |
| `"dereferenceable_or_null"(ptr %p, i64 %size)` | Like `dereferenceable_or_null`; size 0 allowed. |
| `"ignore"(...)` | Means nothing. |
| `"nonnull"(ptr %p)` | Like `nonnull`. |
| `"noundef"(any_type %v)` | Like `noundef`. |
| `"separate_storage"(ptr %p1, ptr %p2)` | No pointer based on one aliases any pointer based on the other. |

Assume bundle operands may be dynamic values. Note the example `"align"(ptr %val, i32 8)` uses `i32` although the signature says `i64`, so integer width is apparently flexible. **Not documented:** the exact permitted integer types.

**Draconian note (verifier):** at most one each of `"deopt"`, `"funclet"`, `"preallocated"`; `"funclet"` and `"preallocated"` take exactly one operand; `"convergencectrl"` takes exactly one token; `"gc-live"` only on `gc.statepoint`; assume calls with bundles must use `i1 true`.

---

## 12. Module-Level Directives

### 12.1 Module-level inline assembly

```llvm
module asm "inline asm code goes here"
module asm "more can go here"

module asm(target_features: "+foo", target_cpu: "bar")
    "inline asm code goes here"
    "more can go here"
```

- Consecutive string literals are joined with newlines.
- Non-printable characters use `\xx` escapes.
- Optional properties: only `target_features` and `target_cpu`, meaning the same as the `"target-features"` and `"target-cpu"` function attributes.
- Consecutive blocks with identical properties are concatenated into one.
- The text must be parseable by LLVM's integrated assembler (unless disabled).

### 12.2 Data layout

```llvm
target datalayout = "layout specification"
```

The specification is a list of items separated by `-`. Each starts with a letter.

| Specifier | Meaning |
|---|---|
| `E` | Big-endian. |
| `e` | Little-endian. |
| `S<size>` | Natural stack alignment in bits. Default "unspecified" (`S0`), which does not limit alignment promotion. |
| `P<as>` | Program (code) address space. Default 0. |
| `G<as>` | Default address space for newly created globals (affects passes, not parsing: textual globals with no address space are in 0). Default 0. |
| `A<as>` | Address space of `alloca`. Default 0. |
| `p[<flags>][<as>][(<name>)]:<size>:<abi>[:<pref>[:<idx>]]` | Pointer properties for address space `<as>` (default 0; range [1, 2^24) when given). `<size>`: bits in the representation. `<idx>`: index width for GEP, <= size, default = size; also the address width. Flags: `u` unstable representation, `e` external state, `z` null is all zeros, `o` null is all ones (at most one of `z`/`o`; default all zeros). `<name>`: optional unique name in parentheses; may not be `A`, `G` or `P`. |
| `i<size>:<abi>[:<pref>]` | Integer alignment for width `<size>` in [1, 2^24). `i8` must have `<abi>` = 8. |
| `v<size>:<abi>[:<pref>]` | Vector alignment for total width `<size>` in [1, 2^24). |
| `ve` | Vectors are element-aligned by default instead of naturally aligned. |
| `f<size>:<abi>[:<pref>]` | Floating-point alignment. 32 and 64 always supported; 80 and 128 on some targets. Range [1, 2^24). |
| `a:<abi>[:<pref>]` | Aggregate alignment. `<abi>` may be 0, meaning one byte. |
| `F<type><abi>` | Function pointer alignment. `i`: independent of function alignment, a multiple of `<abi>`. `n`: a multiple of the function's explicit alignment and of `<abi>`. |
| `m:<mangling>` | Symbol mangling style (table below). Symbols starting with `\01` are passed through without the escape. |
| `n<size1>:<size2>:...` | Native integer widths, e.g. `n32`, `n32:64`, `n8:16:32:64`. |
| `ni:<as0>:<as1>:...` | Marks address spaces as unstable (non-integral). Address space 0 is not allowed. **Deprecated:** kept for compatibility; use the `p` flags instead. |

Mangling styles:

| Code | Style |
|---|---|
| `e` | ELF: private symbols get `.L`. |
| `l` | GOFF: private symbols get `@`. |
| `m` | Mips: private symbols get `$`. |
| `o` | Mach-O: private symbols get `L`; others get `_`. |
| `x` | Windows x86 COFF: C symbols get `_`; `__stdcall`, `__fastcall`, `__vectorcall` get `@N` suffix (N = bytes of parameters); C++ names starting with `?` are untouched. |
| `w` | Windows COFF: like `x` but no `_` on C symbols. |
| `a` | XCOFF: private symbols get `L..`. |

Alignment value rules:
- `<abi>` is the minimum alignment for a type to be "aligned". It is used for default load/store alignment, struct layout, allocation sizes (hence GEP offsets), and the underalignment threshold.
- `<pref>` is optional, must be >= `<abi>`, and is used mainly for allocas and globals. If omitted, its leading `:` is omitted too and it equals `<abi>`.
- Unless stated otherwise, alignments are in bits, in [1, 2^16), and must be 8 * 2^N.

Defaults (applied first, then overridden by the string):

| Default | Meaning |
|---|---|
| `e` | little endian |
| `p:64:64:64` | 64-bit pointers, 64-bit aligned |
| `p[n]:64:64:64` | other address spaces same as 0 |
| `S0` | stack alignment unspecified |
| `i8:8:8` | |
| `i16:16:16` | |
| `i32:32:32` | |
| `i64:32:64` | ABI 32, preferred 64 |
| `f16:16:16` | |
| `f32:32:32` | |
| `f64:64:64` | |
| `f128:128:128` | |
| `v64:64:64` | |
| `v128:128:128` | |
| `a:0:64` | aggregates 64-bit aligned (as stated) |

Type alignment lookup:
1. Use an exact match if present.
2. For an integer type without a match, use the smallest larger integer spec. If none is larger, use the largest. (Defaults: `i7` uses `i8`; `i65` and `i256` use `i64`.)

**Not documented:** Lookup rules for vector and float sizes with no exact match.

**Not documented / inconsistent:** The `a:0:64` default sets ABI 0 (one byte) and preferred 64; the reference's own description says "aggregates are 64-bit aligned".

The data layout must match what the code generator expects. Mid-level optimisers rely on it. Without one, the defaults are used.

**Draconian note:** Parse the data layout into a structured value, seeded with the defaults above. The exact original string should be kept for printing.

### 12.3 Target triple

```llvm
target triple = "x86_64-apple-macosx10.7.0"
```

Fields separated by `-`. Canonical forms:

```
ARCHITECTURE-VENDOR-OPERATING_SYSTEM
ARCHITECTURE-VENDOR-OPERATING_SYSTEM-ENVIRONMENT
```

Passed to the backend to select the target. Tools may override it (e.g. `-mtriple`).

### 12.4 Use-list order directives

Record the in-memory order of a value's use-list so it can be rebuilt. They do not change semantics.

```
uselistorder <ty> <value>, { <order-indexes> }
```

- `<order-indexes>` is a comma-separated permutation applied to the value's uses.
- May appear at global scope or inside a function.
- Inside a function, they must come after the terminator of the last basic block.

```llvm
define void @foo(i32 %arg1, i32 %arg2) {
entry:
  ; ...
bb:
  ; ...
  uselistorder i32 %arg1, { 1, 0, 2 }
  uselistorder label %bb, { 1, 0 }
}

uselistorder ptr @global, { 1, 2, 0 }
uselistorder i32 7, { 1, 0 }
uselistorder i32 (i32) @bar, { 1, 0 }
```

**Not documented:** The exact sort semantics (whether index i gives the new position of use i). Also the `uselistorder_bb` form, if any, is not described here.

### 12.5 Source filename

```llvm
source_filename = "/path/to/source.c"
```

The original module identifier (typically the source file). Preserved through IR and bitcode. Used to build unique global identifiers for local functions in profile data.

---

## 13. Non-Integral Pointers

**Experimental:** the reference marks non-integral pointers as work in progress.

An "integral" pointer's bits are just its address. A "non-integral" pointer has at least one of these properties, set per address space in the data layout (`p` flags):

| Property | Data layout flag | Meaning |
|---|---|---|
| Non-address bits | (implied by representation size > index/address width) | The bits include target metadata. Cannot build a valid pointer from an address alone unless the extra bits are recreated. Example: AMDGPU 160-bit buffer descriptors. |
| Unstable representation | `u` (or legacy `ni`) | Bit pattern may change at any time (e.g. moving GC). |
| External state | `e` | Extra state stored outside the pointer bits (e.g. CHERI validity tag, out-of-band bounds tables). |

**Not documented:** Exactly how "non-address bits" is expressed in the data layout; it appears to follow from `<size>` exceeding `<idx>`.

Rules for **unstable** pointers:
- `inttoptr`/`ptrtoint` work as usual but two identical casts may give different results.
- Optimisers must not insert new dynamic `inttoptr`/`ptrtoint` casts (or similar intrinsics like `llvm.ptrmask`).
- `ptrtoint(v) - ptrtoint(v) == 0` need not hold.
- Alignment facts must hold for every possible representation.

Rules for pointers with **external state**:
- If not also unstable, `ptrtoint` is deterministic and may be inserted.
- `inttoptr` does not recreate the external state; assume the result is not dereferenceable.
- `ptrtoint` returns only in-band bits.
- Loads, stores, `llvm.memcpy` and `llvm.memmove` of such pointers carry the external state.
- External bits are not counted in the data layout size.
- A load/store/memcpy of such pointers must not be converted into an integer or byte access of the same width.

---

## 14. Memory Semantics

### 14.1 Allocated objects

An allocated object (memory object) is a region reserved by an allocation: `alloca`, heap allocation calls, global variable definitions. Its bytes may only be accessed through pointers based on the allocation; otherwise UB.

Rules (else UB):
- No object crosses the unsigned address-space boundary (including the one-past-the-end pointer).
- Object size is non-negative and at most the largest signed value of the index type.

Objects created by operations LLVM recognises cannot change size. `realloc` creates a new object; old pointers cannot access it even at the same address. Objects created by other means (e.g. `mmap`) may grow to the right only, keeping existing pointers valid. Objects never grow left, shrink, or have holes.

### 14.2 Object lifetime

An object is alive from allocation until deallocation. Accessing a dead object is UB, but non-dereferencing operations (`getelementptr`, `ptrtoint`, `icmp`) still give valid results. Stack object lifetime can be set by `llvm.lifetime.start` and `llvm.lifetime.end`.

Exception: loading from a stack object outside its lifetime returns poison (not UB). Storing is still UB.

### 14.3 Pointer aliasing rules

A memory access must use a pointer associated with the accessed address range, else UB.

A pointer is associated with addresses as follows:
- It inherits the addresses of any value it is based on.
- A global variable's address is associated with its storage.
- An allocation result is associated with the allocated storage.
- Null in the default address space is associated with no address.
- `undef` in any address space is associated with no address.
- A non-zero integer constant, or a pointer returned from a function not defined in LLVM, may be associated with ranges allocated outside LLVM. Such ranges never overlap LLVM-allocated ranges.

"Based on":
- A scalar `getelementptr` result is based on its pointer operand.
- Lane `l` of a vector `getelementptr` result is based on lane `l` of its pointer-vector operand.
- A `bitcast` result is based on its operand.
- An `inttoptr` result is based on every pointer that contributed to computing its integer value.
- "Based on" is transitive.

Memory has no type. A load's type only gives size, alignment and interpretation. So type-based alias analysis (TBAA) does not apply to plain IR; it needs metadata.

### 14.4 Pointer capture

A call may capture two parts of a pointer passed to it (as an argument or stored in memory before the call):

- **Address**: the integer value, or any information about it (even "it is not equal to X"). A sub-case is capturing only whether it is null.
- **Provenance**: the ability to access memory through the pointer. A sub-case is read-only provenance.

**Provenance capture.** If provenance is not captured, accessing memory through pointers based on the argument after the call returns or unwinds is UB. If only read provenance is captured, only stores afterwards are UB. Formally, the callee gets a pointer with derived provenance whose permissions are revoked (or reduced to read) when it returns.

```llvm
define void @f(ptr captures(address) %a, ptr %b) {
  store ptr %a, ptr %b      ; fine by itself
  ret void
}
; after the call: reloading the pointer is fine, but loading through it is UB.
; with captures(address, read_provenance): loads are fine, stores are UB.
```

**Address capture.** The address is captured if the function's observable behaviour can depend on it. Comparing pointers does not always capture: a `memmove` that picks a copy direction by comparing addresses has the same observable effect either way, so it can be `captures(none)`.

**Location-specific capture.** A capture may happen only through the return value (`ret:`). Returning a GEP of the argument is a return-only capture. Direct inspection of the address (e.g. `ptrtoint`) is always treated as location-independent, even if it only feeds the return value.

**Example inference rules** (conservative, from the reference):

| Operation | Captures |
|---|---|
| volatile access | address of the pointer |
| `getelementptr`, `bitcast`, `addrspacecast`, `select`, `phi` | nothing |
| `load`, `va_arg` | nothing (unless volatile) |
| `icmp`, `ptrtoaddr` | address only |
| `ptrtoint` | address and provenance |
| `call` / `invoke` | as given by `captures` on the argument; the callee itself is never captured |
| `store`, `atomicrmw`, `cmpxchg` | address and provenance of the value operand; not the pointer operand (unless volatile) |
| anything else (incl. `insertvalue`, `insertelement`) | assume address and provenance |

### 14.5 Volatile memory accesses

`load`, `store`, `llvm.memcpy` etc. may be marked volatile.

- Optimisers must not change the number of volatile operations or their order relative to each other. They may reorder volatile against non-volatile operations.
- Not Java volatile: no cross-thread synchronisation.
- Volatile operations may have target-specific side effects and may touch non-memory addresses (MMIO), including address 0. A volatile access cannot be used to prove a non-volatile access to the same address is defined.
- A volatile operation may modify memory at its own address only if a non-volatile store there would be legal. It may not modify other module-visible memory or call code in the module.
- Without target knowledge, the address space of a volatile operation must not change.
- Volatile operations may trap; the compiler cannot assume execution continues.
- Volatile loads/stores must not be turned into `llvm.memcpy`/`llvm.memmove` (even volatile ones). The backend must not split or merge legal-width volatile accesses. Volatile accesses must not change between integer and floating-point.

### 14.6 Memory model for concurrent operations

LLVM IR has no way to start threads, but defines behaviour when threads exist. The model follows C++ and is axiomatic.

**Happens-before** is the smallest partial order that includes single-thread program order and every synchronizes-with edge. Synchronizes-with edges come from platform mechanisms (locks, thread create/join) and atomic instructions. Program order does not order a thread against signal handlers running in it.

Initialised globals count as having an atomic write of the initializer that happens before every other access.

For each byte `Rbyte` of a read `R`, it may see any write to that byte except:
- a write `write1` if some `write2` to the byte happens after `write1` and before `Rbyte`;
- a write that `Rbyte` happens before.

Value of `Rbyte`:
1. If `R` is volatile: target-dependent.
2. Else, if no write to the byte happens before it: `undef`.
3. Else, if it may see exactly one write: that write's value.
4. Else, if `R` is atomic, all visible writes are atomic, and all access exactly the same bytes: one of the written values (subject to ordering rules in 14.7).
5. Else: `undef`.

Atomic accesses do not tear: if one byte of atomic read `R` reads from atomic write `W`, every other byte of `R` that may see `W` reads from `W`.

`R` returns the bytes it read, so some bytes may be undef while others are not.

Consequence for optimisers (without atomics): you may not introduce a store to a byte that would not otherwise be stored.

### 14.7 Atomic memory orderings

Used by `cmpxchg`, `atomicrmw`, `fence`, atomic `load` and atomic `store`. Accesses are **perfectly overlapping** if they access exactly the same bytes (same address and size).

| Ordering | Meaning | C/C++ equivalent |
|---|---|---|
| `unordered` | Values read are governed by happens-before; a value must have been written by someone. Not allowed on read-modify-write operations. Models Java non-volatile shared variables. No coherence guarantee. | (Java plain) |
| `monotonic` | Adds a total modification order per set of perfectly overlapping monotonic operations, consistent with happens-before. RMW operations read the immediately preceding write in that order. Coherence rules (write-write, read-read, read-write, write-read) hold. Writes eventually become visible. | `memory_order_relaxed` |
| `acquire` | Adds: may form a synchronizes-with edge with a `release`. | `memory_order_acquire` |
| `release` | Adds: if a perfectly overlapping `acquire` reads the value written (possibly after intervening RMWs, a "release sequence"), they synchronize. | `memory_order_release` |
| `acq_rel` | Both acquire and release. | `memory_order_acq_rel` |
| `seq_cst` | Adds a single global total order over all `seq_cst` operations on all addresses. Reads that only touch perfectly overlapping `seq_cst` operations see the latest preceding write in that order. Not guaranteed consistent with happens-before when mixed with weaker accesses. | `memory_order_seq_cst`, Java `volatile` |

Coherence rules (for perfectly overlapping atomics, at least `monotonic`):
- write-write: if W1 happens before W2, W1 is earlier in modification order.
- read-read: if R1 happens before R2 and R1 reads W, R2 does not read anything earlier than W.
- read-write: if R happens before W, R does not read W or anything later.
- write-read: if W happens before R, R does not read anything earlier than W.

Synchronisation scopes:
- `syncscope("singlethread")`: only synchronizes with operations in the same thread (e.g. signal handlers).
- `syncscope("<target-scope>")`: target-defined behaviour.
- No syncscope: synchronizes with all other operations that also have no syncscope.

`fence` treats orderings differently because it has no address (see the instruction chapter).

### 14.8 Elementwise atomic operations

`atomicrmw`, atomic `load` and atomic `store` may be marked `elementwise`.

- The access type must be a fixed vector whose total bit width is a power of two, with an element type the scalar instruction supports.
- The ordering may not be `seq_cst`.
- Behaves like one scalar operation per element, each with the same ordering and syncscope. They all sit at the original position in program order but are not ordered with respect to each other. Synchronising with one gives no happens-before with the others.
- Without `elementwise`, a vector atomic is atomic over the whole vector.

**Not documented:** Where the `elementwise` keyword goes in the instruction syntax (see the instruction chapter).

**Draconian note (verifier):** `elementwise` requires a fixed vector type with power-of-two total width and forbids `seq_cst`.

---

## 15. Floating-Point Semantics

### 15.1 Default floating-point environment

By default LLVM assumes:
- FP traps are disabled,
- FP status flags are not observable,
- rounding is round-to-nearest,
- subnormals are preserved.

So FP math has no side effects and can be speculated. Running in a different environment is usually UB unless `strictfp`, `denormal_fpenv`, or constrained FP intrinsics are used.

### 15.2 NaN behaviour

A NaN has a sign bit, a quiet/signaling bit, and a payload. LLVM assumes quiet bit = 1 means quiet NaN (QNaN), 0 means signaling NaN (SNaN).

- Without an FP operation, NaN bits never change.
- `bitcast`, `fneg`, `llvm.fabs` and `llvm.copysign` are not FP math operations. They only touch the sign bit.

When IEEE 754 says an FP math operation returns a NaN, LLVM returns a NaN with non-deterministic sign, and a quiet bit and payload chosen from:
1. quiet bit set, payload zero ("preferred NaN");
2. quiet bit set, payload copied from an input NaN ("quieting propagation");
3. quiet bit and payload copied from an input NaN ("unchanged propagation");
4. quiet bit set, payload from a target-specific extra set (empty on x86 and ARM; on wasm, all payloads if any input NaN is non-preferred or signaling; on SPARC, the all-ones payload).

Consequences:
- If all input NaNs are quiet (or there are none), the result is quiet.
- An SNaN result is only possible if an SNaN was an input (e.g. `fmul SNaN, 1.0` may fold to SNaN).
- If all input NaNs are preferred and the target has no extra payloads, the result is preferred.
- Operations may treat all NaNs as quiet (e.g. `pow(1.0, SNaN)` may fold to `1.0`).
- Constrained FP intrinsics exclude case 3 and always return a QNaN.

Known LLVM violations: x86-32 without SSE2 (x87 conversions), x86-32 returns in some conventions, and older MIPS with inverted quiet-bit polarity.

### 15.3 Core FP operations

For `half`, `float`, `double` and `fp128` (IEEE binary16/32/64/128), the IEEE 754 section 5 operations return exactly the IEEE result in the default environment, except for NaN results (15.2). Non-NaN results are bit-identical across machines and optimisation levels. Optimisers and backends must not change them.

Fast-math flags, `strictfp`, `denormal_fpenv` and `!fpmath` metadata can relax this.

**Draconian note:** Constant folding of these operations must be correctly rounded IEEE arithmetic. NaN results have freedom per 15.2.

### 15.4 Fast-math flags

Allowed on: `fneg`, `fadd`, `fsub`, `fmul`, `fdiv`, `frem`, `fcmp`, `fptrunc`, `fpext`, `uitofp`, `sitofp`, and on `phi`, `select` and `call` returning a floating-point type.

For `phi`, `select` and `call`, "floating-point type" means:
- FP scalar or vector,
- arrays (nested to any depth) of those,
- homogeneous literal structs of those.

| Flag | Meaning |
|---|---|
| `fast` | Shorthand for all flags. No extra meaning. |
| `nnan` | Arguments and result are not NaN; otherwise poison. |
| `ninf` | Arguments and result are not +/-Inf; otherwise poison. |
| `nsz` | The sign of zero inputs may be flipped non-deterministically. Does not make -0.0 poison. |
| `arcp` | Rewrite-based. `a / b` may become `a * (1.0 / b)`, and `a / (b / c)` may become `a * (c / b)`, in either direction. |
| `contract` | Rewrite-based. Allow contraction, e.g. fusing multiply and add into FMA. Does not allow reassociation to create contractions. |
| `afn` | Rewrite-based. Allow approximate versions of functions (sin, log, sqrt, ...). |
| `reassoc` | Rewrite-based. Allow algebraically equivalent rewrites such as reassociation. |

**Rewrite-based flags** (`arcp`, `contract`, `afn`, `reassoc`): an expression spanning several instructions may be rewritten only if every instruction involved has the flag. The new instructions get the intersection of the input flags. Other flags (`nnan`, `ninf`, `nsz`) are assigned to new instructions based on whether NaN/Inf can actually occur given the original flags.

**Not documented:** The canonical printing order of flags, and whether `fast` is printed instead of listing all flags. The order in this list is `fast nnan ninf nsz` then `arcp contract afn reassoc`.

---

## 16. Summary of Verifier Rules Found in This Chapter

- Uses must be dominated by definitions.
- Declarations: linkage only `external` or `extern_weak`.
- `available_externally` only on definitions.
- `common`: zero initializer, no section, not `constant`; not on functions or aliases.
- `appending`: only on array-typed global variables.
- `private`/`internal`: visibility must be `default`; no DLL storage class.
- Global variable definition initializers are sized; no scalable vectors in globals.
- `align` values are powers of 2 (global max `1 << 32`).
- Entry block: no predecessors, no PHIs.
- Explicit numeric block labels must match the implicit numbering.
- Alias linkage in the allowed set; aliasee restrictions (no weak aliases inside, no declarations unless `available_externally` rules apply).
- Comdat membership: at most one comdat per global object.
- Named metadata operands are nodes, not strings.
- Parameter attribute placement rules (pointer-only, not-on-return, one-parameter-only, intrinsic-only for `immarg`/`elementtype`, `sret` implies `void` return, `inalloca` only on the last argument and not combined with `inreg`/`nest`/`sret`/`byval`).
- `writable` not combined with `readnone`, `readonly`, or a `memory` attribute lacking `argmem: write`.
- `range`: type matches, `a != b` unless both 0.
- `initializes`: sorted, non-overlapping, non-adjacent, non-empty.
- Function attribute conflicts listed in 8.1.
- Operand bundle cardinality rules in section 11.
- Use-list directives at function scope come after the last terminator.
- `elementwise` atomics: fixed vector, power-of-two width, not `seq_cst`.
- `unordered` not allowed on read-modify-write operations.
