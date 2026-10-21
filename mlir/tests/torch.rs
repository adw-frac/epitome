//! PyTorch models compiled by Epitome alone and run. Each is lowered
//! twice:
//!
//! - from the `torch` dialect, as torch-mlir imports it
//!   (`docs/mlir/examples/pytorch`): `torch` to `linalg`, buffers, loops
//!   and the `llvm` dialect;
//! - from `linalg` on tensors as torch-mlir itself lowers it, with named
//!   operations such as `linalg.matmul` (`tests/corpus`, in the generic
//!   form): generalized, then buffers, loops and the `llvm` dialect;
//!
//! then to LLVM IR, through `epitome-opt` and the code generator. A C driver made from each function's signature fills the
//! inputs, calls it and prints the results, which must match what PyTorch
//! computes for the same weights and inputs (`tests/torch/*.expected`,
//! made by `tests/torch/reference.py`). On an AArch64 Mac with clang only.
//!
//! Each stage's output also has to read back, in the generic form.

use std::fmt::Write;
use std::path::{Path, PathBuf};
use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};
use epitome_mlir::ir::{Attr, Type};

/// A model, the file it is read from, and the passes that lower it.
struct Case {
    name: &'static str,
    file: PathBuf,
    passes: &'static [&'static str],
}

fn cases() -> Vec<Case> {
    let corpus = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/corpus");
    let mut cases = Vec::new();
    for name in ["matmul_bias", "mlp", "conv2d", "extra_int8matmul"] {
        let file = examples().join(format!("{name}.torch.mlir"));
        cases.push(Case { name, file, passes: epitome_mlir::TORCH_TO_LLVM });
    }
    for name in ["matmul_bias", "mlp", "conv2d", "extra_int8matmul", "extra_qmatmul"] {
        let file = corpus.join(format!("pytorch__{name}.linalg.mlir"));
        cases.push(Case { name, file, passes: epitome_mlir::LINALG_TO_LLVM });
    }
    cases
}

fn examples() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../docs/mlir/examples/pytorch")
}

/// The C type of a tensor element.
fn c_type(m: &epitome_mlir::Module, ty: epitome_mlir::ir::TypeId) -> &'static str {
    match m.ty(ty) {
        Type::Float("f32") => "float",
        Type::Float("f64") => "double",
        Type::Int { width: 8, .. } => "int8_t",
        Type::Int { width: 16, .. } => "int16_t",
        Type::Int { width: 32, .. } => "int32_t",
        Type::Int { width: 64, .. } => "int64_t",
        other => panic!("no C type for {other:?}"),
    }
}

/// A C program that calls the function in `linalg` (its signature on
/// tensors) with the inputs `reference.py` uses, and prints each result's
/// elements, one a line.
fn driver(linalg: &epitome_mlir::Module) -> String {
    let f = linalg.ops.iter().position(|o| linalg.name(o.name) == "func.func").expect("a function");
    let f = epitome_mlir::ir::OpId(f as u32);
    let name = linalg.op_attr(f, "sym_name").and_then(|a| linalg.string_of(a)).unwrap();
    let Some(Attr::Type(fty)) = linalg.op_attr(f, "function_type").map(|a| linalg.attr(a)) else { panic!() };
    let Type::Function { inputs, results } = linalg.ty(*fty).clone() else { panic!() };
    let mut c = String::from("#include <stdint.h>\n#include <stdio.h>\n");
    let mut params = Vec::new();
    let mut body = String::new();
    let mut args = Vec::new();
    for (k, &t) in inputs.iter().enumerate() {
        let (shape, elem) = linalg.shaped(t).unwrap();
        let (ct, n) = (c_type(linalg, elem), shape.iter().product::<u64>());
        params.push(format!("const {ct} *"));
        let value = if ct == "float" || ct == "double" {
            format!("(((7 * i + {}) % 11) - 5) / 4.0", 3 * k)
        } else {
            format!("((7 * i + {}) % 11) - 5", 3 * k)
        };
        writeln!(body, "  static {ct} a{k}[{n}];\n  for (int i = 0; i < {n}; i++) a{k}[i] = ({ct})({value});").unwrap();
        args.push(format!("a{k}"));
    }
    let mut prints = String::new();
    for (k, &t) in results.iter().enumerate() {
        let (shape, elem) = linalg.shaped(t).unwrap();
        let (ct, n) = (c_type(linalg, elem), shape.iter().product::<u64>());
        params.push(format!("{ct} *"));
        writeln!(body, "  static {ct} r{k}[{n}];").unwrap();
        args.push(format!("r{k}"));
        let print = if ct == "float" || ct == "double" {
            format!("printf(\"%.9g\\n\", (double)r{k}[i]);")
        } else {
            format!("printf(\"%lld\\n\", (long long)r{k}[i]);")
        };
        writeln!(prints, "  for (int i = 0; i < {n}; i++) {print}").unwrap();
    }
    writeln!(
        c,
        "void {name}({});\nint main(void) {{\n{body}  {name}({});\n{prints}  return 0;\n}}",
        params.join(", "),
        args.join(", ")
    )
    .unwrap();
    c
}

/// Lowers a case stage by stage, checking each stage reads back. Returns
/// the module on tensors, whose signature the driver is made from, and the
/// LLVM IR.
fn lower(case: &Case) -> (epitome_mlir::Module, epitome_ir::Module) {
    let what = format!("{} ({})", case.name, case.file.display());
    let src = std::fs::read_to_string(&case.file).unwrap();
    let mut m = epitome_mlir::parse_module(&src).unwrap_or_else(|e| panic!("{what}:{e}"));
    let mut tensors = (case.passes[0] != "torch-to-linalg").then(|| m.clone());
    for pass in case.passes {
        m = epitome_mlir::run_pass(pass, &m).unwrap_or_else(|e| panic!("{what}: {pass}: {e}"));
        let text = m.to_string();
        let again = epitome_mlir::parse_module(&text).unwrap_or_else(|e| panic!("{what}: {pass}: {e}"));
        assert_eq!(again.to_string(), text, "{what}: {pass}: the output does not print the same");
        if tensors.is_none() {
            tensors = Some(m.clone());
        }
    }
    let ir = epitome_mlir::translate::translate(&m).unwrap_or_else(|e| panic!("{what}: {e}"));
    let text = ir.to_string();
    epitome_ir::parse_module(&text).unwrap_or_else(|e| panic!("{what}: the LLVM IR does not read back: {e}"));
    (tensors.unwrap(), ir)
}

#[test]
fn models_lower_to_llvm_ir() {
    for case in cases() {
        lower(&case);
    }
}

#[test]
fn models_match_pytorch() {
    let ok = cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("needs clang on an AArch64 Mac; skipping");
        return;
    }
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("torch");
    std::fs::create_dir_all(&tmp).unwrap();
    let t = Target::aarch64();
    let mut failures = Vec::new();
    for (k, case) in cases().iter().enumerate() {
        let name = case.name;
        let (linalg, mut ir) = lower(case);
        ir.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
        epitome_opt::pipeline::run(&mut ir, &epitome_opt::pipeline::Options::default());
        let compiled = compile(&t, &mut ir, &Options::default()).unwrap_or_else(|e| panic!("{name}: {e}"));
        let obj = tmp.join(format!("{name}{k}.o"));
        std::fs::write(&obj, compiled.object_file(&t).unwrap()).unwrap();
        let c = tmp.join(format!("{name}{k}_main.c"));
        std::fs::write(&c, driver(&linalg)).unwrap();
        let exe = tmp.join(format!("{name}{k}"));
        let built = Command::new("clang").arg(&c).arg(&obj).arg("-o").arg(&exe).output().unwrap();
        assert!(built.status.success(), "{name}: {}", String::from_utf8_lossy(&built.stderr));
        let run = Command::new(&exe).output().unwrap();
        assert!(run.status.success(), "{name}: the program failed");
        let got = String::from_utf8(run.stdout).unwrap();
        let want_path = Path::new(env!("CARGO_MANIFEST_DIR")).join(format!("tests/torch/{name}.expected"));
        let want = std::fs::read_to_string(want_path).unwrap();
        let (got, want): (Vec<&str>, Vec<&str>) = (got.lines().collect(), want.lines().collect());
        if got.len() != want.len() {
            failures.push(format!("{}: {} values, expected {}", case.file.display(), got.len(), want.len()));
            continue;
        }
        for (i, (g, w)) in got.iter().zip(&want).enumerate() {
            let (gv, wv): (f64, f64) = (g.parse().unwrap(), w.parse().unwrap());
            if (gv - wv).abs() > 1e-5 * wv.abs().max(1.0) {
                failures.push(format!("{}: value {i} is {g}, PyTorch gives {w}", case.file.display()));
                break;
            }
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
