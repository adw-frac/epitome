//! The x86-64 description's instructions (integer, SSE, AVX and AVX-512),
//! written and read back. For every
//! entry, lines at the edges of its operands: every register in each place,
//! immediates and displacements at their limits, each memory form,
//! RIP-relative symbols, branches near and far. The test:
//!
//! 1. checks the description (`--check-target`'s encodings: each sample
//!    encodes, decodes as itself, and disassembles);
//! 2. assembles the lines with epitome-as, and checks epitome-objdump reads
//!    the object back as them;
//! 3. where `llvm-mc` is installed (`llvm-mc` or `llvm-mc-18`), assembles
//!    them with it too, and checks the code and relocations are the same.

use std::process::Command;

use epitome_codegen::abi::Syntax;
use epitome_codegen::assembler::Assembler;
use epitome_codegen::mir::{Operand, Reg, fill_template};
use epitome_codegen::objdump::{self, Image};
use epitome_codegen::target::{Kind, Target};

const DISPS: &[i64] = &[0, 1, -1, 127, -128, 128, -129, i32::MAX as i64, i32::MIN as i64];
const COUNTS: &[i64] = &[1, 0, 2, 7, 31];

/// Immediates for an operation of this many bits.
fn imms(bits: u32) -> Vec<i64> {
    let mut v = vec![0, 1, -1, 127, -128];
    if bits > 8 {
        v.extend([128, -129, 32767, -32768]);
    }
    if bits > 16 {
        v.extend([i32::MAX as i64, i32::MIN as i64]);
    }
    v
}

/// An operand's sample value.
enum V {
    Reg(u8),
    Imm(i64),
    Text(String),
}

/// Lines for every entry, each operand cycling through its values.
fn samples(t: &Target) -> String {
    let mut out = String::from("\t.text\n");
    for (i, ins) in t.instrs.iter().enumerate() {
        if ins.enc.is_empty() || ins.asm.is_empty() {
            continue;
        }
        let mnemonic = ins.asm.split_whitespace().next().unwrap_or("");
        let bits = match mnemonic.chars().last() {
            Some('l') => 32,
            Some('w') => 16,
            Some('b') => 8,
            _ => 64,
        };
        let back = format!(".Lback{}", ins.name);
        let lists: Vec<Vec<V>> = ins
            .operands
            .iter()
            .map(|o| match o.kind {
                Kind::Reg(c) => (0..t.machine.def(c).names.len() as i64)
                    .filter(|&k| !(o.name == "m.index" && k == 4))
                    .map(|k| V::Reg(t.machine.phys(c, k)))
                    .collect(),
                Kind::Imm => {
                    let vals = match o.name.as_str() {
                        "m.disp" => DISPS.to_vec(),
                        "m.scale" => vec![1, 2, 4, 8],
                        "n" => COUNTS.to_vec(),
                        _ if mnemonic.contains("shuf") => vec![0, 1, 27, 255],
                        _ => imms(bits),
                    };
                    vals.into_iter().map(V::Imm).collect()
                }
                Kind::Sym => vec![V::Text("sym".into()), V::Text("other".into())],
                Kind::Label => vec![V::Text(back.clone()), V::Text(".Lfar".into())],
                Kind::Cond => vec![V::Imm(0)],
            })
            .collect();
        let n = lists.iter().map(Vec::len).max().unwrap_or(1).max(1);
        if ins.operands.iter().any(|o| o.kind == Kind::Label) {
            out.push_str(&format!("{back}:\n"));
        }
        let mut seen = std::collections::HashSet::new();
        for k in 0..n {
            let line = fill_template(t, None, i, |j| match &lists[j][(k * (j + 1)) % lists[j].len()] {
                V::Reg(r) => Operand::Reg(Reg::P(*r)),
                V::Imm(v) => Operand::Imm(*v),
                V::Text(s) => Operand::Text(s.clone()),
            });
            if seen.insert(line.clone()) {
                out.push_str(&format!("\t{line}\n"));
            }
        }
    }
    out.push_str(".Lfar:\n");
    out
}

fn text_of(img: &Image) -> (&[u8], Vec<(u64, String, String, i64)>) {
    let s = img.sections.iter().find(|s| s.name == ".text").expect("a .text section");
    let relocs = s.relocs.iter().map(|r| (r.offset, r.type_name.clone(), r.target.clone(), r.addend)).collect();
    (&s.data, relocs)
}

#[test]
fn x86_instructions_round_trip() {
    let t = Target::x86_64();

    // 1. The description's own check.
    let report = epitome_codegen::check::check(&t);
    let enc = report.sections.iter().find(|s| s.name == "encodings").unwrap();
    assert!(enc.errors.is_empty(), "{}", enc.errors.join("\n"));
    assert!(enc.checked > 40000, "{} checked", enc.checked);

    // 2. Ours, written and read back.
    let asm = samples(&t);
    let lines = asm.lines().filter(|l| l.starts_with('\t')).count() - 1;
    let ours = Assembler::new(&t).assemble(&asm, Some(Syntax::Elf)).and_then(|a| a.file(&t)).unwrap();
    let img = Image::read(&ours, &t.machine).unwrap();
    let n = objdump::reads_back(&t, &img, &asm, &[]).unwrap();
    assert_eq!(n, lines);

    // 3. llvm-mc's, if it is here.
    let Some(mc) = ["llvm-mc", "llvm-mc-18"].into_iter().find(|c| Command::new(c).arg("--version").output().is_ok())
    else {
        eprintln!("llvm-mc is not installed: not compared with it");
        return;
    };
    let tmp = std::env::temp_dir().join(format!("epitome-x86-{}", std::process::id()));
    std::fs::create_dir_all(&tmp).unwrap();
    let (s, o) = (tmp.join("sample.s"), tmp.join("theirs.o"));
    std::fs::write(&s, &asm).unwrap();
    let out =
        Command::new(mc).args(["-triple=x86_64-linux-gnu", "-filetype=obj", "-o"]).arg(&o).arg(&s).output().unwrap();
    assert!(out.status.success(), "{}", String::from_utf8_lossy(&out.stderr));
    let theirs = Image::read(&std::fs::read(&o).unwrap(), &t.machine).unwrap();
    let ((ours_code, ours_rel), (their_code, their_rel)) = (text_of(&img), text_of(&theirs));
    if ours_code != their_code {
        let at = ours_code.iter().zip(their_code).position(|(a, b)| a != b).unwrap_or(0);
        panic!("the code differs from llvm-mc's at byte {at:#x} ({} and {} bytes)", ours_code.len(), their_code.len());
    }
    assert_eq!(ours_rel, their_rel, "the relocations differ from llvm-mc's");
    let _ = std::fs::remove_dir_all(&tmp);
    eprintln!("{lines} lines: the same {} bytes and {} relocations as {mc}", ours_code.len(), ours_rel.len());
}
