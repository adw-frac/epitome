# Metadata

Source: LLVM Language Reference, sections "Metadata" to "Intrinsic Global Variables" (including Module Flags Metadata, Embedded Objects, Automatic Linker Flags, Dependent Libs, `llvm.errno.tbaa` and ThinLTO Summary).

A few facts in this chapter come from the `load` instruction section of the
same manual (`!nonnull`, `!align`, `!noundef`, `!nontemporal`). Those places
are marked.

## Overview

Metadata is extra information attached to the program. Optimizers and the
code generator may read it. It does not change what the program computes
unless a metadata kind says otherwise (many kinds make a promise, and breaking
the promise is undefined behavior or yields poison).

Key facts:

- Metadata has no type. It is not a value.
- There are two primitive forms: **strings** (`MDString`) and **nodes**
  (`MDNode`). There are also **specialized nodes**: nodes with a fixed name
  and labelled fields. Today every specialized node is a debug-info node.
- Every metadata item is written starting with `!`, except a typed value used
  in metadata position, which is written `<type> <value>`.

### Metadata in value positions

Metadata may appear where a value is expected only when the type is written
as `metadata`. This is allowed in:

- arguments to certain intrinsic functions (each intrinsic says so);
- arguments to the `catchpad` and `cleanuppad` instructions.

There are two wrapper concepts:

| Wrapper | Meaning |
| --- | --- |
| `MetadataAsValue` | A metadata item used as a value. It is a Value. |
| `ValueAsMetadata` | A typed value used as metadata. It is Metadata. |

`ValueAsMetadata` has no syntax of its own. The parser tells the two forms
apart because a type can never begin with `!`.

```llvm
call void @llvm.foo(metadata i32 1)   ; MetadataAsValue(ValueAsMetadata(i32 1))
call void @llvm.foo(metadata !0)      ; MetadataAsValue(MDNode !0)
!{!0}                                 ; tuple whose element is an MDNode
!{i32 1}                              ; tuple whose element is ValueAsMetadata
```

**Epitome note:** after the keyword `metadata`, peek at the next token. If it
starts with `!`, parse metadata. Otherwise parse `<type> <value>` and wrap it.

## Metadata strings (MDString)

Grammar:

```
mdstring ::= '!' '"' chars '"'
```

Any character may appear. Non-printable characters are escaped as `\xx`,
where `xx` is two hex digits. Example: `!"test\00"`.

An MDString is metadata, but it is not a metadata node.

## Metadata nodes (MDNode)

### Tuples

A generic node (a tuple, `MDTuple`) looks like a structure constant: a
comma-separated list in braces, preceded by `!`.

```
mdtuple ::= ['distinct'] '!' '{' [ mdoperand (',' mdoperand)* ] '}'
mdoperand ::= 'null' | metadata-ref | mdstring | mdnode | type value
metadata-ref ::= '!' number   |   '!' name
```

Example: `!{!"test\00", i32 10}`.

Operands may be any values. `null` is allowed as an operand (seen in
`DISubroutineType` and `!inline_history` examples).

### Numbered definitions and `distinct`

Nodes are usually defined at module level with a number:

```llvm
!0 = !{!"test\00", i32 10}
!1 = distinct !{!"test\00", i32 10}
```

- By default nodes are **uniqued**: two nodes with identical contents are
  the same node.
- `distinct` turns uniquing off. Use it when nodes must not be merged by
  content. A `distinct` node can also appear when a transformation changes
  operands and two uniqued nodes would otherwise collide.

**Epitome note:** the in-memory model needs a uniquing table keyed by
(kind, operands) for non-distinct nodes, and a separate identity for each
distinct node. Self-referential nodes (for example `!0 = !{!0}`) must be
supported, so parsing needs forward references.

### Named metadata

Named metadata is a module-level list of nodes, found by name in the
module's symbol table.

```
named-md ::= '!' name '=' '!' '{' [ metadata-ref (',' metadata-ref)* ] '}'
```

Example: `!foo = !{!4, !3}`.

### Attachments

Metadata attaches to instructions, functions and global variables with
`!kind !node`.

```llvm
%indvar.next = add i64 %indvar, 1, !dbg !21

declare !dbg !22 void @f1()
define void @f2() !dbg !22 {
  ret void
}
@g1 = global i32 0, !dbg !22
@g2 = external global i32, !dbg !22
```

Placement:

- Instruction: after the operands, as `, !kind !N`. Several may follow.
- Function declaration: after `declare`, before the return type.
- Function definition: after the signature and attributes, before `{`.
- Global variable: after the initializer and other fields, as `, !kind !N`.

The attached operand may also be an inline node, for example
`!captures !{!"address"}` or `!elf_section_properties !{i32 1879002126, i32 8}`.

Rules:

- An instruction may not have two attachments with the same kind.
- A global object (function or global variable) **may** have several
  attachments with the same kind (see `!implicit.ref`, `!type`).

### Dropping rules

- A transformation must drop any metadata attachment it does not understand
  or cannot keep correct.
- Exception: on globals, `!func_sanitize`, `!type`, `!absolute_symbol`,
  `!implicit.ref` and `!associated` may not be dropped unless the global
  itself is deleted.
- Named metadata on the module may not be dropped, except debug metadata
  (named metadata whose name is `!llvm.dbg.*`).

**Epitome note:** a "strip unknown metadata" utility must keep that list of
global attachments and all non-debug named metadata.

## Specialized metadata nodes

A specialized node has a fixed name and labelled fields. Fields may be
written in any order.

```
specialized ::= ['distinct'] '!' NodeName '(' [ field (',' field)* ] ')'
field ::= fieldname ':' fieldvalue
fieldvalue ::= integer | 'true' | 'false' | string | 'null'
             | metadata-ref | inline-node | DWARF-enum-name | flag ('|' flag)*
             | type value
```

The documentation gives each node by example. It does not give a full field
list or the default value of every field, except where noted.

**Not documented:** the full field list, field types and defaults for most
nodes. The tables below list the fields that the manual names or uses in its
examples. The "type" column is inferred from those examples. Epitome must
decide the complete set elsewhere.

Common field value types used below:

| Type label | Meaning |
| --- | --- |
| int | Integer literal (may be negative where noted) |
| bool | `true` or `false` |
| string | Quoted string `"..."` |
| md | Reference to a node (`!N`), an inline node, or `null` |
| enum | A bare symbolic name such as `DW_TAG_member` |
| flags | One or more flag names joined with `\|` |

### DICompileUnit

A compile unit: the root scope for everything declared in one translation
unit. All compile units are listed in named metadata `!llvm.dbg.cu`.

```llvm
!0 = !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang",
                    isOptimized: true, flags: "-O2", runtimeVersion: 2,
                    splitDebugFilename: "abc.debug", emissionKind: FullDebug,
                    enums: !2, retainedTypes: !3, globals: !4, imports: !5,
                    macros: !6, dwoId: 0x0abcd)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `language:` | enum | Source language, e.g. `DW_LANG_C99`, `DW_LANG_C_plus_plus` |
| `file:` | md | The `DIFile` |
| `producer:` | string | Name of the producing compiler |
| `isOptimized:` | bool | Whether the code was optimized |
| `flags:` | string | Command-line flags |
| `runtimeVersion:` | int | Runtime version |
| `splitDebugFilename:` | string | Name of the split debug file |
| `emissionKind:` | enum | How much debug info to emit, e.g. `FullDebug` |
| `enums:` | md | Tuple of enumeration types to emit |
| `retainedTypes:` | md | Tuple of types to emit regardless of use |
| `globals:` | md | Tuple of `DIGlobalVariableExpression`s |
| `imports:` | md | Tuple of `DIImportedEntity`s |
| `macros:` | md | Tuple of `DIMacro` / `DIMacroFile` nodes |
| `dwoId:` | int | Split-DWARF id (hex literal allowed, e.g. `0x0abcd`) |
| `debugInfoForProfiling:` | bool | Update line-table discriminators for more accurate profiling |
| `dialect:` | enum or int | Optional source-language dialect |

The `enums:`, `retainedTypes:`, `globals:`, `imports:` and `macros:` tuples
are emitted with the unit no matter what optimization does.

`dialect:` maps to `DW_AT_LLVM_language_dialect`. It must name a known
dialect, either by symbol (for example `DW_LLVM_LANG_DIALECT_simt`) or by the
matching number. Leaving the field out is the only way to say "no dialect".

**Not documented:** the full list of `emissionKind:` values and dialect
names (the manual points to a separate "LLVM Language Dialect" page).

### DIFile

A source file.

```llvm
!0 = !DIFile(filename: "path/to/file", directory: "/path/to/dir",
             checksumkind: CSK_MD5,
             checksum: "000102030405060708090a0b0c0d0e0f")
```

| Field | Type | Meaning |
| --- | --- | --- |
| `filename:` | string | File name; may contain slashes |
| `directory:` | string | Directory |
| `checksumkind:` | enum | `CSK_MD5`, `CSK_SHA1` or `CSK_SHA256` |
| `checksum:` | string | Hex checksum |

`checksumkind:` and `checksum:` are optional, but if one is present the
other must be too. A `DIFile` is the only valid target of a `file:` field. It
may also be used as a `scope:`.

### DIBasicType

A primitive type such as `int`, `bool` or `float`.

```llvm
!0 = !DIBasicType(name: "unsigned char", size: 8, align: 8,
                  encoding: DW_ATE_unsigned_char)
!1 = !DIBasicType(tag: DW_TAG_unspecified_type, name: "decltype(nullptr)")
```

| Field | Type | Meaning |
| --- | --- | --- |
| `tag:` | enum | Default `DW_TAG_base_type` |
| `name:` | string | Type name |
| `size:` | int | Size in bits |
| `align:` | int | Alignment in bits |
| `encoding:` | enum | How the bits are interpreted |

Usual `encoding:` values:

| Name | Value |
| --- | --- |
| `DW_ATE_address` | 1 |
| `DW_ATE_boolean` | 2 |
| `DW_ATE_float` | 4 |
| `DW_ATE_signed` | 5 |
| `DW_ATE_signed_char` | 6 |
| `DW_ATE_unsigned` | 7 |
| `DW_ATE_unsigned_char` | 8 |

The manual says "usually"; other encodings are not ruled out.

### DIFixedPointType

A fixed-point type: an integer with a scale factor. It is a kind of
`DIBasicType` and has all its fields. Only these encodings are accepted:

| Name | Value |
| --- | --- |
| `DW_ATE_signed_fixed` | 13 |
| `DW_ATE_unsigned_fixed` | 14 |

```llvm
!0 = !DIFixedPointType(name: "decimal", size: 8, encoding: DW_ATE_signed_fixed,
                       kind: Decimal, factor: -4)
!1 = !DIFixedPointType(name: "binary", size: 8, encoding: DW_ATE_unsigned_fixed,
                       kind: Binary, factor: -16)
!2 = !DIFixedPointType(name: "rational", size: 8, encoding: DW_ATE_signed_fixed,
                       kind: Rational, numerator: 1234, denominator: 5678)
```

| Field | Type | Meaning |
| --- | --- | --- |
| (all `DIBasicType` fields) | | |
| `kind:` | enum | `Binary` (scale is a power of 2), `Decimal` (power of 10) or `Rational` |
| `factor:` | int | Exponent for `Binary` and `Decimal` (may be negative) |
| `numerator:` | int | Numerator of the scale for `Rational` |
| `denominator:` | int | Denominator of the scale for `Rational` |

### DISubroutineType

A function type.

```llvm
!2 = !DISubroutineType(types: !{null, !0, !1}) ; void (int, char)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `types:` | md | Tuple. First operand is the return type; the rest are parameter types in order. `null` as the first operand means no return value. |

**Not documented:** the manual's example defines its operands with
`!BasicType(name: "int", size: 32, align: 32, DW_ATE_signed)`. That spelling
(no `DI` prefix, positional encoding) looks like a typo for `!DIBasicType`
with `encoding:`. Epitome should not accept it.

### DIDerivedType

A type built from another type: pointers, qualifiers, typedefs, members and
so on.

```llvm
!1 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !0, size: 32,
                    align: 32)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `tag:` | enum | Which kind of derived type (table below) |
| `name:` | string | Name (members, typedefs) |
| `scope:` | md | Enclosing scope |
| `file:` | md | `DIFile` |
| `line:` | int | Line number |
| `baseType:` | md | The type derived from. `null` gives `void` (so `void *` is a pointer to null) |
| `size:` | int | Size in bits |
| `align:` | int | Alignment in bits |
| `offset:` | int | For `DW_TAG_member`: bit offset in the containing type |
| `flags:` | flags | `DIFlag...` values |
| `extraData:` | md | For variant-part members: discriminant values (see `DICompositeType`) |

Valid `tag:` values:

| Name | Value |
| --- | --- |
| `DW_TAG_member` | 13 |
| `DW_TAG_pointer_type` | 15 |
| `DW_TAG_reference_type` | 16 |
| `DW_TAG_typedef` | 22 |
| `DW_TAG_inheritance` | 28 |
| `DW_TAG_ptr_to_member_type` | 31 |
| `DW_TAG_const_type` | 38 |
| `DW_TAG_friend` | 42 |
| `DW_TAG_volatile_type` | 53 |
| `DW_TAG_restrict_type` | 55 |
| `DW_TAG_atomic_type` | 71 |
| `DW_TAG_immutable_type` | 75 |

Meaning of the tags:

- `DW_TAG_member`: a member of a composite type. Its type is `baseType:`;
  `offset:` is the bit offset.
- `DW_TAG_inheritance`, `DW_TAG_friend`: used in a composite type's
  `elements:` to list base classes and friends.
- `DW_TAG_typedef`: gives a name to `baseType:`.
- `DW_TAG_pointer_type`, `DW_TAG_reference_type`, `DW_TAG_const_type`,
  `DW_TAG_volatile_type`, `DW_TAG_restrict_type`, `DW_TAG_atomic_type`,
  `DW_TAG_immutable_type`: qualify `baseType:`.

Uniquing rule: if a member's scope is a composite type that has an ODR
`identifier:` and is not a forward declaration (`DIFlagFwdDecl`), the member
is uniqued only by `name:` and `scope:`.

**Not documented:** the field name `extraData:` and the spelling of
`ptr_to_member` extra fields. The manual mentions "ExtraData" only in prose.
The manual also writes `flags: DIFwdDecl` in places and `DIFlagFwdDecl` in
others; the flag is `DIFlagFwdDecl`.

### DICompositeType

A type made of other types: structures, classes, unions, enums, arrays and
variant parts.

```llvm
!3 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "Enum", file: !12,
                      line: 2, size: 32, align: 32, identifier: "_M4Enum",
                      elements: !{!0, !1, !2})
```

| Field | Type | Meaning |
| --- | --- | --- |
| `tag:` | enum | Kind of composite (table below) |
| `name:` | string | Name |
| `scope:` | md | Enclosing scope |
| `file:` | md | `DIFile` |
| `line:` | int | Line |
| `baseType:` | md | Underlying type (for example an array's element type) |
| `size:` | int | Size in bits |
| `align:` | int | Alignment in bits |
| `flags:` | flags | For example `DIFlagFwdDecl`, `DIFlagVector` |
| `elements:` | md | Tuple of the parts (see below) |
| `identifier:` | string | ODR unique identifier, for merging types across modules |
| `templateParams:` | md | Tuple of template parameters |
| `dataLocation:` | md | Arrays only: `DIExpression` (or `DIVariable`) giving the address of the raw data |
| `associated:` | md | Arrays only: `DIExpression` saying whether a Fortran pointer array is associated |
| `allocated:` | md | Arrays only: `DIExpression` saying whether an allocatable array is allocated |
| `rank:` | md | Arrays only: `DIExpression` giving the rank of an assumed-rank array |
| `bitStride:` | int | Arrays only: bits per element, if different from the element's natural size |

Valid `tag:` values:

| Name | Value |
| --- | --- |
| `DW_TAG_array_type` | 1 |
| `DW_TAG_class_type` | 2 |
| `DW_TAG_enumeration_type` | 4 |
| `DW_TAG_structure_type` | 19 |
| `DW_TAG_union_type` | 23 |
| `DW_TAG_variant` | 25 |
| `DW_TAG_variant_part` | 51 |

What `elements:` holds, by tag:

- `DW_TAG_array_type`: subrange nodes (`DISubrange`, and by implication
  `DISubrangeType`), one per dimension. `DIFlagVector` in `flags:` means a
  native packed vector.
- `DW_TAG_enumeration_type`: `DIEnumerator` nodes. Every enumeration type
  must also be listed in the compile unit's `enums:`.
- `DW_TAG_structure_type`, `DW_TAG_class_type`, `DW_TAG_union_type`:
  `DIDerivedType` nodes with tag `DW_TAG_member`, `DW_TAG_inheritance` or
  `DW_TAG_friend`, or `DISubprogram` nodes with `isDefinition: false`.
- `DW_TAG_variant_part`: a variant part of a structure. It has a
  discriminant member that selects which elements are active. Each element is
  a `DW_TAG_member`. If a member has non-null extra data, that is a
  `ConstantInt` or `ConstantDataArray` of the discriminant values that select
  it. A member may itself have a composite type with tag `DW_TAG_variant`;
  then that type's members are inlined into the current one.

ODR rule: for one `identifier:` there should be only one composite type that
is not `DIFlagFwdDecl`. Linking tools unique such definitions by
`identifier:` while parsing, even if the nodes are `distinct`.

**Not documented:** the field name for the variant part's discriminant.

**Epitome note:** module linking must merge `DICompositeType` nodes by
`identifier:` at parse time, ignoring `distinct`.

### DISubrange

An array dimension. Used in `elements:` of a `DW_TAG_array_type`.

```llvm
!0 = !DISubrange(count: 5, lowerBound: 0)
!1 = !DISubrange(count: 5, lowerBound: 1)
!2 = !DISubrange(count: -1)               ; empty array
!11 = !DISubrange(count: !10, lowerBound: 0) ; !10 is a DILocalVariable
!13 = !DISubrange(count: !12, lowerBound: 0) ; !12 is a DIGlobalVariable
```

| Field | Type | Meaning |
| --- | --- | --- |
| `count:` | int or md | Number of elements. `-1` means empty. May refer to a `DILocalVariable` or `DIGlobalVariable` holding the count |
| `lowerBound:` | int or md | First index |
| `upperBound:` | int or md | Last index (alternative to `count:`) |
| `stride:` | int or md | Stride |

**Not documented:** whether `upperBound:` and `stride:` may hold a
`DIExpression` on `DISubrange`. The manual only says a `DISubrangeType` can
hold "a lower bound and count, or a lower bound and upper bound", by analogy
with `DISubrange`.

### DISubrangeType

Like `DISubrange`, but also a type (a `DIType`). It can be the type of an
object or an array index type. Its underlying type is an integer or
enumeration type.

It has a lower bound plus either a count or an upper bound. It may have a
`stride:`, which here is a **bit** stride (only useful when used as an array
index). It may have a `bias:`: for Ada, a value stored in the minimum number
of bits is stored minus the bias. Example: range `-7 .. 0` fits in 3 bits;
`-5` is stored as 2, with bias `-7`.

```llvm
!4 = !DISubrange(name: "subrange", file: !0, line: 17, size: 32,
                 align: 32, baseType: !3, lowerBound: 18, count: 12)
!5 = !DISubrange(name: "biased", lowerBound: -7, upperBound: 0,
                 bias: -7, size: 3)
!6 = !DISubrange(name: "biased", lowerBound: 0, upperBound: 7,
                 stride: 3)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name:` | string | Name |
| `file:` | md | `DIFile` |
| `line:` | int | Line |
| `size:` | int | Size in bits |
| `align:` | int | Alignment in bits |
| `baseType:` | md | Underlying integer or enumeration type |
| `lowerBound:` | int | Lower bound |
| `count:` | int | Count (alternative to `upperBound:`) |
| `upperBound:` | int | Upper bound |
| `stride:` | int | Bit stride |
| `bias:` | int | Storage bias |

**Not documented:** the manual's examples for this section are written
`!DISubrange(...)`, not `!DISubrangeType(...)`. This is probably an error in
the manual. Epitome should spell the node `!DISubrangeType` and treat the
example fields as its fields.

### DIEnumerator

One enumeration value. Used in `elements:` of a `DW_TAG_enumeration_type`.

```llvm
!0 = !DIEnumerator(name: "SixKind", value: 7)
!2 = !DIEnumerator(name: "NegEightKind", value: -8)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name:` | string | Enumerator name |
| `value:` | int | Value (may be negative) |

**Not documented:** how unsigned values and widths are expressed.

### DITemplateTypeParameter

A type parameter of a generic construct. Used optionally in `templateParams:`
of `DICompositeType` and `DISubprogram`.

```llvm
!0 = !DITemplateTypeParameter(name: "Ty", type: !1)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name:` | string | Parameter name |
| `type:` | md | The type argument |

### DITemplateValueParameter

A value parameter of a generic construct. Used optionally in
`templateParams:`.

```llvm
!0 = !DITemplateValueParameter(name: "Ty", type: !1, value: i32 7)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `tag:` | enum | Default `DW_TAG_template_value_parameter`. May also be `DW_TAG_GNU_template_template_param` or `DW_TAG_GNU_template_param_pack` |
| `name:` | string | Parameter name |
| `type:` | md | Type of the value |
| `value:` | typed value or md | The value, e.g. `i32 7` |

### DINamespace

A source-language namespace.

```llvm
!0 = !DINamespace(name: "myawesomeproject", scope: !1, file: !2, line: 7)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name:` | string | Namespace name |
| `scope:` | md | Enclosing scope |
| `file:` | md | `DIFile` |
| `line:` | int | Line |

### DIGlobalVariable

A source-level global variable.

```llvm
@foo = global i32, !dbg !0
!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = !DIGlobalVariable(name: "foo", linkageName: "foo", scope: !2,
                       file: !3, line: 7, type: !4, isLocal: true,
                       isDefinition: false, declaration: !5)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name:` | string | Source name |
| `linkageName:` | string | Mangled name |
| `scope:` | md | Enclosing scope |
| `file:` | md | `DIFile` |
| `line:` | int | Line |
| `type:` | md | Type |
| `isLocal:` | bool | Local to the unit (e.g. `static`) |
| `isDefinition:` | bool | Is a definition |
| `declaration:` | md | Declaration this defines (e.g. a static data member) |

Note that the `!dbg` attachment on the IR global points at a
`DIGlobalVariableExpression`, not directly at the `DIGlobalVariable`.

### DIGlobalVariableExpression

Ties a `DIGlobalVariable` to a `DIExpression`. All of them should be listed
in some compile unit's `globals:`.

```llvm
!0 = !DIGlobalVariableExpression(var: !2,
         expr: !DIExpression(DW_OP_LLVM_fragment, 0, 32))
```

| Field | Type | Meaning |
| --- | --- | --- |
| `var:` | md | The `DIGlobalVariable` |
| `expr:` | md | An inline `DIExpression` |

Several expressions can share one variable, for example when a 64-bit
variable is split into two 32-bit globals with fragments.

### DISubprogram

A source function.

- A `distinct` `DISubprogram` may be attached to a function **definition**
  with `!dbg`.
- A uniqued `DISubprogram` may be attached to a function **declaration**,
  for call-site debug info.

```llvm
define void @_Z3foov() !dbg !0 {
  ...
}

!0 = distinct !DISubprogram(name: "foo", linkageName: "_Zfoov", scope: !1,
                            file: !2, line: 7, type: !3,
                            spFlags: DISPFlagDefinition | DISPFlagLocalToUnit,
                            scopeLine: 8, containingType: !4,
                            virtuality: DW_VIRTUALITY_pure_virtual,
                            virtualIndex: 10, flags: DIFlagPrototyped,
                            isOptimized: true, unit: !5, templateParams: !6,
                            declaration: !7, retainedNodes: !8,
                            thrownTypes: !9)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name:` | string | Source name |
| `linkageName:` | string | Mangled name |
| `scope:` | md | Enclosing scope |
| `file:` | md | `DIFile` |
| `line:` | int | Line of the declaration |
| `type:` | md | Must be a `DISubroutineType` |
| `spFlags:` | flags | Subprogram flags, e.g. `DISPFlagDefinition`, `DISPFlagLocalToUnit` |
| `scopeLine:` | int | Line where the body scope starts |
| `containingType:` | md | Class containing the virtual function |
| `virtuality:` | enum | e.g. `DW_VIRTUALITY_pure_virtual` |
| `virtualIndex:` | int | Index in the vtable |
| `flags:` | flags | `DIFlag...` values, e.g. `DIFlagPrototyped` |
| `isOptimized:` | bool | Whether optimized |
| `unit:` | md | The `DICompileUnit` |
| `templateParams:` | md | Tuple of template parameters |
| `declaration:` | md | The declaration this definition implements |
| `retainedNodes:` | md | Variables and labels to keep even if their IR is optimized away |
| `thrownTypes:` | md | Tuple of thrown types |

Rules:

- Without `DISPFlagDefinition` in `spFlags:`, the node is a declaration in
  the type tree, not a definition. Then `declaration:` must be empty.
- If the scope is a composite type with an ODR `identifier:` that is not
  `DIFlagFwdDecl`, a declaration is uniqued only by `linkageName:` and
  `scope:`.
- A `DILocalVariable` with non-zero `arg:` is listed in `retainedNodes:`.

**Not documented:** the full lists of `DISPFlag...` and
`DW_VIRTUALITY_...` names. The manual also mentions `isDefinition: false`
under `DICompositeType`, which suggests an older boolean field spelling.

### DILexicalBlock

A nested block inside a subprogram. A valid `scope:` target. Usually
`distinct` so blocks at the same place do not merge.

```llvm
!0 = distinct !DILexicalBlock(scope: !1, file: !2, line: 7, column: 35)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `scope:` | md | Parent scope |
| `file:` | md | `DIFile` |
| `line:` | int | Line |
| `column:` | int | Column |

Line and column tell apart two blocks at the same depth.

### DILexicalBlockFile

Marks a section of a lexical block. Change `file:` to show textual
inclusion, or use `discriminator:` to tell apart control flow inside one
source block.

```llvm
!1 = !DILexicalBlockFile(scope: !0, file: !4, discriminator: 0)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `scope:` | md | The lexical block |
| `file:` | md | `DIFile` |
| `discriminator:` | int | Discriminator |

### DILocation

A source location. This is what `!dbg` on an instruction points to.

```llvm
!0 = !DILocation(line: 2900, column: 42, scope: !1, inlinedAt: !2)
!0 = !DILocation(line: 2900, column: 42, scope: !1, irlayers: !3)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `line:` | int | Line |
| `column:` | int | Column |
| `scope:` | md | Mandatory. A `DILexicalBlockFile`, `DILexicalBlock` or `DISubprogram` |
| `inlinedAt:` | md | The `DILocation` of the call this was inlined into |
| `irlayers:` | md | Optional `DILayerLocList`: positions in intermediate IRs |

`irlayers:` is independent of `inlinedAt:`. A location may have either,
both or neither. If there is no intermediate position, the field is left
out (it never points at an empty list). Each location in an `inlinedAt:`
chain may have its own `irlayers:`; LLVM defines no link between them.

### DILayerLoc

A position in one intermediate IR level a program passed through (for
example an MLIR module). It has no scope and no inlined-at context: it is
just a point in a file.

```llvm
!0 = !DILayerLoc(line: 100, column: 1, file: !1, kind: "HighLevelIR")
```

| Field | Type | Meaning |
| --- | --- | --- |
| `kind:` | string | Mandatory. Names the IR level |
| `file:` | md | Mandatory. A `DIFile` |
| `line:` | int | Line |
| `column:` | int | Column |

### DILayerLocList

A non-empty list of `DILayerLoc` nodes. Referenced by `irlayers:`. Its
operands are positional, not labelled.

```llvm
!0 = !DILayerLocList(!1, !2)
```

Order is part of identity: the same entries in a different order make a
different node. LLVM gives the order no meaning. `DILayerLoc` and
`DILayerLocList` are normally uniqued, but `distinct` forms are legal.

**Epitome note:** `DILayerLocList` is the only specialized node in this
chapter with positional operands. The parser needs a special case.

### DILocalVariable

A source local variable or parameter.

```llvm
!0 = !DILocalVariable(name: "this", arg: 1, scope: !3, file: !2, line: 7,
                      type: !3, flags: DIFlagArtificial)
!2 = !DILocalVariable(name: "y", scope: !5, file: !2, line: 7, type: !3)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name:` | string | Name |
| `arg:` | int | Non-zero: this is parameter number `arg` (1-based); it is then included in the subprogram's `retainedNodes:` |
| `scope:` | md | Scope |
| `file:` | md | `DIFile` |
| `line:` | int | Line |
| `type:` | md | Type |
| `flags:` | flags | e.g. `DIFlagArtificial` |

### DIExpression

An expression in a DWARF-like stack language. Debug records such as
`#dbg_declare` and `#dbg_value` use it to say how an IR value relates to a
source variable.

Grammar:

```
diexpression ::= '!DIExpression' '(' [ elem (',' elem)* ] ')'
elem ::= DW_OP-name | integer
```

A `DIExpression` is always written inline. It can never be given an id like
`!1` and referenced.

**Epitome note:** the printer must always print `DIExpression` inline, and
the parser must reject `!N = !DIExpression(...)`.

Examples from the manual:

```llvm
!DIExpression(DW_OP_deref)
!DIExpression(DW_OP_plus_uconst, 3)
!DIExpression(DW_OP_constu, 3, DW_OP_plus)
!DIExpression(DW_OP_LLVM_fragment, 3, 7)
!DIExpression(DW_OP_deref, DW_OP_constu, 3, DW_OP_plus, DW_OP_LLVM_fragment, 3, 7)
!DIExpression(DW_OP_constu, 2, DW_OP_swap, DW_OP_xderef)
!DIExpression(DW_OP_constu, 42, DW_OP_stack_value)
!DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_plus)
```

Operations named in this part of the manual, with operand counts inferred
from the examples:

| Operation | Operands | Inferred meaning |
| --- | --- | --- |
| `DW_OP_deref` | 0 | Load from the address on the stack |
| `DW_OP_plus_uconst` | 1 | Add an unsigned constant |
| `DW_OP_constu` | 1 | Push an unsigned constant |
| `DW_OP_plus` | 0 | Pop two, push sum |
| `DW_OP_swap` | 0 | Swap the top two entries |
| `DW_OP_xderef` | 0 | Dereference in an address space (takes address and space from the stack) |
| `DW_OP_stack_value` | 0 | The stack top is the value, not its address |
| `DW_OP_LLVM_fragment` | 2 | Describes only a piece of the variable: bit offset, bit size. Appears last |
| `DW_OP_LLVM_arg` | 1 | Push the N-th value of an accompanying `DIArgList` |

**Not documented:** this section of the Language Reference says "See
DIExpression for details" and points elsewhere. The complete list of
`DW_OP_*` and `DW_OP_LLVM_*` operations, their operand counts and their
semantics is not in the text this chapter was written from. The rows above
are only what the examples show. Epitome needs another documentation source
(LLVM's "Source Level Debugging" page) before it can parse every operation.

### DIAssignID

Has no operands and is always `distinct`. It links `#dbg_assign` records to
the store instructions they describe (assignment tracking).

```llvm
store i32 %a, ptr %a.addr, align 4, !DIAssignID !2
#dbg_assign(%a, !1, !DIExpression(), !2, %a.addr, !DIExpression(), !3)

!2 = distinct !DIAssignID()
```

Note that the attachment kind is spelled `!DIAssignID`, the same as the node.

### DIArgList

A list of constants or SSA value references. Used in debug records with a
`DIExpression` that uses `DW_OP_LLVM_arg`. Operands are positional typed
values.

```llvm
#dbg_value(!DIArgList(i32 %a, i32 %b),
           !16,
           !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_plus),
           !26)
```

Because it may name local values, a `DIArgList`:

- may only be used as a function argument (or debug-record operand);
- must always be written inline;
- may not appear in named metadata.

### DIFlags

Flags on debug-info nodes, written in `flags:` and joined with `|`.

Flags named in this part of the manual:

| Flag | Meaning |
| --- | --- |
| `DIFlagFwdDecl` | Forward declaration (not a full definition) |
| `DIFlagVector` | On an array type: a native packed vector |
| `DIFlagPrototyped` | Function has a prototype |
| `DIFlagArtificial` | Compiler-generated entity |
| `DIFlagExportSymbols` (prose: "ExportSymbols") | Members of this class, struct or union can be referenced as if in the containing type; decides use of `DW_AT_export_symbols` |

Subprogram flags (`spFlags:`) named: `DISPFlagDefinition`,
`DISPFlagLocalToUnit`.

**Not documented:** the complete flag lists, their numeric values, and
whether a raw integer is accepted in `flags:`. The exact spelling
`DIFlagExportSymbols` is inferred from the pattern; the manual only says
"ExportSymbols".

### DIObjCProperty

An Objective-C property.

```llvm
!3 = !DIObjCProperty(name: "foo", file: !1, line: 7, setter: "setFoo",
                     getter: "getFoo", attributes: 7, type: !2)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name:` | string | Property name |
| `file:` | md | `DIFile` |
| `line:` | int | Line |
| `setter:` | string | Setter selector |
| `getter:` | string | Getter selector |
| `attributes:` | int | Property attribute bits |
| `type:` | md | Type |

### DIProperty

Something accessed like a data member but implemented by an accessor. The
node describes the backing variable (for example the ivar behind an
Objective-C `@property`).

```llvm
!5 = !DIProperty(name: "x", file: !2, line: 8, type: !4, backing_storage: !3)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `name:` | string | Property name |
| `file:` | md | `DIFile` |
| `line:` | int | Line |
| `type:` | md | Type |
| `backing_storage:` | md | The member (`DIDerivedType`) that stores the value |

Note the snake_case field name `backing_storage:`.

### DIImportedEntity

An entity (such as a module) imported into a compile unit.

```llvm
!2 = !DIImportedEntity(tag: DW_TAG_imported_module, name: "foo", scope: !0,
                       entity: !1, line: 7, elements: !3)
!3 = !{!4}
!4 = !DIImportedEntity(tag: DW_TAG_imported_declaration, name: "bar", scope: !0,
                       entity: !5, line: 7)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `tag:` | enum | `DW_TAG_imported_module` or `DW_TAG_imported_declaration` (others not documented) |
| `name:` | string | Name |
| `scope:` | md | Where it is imported |
| `entity:` | md | What is imported |
| `line:` | int | Line |
| `elements:` | md | Tuple of renamed entities inside the import |

### DIMacro

Definition or undefinition of a macro.

```llvm
!2 = !DIMacro(macinfo: DW_MACINFO_define, line: 7, name: "foo(x)",
              value: "((x) + 1)")
!3 = !DIMacro(macinfo: DW_MACINFO_undef, line: 30, name: "foo")
```

| Field | Type | Meaning |
| --- | --- | --- |
| `macinfo:` | enum | `DW_MACINFO_define` or `DW_MACINFO_undef` |
| `line:` | int | Line |
| `name:` | string | Macro name, plus parameters for a function-like macro |
| `value:` | string | Replacement text |

### DIMacroFile

Inclusion of a source file, for macro info.

```llvm
!2 = !DIMacroFile(macinfo: DW_MACINFO_start_file, line: 7, file: !2,
                  nodes: !3)
```

| Field | Type | Meaning |
| --- | --- | --- |
| `macinfo:` | enum | `DW_MACINFO_start_file` |
| `line:` | int | Line of the include |
| `file:` | md | `DIFile` included |
| `nodes:` | md | Tuple of `DIMacro` and `DIMacroFile` nodes from that file |

### DILabel

A label in a subprogram.

```llvm
!2 = !DILabel(scope: !0, name: "foo", file: !1, line: 7, column: 4)
!3 = !DILabel(scope: !0, name: "__coro_resume_3", file: !1, line: 9, column: 3,
              isArtificial: true, coroSuspendIdx: 3)
```

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `scope:` | md | yes | `DILexicalBlockFile`, `DILexicalBlock` or `DISubprogram` |
| `name:` | string | yes | Label name |
| `file:` | md | yes | `DIFile` |
| `line:` | int | yes | Line |
| `column:` | int | no | Column |
| `isArtificial:` | bool | no | Compiler-generated (e.g. by CoroSplit) |
| `coroSuspendIdx:` | int | no | Coroutine suspend point index (set by CoroSplit) |

### DICommonBlock

A Fortran common block. No example is given.

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `scope:` | md | yes | `DILexicalBlockFile`, `DILexicalBlock` or `DISubprogram` |
| `declaration:` | md | no | Declaration |
| `name:` | string | no | Name |
| `file:` | md | no | `DIFile` |
| `line:` | int | no | Line |

### DIModule

A source-language module (for example a Clang module or Fortran module). No
example is given.

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `scope:` | md | yes | `DILexicalBlockFile`, `DILexicalBlock` or `DISubprogram` |
| `name:` | string | yes | Module name |
| `configMacros:` | string | no | Configuration macros |
| `includePath:` | string | no | Include path |
| `apinotes:` | string | no | API notes file |
| `file:` | md | no | `DIFile` |
| `line:` | int | no | Line |
| `isDecl:` | bool | no | Is a declaration |

### DIStringType

A Fortran `CHARACTER(n)` type, whose length and location may be dynamic.
No example is given.

| Field | Type | Meaning |
| --- | --- | --- |
| `tag:` | enum | Optional, default `DW_TAG_string_type` |
| `name:` | string | Name |
| `stringLength:` | md | A `DIVariable` holding the length in bits |
| `stringLengthExpression:` | md | A `DIExpression` computing the length in bits |
| `stringLocationExpression:` | md | A `DIExpression` giving the data location |
| `size:` | int | Literal length in bits. Default 0 |
| `align:` | int | Alignment. Default 0 |
| `encoding:` | enum | Encoding |
| `charType:` | md | Non-default character type |

All fields are optional. The length is taken from the first of
`stringLength:`, `stringLengthExpression:`, `size:` that is present.

### Specialized nodes not covered here

The text mentions `DIVariable` (the common kind of local and global
variables) and `DIType` as abstract categories. They have no syntax of their
own.

**Not documented:** `DIBasicType` `flags:`, `DICompileUnit`
`nameTableKind:`, `DIGenericSubrange`, `DIArgList` printing rules beyond the
example, and many other fields that real LLVM output may contain. They do not
appear in this part of the manual.

## Metadata kinds attached to instructions and globals

Each entry gives where the kind may attach and the shape of its node.
"Empty node" means `!{}`.

### Summary table

| Kind | Attaches to | Operand shape |
| --- | --- | --- |
| `!dbg` | instructions, functions, globals | `DILocation` (instructions), `DISubprogram` (functions), `DIGlobalVariableExpression` (globals) |
| `!tbaa` | loads, stores (memory accesses) | access tag (3 or 4 operands) |
| `!tbaa.struct` | `llvm.memcpy` calls | triples `(i64 offset, i64 size, !tag)` |
| `!noalias` | memory accesses, `fence` | list of scopes |
| `!alias.scope` | memory accesses, `fence` | list of scopes |
| `!fpmath` | FP-typed instructions | `!{float ulps}` |
| `!range` | `load`, `call`, `invoke` of integer or integer vector type | pairs of integers |
| `!nofpclass` | `load` | `!{i32 mask}` |
| `!absolute_symbol` | global variable declaration | pairs of integers |
| `!callees` | indirect calls | list of `ptr @fn` |
| `!callback` | function declarations or definitions | list of encodings |
| `!exclude` | global variable with explicit section | empty node |
| `!metadata_section_kind` | global variable with explicit section | empty node |
| `!unpredictable` | `br`, `select`, `switch` | node (presence is what matters) |
| `!dereferenceable` | loads (of pointers) | `!{i64 bytes}` |
| `!dereferenceable_or_null` | loads (of pointers) | `!{i64 bytes}` |
| `!nonnull` | loads of pointers | empty node |
| `!align` | loads of pointers | `!{i64 align}` |
| `!noundef` | loads | empty node |
| `!nontemporal` | loads, stores | `!{i32 1}` |
| `!captures` | `store` of a pointer | list of strings |
| `!mem.cache_hint` | memory instructions, intrinsic calls | pairs `(i32 operand, !hints)` |
| `!llvm.loop` | loop latch branch | loop node |
| `!llvm.access.group` | memory accesses | distinct empty node, or list of them |
| `!irr_loop` | terminator of irreducible loop header | `!{"loop_header_weight", i64 w}` |
| `!invariant.load` | loads, read-only intrinsic calls | empty node |
| `!invariant.group` | loads, stores | empty node |
| `!atomic.ignore.denormal.mode` | FP `atomicrmw` | empty node |
| `!type` | globals | see Type Metadata (not in this chapter) |
| `!callee_type` | indirect calls | list of `!callgraph`-style nodes |
| `!callgraph` | function definitions | `!{!"typeid"}` |
| `!associated` | global variable definition | `!{ptr @g}` |
| `!prof` | branches, selects, switches, calls, functions | `!{!"kind", ...}` |
| `!annotation` | any instruction | strings or tuples of strings |
| `!func_sanitize` | functions | `!{i32 sig, ptr @proxy}` |
| `!kcfi_type` | functions | `!{i32 id}` |
| `!pcsections` | instructions, functions | not documented here |
| `!memprof` | heap allocation calls | list of contexts |
| `!callsite` | calls | list of `i64` ids |
| `!noalias.addrspace` | memory instructions incl. `atomicrmw`, `cmpxchg`, `call` | pairs of `i32` |
| `!mmra` | memory instructions incl. `fence`, `call` | string pair or tuple of pairs |
| `!nofree` | instructions producing pointers | not documented |
| `!alloc_token` | allocation calls | `!{!"type", i1 hasptr[, !"fn"]}` |
| `!stack-protector` | `alloca` | `!{i32 0}` |
| `!implicit.ref` | function or global variable definition | `!{ptr @g}` |
| `!inline_history` | calls | list of `ptr @fn` or `null` |
| `!elf_section_properties` | functions, globals | `!{i32 sh_type, i32 sh_entsize}` |
| `!srcloc` | inline-asm calls | list of integers (see chapter 2) |
| `!DIAssignID` | stores | `distinct !DIAssignID()` |
| `!make.implicit` | branches | empty node (see FaultMaps) |

**Not documented:** `!nosanitize`, `!heapallocsite` and `!guid` are not
described anywhere in the source text. The task list for this chapter named
`nosanitize`; it is absent from this version of the manual.

### `!tbaa`

TBAA means type-based alias analysis: using the source language's type rules
to prove that two memory accesses do not overlap. LLVM memory has no types,
so the source type system is described in metadata. The scheme is called
"struct-path TBAA".

#### Concepts

- **Root**: every TBAA node leads to one root. Nodes under different roots
  have an unknown relationship, so LLVM assumes they may alias.
- **Scalar type descriptor**: a type with no parts. Each has a parent,
  which is another scalar type or the root. Scalars form a tree.
- **Struct type descriptor**: a type made of other descriptors at known
  offsets.
- **Access tag**: attached to a load or store. A triple
  `(BaseTy, AccessTy, Offset)`.
  - If `BaseTy` is a struct: an access of type `AccessTy` inside `BaseTy`
    at `Offset`.
  - If `BaseTy` is a scalar: `Offset` must be 0 and `BaseTy` must equal
    `AccessTy`.

#### Alias rule

Define `ImmediateParent`:

- Scalar: `ImmediateParent(BaseTy, 0) = (ParentTy, 0)`. Undefined for a
  non-zero offset.
- Struct: `ImmediateParent(BaseTy, Offset) = (NewTy, NewOffset)`, where
  `NewTy` is the member at `Offset` and `NewOffset` is the offset inside
  that member.

Two accesses with tags `(B1, A1, O1)` and `(B2, A2, O2)` may alias if
`(B1, O1)` can be reached from `(B2, O2)` by repeated `ImmediateParent`
steps, or the other way round. If accesses that TBAA says do not alias
actually alias, the behavior is undefined.

#### Encoding

| Entity | Encoding |
| --- | --- |
| Root | Node with 0 operands, or exactly one `MDString` |
| Scalar type | `!{!"name", !parent}` or `!{!"name", !parent, i64 0}`. The optional third operand must be integer zero |
| Struct type | Odd number of operands, more than 1: `!{!"name", !field1, i64 off1, !field2, i64 off2, ...}`. Offsets non-decreasing |
| Access tag | `!{!base, !access, i64 offset}` or `!{!base, !access, i64 offset, i64 const}`. `const` is 0 or 1; 1 means the memory is constant |

The name strings have no meaning to LLVM beyond being strings. The base type
and access type of a tag must share a root.

Example (from `!llvm.errno.tbaa`):

```llvm
!0 = !{!1, !1, i64 0}                     ; access tag: int
!1 = !{!"int", !2, i64 0}                 ; scalar type
!2 = !{!"omnipotent char", !3, i64 0}     ; scalar type
!3 = !{!"Simple C/C++ TBAA"}              ; root
```

**Not documented:** the exact integer types of offsets in struct
descriptors and tags. Examples use `i64`.

### `!tbaa.struct`

Describes the fields of an aggregate copied by `llvm.memcpy`, so padding can
be skipped and each field gets a TBAA tag. The node is a flat list in groups
of three: byte offset, byte size, TBAA tag.

```llvm
!4 = !{ i64 0, i64 4, !1, i64 8, i64 4, !2 }
```

Gaps between fields are padding and need not be copied.

### `!noalias` and `!alias.scope`

Generic "these accesses do not alias those" sets. Both attach to memory
accesses (loads, stores, memory calls) and also to `fence`. Each holds a
list of scopes. If accesses that are declared not to alias actually alias,
the behavior is undefined.

Encoding:

| Entity | Shape |
| --- | --- |
| Domain | `!{name, i1 disjoint}` or `!{name, i1 disjoint, !"description"}` |
| Scope | `!{name, !domain}` or `!{name, !domain, !"description"}` |
| Scope list (the attachment) | `!{!scope, ...}` |

`name` is usually a self-reference (`!0 = !{!0, i1 false}`) for a globally
unique name. A string name may be merged across functions and units. String
names should not be used with disjoint domains.

Rules:

- For a domain D: if the scopes of D in instruction X's `!alias.scope` are
  a subset of (or equal to) the scopes of D in instruction Y's `!noalias`,
  then X and Y do not alias.
- If D is disjoint (`i1 true`): two accesses that both list scopes of D in
  `!alias.scope`, with no scope of D in common, do not alias. Equivalently,
  listing some scopes of a disjoint domain implies `!noalias` for all its
  other scopes.
- Domains are independent. Inlining makes a new domain each time.

```llvm
!0 = !{!0, i1 false}       ; domain
!2 = !{!2, !0}             ; scope in !0
!5 = !{!4}                 ; scope list
%0 = load float, ptr %c, align 4, !alias.scope !5
store float %0, ptr %arrayidx.i, align 4, !noalias !5
```

**Not documented:** the older two-element domain form (no `i1`). This
version of the manual requires the `i1` second entry.

### `!fpmath`

Attaches to any instruction of floating-point type. Gives the maximum
acceptable error of the result, in ULPs, so a faster but less exact method
may be used.

ULP: for a real `x` strictly between finite adjacent floats `a` and `b`,
`ulp(x) = |b - a|`; otherwise it is the distance between the two nearest
distinct finite floats around `x`. `ulp(NaN)` is NaN.

```llvm
!0 = !{ float 2.5 }   ; at most 2.5 ULPs of error
```

The single operand must be a positive `float`.

### `!range`

Attaches only to `load`, `call` and `invoke` producing an integer or vector
of integers. The result lies in the union of half-open ranges `[a, b)`
given as pairs. Otherwise the result is poison.

Rules for each pair `a, b`:

- Both are constants of the instruction's scalar type.
- The range may wrap.
- `a != b` (no full or empty range).

Pairs must be ordered by signed lower bound and must not be contiguous
(adjacent ranges must not touch). For vectors, the range applies per element.

```llvm
!0 = !{ i8 0, i8 2 }            ; 0 or 1
!1 = !{ i8 255, i8 2 }          ; -1, 0 or 1 (wraps)
!2 = !{ i8 0, i8 2, i8 3, i8 6 }
```

**Epitome note:** the verifier must check type match, `a != b`, ordering and
non-contiguity.

### `!nofpclass`

Only on `load`. The loaded value is not in the listed floating-point classes;
if it is, the result is poison. The single operand is an `i32` holding a
10-bit mask, with the same meaning as the `nofpclass` attribute (see chapter
1). Zero is invalid. It does not depend on the floating-point environment.
Examples apply it to scalars, vectors, arrays and structs of floats.

```llvm
%not.nan = load float, ptr %p, align 4, !nofpclass !0
!0 = !{ i32 3 }
```

### `!absolute_symbol`

On a global variable **declaration**. Marks it as an absolute symbol: the
backend uses absolute relocations even in position-independent code. The
operands give the possible ranges of the global's **address**, in `!range`
format. Extra rule: the pair all-ones, all-ones means the full set.

```llvm
@a = external global i8, !absolute_symbol !0
!0 = !{ i64 0, i64 256 }
!1 = !{ i64 -1, i64 -1 }   ; full range
```

### `!callees`

On an indirect call. The callee must be one of the listed functions, or the
behavior is undefined.

```llvm
%result = call i64 %binop(i64 %x, i64 %y), !callees !0
!0 = !{ptr @add, ptr @sub}
```

### `!callback`

On a function declaration or definition (not on call sites). The annotated
function is the **broker**. The metadata says how the broker passes its
arguments to a callback function.

Shape: a list of encodings. Each encoding is:

```
!{ i64 callee_arg_index, (i64 broker_arg_index | i64 -1)*, i1 pass_varargs }
```

- First: which broker argument is the callback function.
- Middle: for each callback parameter in order, the broker argument passed
  to it, or `-1` for unknown or inspected.
- Last: if `true`, all variadic broker arguments are passed after the
  explicit ones.

Rules on the broker: it may not inspect or modify the pass-through
arguments. It need not call the callback, may call it many times, may call
it via other uses, and may call it on another thread.

```llvm
declare !callback !1 dso_local i32 @pthread_create(ptr, ptr, ptr, ptr)
!2 = !{i64 2, i64 3, i1 false}
!1 = !{!2}
```

**Not documented:** whether argument indices are 0-based. The example
(`pthread_create`, callback in the third parameter, labelled `i64 2`)
implies 0-based, while the prose calls it "the second argument".

### `!exclude`

On a global variable with an explicit section, targeting ELF or COFF. The
section is left out of the final binary (ELF `SHF_EXCLUDE`; COFF
`IMAGE_SCN_LNK_REMOVE` and `IMAGE_SCN_MEM_DISCARDABLE`). The node must be
empty.

```llvm
@object = private constant [1 x i8] c"\00", section ".foo" !exclude !0
!0 = !{}
```

Note: the example has no comma before `!exclude`.

**Not documented:** whether a global attachment needs a leading comma. The
`!dbg` examples use `, !dbg`, this example does not.

### `!metadata_section_kind`

On a global variable with an explicit section, for ELF or COFF. The section
is treated as "metadata": generic, no flags, unless it has a special name
such as `"llvm.metadata"`. ELF: `SHT_PROGBITS`, no flags. COFF: not
readable or writable, `IMAGE_SCN_MEM_DISCARDABLE`. The node must be empty.
It conflicts with `!exclude`; one of them may be ignored.

### `!unpredictable`

On `br`, `select` or `switch`. If present, the control flow is completely
unpredictable. Only presence matters.

**Not documented:** the node's contents. Typically `!{}`.

### `!dereferenceable` and `!dereferenceable_or_null`

On a load (the `load` section says these are for loads; it requires one
`i64` operand). The loaded pointer is dereferenceable for that many bytes at
this point (or is null, for the `_or_null` form). Otherwise the behavior is
undefined. These match the parameter attributes of the same names.

`!dereferenceable` with `!nofree` means the pointer stays dereferenceable
forever.

**Not documented:** the manual misspells the name once as `!deferenceable`.
The correct kind is `!dereferenceable`.

### `!nonnull`, `!align`, `!noundef`, `!nontemporal` (from the `load` section)

| Kind | Node | Meaning |
| --- | --- | --- |
| `!nonnull` | `!{}` | Loaded pointer is never null; if null, the result is poison. Pointer loads only |
| `!align` | `!{i64 N}` | Loaded pointer is aligned to `N` (a power of 2); if not, poison. Pointer loads only |
| `!noundef` | `!{}` | Loaded value is well defined; if not, undefined behavior. Combined with a poison-producing kind such as `!nonnull`, a violation becomes undefined behavior |
| `!nontemporal` | `!{i32 1}` | Not expected to be reused in cache. Also on `store`. No defined meaning for atomic loads and stores |

### `!captures`

Only on `store` whose value operand is a pointer. It limits how the stored
copy of the pointer may be used, like the `captures(...)` attribute.

The node is a non-empty list of strings from: `!"address"`,
`!"address_is_null"`, `!"provenance"`, `!"read_provenance"`. `!"none"` is
not allowed.

```llvm
store ptr %x, ptr %y, !captures !{!"address"}
store ptr %x, ptr %y, !captures !{!"address", !"read_provenance"}
```

The first allows only reading the integer address; dereferencing is
undefined behavior. The second also allows reads through the pointer, but
not writes. Nothing is said about other uses of `%x`.

### `!mem.cache_hint`

On any instruction that reads or writes memory, except non-intrinsic calls.
A pure performance hint; dropping it must not change behavior.

Shape: an even number of entries, alternating `i32` operand number and hint
node.

```
!{ i32 opnum, !hints, i32 opnum, !hints, ... }
!hints = !{ !"target.key", (!"string" | iN value), ... }
```

- Operand number: the IR operand index (load pointer is 0; store pointer
  is 1). For intrinsic calls, the argument index.
- Operand numbers are unique, increasing, and must name pointer operands.
- Hint nodes hold key/value pairs. Keys are strings with a target prefix
  (for example `nvvm.`), unique within the node. Values are strings or
  integer constants.

The verifier checks only this structure. Backends check keys and may ignore
unknown ones.

```llvm
%v = load i32, ptr addrspace(1) %p, align 4, !mem.cache_hint !0
!0 = !{ i32 0, !1 }
!1 = !{ !"nvvm.l1_eviction", !"first", !"nvvm.l2_prefetch_size", !"128B" }
```

### `!irr_loop`

On the terminator of a block that is a header of an irreducible loop (a loop
with more than one header). If the block is not such a header, behavior is
undefined. Gives the header's relative weight, usually from profile data.

```llvm
br i1 %cmp, label %t1, label %t2, !irr_loop !0
!0 = !{"loop_header_weight", i64 100}
```

**Not documented:** the example writes the string without `!` (`"..."`
rather than `!"..."`). This is likely a typo; MDStrings need `!`.

### `!invariant.load`

On loads, and on intrinsic calls that only read memory. Every location read
must hold the same value everywhere it is dereferenceable, or the behavior is
undefined. It may also mark reads of inaccessible memory or registers, which
must be constant for the life of that state. The node is empty.

```llvm
load i32, ptr %ptr, !invariant.load !0
call i32 @llvm.read_register.i32(metadata !1), !invariant.load !0
!0 = !{}
```

### `!invariant.group`

**Experimental.** On loads and stores. Node must be empty. All loads and
stores with this tag through the same pointer may be assumed to see the same
value. Pointers from `bitcast` or all-zero-index `getelementptr` count as
the same. `llvm.launder.invariant.group` produces a pointer that is not the
same. Because the node is empty and uniqued, all uses share one node.

It must be dropped when one pointer is replaced by another based on alias
information, because it is tied to the SSA pointer value.

### `!atomic.ignore.denormal.mode`

On floating-point `atomicrmw`. Denormal handling does not matter and may
differ from the function's `denormal_fpenv` mode. This lets targets with
fixed denormal behavior in atomic units emit native atomics. Node: empty;
contents ignored.

**Deprecated:** former spelling `amdgpu.ignore.denormal.mode`.

### `!type`

Described in a separate "Type Metadata" document, not in this chapter's
source. Its shape is `!{i64 offset, !"typeid"}` (seen in the `!callgraph`
discussion).

### `!callee_type`

On indirect calls. Lists the types of the intended callees, for a call graph
section in the object file. It is a list of one or more generalized
`!callgraph`-style nodes, each holding a callee type identifier.

Type identifier (current ABI detail): take the generalized mangled name of
"typeinfo name for T", MD5 it, and read the first 8 bytes as a
little-endian 64-bit integer. Generalization treats all pointer types as
equal when the pointee qualifiers match (`char*`, `char**`, `int*` equal;
`char*` and `const char*` differ).

**Not documented:** a full `!callee_type` example.

### `!callgraph`

On a function definition. A one-element tuple holding the generalized type
identifier string. Unlike `!type`, it has no offset.

```llvm
define void @foo() !callgraph !0
!0 = !{!"_ZTSFvvE.generalized"}
```

### `!associated`

On a global variable **definition**. One operand: a global object (possibly
through an alias). Lowers to ELF `SHF_LINK_ORDER`: the linker may not drop
this global unless it also drops the referenced object. No effect on non-ELF
targets.

Advice: put the global in `@llvm.compiler.used`, and in the same comdat as
the referenced global if that one has a comdat. It cannot express
many-to-one relationships, so functions should generally not reference such
globals.

```llvm
@b = internal global i32 2, comdat $a, section "abc", !associated !0
!0 = !{ptr @a}
```

### `!prof`

Profile data. The first operand is a string naming the kind. Three kinds:

| Kind | Attaches to | Shape |
| --- | --- | --- |
| `branch_weights` | `br`, `select`, `switch`, calls | Not specified here (see "Branch Weight Metadata" document) |
| `function_entry_count` | function definitions | Not specified here |
| `VP` | indirect calls; calls to `memcpy`/`memmove`/`memset` intrinsics | `!{!"VP", i32 kind, i64 total, (i64 value, i64 count)*}` |

`VP` (value profile): kind 0 is indirect call targets (values are hashes of
callee names); kind 1 is memory operations (values are byte lengths).
Values must not repeat. The counts need not add up to the total.

```llvm
call void %f(), !prof !1
!1 = !{!"VP", i32 0, i64 1600, i64 7651369219802541373, i64 1030,
       i64 -4377547752858689819, i64 410}
```

**Not documented:** the operand layout of `branch_weights` and
`function_entry_count`.

### `!annotation`

On any instruction. A tuple of strings, or a tuple of tuples of strings. No
effect on semantics; only for reporting to users.

```llvm
%a.addr = alloca ptr, align 8, !annotation !0
!0 = !{!"auto-init"}
!1 = !{!2}
!2 = !{!"gep offset", !"0"}
```

### `!func_sanitize`

On functions. Two operands: the ubsan function signature (`i32`) and a
pointer to a proxy variable holding the address of the RTTI descriptor. If a
function has both `prologue` and `!func_sanitize`, the prologue comes first
in the output.

```llvm
define void @_Z3funv() !func_sanitize !0 { ... }
!0 = !{i32 846595819, ptr @__llvm_rtti_proxy}
```

### `!kcfi_type`

On functions that may be called indirectly. One `i32` type id, emitted
before the function entry. Indirect calls with the `kcfi` operand bundle
check it.

```llvm
define dso_local i32 @f() !kcfi_type !0 { ret i32 0 }
!0 = !{i32 12345678}
```

### `!pcsections`

On instructions and functions whose addresses (PCs) should be emitted into
special sections.

**Not documented:** the shape. It is in the separate "PC Sections Metadata"
document.

### `!memprof`

On heap allocation calls. A list of contexts. Each context is
`!{!stack, !"tag", ...}`: a node of `i64` call-site ids (leaf first,
outermost last), followed by one or more strings such as `!"cold"` or
`!"notcold"`.

```llvm
%call = call ptr @_Znam(i64 10), !memprof !0, !callsite !5
!0 = !{!1, !3}
!1 = !{!2, !"cold"}
!2 = !{i64 4854880825882961848, i64 1905834578520680781}
!3 = !{!4, !"notcold"}
!4 = !{i64 4854880825882961848, i64 -6528110295079665978}
!5 = !{i64 4854880825882961848}
```

### `!callsite`

On allocation calls and other calls in profiled contexts. A list of `i64`
call-site ids (usually hashes of debug info). One id if not inlined; if
inlined, the ids of the full inline chain, leaf first.

```llvm
%call = call ptr @_Z1Bb(void), !callsite !0
!0 = !{i64 -6528110295079665978, i64 5462047985461644151}
```

### `!noalias.addrspace`

On memory instructions, including `atomicrmw`, `cmpxchg` and `call`. The
access cannot touch objects allocated in the listed address-space ranges.
Same format as `!range`, but entries must be `i32`. If the object is in one
of those address spaces, the behavior is undefined. Meant for targets with
generic address spaces.

```llvm
%rmw.valid = atomicrmw and ptr %ptr, i64 %value seq_cst, !noalias.addrspace !0
!0 = !{i32 5, i32 6}   ; excludes addrspace(5)
```

### `!mmra`

Memory model relaxation annotations: target-defined tags that relax memory
model constraints. On `atomicrmw`, `cmpxchg`, `load`, `store`, `fence` and
memory-touching `call`. A tag is a pair of strings (prefix, suffix). The
attachment is either one pair, or a tuple of pairs.

```llvm
!0 = !{!"amdgpu-synchronize-as", !"global"}
!1 = !{!"amdgpu-synchronize-as", !"private"}
!2 = !{!0, !1}
```

**Epitome note:** a node with exactly two `MDString` operands is a single
tag; a node whose operands are nodes is a list of tags.

### `!nofree`

The memory the pointer points to will not be freed after this instruction.

**Not documented:** which instructions it attaches to and the node's shape.

### `!alloc_token`

On calls to allocation functions. Gives the allocated type for the
`alloc-token` pass.

```llvm
!0 = !{!"<type-name>", i1 <contains-pointer>}
!1 = !{!"<type-name>", i1 <contains-pointer>, !"<function-name>"}
```

### `!stack-protector`

On `alloca`. One integer. `i32 0` means this alloca does not on its own make
the function need a stack protector.

```llvm
%a = alloca [1000 x i8], align 1, !stack-protector !0
!0 = !{i32 0}
```

**Not documented:** the meaning of non-zero values.

### `!implicit.ref`

On a function or global variable definition. One operand: a global object.
Lowers to the `.ref` assembly directive (an implicit reference from the
global's section, keeping the target alive). Only affects XCOFF. Several may
be attached to the same global.

```llvm
@c = global i32 3, section "abc", !implicit.ref !0, !implicit.ref !1
!0 = !{ptr @a}
!1 = !{ptr @b}
```

### `!inline_history`

On call instructions. Lists functions this call was inlined from. A call to
any listed function should not be inlined again, to avoid endless inlining
through mutual recursion. Operands are function pointers or `null` (a
function that was erased).

```llvm
call void @foo(), !inline_history !0
!0 = !{ptr @bar, null, ptr @baz}
```

### `!elf_section_properties`

On a function or global variable. Sets ELF `sh_type` (first operand) and
`sh_entsize` (second operand) for its section.

```llvm
@global = global i32 1, !elf_section_properties !{i32 1879002126, i32 8}
```

(1879002126 is `SHT_LLVM_CFI_JUMP_TABLE`.)

## Loop metadata

### `!llvm.loop`

Attached to the branch in the loop latch block (the block that branches back
to the header). The node is a list of property nodes.

```
!L = distinct !{ !L, [!DILocation_start, [!DILocation_end,]] !prop, ... }
```

- The first operand must be the node itself (a legacy rule, from before
  `distinct` existed).
- Then zero, one or two `DILocation`s: loop start, then loop end.
- Then property nodes. Each usually starts with a string name.

Loop metadata is not a loop identity: it may not survive transformations
and may be shared by several loops.

```llvm
br i1 %exitcond, label %._crit_edge, label %.lr.ph, !llvm.loop !0
!0 = !{!0, !1, !2}
!1 = !{!"llvm.loop.unroll.enable"}
!2 = !{!"llvm.loop.unroll.count", i32 4}
```

### Loop property nodes

"Followup" properties name the attributes a loop produced by a
transformation will have. Their shape is described in a separate "Code
Transformation Metadata" document.

**Not documented:** the operand shape of all `followup_*` properties.

| Property | Shape | Meaning |
| --- | --- | --- |
| `llvm.loop.disable_nonforced` | `!{!"..."}` (inferred) | Disable all optional, heuristic-driven loop transformations; only explicitly requested ones run. Canonicalizations such as rotation still run |
| `llvm.loop.vectorize.enable` | `!{!"llvm.loop.vectorize.enable"}` | Enable vectorization |
| `llvm.loop.vectorize.disable` | `!{!"llvm.loop.vectorize.disable"}` | Disable vectorization |
| `llvm.loop.vectorize.predicate.enable` | single string | Enable predication (fold the scalar epilogue). Implies vectorization |
| `llvm.loop.vectorize.predicate.disable` | single string | Disable predication |
| `llvm.loop.vectorize.scalable.enable` | single string | Enable scalable vectorization (only if vectorization is on) |
| `llvm.loop.vectorize.scalable.disable` | single string | Disable scalable vectorization |
| `llvm.loop.vectorize.width` | `!{!"...", i32 N}` | Target width. 1 disables; 0 or absent means automatic |
| `llvm.loop.vectorize.followup_vectorized` | followup | Attributes of the vectorized loop |
| `llvm.loop.vectorize.followup_epilogue` | followup | Attributes of the scalar epilogue loop |
| `llvm.loop.vectorize.followup_all` | followup | Attributes added to both |
| `llvm.loop.vectorize.body` | `!{!"...", i32 1}` | Added by the vectorizer: this is a vector loop body |
| `llvm.loop.vectorize.epilogue` | `!{!"...", i32 1}` | Added by the vectorizer: this is a remainder loop |
| `llvm.loop.interleave.count` | `!{!"...", i32 N}` | Interleave count. 1 disables; 0 means automatic |
| `llvm.loop.unroll.count` | `!{!"...", i32 N}` | Positive unroll factor. If trip count is smaller, partial unroll |
| `llvm.loop.unroll.disable` | single string | No unrolling |
| `llvm.loop.unroll.runtime.disable` | single string | No runtime unrolling |
| `llvm.loop.unroll.enable` | single string | Fully unroll if trip count known at compile time, else partially |
| `llvm.loop.unroll.full` | single string | Fully unroll |
| `llvm.loop.unroll.followup` | followup | Attributes of the unrolled loop |
| `llvm.loop.unroll.followup_remainder` | followup | Attributes of the remainder loop |
| `llvm.loop.unroll_and_jam.count` | `!{!"...", i32 N}` | Positive unroll-and-jam factor |
| `llvm.loop.unroll_and_jam.disable` | single string | No unroll-and-jam |
| `llvm.loop.unroll_and_jam.enable` | single string | Unroll-and-jam fully if trip count known, else partially |
| `llvm.loop.unroll_and_jam.followup_outer` | followup | Outer unrolled loop |
| `llvm.loop.unroll_and_jam.followup_inner` | followup | Inner jammed loop |
| `llvm.loop.unroll_and_jam.followup_remainder_outer` | followup | Epilogue of the outer loop (ignored if fully unrolled) |
| `llvm.loop.unroll_and_jam.followup_remainder_inner` | followup | Inner loop(s) of the epilogue |
| `llvm.loop.unroll_and_jam.followup_all` | followup | Added to all unroll-and-jam loops |
| `llvm.loop.licm_versioning.disable` | single string | Do not version the loop to enable LICM |
| `llvm.loop.distribute.enable` | single string | Enable loop distribution |
| `llvm.loop.distribute.disable` | single string | Disable loop distribution |
| `llvm.loop.distribute.followup_coincident` | followup | Extracted loops with no cyclic dependencies |
| `llvm.loop.distribute.followup_sequential` | followup | Isolated loops with unsafe dependencies |
| `llvm.loop.distribute.followup_fallback` | followup | Non-distributed fallback version |
| `llvm.loop.distribute.followup_all` | followup | Added to all followup loops |
| `llvm.loop.isdistributed` | not documented | Added after successful distribution |
| `llvm.loop.estimated_trip_count` | `!{!"...", i32 N}` (or narrower int) | Estimated average trip count (header executions per entry) |
| `llvm.loop.parallel_accesses` | `!{!"llvm.loop.parallel_accesses", !group, ...}` | Listed access groups have no loop-carried dependences |
| `llvm.loop.mustprogress` | single string (inferred) | Loop must terminate, unwind or interact observably; otherwise may be removed. Matches the `mustprogress` attribute |
| `llvm.loop.align` | `!{!"...", i32 N}` | Positive power-of-two byte alignment for the loop; backend uses the max of this and its preferred value |
| `llvm.licm.disable` | `!{!"llvm.licm.disable"}` | No LICM on this loop. Has no `llvm.loop` prefix because `disable_nonforced` does not affect it |

Notes:

- `llvm.loop.vectorize.*` and `llvm.loop.interleave.*` are hints only.
- Using `llvm.loop.disable_nonforced` with any explicit directive is
  recommended. A loop should have at most one directive (chain more with
  followups); otherwise the outcome depends on pass order.
- Any loop with `llvm.loop.unroll.*` but no `llvm.loop.unroll_and_jam.*`
  metadata has unroll-and-jam disabled. `llvm.loop.unroll_and_jam.full` is
  not supported.
- Body and epilogue markers together classify a loop: body only = main
  vector loop; epilogue only = scalar epilogue; both = vectorized epilogue;
  neither = an ordinary loop.
- Estimated trip count: passes read and write it through helper functions.
  If absent, it is derived from `branch_weights`. A value of 0 is legal and
  means execution is expected to leave before reaching the header; it is
  distinct from "no estimate".

**Epitome note:** a missing estimated trip count must stay distinguishable
from zero in Epitome's API (for example `Option<u32>`).

### `!llvm.access.group`

On any instruction that may access memory. Points to an **access group**:
a `distinct` empty node. To belong to several groups, point to a tuple of
groups instead.

```llvm
%val = load i32, ptr %arrayidx, !llvm.access.group !0
!0 = !{!1, !2}
!1 = distinct !{}
!2 = distinct !{}
```

Rules:

- An access group must be `distinct` and empty. Being empty is how it is
  told apart from a list of groups.
- A list of groups must not be empty.

### `!llvm.loop.parallel_accesses`

A loop property listing access groups. Instructions in those groups have no
dependences carried by this loop. If every memory access in the loop
belongs to a listed group, the loop is parallel; a carried dependence is
then undefined behavior. If some memory access has no listed group, the
loop is not trivially parallel. An instruction in several groups qualifies
if any of its groups is listed.

```llvm
!0 = distinct !{!0, !{!"llvm.loop.parallel_accesses", !1}}
!1 = distinct !{}
```

Nested loops: the outer loop lists both the inner loop's group and its own.

### `!llvm.mem.parallel_loop_access`

**Not documented:** this kind is not mentioned in this version of the
manual. `llvm.access.group` with `llvm.loop.parallel_accesses` is the
documented mechanism.

## Module flags

Module flags carry facts about the whole module, as key/value pairs, in the
named metadata `!llvm.module.flags`. Each operand is a triple:

```
!{ i32 behavior, !"key", value }
```

- `behavior`: what to do when linked modules both have this key.
- `key`: an `MDString`. A module may have only one entry per key, except
  entries with behavior `Require`.
- `value`: the flag's value.

When modules are linked, the result has exactly one entry per key, decided
by the behavior. `Require` entries are always kept.

### Behaviors

| Value | Name | On merge |
| --- | --- | --- |
| 1 | `Error` | Error if values differ. Otherwise keep the value |
| 2 | `Warning` | Warn if values differ. Keep the first module's value, unless the other module uses `Min` or `Max`, then take the min or max |
| 3 | `Require` | Value is a pair `!{!"other-key", value}`. After linking, `other-key` must exist with that value, or it is an error. Used to restrict `Override` results |
| 4 | `Override` | Use this value regardless of the other module. If both use `Override` with different values, error |
| 5 | `Append` | Concatenate the two values, which must be nodes |
| 6 | `AppendUnique` | Like `Append`, but drop entries of the second list already present |
| 7 | `Max` | Take the larger. Values must be integers |
| 8 | `Min` | Take the smaller. Values must be non-negative integers. A missing flag counts as 0 |

A key may not have two different behaviors, except `Require` and `Override`.

```llvm
!0 = !{ i32 1, !"foo", i32 1 }
!1 = !{ i32 4, !"bar", i32 37 }
!2 = !{ i32 2, !"qux", i32 42 }
!3 = !{ i32 3, !"qux", !{ !"foo", i32 1 } }
!llvm.module.flags = !{ !0, !1, !2, !3 }
```

**Not documented:** the manual says `Min` treats a missing flag as 0, but does
not say how other behaviors treat a flag present in only one module. The
natural reading is that the single value is kept.

**Epitome note:** the module linker must implement these merge rules
exactly, including the `Warning`/`Min`/`Max` interaction.

### Known module flags

| Key | Behavior | Value | Meaning |
| --- | --- | --- | --- |
| `ms-hotpatch` | `Min` (8) | `i32` 0 or 1 | 1 sets the HotPatch bit in the CodeView `S_COMPILE3` record. Does not make functions patchable by itself (`"patchable-function"` attribute does) |
| `frame-pointer` | `Max` | 0, 1, 2 | Synthesized functions get `"frame-pointer"` = `"none"`, `"non-leaf"`, `"all"` |
| `function_return_thunk_extern` | not documented | not documented | Synthesized functions get `fn_return_thunk_extern` |
| `uwtable` | `Max` | 0, 1, 2 | 1: synthesized functions get `uwtable(sync)`; 2: `uwtable(async)` |
| `Objective-C Version` | not documented | 1 or 2 | Required. ObjC ABI version |
| `Objective-C Image Info Version` | not documented | 0 | Required. Image info section version |
| `Objective-C Image Info Section` | not documented | string | Required. `"__OBJC, __image_info, regular"` (ABI 1) or `"__DATA,__objc_imageinfo, regular, no_dead_strip"` (ABI 2) |
| `Objective-C Garbage Collection` | not documented | 0 or 2 | Required. 0 none, 2 supported |
| `Objective-C GC Only` | not documented | 6 | Optional. GC only; requires GC flag = 2 |
| `short_wchar` | example uses 1 | 0 or 1 | 0: `wchar_t` is 4 bytes; 1: 2 bytes (ARM) |
| `short_enum` | example uses 1 | 0 or 1 | 0: enums at least `int`; 1: smallest fitting type (ARM) |
| `float-abi` | `Error` (required) | `"soft"` or `"hard"` | FP calling convention. Absent: target default |
| `thread-model` | `Error` (required) | `"posix"` or `"single"` | Single allows atomics to be lowered to plain operations. Absent: target default |
| `target-abi` | example uses `Error` | string | Target-specific ABI name, e.g. RISC-V `"ilp32"`, `"ilp32d"`, `"lp64"`, `"lp64d"`; ARM `"aapcs"`, `"apcs-gnu"` |
| `exception-model` | `Error` (required) | `"none"`, `"dwarf"`, `"sjlj"`, `"arm"`, `"wineh"`, `"wasm"`, `"emscripten"` | EH model. Absent means unspecified (target default), which differs from `"none"` |
| `long-double-type` | `Error` (required) | `"float"`, `"double"`, `"fp128"`, `"x86_fp80"`, `"ppc_fp128"` | Format libm uses for `long double` |
| `override-stack-alignment` | `Error` (example) | `i32` bytes | Overrides default stack alignment. Different values may not be linked |
| `cfguard` | warn on mismatch | 0, 1, 2 | Windows CFG: 0 off; 1 table only; 2 table and checks |
| `cfguard-mechanism` | warn on mismatch | 0, 1, 2 | 0 default; 1 "check" (call checker then target); 2 "dispatch" |
| `require-logical-pointer` | not documented | not documented | Module may use only logical pointer intrinsics (`@llvm.structured.gep`, `@llvm.structured.alloca`); plain `getelementptr` and `alloca` are illegal |

Objective-C GC interactions: merging GC = 0 with GC = 2 gives 0. A module
with GC = 0 cannot be merged with one that has GC Only = 6.

The synthesized-function flags give default attributes for functions created
by instrumentation passes (for example sanitizers).

**Not documented:** the manual's `short_wchar` example sets the flag to 1
but describes it as a 4-byte `wchar_t`, which contradicts the table (1 means
2 bytes). Trust the table.

## Embedded objects: `!llvm.embedded.objects`

For offloading. Lists globals whose contents are device code to embed into
the host binary. Each operand is `!{ptr @global, !"section-name"}`.

```llvm
!llvm.embedded.objects = !{!0}
!0 = !{ptr @object, !".section"}
```

## Linker options: `!llvm.linker.options`

Linker command-line options embedded in object files. Each operand is a
node whose operands are strings. One node is one option group, kept
together as a unit (for example `-framework Cocoa`).

```llvm
!0 = !{ !"-lz" }
!1 = !{ !"-framework", !"Cocoa" }
!llvm.linker.options = !{ !0, !1 }
```

Each option must be valid for the target linker, or reserved by the target's
assembly or object writer. Nothing else is defined.

## Dependent libraries: `!llvm.dependent-libraries`

Libraries to add to the link. Each operand is a node with one string. The
linker decides what each string means.

```llvm
!0 = !{!"a library specifier"}
!1 = !{!"another library specifier"}
!llvm.dependent-libraries = !{ !0, !1 }
```

## `!llvm.errno.tbaa`

Module-level named metadata listing TBAA access tags for accesses to
`errno`. They are guaranteed `int`-compatible under C/C++ strict aliasing.
Several tags are allowed, so modules with different TBAA trees can be
merged. See the example under `!tbaa`.

## ThinLTO summary

ThinLTO builds a compact summary of each module. In textual IR, summary
entries start with `^`. `llvm-as` writes them into bitcode. Tools that
optimize IR (`opt`, `clang -x ir`) ignore them.

**Not documented:** building an in-memory summary index from text is
described as future work.

**Epitome note:** Epitome's parser must at least accept and skip `^N = ...`
entries, and should be able to round-trip them if it writes bitcode summaries.

There are three entry types.

### Module path entries

```
^0 = module: (path: "/path/to/file.o", hash: (2468601609, 1329373163, 1565878005, 638838075, 3148790418))
```

- `path`: path of the bitcode file.
- `hash`: 160-bit SHA-1 of the IR bitcode, as five 32-bit integers.

### Global value entries

```
^4 = gv: (name: "f"[, summaries: (Summary)[, (Summary)]*]?) ; guid = 14740650423002898831
```

A declaration has no `summaries`. A definition has one summary per module
defining it (several for weak symbols in a combined index). The guid
appears in a comment.

Summary forms:

```
function: (module: ^0, flags: (linkage: external, notEligibleToImport: 0, live: 0, dsoLocal: 0), insts: 2[, FuncFlags]?[, Calls]?[, TypeIdInfo]?[, Params]?[, Refs]?
variable: (module: ^0, flags: (linkage: external, notEligibleToImport: 0, live: 0, dsoLocal: 0)[, Refs]?
alias: (module: ^0, flags: (linkage: external, notEligibleToImport: 0, live: 0, dsoLocal: 0), aliasee: ^2)
```

| Field | Meaning |
| --- | --- |
| `module` | Id of the module entry holding the definition |
| `flags` | `linkage`; `notEligibleToImport` (may not import); `live` (globally live); `dsoLocal` (linker resolved it locally). Last two set during the thin link |
| `insts` | Number of IR instructions in the function |
| `aliasee` | Summary id of the aliased value |

**Not documented:** the closing parentheses in the function and variable
forms are missing in the manual. The full set of `linkage` spellings is not
listed here (presumably the IR linkage names).

#### FuncFlags

```
funcFlags: (readNone: 0, readOnly: 0, noRecurse: 0, returnDoesNotAlias: 0, noInline: 0, alwaysInline: 0, noUnwind: 1, mayThrow: 0, hasUnknownCall: 0)
```

Unlisted flags default to 0 (the conservative value).

#### Calls

```
calls: ((Callee)[, (Callee)]*)
Callee ::= callee: ^1[, hotness: None]?[, relbf: 0]?
```

At most one of `hotness` (`Unknown`, `Cold`, `None`, `Hot`, `Critical`;
default `Unknown`) and `relbf` (branch frequency relative to entry, scaled
down by 2^8; default 0).

#### Params (stack safety)

```
params: ((Param)[, (Param)]*)
Param ::= param: 4, offset: [0, 5][, calls: ((Callee)[, (Callee)]*)]?
Callee ::= callee: ^3, param: 5, offset: [-3, 3]
```

- `param`: parameter number.
- `offset`: inclusive byte range the function may access through this
  pointer, not counting accesses in `calls`.
- Each callee entry: the pointer, at an offset within `offset`, is passed
  as parameter `param` of `callee`. The thin link folds `calls` into
  `offset` and removes it.
- A pointer parameter with no `Param` is unsafe (any offset possible).

Note: the grammar line spells the keyword `Params:` but the example uses
`params:`. The lower-case form is the one in real output.

#### Refs

```
refs: ((Ref)[, (Ref)]*)
```

Each `Ref` is a summary id such as `^1`.

**Not documented:** whether refs carry extra flags (for example read-only
or write-only markers).

#### TypeIdInfo (CFI)

```
typeIdInfo: [(TypeTests)]?[, (TypeTestAssumeVCalls)]?[, (TypeCheckedLoadVCalls)]?[, (TypeTestAssumeConstVCalls)]?[, (TypeCheckedLoadConstVCalls)]?

typeTests: (TypeIdRef[, TypeIdRef]*)
typeTestAssumeVCalls: (VFuncId[, VFuncId]*)
typeCheckedLoadVCalls: (VFuncId[, VFuncId]*)
typeTestAssumeConstVCalls: (ConstVCall[, ConstVCall]*)
typeCheckedLoadConstVCalls: (ConstVCall[, ConstVCall]*)

VFuncId ::= vFuncId: (TypeIdRef, offset: 16)
ConstVCall ::= (VFuncId, args: (Arg[, Arg]*))
```

`TypeIdRef` is a summary id, or a GUID preceded by `guid:`. Each `Arg` is an
integer.

### Type id entries

Only in a combined index, when building with CFI.

```
^4 = typeid: (name: "_ZTS1A", summary: (typeTestRes: (kind: allOnes, sizeM1BitWidth: 7[, alignLog2: 0]?[, sizeM1: 0]?[, bitMask: 0]?[, inlineBits: 0]?)[, WpdResolutions]?)) ; guid = 7004155349499253778
```

- `typeTestRes.kind`: `unsat`, `byteArray`, `inline`, `single` or
  `allOnes`.
- `sizeM1BitWidth`: bit width of size minus one.
- `alignLog2`, `sizeM1`, `bitMask`, `inlineBits`: optional, default 0.

Whole-program devirtualization resolutions:

```
wpdResolutions: ((offset: 0, WpdRes)[, (offset: 1, WpdRes)]*
wpdRes: (kind: branchFunnel)
wpdRes: (kind: singleImpl, singleImplName: "_ZN1A1nEi")
wpdRes: (kind: indir)
resByArg: (ResByArg[, ResByArg]*)
ResByArg ::= args: (Arg[, Arg]*), byArg: (kind: UniformRetVal[, info: 0][, byte: 0][, bit: 0])
```

- Each `wpdRes` may carry an optional `resByArg` for calls whose arguments
  are all constant integers.
- `byArg.kind`: `Indir`, `UniformRetVal`, `UniqueRetVal`,
  `VirtualConstProp`.
- `info`: the uniform return value (`UniformRetVal`), or the return value
  for the unique vtable, 0 or 1 (`UniqueRetVal`).
- `byte`, `bit`: used only when the target cannot store constants in
  absolute symbols.

**Not documented:** the closing parenthesis of `wpdResolutions` is missing
in the manual, and the exact position of `resByArg` within `wpdRes` is not
shown.

## Intrinsic global variables

Some globals named `llvm.*` have special meaning. They should be placed in
section `"llvm.metadata"`. That section and all global names starting with
`llvm.` are reserved for LLVM.

### `@llvm.used`

An array with `appending` linkage, of pointers to named global variables,
functions and aliases (optionally through a `bitcast` or `getelementptr`
cast).

```llvm
@llvm.used = appending global [2 x ptr] [
   ptr @X,
   ptr @Y
], section "llvm.metadata"
```

Compiler, assembler and linker must treat each listed symbol as referenced
by something they cannot see. For example, an internal global only listed
here may not be deleted. This matches GNU C `__attribute__((used))`. Some
targets must emit a directive so the assembler and linker keep the symbol.

### `@llvm.compiler.used`

Like `@llvm.used`, but only the compiler must keep the symbol. The linker
may still optimize it. Rare; should not be exposed to source languages.

### `@llvm.global_ctors`

```llvm
%0 = type { i32, ptr, ptr }
@llvm.global_ctors = appending global [1 x %0] [%0 { i32 65535, ptr @ctor, ptr @data }]
```

Each element: priority (`i32`), constructor function, associated data.
Constructors run when the module loads, in **ascending** priority (lowest
first). Order within equal priority is undefined. If the third field is
non-null and points to a global or function, the constructor runs only if
that data from this module is not discarded. On ELF that data must be in a
comdat.

### `@llvm.global_dtors`

Same layout as `@llvm.global_ctors`. Destructors run when the module
unloads, in **descending** priority (highest first). Equal priority order is
undefined. The third field has the same meaning as for constructors.

**Epitome note:** linking modules concatenates these arrays (appending
linkage). The optimizer must treat everything listed in `@llvm.used` and
`@llvm.compiler.used` as used.

## Gaps in the source

Collected list of what this part of the manual does not cover:

- The full `DIExpression` operation list (only the ops in examples are
  known).
- Complete field lists, field types and defaults for specialized nodes.
- Full `DIFlag...`, `DISPFlag...`, `emissionKind:`, `DW_LANG_...`,
  `DW_VIRTUALITY_...` and dialect enumerations.
- `!prof` `branch_weights` and `function_entry_count` layouts.
- `!type`, `!pcsections` and followup-loop shapes (separate documents).
- `!nosanitize`, `!heapallocsite` and `!llvm.mem.parallel_loop_access` are
  not mentioned at all.
- Several example typos: `!BasicType` in `DISubroutineType`, `!DISubrange`
  in `DISubrangeType`, `"loop_header_weight"` without `!`, the
  `short_wchar` example, `!deferenceable`, and unbalanced parentheses in
  ThinLTO grammar.
