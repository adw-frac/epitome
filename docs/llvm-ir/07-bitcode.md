# Bitcode format

Source: LLVM Bitcode File Format document.

LLVM "bitcode" is really two layers:

1. The **bitstream** container. This is a generic, self-describing binary
   format for nested blocks of records. It knows nothing about LLVM IR.
2. The **LLVM IR encoding**. This is a set of block IDs and record codes that
   say how a module is stored inside a bitstream.

A bitcode stream can also be wrapped, either in a small fixed header (the
bitcode wrapper) or inside a section of a native object file.

This chapter covers the container first, then the wrappers, then the IR
encoding. The source document is incomplete. Several IR blocks are only named,
with no record list. See [Gaps](#gaps) for everything a reader or writer will
need that the document does not give.

The tool `llvm-bcanalyzer` dumps any bitstream in readable form. It is the
usual way to check an encoding by hand.

---

## 1. The bitstream container

### 1.1 Bit order

A bitstream is a sequence of bits. Bits are read starting from the **least
significant bit of each byte**, then moving to the next byte. Every value in
the stream is an unsigned integer built from these bits.

Multi-bit fields are also little-endian at the bit level: the first bit read
is the lowest bit of the value.

**Draconian note:** A reader can load the stream as little-endian 32-bit or
64-bit words and shift bits out from the bottom. A writer accumulates bits at
the top of a current word and flushes full words as little-endian bytes.

### 1.2 Magic number

The first four bytes of any bitstream are an application-specific magic
number. Generic tools may look at it to recognise a known stream type. They
should not treat an unknown magic number as an error, because new bitstream
applications appear all the time.

The LLVM IR magic number is given in [section 3.1](#31-llvm-ir-magic-number).

### 1.3 Primitive encodings

| Encoding | Written as | How it works |
| --- | --- | --- |
| Fixed width | `fixed(N)` | The low N bits of the value, written directly. A 3-bit field holding 1 is `001`. Used when the number of possible values is known, for example 1 bit for a boolean. |
| Variable width (VBR) | `vbr(N)` | The value is split into chunks of N-1 bits, lowest chunk first. Each chunk is written as N bits. The top bit of each N-bit piece is a continuation flag: 1 means more chunks follow, 0 means this is the last chunk. |
| 6-bit character | `char6` | A 6-bit field holding one character from a fixed 64-character alphabet (table below). |
| Blob | `blob` | Only inside an abbreviation. See [1.8](#18-abbreviation-operand-encodings). |

**VBR worked example.** Encode 30 (`0x1E`, binary `11110`) as `vbr4`. Each
chunk holds 3 bits.

- Low 3 bits are `110` (6). More bits remain, so set the continuation bit:
  `1110`.
- Next 3 bits are `011` (3, worth 3 << 3 = 24). Nothing remains, so the
  continuation bit is 0: `0011`.
- The two 4-bit pieces, lowest first, form the byte `0b0011_1110` = 62.
- The reader adds 6 + 24 = 30.

A value that fits in N-1 bits takes a single N-bit piece with the top bit 0.

**char6 alphabet.**

| Characters | Values |
| --- | --- |
| `a` to `z` | 0 to 25 |
| `A` to `Z` | 26 to 51 |
| `0` to `9` | 52 to 61 |
| `.` | 62 |
| `_` | 63 |

No other character can be encoded as char6. A writer must check the whole
string before choosing a char6 abbreviation.

**32-bit alignment.** In some places the stream is padded with zero bits
until the bit position is a multiple of 32. After that the position can be
stated as a count of 32-bit words.

### 1.4 Abbreviation IDs

The stream is a sequence of **blocks** and **data records**. Each one starts
with an **abbreviation ID** (abbrev ID). This is a fixed-width field. Its
width is set by the enclosing block (see [1.5](#15-blocks)).

| Abbrev ID | Name | Meaning |
| --- | --- | --- |
| 0 | `END_BLOCK` | End of the current block. |
| 1 | `ENTER_SUBBLOCK` | Start of a nested block. |
| 2 | `DEFINE_ABBREV` | Defines a new abbreviation. |
| 3 | `UNABBREV_RECORD` | A record written in the general, unabbreviated form. |
| 4 and up | (stream-defined) | A record written using a stream-defined abbreviation. |

### 1.5 Blocks

A **block** is a nested region of the stream. Each block has a block ID that
says what kind of content it holds.

- Block IDs 0 to 7 are reserved for **standard blocks**, whose meaning the
  bitstream format itself defines. Only block 0 (`BLOCKINFO`) is documented.
- Block IDs 8 and up belong to the application. LLVM IR uses several of
  these (see [3.3](#33-llvm-ir-block-ids)).

Every block records its own length, so a reader can skip a whole block in
one step. The LLVM IR reader uses this to skip function bodies and load them
lazily later.

While parsing, each open block carries two pieces of state:

- **Abbrev ID width.** At the very start of the stream (outside any block)
  the width is **2 bits**. Each `ENTER_SUBBLOCK` sets a new width for the
  body of that block.
- **Abbreviation list.** Abbreviations defined inside a block apply only to
  that block. Neither child blocks nor the parent block see them.
  Abbreviations can also come from a `BLOCKINFO` block, in which case they
  apply to every block with the matching block ID.

On entering a child block, the parent's state is saved, and the child starts
with its own width and its own abbreviation list. On leaving the child, the
parent's state is restored.

#### ENTER_SUBBLOCK

| Field | Encoding | Meaning |
| --- | --- | --- |
| abbrev ID = 1 | fixed(current width) | Marks the start of a block. |
| blockid | vbr(8) | Block ID of the new block. |
| newabbrevlen | vbr(4) | Abbrev ID width to use inside the new block. |
| (padding) | zero bits | Align to a 32-bit boundary. |
| blocklen | fixed(32) | Size of the block body in 32-bit words. |

The length lets a reader jump over the block without parsing it.

#### END_BLOCK

| Field | Encoding | Meaning |
| --- | --- | --- |
| abbrev ID = 0 | fixed(current width) | Marks the end of the current block. |
| (padding) | zero bits | Align to a 32-bit boundary. |

Because of this padding, every block is a whole number of 32-bit words long.

**Draconian note:** A writer does not know `blocklen` until the block is done.
Write a placeholder word, remember its position, and back-patch it at
`END_BLOCK`. The document does not say exactly where counting starts and
stops; the natural reading is "words after the `blocklen` word, up to and
including the aligned `END_BLOCK`". Confirm this against real files before
relying on it (see [Gaps](#gaps)).

### 1.6 Data records

A **record** is a **record code** plus a list of unsigned integer operands,
each up to 64 bits. What the code and operands mean depends on the block
type. A record can be written unabbreviated or with an abbreviation.

#### UNABBREV_RECORD

| Field | Encoding |
| --- | --- |
| abbrev ID = 3 | fixed(current width) |
| code | vbr(6) |
| numops | vbr(6) |
| op0, op1, ... | vbr(6) each |

This form can express any record, but it is bulky. For example, a target
triple written this way spends at least 12 bits per character, because all
letters have codes of 32 or more and so need two vbr6 pieces.

#### Abbreviated record

An abbreviated record is `[abbrev ID, fields...]`, where the abbrev ID is 4
or higher and the fields follow the operand list of that abbreviation.

The **record code is the first operand** of the abbreviation. It can be a
literal in the abbreviation (so it is not written in each record), or a fixed
or VBR field written in each record.

**Draconian note:** After decoding an abbreviated record, treat the first
decoded value as the record code and the rest as operands. Then the same
record-handling code works for both abbreviated and unabbreviated records.

### 1.7 DEFINE_ABBREV

An **abbreviation** is a compact layout for a class of records. It is
declared once and then used by many records. Abbreviations live in the
stream, so different files of the same format can use different ones.

| Field | Encoding |
| --- | --- |
| abbrev ID = 2 | fixed(current width) |
| numabbrevops | vbr(5) |
| abbrevop0, abbrevop1, ... | see below |

**ID assignment.** Abbreviation IDs are handed out in order, starting at 4.
For a given block, IDs go first to the abbreviations that `BLOCKINFO`
defines for that block ID (in their order), then to abbreviations defined
inside the block itself (in their order).

Each abbreviation operand starts with one bit, `isliteral`:

| Form | Bits | Meaning |
| --- | --- | --- |
| Literal | `1` (1 bit), then value as vbr(8) | Every record using this abbreviation has this exact value here. Nothing is written in the record for this operand. |
| Encoding, no data | `0` (1 bit), then encoding as fixed(3) | Operand encoding with no parameter. |
| Encoding with data | `0` (1 bit), encoding as fixed(3), then value as vbr(5) | Operand encoding with a parameter, such as a bit width. |

### 1.8 Abbreviation operand encodings

| Code | Name | Extra data | How the field is written in a record |
| --- | --- | --- | --- |
| 1 | Fixed | width (vbr5) | fixed(width) |
| 2 | VBR | width (vbr5) | vbr(width) |
| 3 | Array | none | Length as vbr(6), then that many elements. The element encoding is the **next** abbreviation operand. |
| 4 | Char6 | none | One char6 value (6 bits). Usually used as an array element type. |
| 5 | Blob | none | Length as vbr(6), then zero bits to a 32-bit boundary, then that many 8-bit bytes, then zero bytes until the byte count is a multiple of 4. |

Placement rules:

- An Array must be the last operand, except for the one operand after it
  that gives its element type.
- A Blob must be the last operand.

The document does not give extra-data presence by any rule other than this
table: Fixed and VBR carry data; Array, Char6 and Blob do not.

**Draconian note:** Blobs are aligned so that a reader can point straight into
a memory-mapped file without copying. In Rust this maps well to returning a
`&[u8]` borrowed from the input buffer.

**Worked example.** Suppose a block defines this abbreviation (three
operands):

```
[0, Fixed, 4]    -- record code, 4-bit fixed
[0, Array]       -- an array...
[0, Char6]       -- ...of char6 characters
```

A target triple record `[TRIPLE, 'a', 'b', 'c', 'd']` (TRIPLE is code 2 in
the module block) is then written as:

| Value | Width | Meaning |
| --- | --- | --- |
| 4 | abbrev ID width | First stream-defined abbreviation |
| 2 | fixed(4) | Record code `TRIPLE` |
| 4 | vbr(6) | Array length |
| 0, 1, 2, 3 | 6 bits each | char6 for `a`, `b`, `c`, `d` |

With an abbrev ID width of 3, that is 3 + 4 + 6 + 4 x 6 = 37 bits. Because
the code is not a literal, the same abbreviation also works for any other
char6 string record whose code fits in 4 bits.

### 1.9 Standard block 0: BLOCKINFO

`BLOCKINFO` holds information about other block types. Its records:

| Code | Name | Fields in order | Meaning |
| --- | --- | --- | --- |
| 1 | `SETBID` | blockid | Selects which block ID the following records describe. May appear many times. Must come before any other record. |
| (abbrev ID 2) | `DEFINE_ABBREV` | normal abbreviation definition | Defines an abbreviation for blocks with the current `SETBID` ID, not for `BLOCKINFO` itself. |
| 2 | `BLOCKNAME` | name bytes... | Optional. Name of the block type, for dump tools. |
| 3 | `SETRECORDNAME` | recordid, name bytes... | Optional. Name of one record code in the block type, for dump tools. |

Note that `DEFINE_ABBREV` here is the normal abbrev ID 2 form, not a record
with a code.

Although `BLOCKINFO` is described as "metadata", its abbreviations are needed
to parse later blocks. A reader **must not skip** it.

**Draconian note:** Keep a map from block ID to a list of BLOCKINFO
abbreviations at the reader level, not per block instance. When entering a
block, seed its abbreviation list from that map before any local
`DEFINE_ABBREV`. The document allows a `BLOCKINFO` block inside
`MODULE_BLOCK`; it does not say whether one can also appear at the top level
or how far its effect reaches (see [Gaps](#gaps)).

---

## 2. Wrappers

### 2.1 Bitcode wrapper header

A bitcode file can start with a small header that points at the real
bitstream. This allows extra data to sit in the same file.

The header is five 32-bit fields, all **little-endian** (20 bytes total):

| Offset | Field | Meaning |
| --- | --- | --- |
| 0 | Magic | Always `0x0B17C0DE`. On disk the bytes are `DE C0 17 0B`. |
| 4 | Version | Currently always 0. |
| 8 | Offset | Byte offset from the start of the file to the start of the bitstream. |
| 12 | Size | Size of the bitstream in bytes. |
| 16 | CPUType | Target-specific value describing the target CPU. |

The document does not name this the "Darwin" wrapper and does not say which
platforms produce it or what CPUType values mean.

**Draconian note:** A reader should check the first four bytes: `DE C0 17 0B`
means wrapper, then read `[Offset, Offset + Size)` as the bitstream.
`42 43 C0 DE` means a raw IR bitstream.

### 2.2 Native object file wrapper

Bitcode can also live inside a section of a native object file (ELF, COFF or
Mach-O):

| Object format | Section | Contents |
| --- | --- | --- |
| Mach-O | `__LLVM,__bitcode` | Embedded bitcode. |
| ELF, COFF and others | `.llvmbc` | Embedded bitcode. Older than FatLTO. It may not be suitable for LTO (for example, bitcode from `-fembed-bitcode`). |
| ELF only | `.llvm.lto` | FatLTO bitcode. It has already been through a pre-link LTO pipeline, so it is suitable for LTO. |

LTO means link-time optimisation. FatLTO is a mode where an object file
carries both native code and LTO-ready bitcode.

Tool support varies. `lld` and the gold plugin ignore `.llvmbc` when linking,
but can use `.llvm.lto` with the right command-line options.

---

## 3. LLVM IR encoding

LLVM IR is stored as blocks (for constant pools, function bodies, symbol
tables and so on) and records (for instructions, globals, types and so on).

The document does not list the abbreviations the LLVM writer uses. They are
fully described inside each file, and **a reader must not assume any
particular abbreviation set**.

### 3.1 LLVM IR magic number

The magic is written as six bitstream fields:

| Field | Width | Value |
| --- | --- | --- |
| `'B'` | 8 bits | `0x42` |
| `'C'` | 8 bits | `0x43` |
| | 4 bits | `0x0` |
| | 4 bits | `0xC` |
| | 4 bits | `0xE` |
| | 4 bits | `0xD` |

Applying the low-bit-first rule, the on-disk bytes are **`42 43 C0 DE`**.

### 3.2 Signed VBR

Plain VBR handles signed values badly: a negative number looks like a huge
unsigned value. So signed values use this mapping, then are written as a
normal VBR of the stated width:

- Value v >= 0: write `v << 1` (low bit 0).
- Value v < 0: write `(-v << 1) | 1` (low bit 1).

Small positive and small negative numbers both stay short.

Where it is used, per the document:

- `CST_CODE_INTEGER` and `CST_CODE_WIDE_INTEGER` records in
  `CONSTANTS_BLOCK`.
- Operands of `phi` instructions when the module version is 1 or later
  (relative operand encoding; see [3.4](#version-values)).

**Draconian note:** The document does not say how the most negative 64-bit
value is encoded, since `-v` overflows. Handle it explicitly in both reader
and writer.

### 3.3 LLVM IR block IDs

| Block ID | Name | Contents |
| --- | --- | --- |
| 0 | `BLOCKINFO` | Standard block (see [1.9](#19-standard-block-0-blockinfo)). |
| 8 | `MODULE_BLOCK` | Top-level block for one module. |
| 9 | `PARAMATTR_BLOCK` | Table of attribute lists. |
| 10 | `PARAMATTR_GROUP_BLOCK` | Table of attribute groups. |
| 11 | `CONSTANTS_BLOCK` | Constants for a module or a function. |
| 12 | `FUNCTION_BLOCK` | One function body. |
| 14 | `VALUE_SYMTAB_BLOCK` | Value symbol table. |
| 15 | `METADATA_BLOCK` | Metadata. |
| 16 | `METADATA_ATTACHMENT` | Links metadata to instructions in a function. |
| 17 | `TYPE_BLOCK` | The module's type table. |
| 23 | `STRTAB_BLOCK` | The file's string table. |

IDs 13 and 18 to 22, and anything above 23, are not described.

**Nesting**, as documented:

- `MODULE_BLOCK` may contain: `BLOCKINFO`, `PARAMATTR_BLOCK`,
  `PARAMATTR_GROUP_BLOCK`, `TYPE_BLOCK`, `VALUE_SYMTAB_BLOCK`,
  `CONSTANTS_BLOCK`, `FUNCTION_BLOCK`, `METADATA_BLOCK`.
- `FUNCTION_BLOCK` may contain: `CONSTANTS_BLOCK`, `VALUE_SYMTAB_BLOCK`,
  `METADATA_ATTACHMENT`.
- `STRTAB_BLOCK` sits after the module block(s) it serves (see
  [3.13](#313-strtab_block-id-23)).

### 3.4 MODULE_BLOCK (ID 8)

Each module has exactly one `MODULE_BLOCK`. A file may hold more than one
module ("multi-module bitcode"), and that is valid.

In the record tables below, a "string" field is a run of operands, one per
byte of the string. "Index + 1" fields use 0 to mean "none".

#### Module record codes

| Code | Name | Fields in order | Meaning |
| --- | --- | --- | --- |
| 1 | `VERSION` | version | Format version. 0, 1 and 2 are supported. See below. |
| 2 | `TRIPLE` | string | Target triple. |
| 3 | `DATALAYOUT` | string | Data layout string. |
| 4 | `ASM` | string | Module-level inline asm. Separate asm blocks are joined with newline (byte 10). |
| 5 | `SECTIONNAME` | string | One section name. Emit one per distinct section name used. Globals and functions refer to these by 1-based index, in record order. |
| 6 | `DEPLIB` | string | One dependent library name (from a `deplibs` declaration). One record per library. |
| 7 | `GLOBALVAR` | see below | Declares or defines a global variable. |
| 8 | `FUNCTION` | see below | Declares or defines a function. |
| 9 | `ALIAS` | see below | Defines an alias. |
| 11 | `GCNAME` | string | One garbage collector name. Functions refer to these by 1-based index, in record order. |

Code 10 is not described. `IFUNC` and `COMDAT` records are mentioned (under
version 2) but their codes and layouts are not given.

#### VERSION values

- **Version 0.** Every value an instruction defines gets an ID unique within
  its function. Function-level IDs start at `NumModuleValues`, because they
  share one numbering with module-level values. Numbering restarts for each
  function. Operands are written as these absolute value IDs, which can get
  large.
- **Version 1.** Instruction operands are written **relative** to the
  current instruction: operand = (current value ID) - (operand value ID). An
  operand that is the previous instruction's result is written as 1.
  Constants also use the relative form. Basic block labels do **not**; they
  stay absolute. Forward references give negative numbers. These are rare
  except in `phi`, so `phi` operands are written as signed VBR.
- **Version 2.** Same operand encoding as version 1, plus:
  - `FUNCTION`, `GLOBALVAR`, `ALIAS`, `IFUNC` and `COMDAT` records start with
    two operands, **strtab offset** and **strtab size**, giving the name in
    the string table.
  - `FNENTRY` records in the value symbol table no longer carry the function
    name.
  - The module-level `VALUE_SYMTAB_BLOCK` may contain only `FNENTRY`
    records.

The relative example from the document, in version 1 form:

```
#n   = load #1                    ; #1 means value #n-1
#n+1 = icmp eq #1, (#n+1)-#const0 ; constant operand is also relative
br #1, label #(bb1), label #(bb2) ; labels stay absolute
```

**Draconian note:** A writer targeting current LLVM should emit version 2.
A reader should accept 0, 1 and 2, and keep the version in its parse state
because it changes both operand decoding and name lookup.

#### GLOBALVAR (code 7)

`[GLOBALVAR, strtab_offset, strtab_size, pointer_type, isconst, initid,
linkage, alignment, section, visibility, threadlocal, unnamed_addr,
externally_initialized, dllstorageclass, comdat, attributes,
preemptionspecifier]`

| # | Field | Meaning |
| --- | --- | --- |
| 0 | strtab offset | Name: byte offset in the string table. |
| 1 | strtab size | Name: byte length in the string table. |
| 2 | pointer type | Type index of the pointer type that points to this global. |
| 3 | isconst | Non-zero if the global is constant within the module. |
| 4 | initid | 0 = no initializer. Otherwise value index of the initializer, plus 1. |
| 5 | linkage | Linkage code (table below). |
| 6 | alignment | log2(alignment) + 1. (0 presumably means none given.) |
| 7 | section | 0 = none. Otherwise 1-based index into `SECTIONNAME` records. |
| 8 | visibility | Optional. Visibility code. |
| 9 | threadlocal | Optional. TLS mode code. |
| 10 | unnamed_addr | Optional. unnamed_addr code. |
| 11 | externally_initialized | Not described; by name, a flag for the `externally_initialized` property. |
| 12 | dllstorageclass | Optional. DLL storage class code. |
| 13 | comdat | Encoding of the global's COMDAT. Format not given. |
| 14 | attributes | 0 = none. Otherwise 1-based index into the attribute list table. |
| 15 | preemptionspecifier | Optional. Preemption code. |

"Optional" fields are those the document marks "if present". The usual
reading is that trailing fields may be left off and then take their default
(code 0).

#### FUNCTION (code 8)

`[FUNCTION, strtab_offset, strtab_size, type, callingconv, isproto, linkage,
paramattr, alignment, section, visibility, gc, prologuedata, dllstorageclass,
comdat, prefixdata, personalityfn, preemptionspecifier]`

| # | Field | Meaning |
| --- | --- | --- |
| 0 | strtab offset | Name: byte offset in the string table. |
| 1 | strtab size | Name: byte length in the string table. |
| 2 | type | Type index of the function's function type. |
| 3 | callingconv | Calling convention code (table below). |
| 4 | isproto | Non-zero for a declaration (no body), zero for a definition. |
| 5 | linkage | Linkage code. |
| 6 | paramattr | 0 = none. Otherwise 1-based index into `PARAMATTR_BLOCK` entries. |
| 7 | alignment | log2(alignment) + 1. |
| 8 | section | 0 = none. Otherwise 1-based index into `SECTIONNAME` records. |
| 9 | visibility | Visibility code. |
| 10 | gc | Optional. 0 = none. Otherwise 1-based index into `GCNAME` records. |
| 11 | prologuedata | 0 = none. Otherwise value index of the prologue data, plus 1. |
| 12 | dllstorageclass | DLL storage class code. |
| 13 | comdat | Encoding of the function's COMDAT. Format not given. |
| 14 | prefixdata | 0 = none. Otherwise value index of the prefix data, plus 1. |
| 15 | personalityfn | 0 = none. Otherwise value index of the personality function, plus 1. |
| 16 | preemptionspecifier | Optional. Preemption code. |

The prose also describes an **unnamed_addr** field (optional, same codes as
for globals), but the field list does not include it, so its position is
not documented. See [Gaps](#gaps).

**Draconian note:** Function bodies appear later as `FUNCTION_BLOCK`s. The
document does not say how a body is matched to its `FUNCTION` record. The
natural guess is: in order, to the records with `isproto = 0`. Verify
against real files.

#### ALIAS (code 9)

`[ALIAS, strtab_offset, strtab_size, alias_type, aliasee_val, linkage,
visibility, dllstorageclass, threadlocal, unnamed_addr,
preemptionspecifier]`

| # | Field | Meaning |
| --- | --- | --- |
| 0 | strtab offset | Name: byte offset in the string table. |
| 1 | strtab size | Name: byte length in the string table. |
| 2 | alias type | Type index of the alias. |
| 3 | aliasee val# | Value index of the aliased value. |
| 4 | linkage | Linkage code. |
| 5 | visibility | Optional. Visibility code. |
| 6 | dllstorageclass | Optional. DLL storage class code. |
| 7 | threadlocal | Optional. TLS mode code. |
| 8 | unnamed_addr | Optional. unnamed_addr code. |
| 9 | preemptionspecifier | Optional. Preemption code. |

#### Shared code tables

**Linkage**

| Code | Linkage |
| --- | --- |
| 0 | `external` |
| 1 | `weak` |
| 2 | `appending` |
| 3 | `internal` |
| 4 | `linkonce` |
| 5 | `dllimport` (listed as a linkage) |
| 6 | `dllexport` (listed as a linkage) |
| 7 | `extern_weak` |
| 8 | `common` |
| 9 | `private` |
| 10 | `weak_odr` |
| 11 | `linkonce_odr` |
| 12 | `available_externally` |
| 13 | deprecated |
| 14 | deprecated |

Codes 5 and 6 are old encodings. Modern IR has a separate
`dllstorageclass` field. The document does not say how a reader should
convert codes 5, 6, 13 or 14, and it lists no codes above 14.

**Visibility**

| Code | Visibility |
| --- | --- |
| 0 | `default` |
| 1 | `hidden` |
| 2 | `protected` |

**Thread-local mode**

| Code | Mode |
| --- | --- |
| 0 | not thread-local |
| 1 | thread-local, default TLS model (general dynamic) |
| 2 | `localdynamic` |
| 3 | `initialexec` |
| 4 | `localexec` |

**unnamed_addr**

| Code | Meaning |
| --- | --- |
| 0 | not unnamed_addr |
| 1 | `unnamed_addr` |
| 2 | `local_unnamed_addr` |

**DLL storage class**

| Code | Class |
| --- | --- |
| 0 | default |
| 1 | `dllimport` |
| 2 | `dllexport` |

**Preemption specifier**

| Code | Meaning |
| --- | --- |
| 0 | `dso_preemptable` |
| 1 | `dso_local` |

**Calling convention**

| Code | Convention |
| --- | --- |
| 0 | `ccc` |
| 8 | `fastcc` |
| 9 | `coldcc` |
| 13 | `anyregcc` |
| 14 | `preserve_mostcc` |
| 15 | `preserve_allcc` |
| 16 | `swiftcc` |
| 17 | `cxx_fast_tlscc` |
| 18 | `tailcc` |
| 19 | `cfguard_checkcc` |
| 20 | `swifttailcc` |
| 64 | `x86_stdcallcc` |
| 65 | `x86_fastcallcc` |
| 66 | `arm_apcscc` |
| 67 | `arm_aapcscc` |
| 68 | `arm_aapcs_vfpcc` |

This list is partial. LLVM IR also allows `cc <n>` with any number, and the
LangRef lists many more named conventions. The bitcode value is presumably
the same number used in `cc <n>`, but the document does not say so.

### 3.5 PARAMATTR_BLOCK (ID 9)

This block is the table of **attribute lists**. An attribute list is the full
set of attributes for one function or call: return value, function and each
parameter. Each entry is unique; no two entries describe the same list.

Entries are referenced by 1-based index from:

- the `paramattr` field of module `FUNCTION` records;
- the `attr` field of `INST_CALL` and `INST_INVOKE` records in function
  blocks (whose layout is not documented).

The `attributes` field of `GLOBALVAR` also refers to "the table of
AttributeLists", presumably this one.

| Code | Name | Fields in order | Meaning |
| --- | --- | --- | --- |
| 2 | `ENTRY` | attrgrp0, attrgrp1, ... | One attribute list. Each operand is a group ID (`grpid`) from `PARAMATTR_GROUP_BLOCK`. |
| 1 | `ENTRY_OLD` | paramidx0, attr0, paramidx1, attr1, ... | Legacy (LLVM 3.2 and earlier). Pairs of (which slot, bitmap). Still accepted by readers. |

In `ENTRY_OLD`, `paramidx` is 0 for the return value, `0xFFFFFFFF` for the
function itself, and N (1-based) for parameter N. The `attr` bitmap is:

| Bits | Attribute |
| --- | --- |
| 0 | `zeroext` |
| 1 | `signext` |
| 2 | `noreturn` |
| 3 | `inreg` |
| 4 | `sret` |
| 5 | `nounwind` |
| 6 | `noalias` |
| 7 | `byval` |
| 8 | `nest` |
| 9 | `readnone` |
| 10 | `readonly` |
| 11 | `noinline` |
| 12 | `alwaysinline` |
| 13 | `optsize` |
| 14 | `ssp` |
| 15 | `sspreq` |
| 16-31 | `align n` (16-bit field; the document does not say if it is n or log2(n)) |
| 32 | `nocapture` |
| 33 | `noredzone` |
| 34 | `noimplicitfloat` |
| 35 | `naked` |
| 36 | `inlinehint` |
| 37-39 | `alignstack n`, stored as log2(n) + 1 |

**Draconian note:** A writer only needs code 2. Supporting `ENTRY_OLD` in the
reader is only needed for very old files.

### 3.6 PARAMATTR_GROUP_BLOCK (ID 10)

This block is the table of **attribute groups**. A group is the set of
attributes for one slot (return value, function, or one parameter).

| Code | Name | Fields in order | Meaning |
| --- | --- | --- | --- |
| 3 | `ENTRY` | grpid, paramidx, attr0, attr1, ... | One attribute group. |

- `grpid`: unique key for this group. `PARAMATTR_BLOCK` `ENTRY` records
  refer to groups by this key.
- `paramidx`: 0 = return value, `0xFFFFFFFF` = function, N = parameter N
  (1-based).
- Each `attr` is itself a variable-length run of operands:
  `kind, key..., [value...]`.

| kind | Meaning | key | value |
| --- | --- | --- | --- |
| 0 | Well-known attribute | One integer: the attribute kind code | none |
| 1 | Well-known attribute with integer argument | One integer: the attribute kind code | One integer: the argument |
| 3 | String attribute | Bytes of a null-terminated string (one operand per byte, ending with 0) | none |
| 4 | String attribute with string value | Bytes of a null-terminated string | Bytes of a null-terminated string |

Kind 2 is not used.

The attribute kind codes for kinds 0 and 1 come from an enumeration
(`AttributeKindCodes`) that the document does not list. It gives only two
examples:

| Code | Attribute |
| --- | --- |
| 0 | unused |
| 1 | `align(<n>)` |
| 2 | `alwaysinline` |

Two attributes pack two 32-bit arguments into one 64-bit integer value:

| Attribute | Packed value | Default rule |
| --- | --- | --- |
| `allocsize` | `(EltSizeParam << 32) \| NumEltsParam` | `NumEltsParam` is -1 (all ones in 32 bits) when not given. |
| `vscale_range` | `(Min << 32) \| Max` | `Max` equals `Min` when not given. |

**Draconian note:** Because string attributes end with a 0 operand, a reader
walks the operand list one attribute at a time; there is no per-attribute
length. Draconian needs its own full table of attribute kind codes, which this
document does not provide.

### 3.7 TYPE_BLOCK (ID 17)

This block is the module's **type table**. Every record except `NUMENTRY`
adds one entry. Entries are referenced by 0-based index from instructions,
constants, metadata, other type records, and so on. Entries are unique: no
two indices describe structurally equal types (named structs and opaque types
are the exception; they are never merged).

| Code | Name | Fields in order | Meaning |
| --- | --- | --- | --- |
| 1 | `NUMENTRY` | numentries | Total number of type entries. If present, must be the first record. Adds no entry. |
| 2 | `VOID` | (none) | `void` |
| 3 | `FLOAT` | (none) | `float` (32-bit IEEE) |
| 4 | `DOUBLE` | (none) | `double` (64-bit IEEE) |
| 5 | `LABEL` | (none) | `label` |
| 6 | `OPAQUE` | (none) | Opaque named struct. Name comes from the preceding `STRUCT_NAME`. Two opaque types are never merged. |
| 7 | `INTEGER` | width | Integer type `iN` with N = width. |
| 8 | `POINTER` | pointee type, [address space] | Typed pointer. Address space defaults to 0 if absent. |
| 9 | `FUNCTION_OLD` | vararg, ignored, retty, paramty... | Legacy (LLVM 3.0 and earlier) function type. `ignored` is skipped. |
| 10 | `HALF` | (none) | `half` (16-bit IEEE) |
| 11 | `ARRAY` | numelts, eltty | `[numelts x eltty]` |
| 12 | `VECTOR` | numelts, eltty | `<numelts x eltty>` |
| 13 | `X86_FP80` | (none) | `x86_fp80` |
| 14 | `FP128` | (none) | `fp128` |
| 15 | `PPC_FP128` | (none) | `ppc_fp128` |
| 16 | `METADATA` | (none) | `metadata` |
| 17 | `X86_MMX` | (none) | Deprecated. Read as `<1 x i64>`. |
| 18 | `STRUCT_ANON` | ispacked, eltty... | Literal (unnamed) struct. Packed if ispacked is non-zero. |
| 19 | `STRUCT_NAME` | string | Name for the next `OPAQUE`, `STRUCT_NAMED` or `TARGET_TYPE` record. Adds no entry. |
| 20 | `STRUCT_NAMED` | ispacked, eltty... | Identified (named) struct. Name from the preceding `STRUCT_NAME`. |
| 21 | `FUNCTION` | vararg, retty, paramty... | Function type. Vararg if non-zero. |
| 23 | `BFLOAT` | (none) | `bfloat` (16-bit brain float) |
| 24 | `X86_AMX` | (none) | `x86_amx` |
| 26 | `TARGET_TYPE` | num_tys, ty_params..., int_params... | Target extension type. Name from the preceding `STRUCT_NAME`. The first `num_tys` operands after `num_tys` are type indices; the rest are integer parameters. |

Codes 22 and 25 are not described.

The source says `NUMENTRY` adds no entry; it does not say the same of
`STRUCT_NAME`, but since `STRUCT_NAME` only supplies a name for the next
record, it cannot sensibly add one.

**Opaque pointers.** Current LLVM IR has only the opaque `ptr` type
(see [Types and constants](02-types-and-constants.md)). The only pointer
record documented here is the old typed `POINTER` (code 8), which names a
pointee type. The document does not give the record for `ptr` /
`ptr addrspace(N)`. See [Gaps](#gaps).

**Draconian note:** Struct element types can refer forward to later entries
(for recursive types). The document does not discuss this, so a reader
should allow forward type references and resolve them after the block ends.

### 3.8 CONSTANTS_BLOCK (ID 11)

The document gives only the block ID and these facts:

- It holds constants for either the module or one function, so it can
  appear inside `MODULE_BLOCK` or `FUNCTION_BLOCK`.
- `CST_CODE_INTEGER` and `CST_CODE_WIDE_INTEGER` records use signed VBR.

No record codes or layouts are given.

### 3.9 FUNCTION_BLOCK (ID 12)

The document gives only the block ID and its allowed children:
`CONSTANTS_BLOCK`, `VALUE_SYMTAB_BLOCK` and `METADATA_ATTACHMENT`.

It mentions `INST_CALL` and `INST_INVOKE` records with an `attr` field that
indexes `PARAMATTR_BLOCK`, and the version 1 relative operand encoding
(see [3.4](#version-values)). No instruction record codes or
layouts are given.

### 3.10 VALUE_SYMTAB_BLOCK (ID 14)

Only the block ID is documented, plus these facts from the version 2 notes:

- There is an `FNENTRY` record.
- From version 2, `FNENTRY` does not include the function name.
- From version 2, the module-level value symbol table holds only `FNENTRY`
  records.

The record code and fields of `FNENTRY`, and any other record types, are not
given.

### 3.11 METADATA_BLOCK (ID 15)

Only the block ID is documented.

### 3.12 METADATA_ATTACHMENT (ID 16)

Only the block ID and its purpose (attaching metadata to instructions in a
function) are documented.

### 3.13 STRTAB_BLOCK (ID 23)

| Code | Name | Fields in order | Meaning |
| --- | --- | --- | --- |
| 1 | `STRTAB_BLOB` | blob | The whole string table as one blob operand. |

- Strings are **not** null-terminated. A record names a string by
  `(strtab offset, strtab size)` in bytes.
- A string table serves **all earlier blocks** in the file, back to the
  previous `STRTAB_BLOCK` (if any). So the string table comes **after** the
  module block that uses it.
- A file normally has one string table. It can have more if several bitcode
  files were joined byte-for-byte.

**Draconian note:** A reader cannot resolve global names while reading
`MODULE_BLOCK`, because the string table comes later. Either scan ahead
for the `STRTAB_BLOCK` first (block lengths make skipping cheap), or store
`(offset, size)` pairs and resolve names once the string table is read. A
writer builds the string table while writing the module and emits it as a
top-level block after `MODULE_BLOCK`. Because `STRTAB_BLOB` is a blob, it
is meant to be written with an abbreviation that has a Blob operand. An
`UNABBREV_RECORD` could only carry the bytes as one VBR operand each.

### 3.14 Identification block and symbol table

The document does not describe an identification block or a symbol table
block (`SYMTAB`). Neither appears in its block ID list.

---

## 4. Overall file layout (as far as documented)

```
[optional 20-byte wrapper header: DE C0 17 0B ...]
42 43 C0 DE                       -- IR magic
  (abbrev ID width = 2 at top level)
  ENTER_SUBBLOCK MODULE_BLOCK (8)
    VERSION, TRIPLE, DATALAYOUT, ...
    BLOCKINFO (0), PARAMATTR_GROUP_BLOCK (10), PARAMATTR_BLOCK (9),
    TYPE_BLOCK (17), CONSTANTS_BLOCK (11), METADATA_BLOCK (15),
    GLOBALVAR / FUNCTION / ALIAS records,
    FUNCTION_BLOCK (12) per defined function
      CONSTANTS_BLOCK, METADATA_ATTACHMENT, VALUE_SYMTAB_BLOCK, ...
    VALUE_SYMTAB_BLOCK (14)
  END_BLOCK
  ENTER_SUBBLOCK STRTAB_BLOCK (23)
    STRTAB_BLOB
  END_BLOCK
```

The order of sub-blocks and records inside `MODULE_BLOCK` shown here is a
sketch, not a rule from the document. The document gives no required order,
except that a referenced table must be readable when needed (for example,
the type table before anything uses type indices, and groups before the
lists that name them). Readers should be written to handle what real files
contain.

---

## Gaps

The source document is explicitly incomplete. To read or write real LLVM
bitcode, Draconian needs the following, none of which is in the document.

**Container**

- Exactly which words `blocklen` counts (whether it includes the
  `END_BLOCK` and its padding).
- Whether a `BLOCKINFO` block may appear at top level, and whether its
  abbreviations persist across sibling blocks or modules.
- Standard block IDs 1 to 7: reserved but undefined.
- Whether a Blob may be used as an array element, or a literal may be the
  array element type (the document implies neither is allowed but does not
  say).
- How 64-bit edge cases are handled (VBR values wider than 64 bits; signed
  VBR of the minimum 64-bit value).

**Wrappers**

- The name, origin and `CPUType` values of the wrapper header (the
  "Darwin" wrapper is not named as such). Whether the stream after the
  wrapper may have trailing padding.

**Module block**

- Record codes and layouts for `IFUNC`, `COMDAT`, `VSTOFFSET`, source file
  name, hash, and any other module records. Code 10 is unexplained.
- The position of `unnamed_addr` in the `FUNCTION` record (described but
  missing from the field list). Any fields after `preemptionspecifier`
  (for example partition, address space, DSO-local equivalents, sanitizer
  data) are not listed for `GLOBALVAR`, `FUNCTION` or `ALIAS`.
- The format of the `comdat` field.
- The meaning and width of `externally_initialized`.
- How the `GLOBALVAR` "pointer type" field works now that pointers are
  opaque, and where a global's address space and value type are stored.
- How `FUNCTION_BLOCK`s are matched to `FUNCTION` records.
- What "value index" means across module and function scope: the order in
  which globals, functions, aliases, constants, arguments and instructions
  are numbered.
- Linkage codes above 14, and how to upgrade the legacy codes 5, 6, 13
  and 14.
- The full calling-convention number list.
- Required order of blocks and records in the module.

**Attributes**

- The full `AttributeKindCodes` table (only codes 1 and 2 are given).
- Whether `align n` in `ENTRY_OLD` stores n or log2(n).
- Encodings of type-carrying attributes (`byval(<ty>)`, `sret(<ty>)`,
  `elementtype`, and so on) and of any attribute kinds beyond 0, 1, 3, 4.

**Types**

- The record for opaque pointer types (`ptr`, `ptr addrspace(N)`).
- Type codes 22 and 25, and any codes above 26 (for example scalable vector
  flags, token type).
- How forward references inside the type table work.

**Constants, functions, symbol tables, metadata**

- Every record code and layout in `CONSTANTS_BLOCK` (including
  `SETTYPE`, null, undef, poison, integer, wide integer, float, aggregate,
  string, constant expressions). Only the names `CST_CODE_INTEGER` and
  `CST_CODE_WIDE_INTEGER` are given.
- Every instruction record in `FUNCTION_BLOCK` (`DECLAREBLOCKS`, each
  instruction, operand type rules, flags, debug locations). Only the names
  `INST_CALL` and `INST_INVOKE` appear.
- The exact relative-operand rule: when a type is also written after an
  operand (for forward references), and which operands are relative.
- Every record in `VALUE_SYMTAB_BLOCK`, including the code and fields of
  `FNENTRY`.
- Every record in `METADATA_BLOCK`, including how metadata strings, nodes,
  named metadata, metadata kinds and debug-info nodes are encoded. Where
  metadata kind names are declared.
- Every record in `METADATA_ATTACHMENT`.
- Block IDs and contents of other blocks used by current LLVM, such as an
  identification block, a symbol table block, operand bundle tags, sync
  scope names, use-list order, and module summary (ThinLTO) blocks. Block IDs
  13, 18 to 22 and above 23 are not covered.

**Practical consequence:** this document is enough to build a correct
generic bitstream reader and writer, wrapper detection, the string table,
the attribute tables (given a kind-code table) and most of the type table.
It is not enough to read or write function bodies, constants, metadata or
symbol tables. Those parts need another clean-room source, or must be
worked out from observing tool output (for example `llvm-bcanalyzer`
dumps of files Draconian did not write), if the clean-room rules allow it.
