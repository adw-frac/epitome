# MLIR Language, Builtin Dialect and Bytecode

Source: MLIR documentation at mlir.llvm.org/docs, read on 2026-10-20. Each
section names the pages it uses. The site tracks MLIR's development branch,
not a numbered release.

This chapter covers the textual form of MLIR: its structure, lexical rules,
the generic operation syntax, regions and symbols, every type and attribute
in the builtin dialect, affine maps and integer sets, and the bytecode
container. It is written only from published documentation. No MLIR source,
TableGen file or test file was read.

---

## 1. Overview

Source: https://mlir.llvm.org/docs/LangRef/ (sections High-Level Structure,
Dialects, Blocks), https://mlir.llvm.org/docs/Rationale/Rationale/ (Block
Arguments vs PHI nodes, Integer signedness semantics, Assembly forms), and
Lattner et al., "MLIR: A Compiler Infrastructure for the End of Moore's Law",
arXiv:2002.11054 (published at CGO 2021 as "MLIR: Scaling Compiler
Infrastructure for Domain Specific Computation"). Read 2026-10-20.

### 1.1 The parts of the IR

MLIR is a graph. The nodes are **operations**. The edges are **values**.

| Concept | What it is |
| --- | --- |
| Operation | A node. It has a name, zero or more operands, zero or more results, properties, an attribute dictionary, zero or more successor blocks, zero or more regions, and a location. |
| Value | An edge. Every value is either the result of exactly one operation or an argument of exactly one block. Every value has a type. |
| Block | An ordered list of operations, with a list of typed block arguments. |
| Region | An ordered list of blocks. A region always belongs to an operation. It has no name, type or attributes. |
| Dialect | A namespace that groups operations, types and attributes, for example `arith`, `func`, `llvm`. |
| Type | The type of a value. The type system is open: dialects add types. |
| Attribute | Constant data attached to an operation, such as a predicate or a literal. Attributes are also open. |

Operations live in blocks. Blocks live in regions. Regions live in
operations. So the IR nests to any depth. A file is a list of top-level
operations, usually one `builtin.module`.

MLIR has three equivalent forms: an in-memory form, a textual form
(`.mlir`), and a binary bytecode form. They carry the same information. This
chapter describes the text form in sections 2 to 6, and the bytecode
container in section 7.

### 1.2 How MLIR differs from LLVM IR

| LLVM IR | MLIR |
| --- | --- |
| A fixed instruction set, defined by LangRef. | No fixed set. Any dialect may define operations. An operation is identified by a string such as `arith.addi` or `tf.Conv2d`. |
| A flat module of functions, each a list of basic blocks. | Operations may contain regions, so structure nests. A function is itself an operation (`func.func`, `llvm.func`) whose body is a region. |
| `phi` instructions merge values at block entry. | Blocks take arguments. A branch passes values to its successor's arguments. Function parameters are the entry block's arguments. |
| Every function body is a control-flow graph with SSA dominance. | Each region has a kind. SSACFG regions behave like LLVM function bodies. Graph regions have no control flow and no ordering. |
| A fixed set of types. | An open type system. The builtin dialect gives a common base set. |
| Integers have no signedness. | Builtin integers may be signless (`i32`), signed (`si32`) or unsigned (`ui32`). The `arith` dialect uses signless integers, as LLVM does. |
| Metadata is a separate value-like kind (`!0`, `!{...}`). | Constant data is carried by attributes. Locations are attributes too, and every operation has one. |
| Global names are `@` identifiers resolved module-wide. | Global names are **symbols**, resolved by the nearest enclosing symbol table. References may be nested (`@a::@b`). |

The Rationale page explains block arguments in place of phi. The parallel
copy meaning of SSA is clearer, and function arguments stop being a special
case.

**Epitome note:** Epitome reads LLVM IR. The closest MLIR equivalent is the
`llvm` dialect inside a `builtin.module`. To read MLIR, Epitome needs a
generic parser for the structure in this chapter, plus a custom-syntax
parser for each operation it wants to read in pretty form (section 3).

### 1.3 Generic and custom forms

Every operation has a **generic form** that any parser can read without
knowing the operation (section 2.4). A dialect may also register a
**custom assembly form** for each of its operations. The Rationale page says
the generic form exists because MLIR is open: an operation's dialect may not
be loaded, but the IR must still be readable and printable.

---

## 2. Lexical syntax and the generic grammar

Source: https://mlir.llvm.org/docs/LangRef/ (Notation, Common syntax, Top
level Productions, Identifiers and keywords, Operations, Blocks, Regions,
Type System, Attributes), https://mlir.llvm.org/docs/Dialects/Builtin/,
https://mlir.llvm.org/docs/PassManagement/ (crash reproducers). Read
2026-10-20.

### 2.1 Grammar notation

LangRef writes its grammar in EBNF:

```
alternation ::= expr0 | expr1 | expr2  // Either expr0 or expr1 or expr2.
sequence    ::= expr0 expr1 expr2      // Sequence of expr0 expr1 expr2.
repetition0 ::= expr*  // 0 or more occurrences.
repetition1 ::= expr+  // 1 or more occurrences.
optionality ::= expr?  // 0 or 1 occurrence.
grouping    ::= (expr) // Everything inside parens is grouped together.
literal     ::= `abcd` // Matches the literal `abcd`.
```

Literal tokens are in backticks. LangRef itself notes a TODO to separate
lexing from parsing, so the grammar mixes tokens and productions.

### 2.2 Common tokens

```
digit     ::= [0-9]
hex_digit ::= [0-9a-fA-F]
letter    ::= [a-zA-Z]
id-punct  ::= [$._-]

integer-literal ::= decimal-literal | hexadecimal-literal
decimal-literal ::= digit+
hexadecimal-literal ::= `0x` hex_digit+
float-literal ::= [-+]?[0-9]+[.][0-9]*([eE][-+]?[0-9]+)?
string-literal  ::= `"` [^"\n\f\v\r]* `"`   TODO: define escaping rules
```

Notes on these rules:

- A float literal needs a digit before the dot. `42.` is valid; `.5` is not.
- An integer literal has no sign. Negative integers appear in attributes
  such as `-1 : i32`, but the grammar does not show where the `-` is lexed.
- Comments start with `//` and run to the end of the line. There are no
  block comments.

**Not documented:** string escapes. LangRef marks them as a TODO. The
`dense_resource` example in section 5 shows a hex blob written inside an
ordinary string, so no escapes are needed there.

**Not documented:** whether a minus sign is part of an integer token, and
how negative integers and floats are parsed in attribute position.

### 2.3 Identifiers and sigils

```
bare-id ::= (letter|[_]) (letter|digit|[_$.])*
bare-id-list ::= bare-id (`,` bare-id)*
value-id ::= `%` suffix-id
alias-name :: = bare-id
suffix-id ::= (digit+ | ((letter|id-punct) (letter|id-punct|digit)*))

symbol-ref-id ::= `@` (suffix-id | string-literal) (`::` symbol-ref-id)?
value-id-list ::= value-id (`,` value-id)*

// Uses of value, e.g. in an operand list to an operation.
value-use ::= value-id (`#` decimal-literal)?
value-use-list ::= value-use (`,` value-use)*
```

(`alias-name :: = bare-id` is copied as LangRef prints it, with a space.)

Every identifier kind has a sigil, so identifiers never clash with keywords:

| Sigil | Names | Example |
| --- | --- | --- |
| `%` | SSA values | `%0`, `%arg0`, `%batch_size` |
| `^` | Blocks | `^bb0`, `^exit` |
| `@` | Symbols | `@main`, `@"quoted name"`, `@mod::@fn` |
| `!` | Type aliases and dialect types | `!avx_m128`, `!llvm.ptr` |
| `#` | Attribute aliases and dialect attributes | `#map`, `#llvm.linkage<internal>` |

A `suffix-id` is either all digits (`%42`) or starts with a letter or one of
`$ . _ -` (`%x.y`, `%-tmp`). A bare id cannot start with a digit or with
`$ . -`.

Value names are not part of the IR. A printer may rename them, and normally
prints `%0`, `%1` and so on. Keywords may be added to MLIR at any time
without breaking existing names, because names are always prefixed. In a few
unambiguous places, such as affine expressions, identifiers have no sigil
(`d0`, `s0`).

**Epitome note:** names in a file are only labels for the parser. The
in-memory IR must not depend on them. Round-tripping text need not keep
value names.

### 2.4 The generic operation form

```
operation             ::= op-result-list? (generic-operation | custom-operation)
                          trailing-location?
generic-operation     ::= string-literal `(` value-use-list? `)`  successor-list?
                          dictionary-properties? region-list? dictionary-attribute?
                          `:` function-type
custom-operation      ::= bare-id custom-operation-format
op-result-list        ::= op-result (`,` op-result)* `=`
op-result             ::= value-id (`:` integer-literal)?
successor-list        ::= `[` successor (`,` successor)* `]`
successor             ::= caret-id (`:` block-arg-list)?
dictionary-properties ::= `<` dictionary-attribute `>`
region-list           ::= `(` region (`,` region)* `)`
dictionary-attribute  ::= `{` (attribute-entry (`,` attribute-entry)*)? `}`
trailing-location     ::= `loc` `(` location `)`
```

The parts of a generic operation, in order:

| Part | Syntax | Notes |
| --- | --- | --- |
| Results | `%a, %b =` or `%r:2 =` | Optional. `%r:2` names a group of 2 results, used as `%r#0` and `%r#1`. Groups and single names may be mixed. |
| Name | `"dialect.op"` | Always a quoted string in generic form. |
| Operands | `(%x, %r#1)` | Always present, may be empty: `()`. |
| Successors | `[^bb1, ^bb2]` | Optional. Blocks the operation may branch to. |
| Properties | `<{key = value, ...}>` | Optional. Inherent data stored on the operation (section 2.9). |
| Regions | `({ ... }, { ... })` | Optional. Each region is a brace-enclosed list of blocks. |
| Attributes | `{key = value, ...}` | Optional. The attribute dictionary. |
| Type | `: (operand types) -> (result types)` | Always present. A function type. |
| Location | `loc(...)` | Optional. |

The `successor` production allows a `block-arg-list` after the label. The
LangRef examples pass successor operands in custom forms
(`cf.br ^bb3(%a: i64)`). In generic form, the operand list of a branch holds
all operands, including those passed to successors.

**Not documented:** how a generic form splits its single operand list
between "normal" operands and each successor's operands. The successor
grammar suggests `^bb1(%a : i64)` may be written inside the successor list,
but no example shows the generic spelling. The operation definition
(section 2.10) mentions `AttrSizedOperandSegments`, which keeps segment
sizes in an attribute or property; its exact name is not shown in the pages
read.

Examples from LangRef:

```mlir
// An operation that produces two results.
// The results of %result can be accessed via the <name> `#` <opNo> syntax.
%result:2 = "foo_div"() : () -> (f32, i32)

// Pretty form that defines a unique name for each result.
%foo, %bar = "foo_div"() : () -> (f32, i32)

// Invoke a TensorFlow function called tf.scramble with two inputs
// and an attribute "fruit" stored in properties.
%2 = "tf.scramble"(%result#0, %bar) <{fruit = "banana"}> : (f32, i32) -> f32

// Invoke an operation with some discardable attributes
%foo, %bar = "foo_div"() {some_attr = "value", other_attr = 42 : i64} : () -> (f32, i32)
```

A generic operation with a region (from the Value Scoping example):

```mlir
"any_op"(%a) ({ // if %a is in-scope in the containing region...
   // then %a is in-scope here too.
  %new_value = "another_op"(%a) : (i64) -> (i64)
}) : (i64) -> (i64)
```

A generic operation is told apart from a custom one by its first token: a
string literal starts a generic form, a bare id starts a custom form.

**Epitome note:** the number of results is fixed by the function type. The
parser must check that the result names cover exactly that many results,
counting `%r:N` as N.

### 2.5 Blocks

```
block           ::= block-label operation+
block-label     ::= block-id block-arg-list? `:`
block-id        ::= caret-id
caret-id        ::= `^` suffix-id
value-id-and-type ::= value-id `:` type

// Non-empty list of names and types.
value-id-and-type-list ::= value-id-and-type (`,` value-id-and-type)*

block-arg-list ::= `(` value-id-and-type-list? `)`
```

A labelled block has at least one operation. Block arguments are written
like function parameters: `^bb3(%c: i64):`.

```mlir
func.func @simple(i64, i1) -> i64 {
^bb0(%a: i64, %cond: i1): // Code dominated by ^bb0 may refer to %a
  cf.cond_br %cond, ^bb1, ^bb2

^bb1:
  cf.br ^bb3(%a: i64)    // Branch passes %a as the argument

^bb2:
  %b = arith.addi %a, %a : i64
  cf.br ^bb3(%b: i64)    // Branch passes %b as the argument

^bb3(%c: i64):
  cf.br ^bb4(%c, %a : i64, i64)

^bb4(%d : i64, %e : i64):
  %0 = arith.addi %d, %e : i64
  return %0 : i64   // Return is also a terminator.
}
```

Values that do not depend on control flow need not go through block
arguments. Above, `%a` is used directly in `^bb3`.

**Not documented:** whether a block argument may carry its own location in
text (for example `%a: i64 loc("x":1:2)`). The bytecode format stores an
optional location per block argument (section 7.7), so the in-memory IR has
one.

### 2.6 Regions

```
region      ::= `{` entry-block? block* `}`
entry-block ::= operation+
```

The first block is the **entry block**. Its label may be left out, but only
if it has no arguments. An empty region is written `{}`. Section 4 covers
region meaning.

### 2.7 Types: general productions

```
type ::= type-alias | dialect-type | builtin-type

type-list-no-parens ::=  type (`,` type)*
type-list-parens ::= `(` `)`
                   | `(` type-list-no-parens `)`

// This is a common way to refer to a value with a specified type.
ssa-use-and-type ::= ssa-use `:` type
ssa-use ::= value-use

// Non-empty list of names and types.
ssa-use-and-type-list ::= ssa-use-and-type (`,` ssa-use-and-type)*

function-type ::= (type | type-list-parens) `->` (type | type-list-parens)
```

LangRef lets either side of `->` be a single unparenthesised type. The
builtin `FunctionType` page gives a stricter rule (section 5.9): inputs are
always parenthesised, and a single result may be bare only if it is not
itself a function type. LangRef's own alias example writes
`vector<4 x f32> -> ()`, so readers should accept a bare input type.

**Epitome note:** accept the LangRef form when reading. When printing,
always parenthesise inputs, and parenthesise results unless there is
exactly one non-function result. Both readings then agree.

### 2.8 Aliases

```
type-alias-def ::= `!` alias-name `=` type
type-alias ::= `!` alias-name

attribute-alias-def ::= `#` alias-name `=` attribute-value
attribute-alias ::= `#` alias-name
```

The top level of a file may contain alias definitions as well as
operations:

```
toplevel := (operation | attribute-alias-def | type-alias-def)*
```

Rules:

- An alias must be defined before it is used.
- An alias name may not contain `.`. Dotted names are kept for dialect
  types and attributes (`!llvm.ptr`, `#llvm.fastmath<fast>`).
- An alias is only a shorthand. Using it is the same as writing the aliased
  type or attribute in full.

```mlir
!avx_m128 = vector<4 x f32>
"foo"(%x) : !avx_m128 -> ()

#map = affine_map<(d0) -> (d0 + 10)>
%b = affine.apply #map(%a)
```

Locations are attributes (section 5.20), so a location may be given an
attribute alias and used as `loc(#loc3)`. MLIR's printer often prints
locations this way, with a list of `#locN = loc(...)` definitions.

**Not documented:** the pages read do not show `#loc` aliases or say where
the printer puts them. Since `location` has no production of its own, it is
also not stated that `loc(#alias)` is valid. Epitome should accept an
attribute alias inside `loc(...)`, and should accept alias definitions
anywhere at the top level, including after the operations that use them if
MLIR's printer emits them there. Check this against real `mlir-opt` output.

**Not documented:** what the printer chooses to alias. The
DefiningDialects/AttributesAndTypes page says a dialect can ask for aliases
through `OpAsmAttrInterface` and `OpAsmTypeInterface`, or use its mnemonic as
the alias name (`genMnemonicAlias`). Names and numbering are not specified.

### 2.9 Attribute entries, properties and discardable attributes

```
attribute-entry ::= (bare-id | string-literal) `=` attribute-value
attribute-value ::= attribute-alias | dialect-attribute | builtin-attribute
```

A key is a bare id or a quoted string. A dictionary is sorted by name and
names are unique (section 5.4).

The Builtin `UnitAttr` page shows a short form: a key with no `= value`
means the key maps to `unit`.

```mlir
func.func @simple_form() attributes {dialectName.unitAttr}
```

**Not documented:** LangRef's `attribute-entry` production does not allow
the short form. Epitome should accept it, as the Builtin page shows.

An operation's data is split into two kinds:

| Kind | Meaning | Where stored | Key rule |
| --- | --- | --- | --- |
| Inherent attribute | Part of the operation's meaning, verified by the operation. Example: the `predicate` of `arith.cmpi`. | In **properties**, if the operation has adopted properties. Otherwise in the attribute dictionary. | No dialect prefix. |
| Discardable attribute | Meaning given by some other dialect. Example: `gpu.container_module`. | Always in the attribute dictionary. | Starts with a dialect prefix (`dialect.name`). |

Properties are data stored directly on the operation. They can always be
turned into an attribute, so the generic form prints them as a dictionary in
angle brackets: `<{fruit = "banana"}>`. Only the top-level dictionary of an
operation follows the inherent/discardable split. Nested dictionaries are
plain values.

**Epitome note:** treat the generic `<{...}>` as a dictionary attribute
belonging to the operation's properties. Keep it separate from the
attribute dictionary. Because properties can always be shown as attributes,
a reader that does not know an operation can still store them as a
dictionary attribute.

### 2.10 Dialect types and attributes

```
dialect-namespace ::= bare-id

dialect-type ::= `!` (opaque-dialect-type | pretty-dialect-type)
opaque-dialect-type ::= dialect-namespace dialect-type-body
pretty-dialect-type ::= dialect-namespace `.` pretty-dialect-type-lead-ident
                                              dialect-type-body?
pretty-dialect-type-lead-ident ::= `[A-Za-z][A-Za-z0-9._]*`

dialect-type-body ::= `<` dialect-type-contents+ `>`
dialect-type-contents ::= dialect-type-body
                            | `(` dialect-type-contents+ `)`
                            | `[` dialect-type-contents+ `]`
                            | `{` dialect-type-contents+ `}`
                            | [^\[<({\]>)}\0]+
```

Dialect attributes use the same grammar with `#` in place of `!`
(`dialect-attribute`, `opaque-dialect-attribute`,
`pretty-dialect-attribute`, `dialect-attribute-body`,
`dialect-attribute-contents`).

Two spellings mean the same thing:

| Form | Type example | Attribute example |
| --- | --- | --- |
| Opaque | `!tf<string>`, `!foo<something<abcd>>`, `!foo<"a123^^^" + bar>` | `#foo<string<"">>`, `#foo<"a123^^^" + bar>` |
| Pretty | `!tf.string`, `!foo.something<abcd>` | `#foo.string<"">` |

The body is any text with balanced `<>`, `()`, `[]` and `{}`. The generic
parser does not look inside it; it hands the text to the dialect.

**Epitome note:** for a dialect Epitome does not know, it can still read
the value by matching brackets and storing the text. This is what MLIR does
for unregistered dialects (the Rationale page: an unregistered dialect type
is kept as an `OpaqueType` and can be round-tripped). Equality is then only
text equality.

**Not documented:** how brackets inside string literals in the body are
handled. The regex `[^\[<({\]>)}\0]+` would stop at a `>` inside a string,
but the example `"a123^^^"` suggests strings are lexed as tokens. Epitome
should lex strings as whole tokens while matching brackets.

**Not documented:** how the pretty form's lead identifier and the opaque
form's body map to each other in general. Each dialect defines its own
syntax.

### 2.11 Locations

Every operation has a location. When no location is known, it is the
unknown location, written `loc(?)`.

```
trailing-location ::= `loc` `(` location `)`
```

The location forms come from the builtin location attributes:

| Form | Syntax | Example |
| --- | --- | --- |
| Unknown | `?` | `loc(?)` |
| File, line, column (and range) | `string-literal : line : col (to line? : col?)?` | `loc("mysource.cc":10:8)`, `loc("mysource.cc":10:8 to 12:18)` |
| Name | `string-literal ( ( location ) )?` | `loc("CSE"("mysource.cc":10:8))` |
| Call site | `callsite ( location at location )` | `loc(callsite("foo" at "mysource.cc":10:8))` |
| Fused | `fused (< attribute >)? [ locations ]` | `loc(fused<"CSE">["mysource.cc":10:8, "mysource.cc":22:8])` |
| Opaque | not printable | An external pointer plus a fallback location; only the fallback is serialised. |

Section 5.20 gives the full grammars.

**Not documented:** what location the parser gives an operation with no
`loc(...)`. The SourceMgr diagnostics on the Diagnostics page show
`file:line:col`, so the parser seems to use the operation's position in the
input file.

**Not documented:** the location of the whole file's implicit module, if
one is created.

### 2.12 File-level metadata: `{-# ... #-}`

A file may end with a metadata block in `{-#` and `#-}`. It holds
**resources**: named data kept outside the IR itself, such as large weight
blobs. It has two sections:

| Key | Holds |
| --- | --- |
| `dialect_resources` | A dictionary per dialect namespace. Each entry is named data owned by that dialect. The builtin dialect's blobs back `dense_resource` attributes. |
| `external_resources` | A dictionary per external owner, not a dialect. The crash reproducer uses the key `mlir_reproducer`. |

From the Builtin page:

```mlir
"example.user_op"() {attr = dense_resource<blob1> : tensor<3xi64> } : () -> ()

{-#
dialect_resources: {
    builtin: {
      blob1: "0x08000000010000000000000002000000000000000300000000000000"
    }
  }
#-}
```

From the PassManagement page:

```mlir
{-#
  external_resources: {
    mlir_reproducer: {
      pipeline: "builtin.module(func.func(cse,canonicalize),inline)",
      disable_threading: true,
      verify_each: true
    }
  }
#-}
```

Values may be strings, booleans or hex blobs written as strings starting
`0x`. The bytecode resource section (section 7.6) has the same three kinds:
bool, string and blob.

In the `blob1` example, the first four bytes `08000000` are not data. The
tensor has three `i64` values (`1`, `2`, `3`, little-endian), which are the
remaining 24 bytes. The leading word looks like the blob's alignment (8).

**Not documented:** the grammar of the block, where it may appear (only at
the end of the file?), and the meaning of the leading four bytes of a hex
blob. The alignment reading above is our inference from the example.

### 2.13 Unregistered operations

An operation whose dialect is not loaded can still be written in generic
form. The Linalg page runs `mlir-opt` with `-allow-unregistered-dialect` on
files using such operations. Without that flag, unknown operations are an
error.

---

## 3. Custom assembly formats

Source: https://mlir.llvm.org/docs/LangRef/ (Operations),
https://mlir.llvm.org/docs/DefiningDialects/Operations/ (Declarative
Assembly Format, properties), https://mlir.llvm.org/docs/Rationale/Rationale/
(Assembly forms), https://mlir.llvm.org/docs/Diagnostics/,
https://mlir.llvm.org/docs/Passes/ (`-snapshot-op-locations`). Read
2026-10-20.

### 3.1 What a parser must know

```
custom-operation      ::= bare-id custom-operation-format
```

A custom form starts with the operation name as a bare id, for example
`arith.addi`. Everything after the name is defined by that operation. There
is no general grammar for `custom-operation-format`. A parser can only read
a custom form if it knows that operation's format.

So a complete MLIR reader needs, for each operation it supports:

1. The operation name.
2. Its custom format, if it has one.
3. Enough of its definition to map the format's pieces back to operands,
   results, properties, attributes, successors and regions.

The generic form is always valid for every operation. A printer can always
fall back to it.

**Epitome note:** a first MLIR reader can accept only generic form and use
`mlir-opt` to convert other files. Custom formats can then be added per
operation, for the dialects Epitome cares about.

### 3.2 Getting generic output from MLIR's tools

The Diagnostics page says that when MLIR prints an operation inside an
error, it uses generic form. The `-snapshot-op-locations` pass has options
named after the global printing flags: `-print-op-generic` ("Print the
generic op form"), `-print-debuginfo` ("Print debug info in MLIR output"),
`-pretty-debuginfo`, and `-print-local-scope` ("Print with local scope and
inline information (eliding aliases for attributes, types, and
locations").

The global `mlir-opt` flag is commonly spelled `--mlir-print-op-generic`,
with `--mlir-print-debuginfo` to print locations and
`--mlir-print-local-scope` to inline aliases.

**Not documented:** the pages read do not list `mlir-opt`'s global printer
flags. The spellings above follow the pass option names with an `mlir-`
prefix; check them with `mlir-opt --help`.

### 3.3 What the declarative format tells a reader

Most upstream operations define their custom form in a declarative format
string. The generated dialect pages print it under "Syntax:" for each
operation, for example:

```
operation ::= `builtin.module` ($sym_name^)? prop-dict attr-dict-with-keyword $bodyRegion
```

The pieces a reader meets:

| Piece | Meaning in the text |
| --- | --- |
| `` `keyword` `` | A literal token. |
| `$name` | An operand, result, attribute, property, successor or region of that name. |
| `type($x)` | The type of `$x`. |
| `functional-type(a, b)` | A function type built from the types of `a` and `b`. |
| `attr-dict` | The attribute dictionary `{...}`. May be empty and is then not printed. Under the default strict rules it holds only discardable attributes. |
| `attr-dict-with-keyword` | The same, but preceded by the keyword `attributes`. |
| `prop-dict` | The properties not printed elsewhere, as `<key = value, ...>`. A unit property is spelled `<key>`. Default-valued properties are not printed. The legacy spelling `<{key = attribute, ...}>` is also accepted. |
| `(...)?` with `^` | An optional group. The `^` marks the element whose presence decides whether the group is printed. |
| `custom<Name>(...)` | Hand-written C++ parse and print code. Not described by any document. |

**Epitome note:** the dialect pages give enough to parse most operations
without source code. `custom<...>` directives are the exception. Their
syntax must be learnt from examples on the dialect pages and from
`mlir-opt` output, and recorded as observed behaviour.

**Not documented:** the custom form of operations without a declarative
format. Their syntax appears only in examples on the dialect pages.

### 3.4 Short operation names

LangRef examples write `return`, `module` and `unrealized_conversion_cast`
without a dialect prefix, inside functions and at the top level.

**Not documented:** the rule that lets a parser drop the dialect prefix.
The `func.func` and `builtin.module` operations list `OpAsmOpInterface`, and
the builtin dialect is loaded everywhere, which suggests a default dialect
for the operations nested in a region. The pages read do not state the
rule. Epitome should accept `module` and `unrealized_conversion_cast` as
builtin, and resolve other unprefixed names against the enclosing
operation's dialect (`return` inside `func.func` is `func.return`).

---

## 4. Regions, dominance and symbols

Source: https://mlir.llvm.org/docs/LangRef/ (Blocks, Regions),
https://mlir.llvm.org/docs/Traits/, https://mlir.llvm.org/docs/Interfaces/
(RegionKindInterfaces, SymbolInterfaces),
https://mlir.llvm.org/docs/SymbolsAndSymbolTables/. Read 2026-10-20.

### 4.1 Region kinds

The operation that holds a region decides what the region means. It
reports each region's kind through `RegionKindInterface`:

| Kind | Meaning |
| --- | --- |
| `RegionKind::SSACFG` | Blocks form a control-flow graph. Operations run in order. SSA dominance applies. |
| `RegionKind::Graph` | No control flow. Order is not meaningful. Any value defined in the region may be used anywhere in it, including cycles. Only one block is allowed. |

The interface also has `hasSSADominance(index)`, which is true when the
region needs dominance.

**Not documented:** the default kind of a region whose operation does not
implement `RegionKindInterface`. The examples treat such regions as SSACFG.

### 4.2 SSACFG regions

Control enters a region at its entry block. Each block ends with a
terminator. A terminator's successors are the blocks control may go to
next, and they must be in the same region. A terminator with no successors
either returns control to the parent operation (like `return`) or stops
control (like `ub.unreachable`); the terminator's operation decides which.

Other rules:

- The entry block may not be a successor of any block.
- Its arguments are the region's arguments. The parent operation decides
  their values. For a function, they are the parameters.
- Control may leave a region from any block with a suitable terminator.
  So regions are single-entry, multiple-exit.
- A block other than the entry block that no terminator names as a
  successor is unreachable, and may be deleted.
- An operation with several regions decides how control moves between
  them. It may run them in any order, more than once, or at the same time.
- An operation may "box" a region into a closure value. Its meaning is up
  to the operation.

### 4.3 Graph regions

```mlir
"test.graph_region"() ({ // A Graph region
  %1 = "op1"(%1, %3) : (i32, i32) -> (i32)  // OK: %1, %3 allowed here
  %2 = "test.ssacfg_region"() ({
     %5 = "op2"(%1, %2, %3, %4) : (i32, i32, i32, i32) -> (i32) // OK: %1, %2, %3, %4 all defined in the containing region
  }) : () -> (i32)
  %3 = "op2"(%1, %4) : (i32, i32) -> (i32)  // OK: %4 allowed here
  %4 = "op3"(%1) : (i32) -> (i32)
}) : () -> ()
```

Values may be used before their definition, and an operation may use its
own result. Graph regions are limited to one block for now; LangRef says
this is not a semantic need and may be lifted.

**Epitome note:** a parser must allow forward references to values. In a
graph region they are legal. In an SSACFG region they are legal in text
(a value defined in a later block may dominate the use) and are checked by
the verifier. So the parser should create placeholders for unknown names
and resolve them at the end of the region, reporting names never defined.

### 4.4 Value scope and hierarchical dominance

- A value defined in a region can never be used outside it.
- By default, an operation inside a region may use any value that its
  parent operation could use as an operand. For SSACFG regions this means
  values that dominate the parent operation.
- A region argument may be used by any operation nested in the region, at
  any depth.
- Whether a value may be used by another operation in the same region
  depends on the region kind: dominance for SSACFG, always for Graph.
- A branch can only name blocks in its own region.

LangRef calls this **hierarchical dominance**.

### 4.5 Isolation from above

An operation with the trait `IsolatedFromAbove` does not let its regions
use values defined outside it. This is invalid if `foo.region_op` is
isolated:

```mlir
%result = arith.constant 10 : i32
foo.region_op {
  foo.yield %result : i32
}
```

Isolation lets MLIR run passes on isolated operations in parallel. Symbols
(section 4.8) are how isolated operations refer to things outside
themselves. Tokens (section 5.13) cannot cross an isolation boundary.

### 4.6 Terminators

| Trait | Meaning |
| --- | --- |
| `Terminator` | The operation is a terminator. |
| `NoTerminator` | The operation's regions need no terminator. Such regions must have a single block. `builtin.module` uses it. |
| `SingleBlock` | Each region has exactly one block. |
| `SingleBlockImplicitTerminator<op>` | As `SingleBlock`, and the block must end with the named terminator. |
| `HasParent<op>` / `ParentOneOf<[...]>` | The operation may only appear directly inside the named parent operations. |

The last operation of every block must be a terminator, unless the parent
operation has `NoTerminator`. An operation that never returns, such as a
call that does not come back, does not remove this need.

**Not documented:** whether the implicit terminator of a
`SingleBlockImplicitTerminator` operation may be left out of the text. The
name suggests the custom form omits it and the parser adds it. Generic form
should always show it.

### 4.7 Other traits a reader meets

| Trait | Meaning |
| --- | --- |
| `AffineScope` | Starts a new polyhedral scope. Index values defined at its top level, dominating it, or as its region arguments are valid affine symbols (section 6.2). |
| `AutomaticAllocationScope` | Stack allocations such as `memref.alloca` are freed when control leaves this operation's regions. |
| `HasOnlyGraphRegion` | Listed on `builtin.module`; its region is a graph region. |
| `NoRegionArguments` | Listed on `builtin.module`; its region has no arguments. |
| `SymbolTable` | The operation's region is a symbol table. |
| `Commutative`, `ElementwiseMappable` | Semantic facts for transformations, not structure. |

**Not documented:** `HasOnlyGraphRegion` and `NoRegionArguments` are not
described on the Traits page; their meaning here is taken from their names.

### 4.8 Symbols and symbol tables

A **symbol** is an operation with a name, sitting directly in the region
of a **symbol table** operation. `func.func` is a symbol. `builtin.module`
is both a symbol table and, when it has a name, a symbol.

Rules:

- Symbol names are unique within their symbol table.
- A symbol's name is a `StringAttr`, usually the inherent attribute
  `sym_name`.
- Symbols have no SSA results.
- A symbol is either a definition or a declaration (defined outside the
  visible IR).
- Symbols are referred to by `SymbolRefAttr` values, never by SSA values.

```
symbol-ref-id ::= `@` (suffix-id | string-literal) (`::` symbol-ref-id)?
symbol-ref-attribute ::= symbol-ref-id (`::` symbol-ref-id)*
```

A reference is resolved in the **nearest enclosing symbol table** of the
operation that holds it. A nested reference `@a::@b` finds `@a` in that
table; `@a` must itself be a symbol table, and `@b` is found inside it.

```mlir
module @module_symbol {
  func.func @nested_symbol()
}
"foo.user"() {uses = [@module_symbol::@nested_symbol]} : () -> ()
```

A reference cannot see symbols in an outer table once a nearer table
encloses it:

```mlir
func.func @symbol()
module {
  // Error: resolved in the inner module, where @symbol does not exist.
  "foo.user"() {uses = [@symbol]} : () -> ()
}
```

Because references are attributes, they may appear anywhere an attribute
can, they ignore dominance and definition order, and they do not create SSA
uses.

### 4.9 Visibility

| Visibility | Meaning |
| --- | --- |
| `public` (default) | May be referenced from outside the visible IR. Not all uses are known. A declaration may not be public. |
| `private` | Only referenced from within the current symbol table. |
| `nested` | Referenced from outside the current symbol table, but not outside the visible IR, provided each enclosing table is itself a non-private symbol. |

Most operations store visibility in an optional inherent string attribute
`sym_visibility`. Its absence means public. Function custom forms print it
after the operation name, unquoted:

```mlir
func.func private @private_function()
func.func nested @nested_function()
```

The documentation warns that an operation may store visibility another
way, so a client should not assume the attribute exists.

**Epitome note:** `private` maps naturally to LLVM `internal` or `private`
linkage, but the `llvm` dialect has its own linkage attribute. Visibility is
about structural reachability in the IR, not object-file linkage.

---

## 5. The builtin dialect

Source: https://mlir.llvm.org/docs/Dialects/Builtin/, with
https://mlir.llvm.org/docs/LangRef/ (Builtin Types, Builtin Attribute
Values, Token Type) and https://mlir.llvm.org/docs/Rationale/Rationale/.
Read 2026-10-20.

The builtin dialect is loaded in every MLIR context. Its types and
attributes are written without a sigil or prefix (`i32`, `tensor<4xf32>`,
`dense<0>`), unlike dialect types (`!d.x`) and attributes (`#d.x`).

```
type ::= type-alias | dialect-type | builtin-type
```

### 5.1 Integer types

```
// Sized integers like i1, i4, i8, i16, i32.
signed-integer-type ::= `si` [1-9][0-9]*
unsigned-integer-type ::= `ui` [1-9][0-9]*
signless-integer-type ::= `i` [1-9][0-9]*
integer-type ::= signed-integer-type |
                 unsigned-integer-type |
                 signless-integer-type
```

| Spelling | Signedness | Example |
| --- | --- | --- |
| `iN` | Signless: the operation decides. | `i1`, `i32`, `i13` |
| `siN` | Signed | `si8` |
| `uiN` | Unsigned | `ui64` |

The width starts with a non-zero digit, so `i0` and `i08` do not match.
Any width is allowed "up to a fixed limit".

**Not documented:** the maximum width.

**Epitome note:** LLVM IR only has signless integers. `siN` and `uiN` occur
in higher-level dialects. The `llvm` dialect uses signless `iN`.

### 5.2 Index type

```
// Target word-sized integer.
index-type ::= `index`
```

A signless integer whose width is the target's machine word. Used for
sizes, subscripts and affine values. It may be an element type of tensors,
vectors and memrefs.

**Not documented:** how the width is chosen. It is not stored in the type.
Lowering to LLVM must pick it, presumably from a data layout.

### 5.3 Floating-point types

The Builtin page lists each float type by its class name. The keyword is
not printed for most of them. Keywords confirmed by examples in the pages
read are in **bold**.

| Class | Keyword | Format |
| --- | --- | --- |
| `Float16Type` | **`f16`** | IEEE half |
| `BFloat16Type` | **`bf16`** | bfloat16 |
| `Float32Type` | **`f32`** | IEEE single |
| `Float64Type` | **`f64`** | IEEE double |
| `Float80Type` | **`f80`** | x87 extended |
| `Float128Type` | **`f128`** | IEEE quad |
| `FloatTF32Type` | `tf32` | TF32 |
| `Float8E5M2Type` | **`f8E5M2`** | S1E5M2, bias 15, inf and NaN |
| `Float8E4M3Type` | `f8E4M3` | S1E4M3, bias 7, inf and NaN |
| `Float8E4M3FNType` | `f8E4M3FN` | S1E4M3, bias 7, no inf, NaN = all ones |
| `Float8E5M2FNUZType` | `f8E5M2FNUZ` | S1E5M2, bias 16, no inf, no -0, NaN = `0x80` |
| `Float8E4M3FNUZType` | `f8E4M3FNUZ` | S1E4M3, bias 8, no inf, no -0, NaN = `0x80` |
| `Float8E4M3B11FNUZType` | `f8E4M3B11FNUZ` | S1E4M3, bias 11, no inf, no -0, NaN = `0x80` |
| `Float8E3M4Type` | `f8E3M4` | S1E3M4, bias 3, inf and NaN |
| `Float8E5M3FNUType` | `f8E5M3FNU` | S0E5M3, bias 15, unsigned, no inf, NaN = all ones |
| `Float8E8M0FNUType` | **`f8E8M0FNU`** | S0E8M0, bias 127, powers of two only, no zero, NaN = all ones |
| `Float6E2M3FNType` | `f6E2M3FN` | S1E2M3, bias 1, no inf or NaN |
| `Float6E3M2FNType` | `f6E3M2FN` | S1E3M2, bias 3, no inf or NaN |
| `Float4E2M1FNType` | **`f4E2M1FN`** | S1E2M1, bias 1, no inf or NaN |

All the small formats have denormals when the exponent is zero, except
`f8E8M0FNU`, which has none. The suffix letters follow a pattern: `FN`
means finite (no infinity), `UZ` means unsigned zero (no negative zero),
and a trailing `U` means no sign bit.

**Not documented:** the keywords not in bold. They are inferred from the
class names, following the confirmed `f8E5M2`, `f8E8M0FNU` and `f4E2M1FN`.
Check each against `mlir-opt` before relying on it. The Builtin page gives no
grammar production for `float-type`.

**Epitome note:** LLVM IR has `half`, `bfloat`, `float`, `double`,
`x86_fp80`, `fp128` and `ppc_fp128`. The small formats have no LLVM IR type;
the `llvm` dialect lowers them to integers.

### 5.4 Complex type

```
complex-type ::= `complex` `<` type `>`
```

A real and an imaginary part of the element type. The element must be a
float or integer scalar: `complex<f32>`, `complex<i32>`.

### 5.5 Tuple type

```
tuple-type ::= `tuple` `<` (type ( `,` type)*)? `>`
```

A fixed list of possibly different types: `tuple<>`, `tuple<f32>`,
`tuple<i32, f32, tensor<i1>, i5>`. MLIR has no standard operations on
tuples.

### 5.6 Vector type

```
vector-type ::= `vector` `<` vector-dim-list vector-element-type `>`
vector-element-type ::= float-type | integer-type | index-type
vector-dim-list := (static-dim-list `x`)?
static-dim-list ::= static-dim (`x` static-dim)*
static-dim ::= (decimal-literal | `[` decimal-literal `]`)
```

- Dimensions must be positive. Zero is not allowed.
- A dimension in brackets is **scalable**: its real size is a run-time
  multiple of the written size (as in SVE).
- A 0-D vector has no dimensions: `vector<f32>`.
- Hex literals are not allowed. `vector<0x42xi32>` is read as shape
  `(0, 42)`, which is invalid because of the zero.

```mlir
vector<3x42xi32>      // 2-D fixed
vector<[4]xf32>       // 1-D scalable
vector<[2]x[8]xf32>   // 2-D, both scalable
vector<4x[4]xf32>     // 4 scalable vectors of 4 x f32
vector<2x[4]x8xf32>   // only the middle dimension is scalable
```

LangRef's alias example writes spaces around `x`: `vector<4 x f32>`. Spaces
are allowed between the tokens.

**Epitome note:** the lexer must split `4xf32` into `4`, `x`, `f32`. A
dimension list is digits, then `x`, then the next item. This is why
hexadecimal is banned inside shapes: `0xf32` would otherwise be a hex
literal.

**Epitome note:** LLVM IR has 1-D vectors only, written
`<4 x float>` and `<vscale x 4 x float>`. An MLIR multi-dimensional vector
has no direct LLVM IR type.

### 5.7 Tensor types

Ranked:

```
tensor-type ::= `tensor` `<` dimension-list type (`,` encoding)? `>`
dimension-list ::= (dimension `x`)*
dimension ::= `?` | decimal-literal
encoding ::= attribute-value
```

Unranked:

```
tensor-type ::= `tensor` `<` `*` `x` type `>`
```

A tensor is an N-dimensional value with a known element type. Its layout
in memory is hidden; `memref` is the type for buffers. Each dimension is a
non-negative number or `?` (dynamic). Zero is allowed. A rank-0 tensor
holds one element.

```mlir
tensor<? x ? x 13 x ? x f32>
tensor<17 x 4 x 13 x 4 x f32>
tensor<f32>                   // rank 0
tensor<0 x 42 x f32>          // zero-sized dimensions are allowed
tensor<0xf32>                 // not hex: 0 x f32
tensor<?x?xf64, #ENCODING>    // with an encoding attribute
tensor<*xf32>                 // unranked
```

The optional **encoding** is any attribute, for example a sparse-tensor
format. A missing encoding means a plain tensor.

**Not documented:** the encoding's interface. The page itself says "TODO:
provide this interface, and document it further."

### 5.8 Memref types

Ranked:

```
layout-specification ::= attribute-value
memory-space ::= attribute-value
memref-type ::= `memref` `<` dimension-list-ranked type
                (`,` layout-specification)? (`,` memory-space)? `>`
```

Unranked:

```
unranked-memref-type ::= `memref` `<*x` type (`,` memory-space)? `>`
memory-space ::= attribute-value
```

A memref is a reference to a region of memory, like a pointer with a shape.
It shares the tensor shape syntax. `memref<f32>`, `memref<0 x f32>`,
`memref<1 x 0 x f32>` and `memref<0 x 1 x f32>` are all different types.

Allowed element types: builtin integers, `index`, builtin floats, builtin
vectors of those, other memrefs, and any type that implements
`MemRefElementTypeInterface`.

**Layout.** The optional layout maps a multi-dimensional index to a
position in linear memory. Two in-bounds indices must not map to the same
element. The builtin layouts are:

| Layout | Syntax | Example |
| --- | --- | --- |
| Strided | `strided<[strides], offset: n>` (section 5.18) | `memref<2x3x4xf32, strided<[12, 4, 1]>>` |
| Affine map | an `affine_map<...>` attribute (section 6) | `memref<16x32xf32, affine_map<(d0, d1) -> (d1, d0)>>` |

Other attributes may be layouts if they implement
`MemRefLayoutAttrInterface` and can be turned into a semi-affine map.

- No layout means the identity map, laid out row-major.
- An explicit identity map is dropped when the type is built, so
  `memref<?x?xf32, affine_map<(i, j) -> (i, j)>>` is the same type as
  `memref<?x?xf32>`.
- In a strided layout, a missing offset means 0. So
  `memref<2, strided<[2], offset: 0>>` and `memref<2, strided<[2]>>` are the
  same type.
- A strided layout stands for the map
  `(d0, ... dN)[offset, stride0, ... strideN] -> (offset + d0 * stride0 + ... dN * strideN)`.

**Memory space.** The last parameter is any attribute: an integer, a
string, a dictionary or a dialect attribute. Its meaning is target-specific.
No memory space means the target's default.

```mlir
memref<16x32xf32, #identity>
memref<16x4x?xf32, #col_major>
memref<?x?xf32, #tiled_dynamic>
memref<*xf32>                    // unranked
memref<*f32, 10>                 // as printed on the page (see note)
```

Unranked memrefs exist so that external library functions can take a
memref of any rank. Other uses are discouraged.

**Not documented:** the page's examples write `memref<*f32>` and
`memref<*f32, 10>`, but the grammar and the text say `memref<*xf32>`. We
take `<*x` as correct and treat the examples as typos.

**Not documented:** `dimension-list-ranked` is not defined on the page. We
take it to be the tensor `dimension-list`. Also, the parser cannot tell a
layout from a memory space by position alone when only one extra attribute
is given. It must decide by kind: a layout attribute (strided, affine map,
or one implementing the layout interface) or a memory space (anything
else). How MLIR decides is not stated.

### 5.9 Function type

```
// Function types may have multiple results.
function-result-type ::= type-list-parens | non-function-type
function-type ::= type-list-parens `->` function-result-type
```

A list of parameter types and a list of result types. Used for function
signatures and for the type of every generic operation. Compare the looser
LangRef rule in section 2.7.

```mlir
(i32, f32) -> i64
() -> ()
(index) -> (i1, i1)
```

**Not documented:** `non-function-type` is not defined. We read it as any
type other than a function type.

### 5.10 Graph type

The page lists `GraphType`, but its description and syntax are a copy of
the function type's.

**Not documented:** the spelling and use of `GraphType`.

### 5.11 None type

```
none-type ::= `none`
```

A unit type: exactly one value, with no defined run-time form.

```mlir
%none_val = "foo.unknown_op"() : () -> none
```

### 5.12 Opaque type

```
opaque-type ::= `opaque` `<` type `>`
```

Holds a type of an unregistered dialect as raw text. The only useful test
is equality.

```mlir
opaque<"llvm", "struct<(i32, float)>">
opaque<"pdl", "value">
```

**Not documented:** the grammar says `opaque<type>`, but the examples show
two strings, the dialect namespace and the body. The parameters
(`dialectNamespace`, `typeData`) match the examples. The Rationale page says
an unregistered dialect type is held as an `OpaqueType`. It does not say
whether it prints back as `!dialect<...>` or as `opaque<...>`.

### 5.13 Token type

```
token-type ::= `token`
```

A value with no run-time data that links a use to the operation (or
region) that made it. Rules:

- A token may not be forwarded, for example as a successor operand of a
  branch.
- There are no token constants, and tokens do not constant-fold.
- CSE, DCE and hoisting are not affected by tokens.
- A token cannot cross an `IsolatedFromAbove` boundary.
- An operation must opt in with `TokenProducerTrait` or
  `TokenConsumerTrait` to make or use tokens.
- Tokens do not match the `AnyType` constraint.

This mirrors LLVM IR's `token` type.

### 5.14 Summary of builtin types

| Type | Spelling |
| --- | --- |
| Integer | `iN`, `siN`, `uiN` |
| Index | `index` |
| Float | `f16`, `bf16`, `f32`, `f64`, `f80`, `f128`, `tf32`, `f8...`, `f6...`, `f4E2M1FN` |
| Complex | `complex<T>` |
| Tuple | `tuple<T, ...>` |
| Vector | `vector<4x[8]xT>` |
| Ranked tensor | `tensor<4x?xT, enc>` |
| Unranked tensor | `tensor<*xT>` |
| Ranked memref | `memref<4x?xT, layout, space>` |
| Unranked memref | `memref<*xT, space>` |
| Function | `(T, ...) -> (T, ...)` |
| None | `none` |
| Token | `token` |
| Opaque | `opaque<"dialect", "data">` |

### 5.15 Builtin attributes: scalars

**Integer.**

```
integer-attribute ::= (integer-literal ( `:` (index-type | integer-type) )?)
                      | `true` | `false`
```

```mlir
10 : i32
10      // i64 is implied
true    // i1
false   // i1
```

With no type, an integer attribute is `i64`. An `i1` attribute prints as
`true` or `false`. There is no separate bool attribute class in the list;
booleans are `i1` integer attributes.

**Float.**

```
float-attribute ::= (float-literal (`:` float-type)?)
                  | (hexadecimal-literal `:` float-type)
```

```mlir
42.0         // float attribute defaults to f64 type
42.0 : f32   // float attribute of f32 type
0x7C00 : f16 // positive infinity
0x7CFF : f16 // NaN (one of possible values)
42 : f32     // Error: expected integer type
```

With no type, a float attribute is `f64`. A hex literal gives the raw bits
and must have a float type, else it is an integer.

**Epitome note:** a printer must use the hex form for infinities and NaNs.
LLVM IR does the same with `0x7FF0000000000000`, but MLIR's hex width
matches the float type (`0x7C00` for `f16`), not always 64 bits.

**Not documented:** when the printer chooses hex over decimal for finite
values, and how many digits it prints for decimal.

**String.**

```
string-attribute ::= string-literal (`:` type)?
```

```mlir
"An important string"
"string with a type" : !dialect.string
```

**Unit.**

```
unit-attribute ::= `unit`
```

Has only one value. Used for flags whose presence is the meaning. Inside a
dictionary, `{name}` is short for `{name = unit}`.

**Type.**

```
type-attribute ::= type
```

A type used as an attribute: `i32`, `!dialect.type`.

**Epitome note:** in attribute position, an identifier like `i32`, `index`
or `tensor<...>` is a type attribute, while `10` or `42.0` is a number.
The parser must try number, string, keyword attribute and type in a fixed
order. `true`, `false`, `unit`, `dense`, `sparse`, `array`, `affine_map`,
`affine_set`, `strided`, `distinct` and `loc` are attribute keywords, not
types.

**Symbol reference.**

```
symbol-ref-attribute ::= symbol-ref-id (`::` symbol-ref-id)*
```

`@flat_reference`, `@parent_reference::@nested_reference`. See section 4.8.

### 5.16 Builtin attributes: containers

**Array.**

```
array-attribute ::= `[` (attribute-value (`,` attribute-value)*)? `]`
```

```mlir
[]
[10, i32]
[affine_map<(d0, d1, d2) -> (d0, d1)>, i32, "string attribute"]
```

**Dictionary.**

```
dictionary-attribute ::= `{` (attribute-entry (`,` attribute-entry)*)? `}`
```

Entries are kept sorted by name, and names are unique.

```mlir
{}
{attr_name = "string attribute"}
{int_attr = 10, "string attr name" = "string attribute"}
```

**Epitome note:** sort entries when building a dictionary. Report duplicate
keys as an error. The sort order (byte order of the name, presumably) is
not stated.

**Dense array.**

```
dense-array-attribute ::= `array` `<` (integer-type | float-type)
                                      (`:` tensor-literal)? `>`
```

A flat 1-D list of bools, integers or floats whose width is a multiple of
8. Bools are stored as bytes. Unlike dense elements, there is no splat form.

```mlir
array<i8>
array<i32: 10, 42>
array<f64: 42., 12.>
```

Inside a custom operation format, a typed subclass (for example
`DenseI64ArrayAttr`) may be printed without the wrapper, as `[1, 2, 3]`.

**Not documented:** `tensor-literal` is not defined on the page. The
examples show a comma-separated list of numbers. Also, `array<i1: ...>` is
not shown, though bool elements are allowed.

### 5.17 Builtin attributes: elements

These hold data for every element of a tensor or vector type.

**Dense elements.** The page calls the class `DenseTypedElementsAttr`.

```mlir
// Literal-first syntax: A splat tensor of integer values.
dense<10> : tensor<2xi32>

// Literal-first syntax: A tensor of 2 float32 elements.
dense<[10.0, 11.0]> : tensor<2xf32>

// Type-first syntax: A splat tensor of integer values.
dense<tensor<2xi32> : 10 : i32>

// Type-first syntax: A tensor of 2 float32 elements.
dense<tensor<2xf32> : [10.0 : f32, 11.0 : f32]>
```

- The element count comes from the shaped type. Unranked types are not
  allowed.
- A single value is a **splat**: every element has that value.
- Nested brackets follow the shape: `dense<[[1, 2], [3, 4]]> : tensor<2x2xi32>`.
- The literal-first form is only for complex, float, index and integer
  elements. Other element types use the type-first form.
- Storage: element `i` starts at byte `i * ceildiv(w, 8)` for element width
  `w`. Every element starts on a whole byte.

**Not documented:** the hex form. MLIR is known to print large dense data as
`dense<"0x...">`, a hex string of the raw bytes, but the Builtin page does
not show or define it. Its byte order, the splat case, and the threshold
for using it are unknown. The complex literal syntax (likely `(re, im)`) is
also not shown.

**Dense strings.**

```
dense-string-elements-attribute ::= `dense` `<` attribute-value `>` `:`
                                    ( tensor-type | vector-type )
```

```mlir
dense<"example"> : tensor<2x!foo.string>
dense<["example1", "example2"]> : tensor<2x!foo.string>
```

Any element type is allowed, so dialect string types work.

**Dense resource.**

```
dense-resource-elements-attribute ::=
  `dense_resource` `<` resource-handle `>` `:` shaped-type
```

The data lives in a builtin dialect resource, named by the handle, in the
file's `{-# dialect_resources: { builtin: { ... } } #-}` block
(section 2.12). Typed views exist for bool, integer and float elements.

**Sparse elements.**

```
sparse-elements-attribute ::= `sparse` `<` attribute-value `,`
                              attribute-value `>` `:`
                              ( tensor-type | vector-type )
```

Coordinate-list (COO) form. The first value is an `[N, rank]` tensor of
64-bit indices. The second is an `[N]` list of values. All other elements
are zero.

```mlir
sparse<[[0, 0], [1, 2]], [1, 5]> : tensor<3x4xi32>
//  [[1, 0, 0, 0],
//   [0, 0, 5, 0],
//   [0, 0, 0, 0]]
```

### 5.18 Builtin attributes: layouts and polyhedral values

**Affine map.**

```
affine-map-attribute ::= `affine_map` `<` affine-map `>`
```

`affine_map<(d0) -> (d0)>`, `affine_map<(d0, d1, d2) -> (d0, d1)>`. See
section 6.

**Integer set.**

```
integer-set-attribute ::= `affine_set` `<` integer-set `>`
```

`affine_set<(d0) : (d0 - 2 >= 0)>`. See section 6.

**Strided layout.**

```
strided-layout-attribute ::= `strided` `<` `[` stride-list `]`
                             (`,` `offset` `:` dimension)? `>`
stride-list ::= /*empty*/
              | dimension (`,` dimension)*
dimension ::= decimal-literal | `?`
```

One stride per dimension, in elements. An optional offset to the first
element, also in elements. `?` means dynamic. Strides must be positive and
the offset non-negative, at run time too; breaking this is undefined
behaviour.

```mlir
strided<[12, 4, 1]>
strided<[?, 1], offset: ?>
```

### 5.19 Builtin attributes: opaque and distinct

**Opaque.**

```
opaque-attribute ::= dialect-namespace `<` attr-data `>`
```

An attribute of an unregistered dialect, kept as raw text:
`#dialect<"opaque attribute data">`. Only equality is meaningful. It also
has a type parameter.

**Distinct.**

```
distinct-id ::= integer-literal
distinct-attribute ::= `distinct` `[` distinct-id `]<` attribute `>`
```

```mlir
#distinct = distinct[0]<42.0 : f32>
#distinct1 = distinct[1]<42.0 : f32>
#distinct2 = distinct[2]<array<i32: 10, 42>>
```

Normal attributes are unique by value: two equal attributes are the same
object. A distinct attribute is not. It wraps a value with a fresh
identity, so `#distinct` and `#distinct1` above differ though they wrap the
same float. The number in brackets is assigned when printing, like value
names, and only links uses within one file. Use: marking groups, such as
alias-analysis scopes.

**Epitome note:** this is the MLIR equivalent of LLVM IR's `distinct !{}`
metadata. When reading, the same `distinct[N]` in one file must give the
same attribute. The number itself is not kept.

### 5.20 Location attributes

```
callsite-location ::= `callsite` `(` location `at` location `)`

filelinecol-location ::= string-literal `:` integer-literal `:`
                         integer-literal
                         (`to` (integer-literal ?) `:` integer-literal ?)

fusion-metadata ::= `<` attribute-value `>`
fused-location ::= `fused` fusion-metadata? `[` (location (`,` location)* )? `]`

name-location ::= string-literal (`(` location `)`)?

unknown-location ::= `?`
```

| Class | Meaning |
| --- | --- |
| `CallSiteLoc` | A callee location and the caller location it was reached from. Nests to form a stack. |
| `FileLineColRange` | A file with a line, a line and column, or a range: `file:line`, `file:line:col`, `file:line:col to :col`, `file:line:col to line:col`. |
| `FusedLoc` | Several locations merged into one, with optional metadata such as the name of the pass that merged them. |
| `NameLoc` | A name, optionally with a child location. Used for variable or node names. |
| `OpaqueLoc` | A pointer to an outside structure plus a fallback location. Only the fallback is serialised. |
| `UnknownLoc` | No location. Printed `loc(?)`. |

**Not documented:** the description lists `file:line` without a column,
but the grammar requires `string : int : int`. The page also does not
explain the `to` grammar's two optional parts clearly. Epitome should
accept the four forms listed in the description.

**Epitome note:** LLVM IR keeps source positions in `!DILocation`
metadata, separately from instructions. In MLIR, every operation has a
location. When importing LLVM IR to MLIR, debug locations become MLIR
locations.

### 5.21 Builtin operations

**`builtin.module`**

```
operation ::= `builtin.module` ($sym_name^)? prop-dict attr-dict-with-keyword $bodyRegion
```

```mlir
module {
  func.func @foo()
}
module @named attributes {foo.bar = 1} {
}
```

A top-level container. Its region is a graph region with one block, no
arguments and no terminator. It is isolated from above and is a symbol
table. It may have a symbol name. The page also shows an inherent `dlti`
attribute in properties:

```mlir
module <{dlti = #dlti.map<"chip" = "sm_90">}> {}
```

| Item | Value |
| --- | --- |
| Traits | `AffineScope`, `HasOnlyGraphRegion`, `IsolatedFromAbove`, `NoRegionArguments`, `NoTerminator`, `SingleBlock`, `SymbolName`, `SymbolTable`, `SymbolVisibility` |
| Interfaces | `OpAsmOpInterface`, `RegionKindInterface`, `Symbol` |
| Attributes | `sym_name` (string), `sym_visibility` (string), `dlti` (any attribute implementing `DLTIQueryInterface`) |

**Not documented:** whether a file whose top level holds operations other
than one `module` is wrapped in an implicit module by the parser. LangRef's
first example has two `func.func` at the top level with no module. Epitome
should wrap such files in an unnamed module, and accept a file holding a
single explicit module as that module.

**`builtin.unrealized_conversion_cast`**

```
operation ::= `builtin.unrealized_conversion_cast` ($inputs^ `:` type($inputs))? `to` type($outputs) attr-dict
```

```mlir
%result = unrealized_conversion_cast to !bar.tuple_type<>
%result1 = unrealized_conversion_cast %operand : !foo.type to !bar.lowered_type
%results2:2 = unrealized_conversion_cast %tuple_operand : !foo.tuple_type<!foo.type, !foo.type> to !foo.type, !foo.type
%result3 = unrealized_conversion_cast %operand, %operand : !foo.type, !foo.type to !bar.tuple_type<!foo.type, !foo.type>
```

A placeholder that converts 0 to N inputs into 1 to N outputs while one
type system is being lowered to another. It has no meaning of its own and
should be gone when conversion ends. It has no memory effects and is always
speculatable. Inputs and outputs are any non-token type.

**Epitome note:** if Epitome imports MLIR and finds this operation, the
input was not fully lowered. Report an error rather than guess.

---

## 6. Affine maps and integer sets

Source: https://mlir.llvm.org/docs/Dialects/Affine/ (Polyhedral
Structures), https://mlir.llvm.org/docs/Dialects/Builtin/ (MemRefType,
AffineMapAttr, IntegerSetAttr), https://mlir.llvm.org/docs/Traits/
(AffineScope). Read 2026-10-20.

### 6.1 Dimensions and symbols

An affine map or integer set has two kinds of inputs, both of `index`
type:

| Kind | Written | Meaning |
| --- | --- | --- |
| Dimension | In parentheses: `(d0, d1)` | An index that varies, such as a loop variable or array subscript. |
| Symbol | In square brackets: `[s0]` | An unknown that is fixed for the region of interest, such as a size. |

When an operation applies a map, it binds SSA values the same way:

```
dim-use-list ::= `(` ssa-use-list? `)`
symbol-use-list ::= `[` ssa-use-list? `]`
dim-and-symbol-use-list ::= dim-use-list symbol-use-list?
```

```mlir
#affine_map2to3 = affine_map<(d0, d1)[s0] -> (d0, d1 + s0, d1 - s0)>
// Binds %N to the s0 symbol in affine_map2to3.
%x = memref.alloc()[%N] : memref<40x50xf32, #affine_map2to3>
```

### 6.2 Which values may be symbols

A value may be bound to a symbol if it is:

1. a region argument of an `AffineScope` operation (such as a function);
2. defined directly at the top level of an `AffineScope` operation;
3. defined outside, and dominating, the `AffineScope` operation that holds
   the use;
4. the result of a constant operation;
5. the result of a `Pure` operation whose operands are valid symbols;
6. the result of a `dim` operation on a suitable memref.

If the use is in no `AffineScope`, only rules 4 to 6 apply. Dimensions
accept anything a symbol accepts, plus `affine.for` and `affine.parallel`
induction variables and `affine.apply` results.

This is a verification rule for the affine dialect, not part of the
syntax.

### 6.3 Affine expressions

```
affine-expr ::= `(` affine-expr `)`
              | affine-expr `+` affine-expr
              | affine-expr `-` affine-expr
              | `-`? integer-literal `*` affine-expr
              | affine-expr `ceildiv` integer-literal
              | affine-expr `floordiv` integer-literal
              | affine-expr `mod` integer-literal
              | `-`affine-expr
              | bare-id
              | `-`? integer-literal

multi-dim-affine-expr ::= `(` `)`
                        | `(` affine-expr (`,` affine-expr)* `)`
```

- `ceildiv` rounds up, `floordiv` rounds down. `mod` gives a non-negative
  result. Their right-hand constant must be positive.
- Multiplication must have a constant on one side.
- Precedence, highest first: parentheses; unary minus; `*`, `floordiv`,
  `ceildiv`, `mod`; then `+` and `-`. All are left-associative.
- A `bare-id` must be one of the map's dimension or symbol names.

These are "quasi-affine" functions: linear, plus a constant, plus division
and modulo by positive constants. `(i * j)` and `(i mod j)` are not affine.

### 6.4 Affine maps

```
affine-map-inline
   ::= dim-and-symbol-value-lists `->` multi-dim-affine-expr
```

Names in the dimension and symbol lists must be unique, and only those
names may appear in the results. A map with symbols is "symbolic".

```
affine-map-id ::= `#` suffix-id

// Definitions of affine maps are at the top of the file.
affine-map-def    ::= affine-map-id `=` affine-map-inline
module-header-def ::= affine-map-def

// Uses of affine maps may use the inline form or the named form.
affine-map ::= affine-map-id | affine-map-inline
```

In current MLIR, a named map is an ordinary attribute alias of an
`affine_map<...>` attribute:

```mlir
#affine_map42 = affine_map<(d0, d1)[s0] -> (d0, d0 + d1 + s0 floordiv 2)>
%a = memref.alloc()[%N] : memref<4x4xf32, #affine_map42>
%b = memref.alloc()[%N] : memref<4x4xf32, affine_map<(d0, d1)[s0] -> (d0, d0 + d1 + s0 floordiv 2)>>
```

Dimensions are bound each time the map is applied. Symbols are bound when
the map is set up, for example when a memref is allocated with that layout.

**Not documented:** `dim-and-symbol-value-lists` is not defined. From the
examples it is `( id-list? )` followed by an optional `[ id-list? ]`. The
names are not fixed to `d0` and `s0`; the Builtin page uses `(i, j)`. The
printer appears to use `d0, d1, ...` and `s0, s1, ...`.

**Not documented:** the Affine page's `affine-map-def` grammar has no
`affine_map<...>` wrapper, and some Builtin examples use the older bare
form `#layout_map_row_major = (i, j) -> (i, j)`. One Builtin example uses
`div`, which is not in the grammar. Epitome should accept only the wrapped
form and treat the others as outdated.

### 6.5 Semi-affine maps

Semi-affine maps also allow `*`, `floordiv`, `ceildiv` and `mod` by a
**symbol**, not only by a constant:

```
semi-affine-expr ::= `(` semi-affine-expr `)`
                   | semi-affine-expr `+` semi-affine-expr
                   | semi-affine-expr `-` semi-affine-expr
                   | symbol-or-const `*` semi-affine-expr
                   | semi-affine-expr `ceildiv` symbol-or-const
                   | semi-affine-expr `floordiv` symbol-or-const
                   | semi-affine-expr `mod` symbol-or-const
                   | bare-id
                   | `-`? integer-literal

symbol-or-const ::= `-`? integer-literal | symbol-id
```

Memref layouts are semi-affine maps, so this is the grammar a memref layout
parser needs:

```mlir
#tiled_dynamic = affine_map<(d0, d1)[s0, s1] -> (d0 floordiv s0, d1 floordiv s1,
                             d0 mod s0, d1 mod s1)>
```

**Epitome note:** `affine_map<...>` holds one parser for both. The
restrictions of plain affine maps are checked where a strict affine map is
required (for example by `affine.apply`), not by the attribute parser.

### 6.6 Integer sets

```
affine-constraint ::= affine-expr `>=` `affine-expr`
                    | affine-expr `<=` `affine-expr`
                    | affine-expr `==` `affine-expr`
affine-constraint-conjunction ::= affine-constraint (`,` affine-constraint)*

integer-set-id ::= `#` suffix-id

integer-set-inline
   ::= dim-and-symbol-value-lists `:` '(' affine-constraint-conjunction? ')'

// Declarations of integer sets are at the top of the file.
integer-set-decl ::= integer-set-id `=` integer-set-inline

// Uses of integer sets may use the inline form or the named form.
integer-set ::= integer-set-id | integer-set-inline
```

An integer set is the set of integer points (dimensions) satisfying all
constraints, for given symbol values. The constraints are joined by "and".
An empty constraint list means no bound.

```mlir
#set42 = affine_set<(d0, d1)[s0, s1]
   : (d0 >= 0, -d0 + s0 - 1 >= 0, d1 >= 0, -d1 + s1 - 1 >= 0)>

affine.if #set42(%i, %j)[%M, %N] {
  ...
}
```

**Not documented:** the grammar quotes the right-hand `affine-expr` in
backticks, as if it were a literal. This is a typo. Also, only the
examples show that MLIR prints constraints with `0` on the right.

---

## 7. Bytecode format

Source: https://mlir.llvm.org/docs/BytecodeFormat/, and LangRef (IR
Versioning). Read 2026-10-20.

### 7.1 Purpose and stability

Bytecode is MLIR's binary form. The format is versioned. MLIR promises that
newer readers accept older bytecode, and that writers can target an older
format version. This only holds if the dialects themselves do not change.

A dialect may store its own version in the file through
`BytecodeDialectInterface`, and upgrade old IR after reading with
`upgradeFromVersion`. LangRef says versioning is only supported in
bytecode, not text.

### 7.2 Magic number

The file starts with four bytes: `4D 4C EF 52`, which is `M`, `L`, `ï`,
`R`. (The `ï` is byte `0xEF`, not UTF-8.)

### 7.3 Primitives

| Primitive | Encoding |
| --- | --- |
| Fixed-width integer | Unsigned, little-endian, known size. |
| VarInt | "PrefixVarInt": 1 to 9 bytes for a 64-bit value. The low bits of the first byte hold a unary length: zero bits followed by a 1. |
| Signed VarInt | Zigzag first: `(value << 1) ^ (value >> 63)`, then VarInt. |
| String | Characters with a length. In practice, an index into the string section. |

VarInt first-byte patterns (low bit on the right):

```
xxxxxxx1:  7 value bits, the encoding uses 1 byte
xxxxxx10: 14 value bits, the encoding uses 2 bytes
xxxxx100: 21 value bits, the encoding uses 3 bytes
xxxx1000: 28 value bits, the encoding uses 4 bytes
xxx10000: 35 value bits, the encoding uses 5 bytes
xx100000: 42 value bits, the encoding uses 6 bytes
x1000000: 49 value bits, the encoding uses 7 bytes
10000000: 56 value bits, the encoding uses 8 bytes
00000000: 64 value bits, the encoding uses 9 bytes
```

**Not documented:** the bit order of the value across bytes. The text
says the remaining bits of the first byte and all bits of the following
bytes "provide the value". We read it as little-endian: shift the first
byte right by (length) bits, then append each following byte above it.
Check with a real file.

**Epitome note:** this is not the LEB128 used by LLVM's bitcode or DWARF,
and not LLVM's VBR fields. It needs its own reader.

### 7.4 Sections

```
section {
  idAndIsAligned: byte // id | (hasAlign << 7)
  length: varint,

  alignment: varint?,
  padding: byte[], // Padding bytes are always `0xCB`.

  data: byte[]
}
```

- The low 7 bits of the first byte are the section ID. The high bit says an
  alignment follows.
- `length` lets a reader skip the section.
- If aligned, padding bytes `0xCB` come before the data. Alignment is a
  power of two. The whole input buffer must be at least as aligned as any
  section.
- Each section appears at most once.

Top level:

```
bytecode {
  magic: "MLïR",
  version: varint,
  producer: string,
  sections: section[]
}
```

The producer is a null-terminated string written inline.

### 7.5 Section contents

| Section | Contents |
| --- | --- |
| String | `numStrings`, then each string's length **in reverse order**, then all strings concatenated. Other sections refer to strings by index. |
| Dialect | Each dialect's name (string index) with a flag for "has version"; the version as a nested blob; then operation names grouped by dialect, each with a flag for "is registered". |
| Attribute/type | The encoded attributes, then the encoded types. |
| Attribute/type offsets | Counts of attributes and types, then groups per dialect. Each entry is `(size << 1) \| hasCustomEncoding`. Sizes, not absolute offsets, to compress better. |
| Resource | The values of resources: bool (byte), string (string index), or blob (alignment, size, padding, bytes). |
| Resource offsets | Number of external resource groups, then groups keyed by provider (dialect or external entity), each entry giving key, size and kind. |
| IR | One block with no arguments, holding the top-level operations. |

Dialect section layout:

```
dialect_section {
  numDialects: varint,
  dialectNames: dialect_name_group[],
  opNames: dialect_ops_group[]  // ops grouped by dialect
}

dialect_name_group {
  nameAndIsVersioned: varint  // (dialectID << 1) | (hasVersion),
  version: dialect_version_section  // only if versioned
}

dialect_ops_group {
  dialect: varint,
  numOpNames: varint,
  opNames: op_name_group[]
}

op_name_group {
  nameAndIsRegistered: varint  // (nameID << 1) | (isRegisteredOp)
}
```

### 7.6 Attribute and type encodings

Each attribute or type is encoded one of two ways:

1. **Text fallback.** Its textual form as a null-terminated string, for
   example `"!bytecode.type<42>"`. Any attribute or type can be written
   this way.
2. **Dialect encoding.** A custom binary form written by the dialect's
   `writeAttribute`/`writeType` and read by `readAttribute`/`readType`. The
   dialect chooses the whole layout. A common habit is a leading varint
   saying which kind follows.

The flag in the offset section says which one is used.

**Epitome note:** a reader that knows no dialect encodings can still read
any text-fallback entry with the text parser from sections 2 and 5. The
builtin dialect almost certainly uses a custom encoding, which is not
documented (see 7.9).

### 7.7 Operations, regions and blocks

```
op {
  name: varint,
  encodingMask: byte,
  location: varint,

  attrDict: varint?,

  numResults: varint?,
  resultTypes: varint[],

  numOperands: varint?,
  operands: varint[],

  numSuccessors: varint?,
  successors: varint[],

  numUseListOrders: varint?,
  useListOrders: uselist[],

  regionEncoding: varint?, // (numRegions << 1) | (isIsolatedFromAbove)

  // regions are stored in a section if isIsolatedFromAbove
  regions: (region | region_section)[]
}

region {
  numBlocks: varint,

  numValues: varint?,
  blocks: block[]
}

block {
  encoding: varint, // (numOps << 1) | (hasBlockArgs)
  arguments: block_arguments?, // Optional based on encoding
  ops : op[]
}

block_arguments {
  numArgs: varint?,
  args: block_argument[]
  numUseListOrders: varint?,
  useListOrders: uselist[],
}

block_argument {
  typeAndLocation: varint, // (type << 1) | (hasLocation)
  location: varint? // Optional, else unknown location
}
```

Key points:

- `name` indexes the operation names from the dialect section.
- `encodingMask` says which optional fields are present.
- `location` and `attrDict` index the attribute table. Result types index
  the type table.
- An operand is a value number: the position of its definition counted
  from the start of the nearest isolated-from-above ancestor region.
- A successor is the block's index in the parent region.
- An isolated operation's regions are stored in their own section, so they
  can be read lazily.
- A region gives its block count, then (if non-empty) the number of values
  defined directly in it.

**Use-list orders.** MLIR keeps the order of each value's uses. The
expected order is the reverse of the order operands are met in a pre-order
walk. If a value's uses are in a different order, a permutation is stored:
either a full index list, or `(i, j)` pairs when fewer than half the uses
moved. The low bit of `useListEncoding` picks the form.

### 7.8 Properties in bytecode

**Not documented:** the page does not mention properties. Operations that
store inherent attributes in properties must encode them somewhere, but the
`op` record above has no field for them.

### 7.9 What the bytecode page leaves out

**Not documented:** the numeric section IDs, the current format version
number and what changed in each version, the bit assignments in
`encodingMask`, the `uselist` field `indexInRange`, the encoding of builtin
attributes and types, and the `region_section` layout. Epitome would have
to learn these from files written by MLIR's tools. Until then, Epitome
should read MLIR as text, and convert bytecode to text with `mlir-opt`
first.

---

## 8. Diagnostics and verification

Source: https://mlir.llvm.org/docs/Diagnostics/,
https://mlir.llvm.org/docs/DefiningDialects/Operations/ (custom verifiers),
https://mlir.llvm.org/docs/LangRef/. Read 2026-10-20.

### 8.1 Parsing versus verification

As in LLVM IR, the parser accepts more than is valid. A separate verifier
checks the rules. The rules a reader of MLIR must check, gathered from the
sections above:

| Rule | Section |
| --- | --- |
| Every used value name is defined in scope. | 4.4 |
| In SSACFG regions, every use is dominated by its definition (hierarchical dominance). | 4.4 |
| Graph regions have one block. | 4.3 |
| Every block ends in a terminator, unless the parent has `NoTerminator`. `NoTerminator` regions have one block. | 4.6 |
| Successors are blocks of the same region. The entry block is never a successor. | 4.2 |
| `IsolatedFromAbove` regions use no outside values. | 4.5 |
| Symbol names are unique in each symbol table. Nested references go through symbol tables. Declarations are not public. | 4.8, 4.9 |
| Result count matches the function type; operand count matches the operand list. | 2.4 |
| Dictionary keys are unique. | 5.16 |
| Discardable attributes have a dialect prefix; inherent ones do not. | 2.9 |
| Aliases are defined before use and contain no `.`. | 2.8 |
| Shapes: vector dimensions positive, tensor and memref dimensions non-negative or `?`, no hex in shapes. | 5.6 to 5.8 |
| Dense elements: value count is 1 (splat) or matches the shape. | 5.17 |
| Tokens are not forwarded through branches and do not cross isolation. | 5.13 |
| Each operation's own rules (types of operands, required attributes, parent operation). | per dialect |

**Not documented:** the order in which MLIR runs these checks, and whether
it stops at the first error.

### 8.2 Diagnostics

A diagnostic has a location, a severity (`Error`, `Warning`, `Remark`,
`Note`), a message built from arguments, and optional metadata not shown in
the message. Notes attach to another diagnostic.

When an operation is printed inside an **error**, it is printed in generic
form, because the operation may be invalid and its custom printer may
assume validity. Other severities use the custom form. The
`-mlir-print-op-on-diagnostic` flag attaches the failing operation to the
message.

Errors from an operation's verifier begin with `'op-name' op`. Text output
uses the familiar `file:line:col: error: message` form, with the source line
and a caret:

```
/tmp/test.mlir:6:24: error: expected non-function type
func.func @foo() -> (index, ind) {
                       ^
```

### 8.3 Expected-diagnostic comments

MLIR's tests mark expected diagnostics with comments:

```
expected-(error|note|remark|warning)(-re)? {{ message }}
```

- `@+N` and `@-N` move the expected line; `@above` and `@below` mean the
  nearest line without a designator.
- With `-re`, `{{...}}` inside the message is an extended POSIX regex.
- The check fails on any unexpected diagnostic and on any expected
  diagnostic that was not produced.

```mlir
func.func @bad_branch() {
  cf.br ^missing  // expected-error {{reference to an undefined block}}
}
```

**Epitome note:** Epitome's MLIR reader can reuse this convention for its
own error tests. The messages need not match MLIR's.

---

## Still to read

These public documents may close gaps marked above.

| Gap | Document |
| --- | --- |
| `func.func`, `func.return`, `func.call` custom syntax and the default dialect for unprefixed names | [Func dialect](https://mlir.llvm.org/docs/Dialects/Func/) |
| The `llvm` dialect: types, linkage, the mapping to LLVM IR | [LLVM dialect](https://mlir.llvm.org/docs/Dialects/LLVM/), [LLVM IR target](https://mlir.llvm.org/docs/TargetLLVMIR/) |
| `cf.br` and `cf.cond_br` custom syntax and successor operands | [ControlFlow dialect](https://mlir.llvm.org/docs/Dialects/ControlFlowDialect/) |
| `mlir-opt` global flags (`--mlir-print-op-generic`, `--mlir-print-debuginfo`, `--mlir-print-local-scope`, `--emit-bytecode`, `-allow-unregistered-dialect`) | [mlir-opt](https://mlir.llvm.org/docs/Tools/MLIROpt/) and `mlir-opt --help` |
| Exact keywords for the small float types and `tf32` | Run `mlir-opt` on test inputs; record as observed behaviour |
| The `dense<"0x...">` hex form, its byte order and when it is used | Run `mlir-opt` on large constants; record as observed behaviour |
| `#loc` aliases: syntax and placement at the end of the file | Run `mlir-opt --mlir-print-debuginfo`; record as observed behaviour |
| Implicit top-level module, parser default locations | [Pass management](https://mlir.llvm.org/docs/PassManagement/), observed behaviour |
| String literal escapes | Observed behaviour |
| Bytecode section IDs, versions, `encodingMask` bits, properties, builtin encodings | No public page found. Learn from files written by MLIR's tools |
| Declarative format details: optional groups, `functional-type`, `oilist`, `ref` | [Operation definition](https://mlir.llvm.org/docs/DefiningDialects/Operations/), Declarative Assembly Format, read in full |
| Attribute and type assembly formats (`struct`, `params`) used by dialect pretty forms | [Attributes and types](https://mlir.llvm.org/docs/DefiningDialects/AttributesAndTypes/) |
| Data layout (`dlti`) and the width of `index` | [DLTI dialect](https://mlir.llvm.org/docs/Dialects/DLTIDialect/), [Data layout](https://mlir.llvm.org/docs/DataLayout/) |
| Sparse tensor encodings | [SparseTensor dialect](https://mlir.llvm.org/docs/Dialects/SparseTensorOps/) |
| Design background: regions, symbols, progressive lowering | Lattner et al., CGO 2021, read in full |

## Conventions

As in the [LLVM IR reference](../llvm-ir/README.md):

- **Epitome note:** something the documentation implies for our
  implementation.
- **Not documented:** a question the documentation does not answer. Epitome
  decides these for itself, and records the decision in the design docs.

Exact names, keywords and grammar are copied from the documentation because
Epitome must read and write them. Explanations are in our own words.
