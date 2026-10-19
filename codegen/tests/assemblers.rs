//! draconian-as and clang's assembler agree on every instruction the
//! AArch64 description has: sample lines of each (`draconian-llc
//! --sample-asm`, several per instruction, over a spread of operands) are
//! assembled by both, and the code must be the same word for word. Most of
//! the description's entries (80-asm.ll) were fitted to clang's encodings,
//! so this keeps them, and the rest, honest.
//!
//! Skipped when clang is not installed.

use std::process::Command;

use draconian_codegen::abi::Syntax;
use draconian_codegen::assembler::Assembler;
use draconian_codegen::objdump::Image;
use draconian_codegen::target::Target;

/// What clang must be told the machine has, for every extension the
/// description's instructions need.
const MARCH: &str = "-march=armv9.4-a+crc+crypto+sha3+sm4+rcpc+rcpc3+lse+lse128+rdm+dotprod+fp16+fp16fml+bf16+i8mm\
+f64mm+fp8+fp8fma+fp8dot2+fp8dot4+faminmax+lut+cssc+mops+the+d128+gcs+rasv2+ite+flagm+predres+sb+ssbs+tme+ls64+wfxt\
+hbc+brbe+pauth-lr+fprcvt+lsfe+lsui+occmo+cmpbr+pauth+bti+memtag";

fn code(bytes: &[u8], t: &Target) -> Vec<u32> {
    let img = Image::read(bytes, &t.machine).unwrap();
    img.sections
        .iter()
        .filter(|s| s.code)
        .flat_map(|s| s.data.chunks(4).map(|c| u32::from_le_bytes(c.try_into().unwrap())).collect::<Vec<_>>())
        .collect()
}

#[test]
fn draconian_as_and_clang_agree() {
    let ok = Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("clang not found; skipping");
        return;
    }
    let t = Target::aarch64();
    let text = draconian_codegen::check::sample_assembly(&t, Syntax::Elf, 3);
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
    let (a, b) = (code(&ours, &t), code(&std::fs::read(&o).unwrap(), &t));
    let lines: Vec<&str> = text.lines().filter(|l| l.contains(":\t")).collect();
    assert_eq!(a.len(), b.len());
    assert_eq!(a.len(), lines.len());
    let wrong: Vec<String> = a
        .iter()
        .zip(&b)
        .zip(&lines)
        .filter(|((x, y), _)| x != y)
        .take(20)
        .map(|((x, y), l)| format!("{l}: ours {x:08x}, clang {y:08x}"))
        .collect();
    assert!(wrong.is_empty(), "{} lines, these differ:\n{}", lines.len(), wrong.join("\n"));
    println!("{} lines assemble alike", lines.len());
}
