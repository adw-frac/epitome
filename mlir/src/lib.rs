//! MLIR for Epitome: the in-memory form, and a parser and printer for the
//! generic text form.
//!
//! Written from MLIR's published documentation only; see `docs/mlir` and
//! `docs/design/mlir.md`.
//!
//! ```
//! let src = "%0 = \"arith.constant\"() <{value = 1 : i32}> : () -> i32\n";
//! let module = epitome_mlir::parse_module(src).unwrap();
//! assert_eq!(module.to_string(), src);
//! ```

pub mod affine;
pub mod bufferize;
pub mod build;
pub mod ir;
pub mod lexer;
pub mod linalg_generalize;
pub mod linalg_kernels;
pub mod linalg_to_loops;
pub mod parser;
pub mod printer;
pub mod to_llvm;
pub mod torch_to_linalg;
pub mod translate;

pub use ir::Module;
pub use parser::{ParseError, parse_module};
pub use printer::print_module;

/// The passes `epitome-mlir-opt --pass` runs, by name, in the order they
/// lower: from `torch` down to the `llvm` dialect.
pub const PASSES: &[&str] = &[
    "torch-to-linalg",
    "linalg-generalize-named-ops",
    "bufferize",
    "linalg-to-kernels=<target>",
    "linalg-to-loops",
    "to-llvm",
];

/// `torch-to-llvm` runs these in turn: from PyTorch, as torch-mlir
/// imports it, to the `llvm` dialect.
pub const TORCH_TO_LLVM: &[&str] = &["torch-to-linalg", "bufferize", "linalg-to-loops", "to-llvm"];

/// `linalg-to-llvm` runs these in turn: from `linalg` on tensors, as
/// upstream's tools write it, to the `llvm` dialect.
pub const LINALG_TO_LLVM: &[&str] = &["linalg-generalize-named-ops", "bufferize", "linalg-to-loops", "to-llvm"];

/// Runs pass `name` on `m`, giving a new module.
pub fn run_pass(name: &str, m: &Module) -> Result<Module, String> {
    match name {
        "torch-to-llvm" | "linalg-to-llvm" => {
            let passes = if name == "torch-to-llvm" { TORCH_TO_LLVM } else { LINALG_TO_LLVM };
            let mut m = run_pass(passes[0], m)?;
            for p in &passes[1..] {
                m = run_pass(p, &m)?;
            }
            Ok(m)
        }
        "linalg-generalize-named-ops" => linalg_generalize::run(m),
        _ if name.starts_with("linalg-to-kernels=") => linalg_kernels::run(m, &name["linalg-to-kernels=".len()..]),
        "torch-to-linalg" => torch_to_linalg::run(m),
        "bufferize" => bufferize::run(m),
        "linalg-to-loops" => linalg_to_loops::run(m),
        "to-llvm" => to_llvm::run(m),
        _ => Err(format!("unknown pass '{name}'; the passes are {}", PASSES.join(", "))),
    }
}
