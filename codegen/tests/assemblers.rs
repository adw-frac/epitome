//! epitome-as and clang's assembler agree on every instruction the
//! AArch64 description has: sample lines of each (`epitome-llc
//! --sample-asm`, several per instruction, over a spread of operands) are
//! assembled by both, and the code must be the same word for word. Most of
//! the description's entries (80-asm.ll) were fitted to clang's encodings,
//! so this keeps them, and the rest, honest.
//!
//! RISC-V's are checked the same way against LLVM's RISC-V assembler, as
//! rustc has it (its `riscv64gc-unknown-none-elf` target).
//!
//! Each is skipped when its assembler is not installed.

use std::process::Command;

use epitome_codegen::abi::Syntax;
use epitome_codegen::assembler::Assembler;
use epitome_codegen::objdump::Image;
use epitome_codegen::target::Target;

/// What clang must be told the machine has, for every extension the
/// description's instructions need.
const MARCH: &str = "-march=armv9.4-a+crc+crypto+sha3+sm4+rcpc+rcpc3+lse+lse128+rdm+dotprod+fp16+fp16fml+bf16+i8mm\
+f64mm+fp8+fp8fma+fp8dot2+fp8dot4+faminmax+lut+cssc+mops+the+d128+gcs+rasv2+ite+flagm+predres+sb+ssbs+tme+ls64+wfxt\
+hbc+brbe+pauth-lr+fprcvt+lsfe+lsui+occmo+cmpbr+pauth+bti+memtag+rng";

/// The sample lines that differ between our object and theirs.
fn differences(t: &Target, text: &str, ours: &[u8], theirs: &[u8]) -> Vec<String> {
    let (a, b) = (code(ours, t), code(theirs, t));
    let lines: Vec<&str> = text.lines().filter(|l| l.contains(":\t")).collect();
    assert_eq!(a.len(), b.len());
    assert_eq!(a.len(), lines.len());
    a.iter()
        .zip(&b)
        .zip(&lines)
        .filter(|((x, y), _)| x != y)
        .take(20)
        .map(|((x, y), l)| format!("{l}: ours {x:08x}, theirs {y:08x}"))
        .collect()
}

fn code(bytes: &[u8], t: &Target) -> Vec<u32> {
    let img = Image::read(bytes, &t.machine).unwrap();
    img.sections
        .iter()
        .filter(|s| s.code)
        .flat_map(|s| s.data.chunks(4).map(|c| u32::from_le_bytes(c.try_into().unwrap())).collect::<Vec<_>>())
        .collect()
}

#[test]
fn epitome_as_and_clang_agree() {
    let ok = Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("clang not found; skipping");
        return;
    }
    let t = Target::aarch64();
    let text = epitome_codegen::check::sample_assembly(&t, Syntax::Elf, 3);
    let tmp = std::path::PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("assemblers");
    std::fs::create_dir_all(&tmp).unwrap();
    let s = tmp.join("aarch64.s");
    std::fs::write(&s, &text).unwrap();
    let ours = Assembler::new(&t).assemble(&text, Some(Syntax::Elf)).and_then(|a| a.file(&t)).unwrap();
    let o = tmp.join("aarch64.clang.o");
    let out = Command::new("clang")
        .args(["--target=aarch64-linux-gnu", MARCH, "-ferror-limit=0", "-c"])
        .arg(&s)
        .arg("-o")
        .arg(&o)
        .output()
        .unwrap();
    assert!(out.status.success(), "clang:\n{}", String::from_utf8_lossy(&out.stderr));
    let wrong = differences(&t, &text, &ours, &std::fs::read(&o).unwrap());
    assert!(wrong.is_empty(), "these differ:\n{}", wrong.join("\n"));
}

#[test]
fn epitome_as_and_llvm_agree_on_riscv() {
    let root = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let t = Target::load_path(root.join("targets/riscv64").to_str().unwrap()).unwrap();
    let text = epitome_codegen::check::sample_assembly(&t, Syntax::Elf, 3);
    let tmp = std::path::PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("assemblers");
    std::fs::create_dir_all(&tmp).unwrap();
    // rustc assembles it as a crate's global assembly, without compressing
    // instructions or relaxing branches.
    std::fs::write(tmp.join("riscv64.s"), format!(".option norvc\n.option norelax\n{text}")).unwrap();
    std::fs::write(
        tmp.join("riscv64.rs"),
        "#![no_std]\ncore::arch::global_asm!(include_str!(\"riscv64.s\"), options(raw));\n",
    )
    .unwrap();
    let o = tmp.join("riscv64.o");
    let out = Command::new("rustc")
        .args(["--target", "riscv64gc-unknown-none-elf", "--crate-type", "lib", "--emit", "obj", "-C"])
        .arg(format!("target-feature={RISCV_FEATURES}"))
        .arg("-o")
        .arg(&o)
        .arg(tmp.join("riscv64.rs"))
        .output()
        .unwrap();
    let err = String::from_utf8_lossy(&out.stderr);
    if err.contains("can't find crate for `core`") {
        eprintln!("rustc has no riscv64gc-unknown-none-elf target; skipping");
        return;
    }
    assert!(out.status.success(), "rustc:\n{err}");
    let ours = Assembler::new(&t).assemble(&text, Some(Syntax::Elf)).and_then(|a| a.file(&t)).unwrap();
    let wrong = differences(&t, &text, &ours, &std::fs::read(&o).unwrap());
    assert!(wrong.is_empty(), "these differ:\n{}", wrong.join("\n"));
}

/// The extensions the RISC-V description's instructions need.
const RISCV_FEATURES: &str = "+m,+a,+f,+d,+zicsr,+zifencei,+zba,+zbb,+zbs,+zbc,+zbkb,+zbkc,+zbkx,+zicond,+zfa,+zfh,\
+zawrs,+zacas,+zabha,+zicbom,+zicboz,+zicbop,+zihintntl,+zimop,+zknd,+zkne,+zknh,+zksed,+zksh,+svinval,+zicntr,\
+experimental-zalasr,+experimental-zicfilp,+experimental-zicfiss";
