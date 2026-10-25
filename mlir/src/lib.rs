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
pub mod linalg_fold;
pub mod linalg_fuse;
pub mod linalg_generalize;
pub mod linalg_kernels;
pub mod linalg_outline;
pub mod linalg_split;
pub mod linalg_to_loops;
pub mod linalg_vectorize;
pub mod math_approx;
pub mod parser;
pub mod printer;
pub mod stablehlo_to_linalg;
pub mod to_llvm;
pub mod torch_to_linalg;
pub mod translate;
pub mod weights;

pub use ir::Module;
pub use parser::{ParseError, parse_module};
pub use printer::print_module;

/// The passes `epitome-mlir-opt --pass` runs, by name, in the order they
/// lower: from `torch` down to the `llvm` dialect.
pub const PASSES: &[&str] = &[
    "torch-to-linalg",
    "stablehlo-to-linalg",
    "linalg-generalize-named-ops",
    "linalg-fold-constants",
    "linalg-fuse-elementwise",
    "bufferize",
    "linalg-to-kernels=<target>",
    "linalg-split=<chunks>[:<rows>]",
    "outline-linalg",
    "linalg-vectorize=<width>",
    "linalg-to-loops",
    "math-polynomial-approximation",
    "to-llvm",
];

/// `torch-to-llvm` runs these in turn: from PyTorch, as torch-mlir
/// imports it, to the `llvm` dialect.
pub const TORCH_TO_LLVM: &[&str] = &["torch-to-linalg", "bufferize", "linalg-to-loops", "to-llvm"];

/// `linalg-to-llvm` runs these in turn: from `linalg` on tensors, as
/// upstream's tools write it, to the `llvm` dialect.
pub const LINALG_TO_LLVM: &[&str] = &[
    "linalg-generalize-named-ops",
    "linalg-fold-constants",
    "linalg-fuse-elementwise",
    "bufferize",
    "linalg-to-loops",
    "to-llvm",
];

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
        "linalg-fold-constants" => linalg_fold::run(m),
        "linalg-fuse-elementwise" => linalg_fuse::run(m),
        "outline-linalg" => linalg_outline::run(m),
        _ if name.starts_with("linalg-split=") => {
            // chunks[:rows], at most so many chunks, products' rows at least
            // so many to a chunk.
            let arg = &name["linalg-split=".len()..];
            let (chunks, rows) = arg.split_once(':').unwrap_or((arg, "1"));
            let (Ok(chunks), Ok(rows)) = (chunks.parse(), rows.parse()) else {
                return Err(format!("{name}: chunks[:rows] is expected"));
            };
            linalg_split::run(m, chunks, rows)
        }
        _ if name.starts_with("linalg-to-kernels=") => linalg_kernels::run(m, &name["linalg-to-kernels=".len()..]),
        _ if name.starts_with("linalg-vectorize=") => {
            let width =
                name["linalg-vectorize=".len()..].parse().map_err(|_| format!("{name}: a width is expected"))?;
            linalg_vectorize::run(m, width)
        }
        "math-polynomial-approximation" => math_approx::run(m),
        "torch-to-linalg" => torch_to_linalg::run(m),
        "stablehlo-to-linalg" => stablehlo_to_linalg::run(m),
        "bufferize" => bufferize::run(m),
        "linalg-to-loops" => linalg_to_loops::run(m),
        "to-llvm" => to_llvm::run(m),
        _ => Err(format!("unknown pass '{name}'; the passes are {}", PASSES.join(", "))),
    }
}
