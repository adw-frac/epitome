//! Level 0: the `llvm` dialect translated to LLVM IR. Every `llvm`-dialect
//! file of the corpus translates and its IR reads back; the result has the
//! functions, globals and instructions of the tools' own `.ll` files; and,
//! on an AArch64 Mac with clang, translated programs run and give the
//! tools' answers.

use std::collections::{BTreeMap, BTreeSet};
use std::path::{Path, PathBuf};
use std::process::Command;

use epitome_ir::module::{Function, GlobalKind, Module, Op};
use epitome_mlir::translate::translate;

fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).to_path_buf()
}

fn translate_file(path: &Path) -> Module {
    let src = std::fs::read_to_string(path).unwrap();
    let m = epitome_mlir::parse_module(&src).unwrap_or_else(|e| panic!("{}: {e}", path.display()));
    translate(&m).unwrap_or_else(|e| panic!("{}: {e}", path.display()))
}

/// Translates `src`, prints the IR and reads it back.
fn translate_text(src: &str) -> String {
    let m = epitome_mlir::parse_module(src).unwrap();
    let text = translate(&m).unwrap().to_string();
    epitome_ir::parse_module(&text).unwrap_or_else(|e| panic!("{e}\n{text}"));
    text
}

#[test]
fn the_corpus_translates_and_reads_back() {
    let mut files: Vec<PathBuf> = std::fs::read_dir(root().join("tests/corpus"))
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| p.file_name().unwrap().to_str().unwrap().contains("llvm") && p.extension().unwrap() == "mlir")
        .collect();
    files.sort();
    assert!(files.len() >= 12, "only {} llvm-dialect files", files.len());
    let mut failures = Vec::new();
    for path in &files {
        let src = std::fs::read_to_string(path).unwrap();
        let name = path.file_name().unwrap().to_string_lossy();
        let m = match epitome_mlir::parse_module(&src) {
            Ok(m) => m,
            Err(e) => {
                failures.push(format!("{name}: does not parse: {e}"));
                continue;
            }
        };
        let text = match translate(&m) {
            Ok(ir) => ir.to_string(),
            Err(e) => {
                failures.push(format!("{name}: {e}"));
                continue;
            }
        };
        if let Err(e) = epitome_ir::parse_module(&text) {
            failures.push(format!("{name}: the IR does not read back: {e}"));
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}

/// An instruction's opcode, as LLVM IR writes it.
fn opcode(op: &Op) -> &'static str {
    match op {
        Op::Binary { op, .. } => op.keyword(),
        Op::Cast { op, .. } => op.keyword(),
        Op::Ret(_) => "ret",
        Op::Br(_) | Op::CondBr { .. } => "br",
        Op::Switch { .. } => "switch",
        Op::Unreachable => "unreachable",
        Op::FNeg { .. } => "fneg",
        Op::ExtractValue { .. } => "extractvalue",
        Op::InsertValue { .. } => "insertvalue",
        Op::ExtractElement { .. } => "extractelement",
        Op::InsertElement { .. } => "insertelement",
        Op::ShuffleVector { .. } => "shufflevector",
        Op::Alloca { .. } => "alloca",
        Op::Load { .. } => "load",
        Op::Store { .. } => "store",
        Op::Gep { .. } => "getelementptr",
        Op::ICmp { .. } => "icmp",
        Op::FCmp { .. } => "fcmp",
        Op::Phi { .. } => "phi",
        Op::Select { .. } => "select",
        Op::Freeze(_) => "freeze",
        Op::Call(_) => "call",
        _ => "other",
    }
}

/// What two translations of one program must share: the functions (with
/// whether each has a body), the global variables, and each function's
/// opcodes, counted.
#[derive(Debug, Default)]
struct Summary {
    functions: BTreeMap<String, (bool, BTreeMap<&'static str, usize>)>,
    globals: BTreeSet<String>,
}

fn summary(m: &Module) -> Summary {
    let mut s = Summary::default();
    for &g in &m.global_order {
        let gl = m.global(g);
        let name = gl.name.clone().unwrap_or_default();
        match &gl.kind {
            GlobalKind::Function(f) => {
                s.functions.insert(name, (f.has_body, opcodes(f)));
            }
            GlobalKind::Variable(_) => {
                s.globals.insert(name);
            }
            _ => {}
        }
    }
    s
}

fn opcodes(f: &Function) -> BTreeMap<&'static str, usize> {
    let mut counts = BTreeMap::new();
    for &b in &f.layout {
        for &i in &f.blocks[b.index()].insts {
            *counts.entry(opcode(&f.insts[i.index()].op)).or_default() += 1;
        }
    }
    counts
}

/// The differences between our translation and the tools'.
fn differences(ours: &Summary, theirs: &Summary) -> Vec<String> {
    let mut out = Vec::new();
    for g in theirs.globals.difference(&ours.globals) {
        out.push(format!("global @{g} is missing"));
    }
    for (name, (body, ops)) in &theirs.functions {
        match ours.functions.get(name) {
            None => out.push(format!("function @{name} is missing")),
            Some((b, _)) if b != body => out.push(format!("@{name}: defined {b}, the tools' {body}")),
            Some((_, o)) if o != ops => out.push(format!("@{name}: opcodes {o:?}, the tools' {ops:?}")),
            _ => {}
        }
    }
    out
}

#[test]
fn the_translation_matches_the_tools() {
    let examples = root().join("../docs/mlir/examples");
    let pairs = [
        ("chisel__gcd__GCD.llvm.mlir", "chisel/gcd/GCD.ll"),
        ("chisel__counter__Counter.llvm.mlir", "chisel/counter/Counter.ll"),
        ("chisel__fir__Fir.llvm.mlir", "chisel/fir/Fir.ll"),
        ("pytorch__matmul_bias.llvm.mlir", "pytorch/matmul_bias.ll"),
        ("pytorch__mlp.llvm.mlir", "pytorch/mlp.ll"),
        ("pytorch__conv2d.llvm.mlir", "pytorch/conv2d.ll"),
    ];
    let mut report = Vec::new();
    for (mlir, ll) in pairs {
        let ours = translate_file(&root().join("tests/corpus").join(mlir));
        let ours = epitome_ir::parse_module(&ours.to_string()).unwrap();
        let text = std::fs::read_to_string(examples.join(ll)).unwrap();
        let theirs = epitome_ir::parse_module(&text).unwrap_or_else(|e| panic!("{ll}: {e}"));
        for d in differences(&summary(&ours), &summary(&theirs)) {
            report.push(format!("{mlir}: {d}"));
        }
    }
    assert!(report.is_empty(), "{}", report.join("\n"));
}

/// A `cond_br` to one block twice with different values: the second edge
/// gets a block of its own, so that each phi entry has its own predecessor.
#[test]
fn a_block_reached_twice_gets_a_split_edge() {
    let src = r#""builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<i32 (i1, i32, i32)>, linkage = #llvm.linkage<external>, sym_name = "pick"}> ({
  ^bb0(%arg0: i1, %arg1: i32, %arg2: i32):
    "llvm.cond_br"(%arg0, %arg1, %arg2)[^bb1, ^bb1] <{operandSegmentSizes = array<i32: 1, 1, 1>}> : (i1, i32, i32) -> ()
  ^bb1(%0: i32):
    "llvm.return"(%0) : (i32) -> ()
  }) : () -> ()
}) : () -> ()
"#;
    let text = translate_text(src);
    for want in ["br i1 %0, label %4, label %6", "%5 = phi i32 [ %1, %3 ], [ %2, %6 ]", "6:", "br label %4"] {
        assert!(text.contains(want), "no {want:?} in\n{text}");
    }
}

/// Intrinsics get their overload suffixes and immediate arguments;
/// predicates, flags and constants come through.
#[test]
fn intrinsics_and_flags() {
    let src = r#""builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<f32 (f32, f32, ptr, ptr, i64, i32)>, linkage = #llvm.linkage<internal>, sym_name = "f"}> ({
  ^bb0(%a: f32, %b: f32, %p: !llvm.ptr, %q: !llvm.ptr, %n: i64, %k: i32):
    %0 = "llvm.intr.fma"(%a, %b, %a) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32, f32) -> f32
    "llvm.intr.memcpy"(%p, %q, %n) <{isVolatile = false}> : (!llvm.ptr, !llvm.ptr, i64) -> ()
    %1 = "llvm.intr.smax"(%k, %k) : (i32, i32) -> i32
    %2 = "llvm.intr.abs"(%1) <{is_int_min_poison = true}> : (i32) -> i32
    %3 = "llvm.intr.ctpop"(%n) : (i64) -> i64
    %4 = "llvm.mlir.constant"() <{value = 3 : index}> : () -> i64
    %5 = "llvm.mul"(%3, %4) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %6 = "llvm.icmp"(%5, %4) <{predicate = 6 : i64}> : (i64, i64) -> i1
    %7 = "llvm.mlir.constant"() <{value = 2 : i64}> : () -> i64
    %8 = "llvm.add"(%4, %7) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %9 = "llvm.getelementptr"(%p, %8) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%0, %9) <{alignment = 4 : i64, ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %10 = "llvm.select"(%6, %a, %0) <{fastmathFlags = #llvm.fastmath<none>}> : (i1, f32, f32) -> f32
    "llvm.return"(%10) : (f32) -> ()
  }) : () -> ()
}) : () -> ()
"#;
    let text = translate_text(src);
    for want in [
        "define internal float @f(float %0, float %1, ptr %2, ptr %3, i64 %4, i32 %5)",
        "call float @llvm.fma.f32(float %0, float %1, float %0)",
        "call void @llvm.memcpy.p0.p0.i64(ptr %2, ptr %3, i64 %4, i1 false)",
        "call i32 @llvm.smax.i32(i32 %5, i32 %5)",
        "call i32 @llvm.abs.i32(i32 %8, i1 true)",
        "call i64 @llvm.ctpop.i64(i64 %4)",
        "mul nuw nsw i64 %10, 3",
        "icmp ult i64 %11, 3",
        "getelementptr inbounds nuw float, ptr %2, i64 5",
        "store float %7, ptr %13, align 4",
        "declare float @llvm.fma.f32(float, float, float)",
    ] {
        assert!(text.contains(want), "no {want:?} in\n{text}");
    }
}

/// A switch, a global with a `dense` initialiser and one with a region, and
/// a function's attributes.
#[test]
fn switches_and_globals() {
    let src = r#""builtin.module"() ({
  "llvm.mlir.global"() <{addr_space = 0 : i32, alignment = 16 : i64, constant, global_type = !llvm.array<2 x array<2 x i32>>, linkage = #llvm.linkage<private>, sym_name = "table", value = dense<[[1, 2], [3, 4]]> : tensor<2x2xi32>}> ({
  }) : () -> ()
  "llvm.mlir.global"() <{addr_space = 0 : i32, global_type = !llvm.struct<(ptr, i32)>, linkage = #llvm.linkage<internal>, sym_name = "pair"}> ({
    %0 = "llvm.mlir.addressof"() <{global_name = @table}> : () -> !llvm.ptr
    %1 = "llvm.mlir.constant"() <{value = 7 : i32}> : () -> i32
    %2 = "llvm.mlir.undef"() : () -> !llvm.struct<(ptr, i32)>
    %3 = "llvm.insertvalue"(%2, %0) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, i32)>, !llvm.ptr) -> !llvm.struct<(ptr, i32)>
    %4 = "llvm.insertvalue"(%3, %1) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, i32)>, i32) -> !llvm.struct<(ptr, i32)>
    "llvm.return"(%4) : (!llvm.struct<(ptr, i32)>) -> ()
  }) : () -> ()
  "llvm.func"() <{arg_attrs = [{llvm.noundef}], function_type = !llvm.func<i32 (i32)>, linkage = #llvm.linkage<external>, no_unwind, sym_name = "classify"}> ({
  ^bb0(%arg0: i32):
    %0 = "llvm.mlir.constant"() <{value = 10 : i32}> : () -> i32
    %1 = "llvm.mlir.constant"() <{value = 20 : i32}> : () -> i32
    "llvm.switch"(%arg0, %arg0, %0, %1)[^bb1, ^bb1, ^bb1] <{case_operand_segments = array<i32: 1, 1>, case_values = dense<[1, 2]> : vector<2xi32>, operandSegmentSizes = array<i32: 1, 1, 2>}> : (i32, i32, i32, i32) -> ()
  ^bb1(%2: i32):
    "llvm.return"(%2) : (i32) -> ()
  }) : () -> ()
}) {llvm.target_triple = "aarch64-unknown-linux-gnu"} : () -> ()
"#;
    let text = translate_text(src);
    for want in [
        "target triple = \"aarch64-unknown-linux-gnu\"",
        "@table = private constant [2 x [2 x i32]] [[2 x i32] [i32 1, i32 2], [2 x i32] [i32 3, i32 4]], align 16",
        "@pair = internal global { ptr, i32 } { ptr @table, i32 7 }",
        "define i32 @classify(i32 noundef %0) nounwind",
        "switch i32 %0, label %2 [",
        "%3 = phi i32 [ %0, %1 ], [ 10, %4 ], [ 20, %5 ]",
    ] {
        assert!(text.contains(want), "no {want:?} in\n{text}");
    }
}

fn can_run() -> bool {
    let ok = cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("needs clang on an AArch64 Mac; skipping");
    }
    ok
}

fn tmp(name: &str) -> PathBuf {
    let dir = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("translate").join(name);
    std::fs::create_dir_all(&dir).unwrap();
    dir
}

/// Links with clang and runs, returning what the program printed.
fn link_and_run(dir: &Path, inputs: &[&Path], exe: &str) -> String {
    let exe = dir.join(exe);
    let built = Command::new("clang").args(inputs).arg("-o").arg(&exe).output().unwrap();
    assert!(built.status.success(), "{}", String::from_utf8_lossy(&built.stderr));
    let out = Command::new(&exe).output().unwrap();
    assert!(out.status.success(), "{} failed", exe.display());
    String::from_utf8(out.stdout).unwrap()
}

/// Arcilator's GCD, translated, optimised and compiled by Epitome, driven
/// by its C driver.
#[test]
fn gcd_runs() {
    if !can_run() {
        return;
    }
    let mut m = translate_file(&root().join("tests/corpus/chisel__gcd__GCD.llvm.mlir"));
    m.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
    epitome_opt::pipeline::run(&mut m, &epitome_opt::pipeline::Options::default());
    let t = epitome_codegen::target::Target::aarch64();
    let compiled = epitome_codegen::compile(&t, &mut m, &epitome_codegen::Options::default()).unwrap();
    let dir = tmp("gcd");
    let object = dir.join("GCD.o");
    std::fs::write(&object, compiled.object_file(&t).unwrap()).unwrap();
    let driver = root().join("../docs/mlir/examples/chisel/gcd/gcd_driver.c");
    let out = link_and_run(&dir, &[&driver, &object], "gcd");
    assert!(out.contains("gcd(1071, 462) = 21 "), "{out}");
}

/// torch-mlir's `matmul_bias`, translated by Epitome and compiled by
/// clang, against clang's build of `mlir-translate`'s output, through the
/// C harness.
#[test]
fn matmul_bias_runs() {
    if !can_run() {
        return;
    }
    let m = translate_file(&root().join("tests/corpus/pytorch__matmul_bias.llvm.mlir"));
    let dir = tmp("matmul_bias");
    let ours = dir.join("ours.ll");
    std::fs::write(&ours, m.to_string()).unwrap();
    let examples = root().join("../docs/mlir/examples/pytorch");
    let harness = examples.join("harness_matmul_bias.c");
    let run = |ll: &Path, name: &str| {
        let object = dir.join(format!("{name}.o"));
        let built =
            Command::new("clang").arg("-c").arg("-x").arg("ir").arg(ll).arg("-o").arg(&object).output().unwrap();
        assert!(built.status.success(), "{name}: {}", String::from_utf8_lossy(&built.stderr));
        link_and_run(&dir, &[&harness, &object], name)
    };
    let got = run(&ours, "ours");
    let want = run(&examples.join("matmul_bias.ll"), "theirs");
    assert_eq!(got, want);
    assert!(got.contains("11 22 33 46 \n14 25 36 55 \n"), "{got}");
}

/// An op with no translation is an error that names the function and the op.
#[test]
fn errors_name_the_function_and_op() {
    let src = r#""builtin.module"() ({
  "llvm.func"() <{function_type = !llvm.func<void ()>, sym_name = "f"}> ({
    "llvm.fence"() <{ordering = 7 : i64}> : () -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()
"#;
    let m = epitome_mlir::parse_module(src).unwrap();
    assert_eq!(translate(&m).unwrap_err(), "@f: llvm.fence: not supported yet");
}
