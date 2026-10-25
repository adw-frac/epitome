# SystemVerilog

This is the plan for `epitome-sv`, a SystemVerilog compiler. It reads
IEEE 1800-2023 source, elaborates the design, and compiles it with
Epitome's optimiser and code generator into a simulator, as the `hw`,
`comb` and `seq` path of [MLIR](mlir.md) does for circuits from CIRCT.

The work is measured against the
[IEEE 1800-2023 conformance tests](https://github.com/andy-thomason/IEEE1800-2023-tests)
(`test1800`): 1478 self-checking tests, one directory per clause of the
standard. For sources and status labels, see the [index](README.md).

**Status:** Partial. The crate exists with a skeleton lexer. The parser
is next (section 10, step 2).

## 1. Goals

- **Parse all of IEEE 1800-2023.** Every test in `test1800` that is
  legal must parse, and every test whose `:should_fail_because:` is a
  syntax error must be rejected, with a message that points at the line
  and column.
- **Elaborate and simulate** the synthesisable subset first, then the
  testbench language (classes, `fork`, constrained random, assertions) as
  `test1800` clause by clause asks for it.
- **Compile, not interpret.** A design becomes Epitome IR and then machine
  code. Clocked logic that settles in one pass becomes a cycle-based
  `eval` function, which is one very large basic block (see
  [parallel](parallel.md), "Big blocks").
- **Stay linear in the size of the input.** Large netlists have millions
  of lines. No pass may be worse than linear in a module's size, and
  modules are processed in parallel with the same output for any number
  of threads.
- **Follow the clean-room rules** in section 9.

Out of scope for now: SDF back-annotation (clause 32), protected envelopes
(clause 34), and the VPI, assertion and coverage C APIs (clauses 36–40).
They come after everything else passes.

## 2. Where it fits

```text
  .sv / .svh files
        │
        ▼
 ┌──────────────────────────── epitome-sv ───────────────────────────┐
 │ source map ─► preprocess ─► lex ─► parse ─► AST                   │
 │                                              │                    │
 │                         elaborate (parameters, generate, hierarchy)│
 │                                              ▼                    │
 │                         typed, flattened design (per instance)    │
 │                                              │                    │
 │                  lower: processes ─► Epitome IR + runtime calls   │
 └──────────────────────────────────────────────┬────────────────────┘
                                                 ▼
                                  epitome_ir::Module
                                                 ▼
                        epitome-opt ─► epitome-codegen ─► .o
                                                 ▼
                         linked with the runtime (scheduler, $display,
                         strings, classes, queues) into a simulator
```

`epitome-sv` depends on `epitome-ir` only. The binary links the
optimiser and code generator.

## 3. Source text and positions

### 3.1 Tokens are slices

A token is a `&str` that points into the source text, as in the IR and
MLIR lexers:

```rust
pub struct Token<'a>(pub &'a str);
```

Its kind is worked out from its first characters when it is needed, and
its position from where the slice sits in memory: the byte offset is the
token's pointer minus the source's pointer, and the line and column come
from that offset. Tokens are two words, copy freely, and need no position
fields. The end-of-file token is the empty slice at the end of the text.

Error reports carry a token (or any subslice of the source), never a
line number worked out early.

### 3.2 The source map

The preprocessor produces text that is not in any one file: included
files, and macro bodies with their arguments substituted. Every piece of
text a token can point into is therefore held in one `SourceMap`:

- each file read, and each piece of text the preprocessor makes, is a
  `Source { name, text, origin }`, kept for the life of the compilation
  (text is never moved once added, so slices stay valid);
- `SourceMap::locate(&str)` finds which source holds a slice by its
  address, by binary search on the sources' address ranges, then gives
  `name:line:col`;
- `origin` says where text from a macro came from (the `` `define `` and
  the use), so an error inside an expansion can say "in expansion of
  `` `FOO `` at a.sv:12:5".

Most tokens come straight from a file, so the common case costs nothing.

## 4. Preprocessing (clause 22)

Compiler directives start with a backtick. The preprocessor works on
tokens, not characters, and passes through every token that is not a
directive, unchanged and still pointing into its file.

- `` `define ``, `` `undef ``, `` `undefineall ``, macros with arguments
  and default arguments, `` `" ``, `` `\`" `` and ` `` ` (token pasting).
  A pasted or stringified token is new text, added to the source map.
- `` `ifdef ``, `` `ifndef ``, `` `elsif ``, `` `else ``, `` `endif ``,
  including the 2023 expressions in `` `ifdef (A && !B) ``.
- `` `include `` with `"file"` and `<file>`, searched in the including
  file's directory and then the `-I` list.
- `` `timescale ``, `` `default_nettype ``, `` `celldefine ``,
  `` `unconnected_drive ``, `` `pragma ``, `` `line ``, `` `__FILE__ ``,
  `` `__LINE__ ``, `` `resetall ``: recorded as attributes on the tokens
  that follow, for elaboration to read.
- `` `begin_keywords `` / `` `end_keywords ``: a stack of keyword sets
  (1364-1995 through 1800-2023). The lexer asks the current set whether a
  word is a keyword (section 5).

The output is a stream of tokens, each still a `&str` into some source.

## 5. Lexing (clause 5)

The lexer turns text into tokens on demand, from a byte offset, as the
MLIR lexer does. The parts that need care:

- **Comments** `//` and `/* */` are dropped; `/*` does not nest.
- **Identifiers** are `[a-zA-Z_][a-zA-Z0-9_$]*`. **Escaped identifiers**
  run from `\` to the next white space, which ends them and is not part
  of the name. `\bus+index ` and `bus+index` are different names; `\cpu3 `
  and `cpu3` are the same (5.6.1).
- **System names** `$display`, and **directives** `` `name ``.
- **Keywords** are identifiers that the current keyword set reserves
  (Annex B). The lexer does not classify them; `Token::is_keyword` asks.
- **Numbers**: decimal, `'b`/`'o`/`'d`/`'h` with an optional size and `s`,
  `x`/`z`/`?` digits, underscores (not first), the unbased unsized
  literals `'0 '1 'x 'z`, reals with exponents, and time literals `10ns`,
  `1.5us`, `1step`. Spaces may separate the size from the `'` and the
  base from the digits (`8 'h FF`), but not the `'` from the base
  (`8' hFF` is an error). The lexer makes the size, the `'b` part and the
  digits separate tokens; the parser joins them into one literal.
- **Strings**: `"..."` with the escapes of 5.9.1 and a backslash-newline
  continuation, and the triple-quoted `"""..."""` of 1800-2023.
- **Operators** by longest match: `<<<=`, `>>>=`, `<->`, `|->`, `|=>`,
  `#-#`, `#=#`, `##`, `->>`, `:=`, `:/`, `::`, `.*`, `'{`, `@@`, `(*`
  and `*)` are not tokens: `@(*)` is a sensitivity list, so attributes
  are recognised by the parser as `(` immediately followed by `*`.
- **Context**: inside a `table` of a UDP, `0`, `1`, `x`, `?`, `b`, `r`,
  `f`, `p`, `n`, `*` and `-` are single-character entries. The parser
  asks the lexer for "table" tokens there, which is why tokens are made
  on demand rather than all at once.

## 6. Parsing (Annex A)

A hand-written recursive-descent parser over the token stream, following
the grammar of Annex A, with precedence climbing for expressions
(table 11-2). It builds an AST in an arena: nodes are indices, every node
holds the `&str` span of its first and last token, so any node can be
reported by position.

SystemVerilog's grammar is ambiguous without knowing which names are
types. `a * b;` is a declaration if `a` is a type and an expression
otherwise; `#(` follows a type or a module name. The parser keeps a
scope of names declared as types (`typedef`, classes, parameters with
`type`, package imports) and asks it at these points. A name used before
it is declared (allowed in some places, 6.18) is parsed as an expression
first and re-read as a type when elaboration knows better.

The AST covers, in order of the build:

1. compilation units, modules, ports, parameters, nets and variables,
   continuous assignments, `always*`/`initial`/`final`, statements and
   expressions: enough for most of clauses 3–13 and 23;
2. packages, interfaces and modports, generate blocks, functions and
   tasks: clauses 13, 25–27;
3. classes, constraints, covergroups: clauses 8, 18, 19;
4. assertions, sequences, properties, checkers, clocking blocks: clauses
   14, 16, 17;
5. programs, configurations, UDPs, gates, specify blocks and timing
   checks: clauses 24, 28–31, 33.

Errors are recovered at `;`, `end*` keywords and `endmodule`, so one
mistake gives one message.

## 7. Elaboration (clause 23)

Elaboration turns the AST into a design: it binds names, evaluates
parameters and constant expressions, unrolls generate blocks, resolves
the hierarchy from `top` downwards, and works out the type and width of
every expression (clause 11's rules for self- and context-determined
widths). Each distinct parameterisation of a module is elaborated once
and shared between its instances.

Values have four states. A `logic [N-1:0]` is two `iN` words (value and
unknown bits); a `bit` vector is one. Constant evaluation follows the
same rules as simulation, so they share one implementation.

## 8. Simulation

Clause 4's scheduler has regions (active, inactive, NBA, observed,
reactive, postponed). The plan:

- **Processes become functions.** Each `always`, `initial`, continuous
  assignment and forked thread is lowered to Epitome IR. A process that
  waits (`@`, `#`, `wait`) is a state machine: its locals live in a frame
  and each wait point is a resume label, so threads cost no stack.
- **A runtime in Rust** holds the event queues, the time wheel, NBA
  updates, strings, dynamic arrays, queues, associative arrays, class
  objects and `$display`-style formatting. Generated code calls it
  through `extern "C"` functions.
- **Cycle-based fast path.** Logic that is synchronous to one clock and
  has no delays is scheduled statically: one `eval` per edge, which
  Epitome compiles as a big block. This is the same code as the `seq`
  lowering in [MLIR](mlir.md) section 7.

## 9. Clean-room rules

`epitome-sv` is a clean-room build from IEEE 1800-2023 alone. The
standard's prose, grammar (Annex A) and keyword list (Annex B) say what
the compiler must do. We do not read the source code of other
SystemVerilog tools (Verilator, Icarus, slang, Surelog, sv-parser, Yosys,
or any commercial simulator). Running them as programs, as `test1800`
does, to see what they accept and print is fair; reading how they do it
is not.

The standard is copyright IEEE, so **nothing is copied from it**: no
prose, no BNF productions, no tables, no examples, in code, comments,
tests or documents. We cite the clause number (`// 5.7.1`) and describe
the rule in our own words, as `test1800` does. The parser is structured
after Annex A, but its comments say what a function accepts in our words
rather than quoting the production. The PDF itself is never committed.

## 10. Build order and testing

`epitome-sv` gets a `test1800` profile of the `generic` kind: it is run as
`epitome-sv [flags] test.sv`, and its exit status and output are judged
the same way as Verilator's and Icarus's. Each step below ends when its
pass rate on the clauses it targets stops climbing.

1. **Lexer** (Done in skeleton): every `.sv` file in `test1800` tokenises
   without error, except tests that `:should_fail_because:` of a lexical
   rule. A cargo test walks the suite when `IEEE1800_TESTS` points at a
   checkout of it.
2. **Parser**: `epitome-sv --parse-only`. Target: every `:type: parse`
   test (341 of them) gives the right answer, then every legal test in
   the suite parses. The cargo test reports the count that parse and lists
   the first failures with `file:line:col`.
3. **Preprocessor**: clause 22 and every test that uses `` `define ``.
4. **Elaboration**: `:type: elaboration` tests, clauses 6, 7, 11, 23, 26,
   27.
5. **Simulation of the synthesisable subset**: the runtime with
   `$display`, `$finish`, `initial`, `always_ff`, `always_comb`, NBAs and
   `#` delays. Every test prints `PASS` this way, so this unlocks the
   bulk of clauses 3–13.
6. **Testbench language**: classes, queues, `fork`/`join`, mailboxes,
   semaphores, constrained random, then assertions and coverage.

The aim at each stage is to pass more of `test1800` than Verilator and
Icarus (66.8% and 68.6% today).

## 11. Open questions

- **Open:** whether the preprocessor runs once over a whole file before
  parsing, or lazily as the parser pulls tokens. Lazy is needed if
  `` `begin_keywords `` changes the keywords of tokens already lexed;
  eager is simpler. Start eager, with the keyword question asked when the
  parser looks at a token, not when it is lexed.
- **Open:** how much of four-state arithmetic to do inline in IR and how
  much to call the runtime for, for wide vectors.
- **Open:** whether to lower to the MLIR `hw`/`comb`/`seq` form and reuse
  that path, or straight to Epitome IR. Straight to IR is planned; the
  MLIR path would let CIRCT's tools check our netlists.
