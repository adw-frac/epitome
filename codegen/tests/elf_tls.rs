//! ELF thread-local variables on AArch64, reached through their TLSDESC
//! descriptors (`prepare::thread_locals`). Nothing here runs Linux
//! programs, so the test checks the object a linker would see:
//!
//! 1. each variable's address is the thread pointer plus what the call
//!    through its descriptor returns, by the sequence linkers rewrite (its
//!    four relocations, in order, in x0 and x1);
//! 2. variables, defined here or elsewhere, are thread-local symbols, and
//!    those defined here are in `.tdata`;
//! 3. epitome-as makes the same object of our assembly, and so does
//!    clang's assembler, when it is installed.

use std::process::Command;

use epitome_codegen::assembler::Assembler;
use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile, elf};

const SRC: &str = r#"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@x = thread_local global i64 5, align 8
@z = thread_local global i64 0, align 8
@y = external thread_local global i32, align 4

define i64 @get() {
  %px = call ptr @llvm.threadlocal.address.p0(ptr @x)
  %a = load i64, ptr %px
  %pz = call ptr @llvm.threadlocal.address.p0(ptr @z)
  %b = load i64, ptr %pz
  %py = call ptr @llvm.threadlocal.address.p0(ptr @y)
  %c = load i32, ptr %py
  %c64 = sext i32 %c to i64
  %s = add i64 %a, %b
  %t = add i64 %s, %c64
  ret i64 %t
}

define void @put(i64 %v) {
  %px = call ptr @llvm.threadlocal.address.p0(ptr @x)
  store i64 %v, ptr %px
  ret void
}

declare ptr @llvm.threadlocal.address.p0(ptr)
"#;

/// The symbols of ELF object `obj`: name, type (`STT_*`) and section index.
fn symbols(obj: &[u8]) -> Vec<(String, u8, u16)> {
    let u16_at = |o: usize| u16::from_le_bytes(obj[o..o + 2].try_into().unwrap());
    let u32_at = |o: usize| u32::from_le_bytes(obj[o..o + 4].try_into().unwrap());
    let u64_at = |o: usize| u64::from_le_bytes(obj[o..o + 8].try_into().unwrap()) as usize;
    let (shoff, n) = (u64_at(0x28), u16_at(0x3c) as usize);
    let header = |k: usize| shoff + k * 64;
    let mut out = Vec::new();
    for k in 0..n {
        let h = header(k);
        if u32_at(h + 4) != 2 {
            continue;
        }
        let strtab = u64_at(header(u32_at(h + 40) as usize) + 24);
        let (at, size) = (u64_at(h + 24), u64_at(h + 32));
        for e in (at..at + size).step_by(24) {
            let name = strtab + u32_at(e) as usize;
            let end = name + obj[name..].iter().position(|&b| b == 0).unwrap();
            out.push((String::from_utf8_lossy(&obj[name..end]).into_owned(), obj[e + 4] & 15, u16_at(e + 6)));
        }
    }
    out
}

#[test]
fn variables_are_reached_through_descriptors() {
    let t = Target::aarch64();
    let mut m = epitome_ir::parse_module(SRC).unwrap();
    let c = compile(&t, &mut m, &Options::default()).unwrap();
    let asm = &c.asm;

    // 1. Each variable's sequence, as linkers expect it.
    for v in ["x", "z", "y"] {
        let seq = format!(
            "\tadrp x0, :tlsdesc:{v}\n\tldr x1, [x0, :tlsdesc_lo12:{v}]\n\tadd x0, x0, :tlsdesc_lo12:{v}\n\
             \t.tlsdesccall {v}\n\tblr x1\n"
        );
        assert!(asm.contains(&seq), "no descriptor call for {v}:\n{asm}");
    }
    assert_eq!(asm.matches("mrs ").count(), 4, "{asm}");
    assert!(asm.contains(".section .tdata,\"awT\",@progbits"), "{asm}");

    let obj = c.object_file(&t).unwrap();
    let img = epitome_codegen::objdump::Image::read(&obj, &t.machine).unwrap();
    let relocs = epitome_codegen::objdump::relocations(&img);
    for v in ["x", "z", "y"] {
        let kinds: Vec<&str> = relocs
            .lines()
            .filter(|l| l.ends_with(&format!(" {v}")))
            .filter_map(|l| l.split_whitespace().nth(1))
            .collect();
        let one = [
            "R_AARCH64_TLSDESC_ADR_PAGE21",
            "R_AARCH64_TLSDESC_LD64_LO12",
            "R_AARCH64_TLSDESC_ADD_LO12",
            "R_AARCH64_TLSDESC_CALL",
        ];
        let times = if v == "x" { 2 } else { 1 };
        assert_eq!(kinds, one.repeat(times), "{v}:\n{relocs}");
    }

    // 2. Thread-local symbols (STT_TLS), defined ones in .tdata.
    let syms = symbols(&obj);
    let tdata = img.sections.iter().position(|s| s.name == ".tdata").expect("a .tdata section");
    for (v, defined) in [("x", true), ("z", true), ("y", false)] {
        let &(_, ty, shndx) = syms.iter().find(|s| s.0 == v).unwrap_or_else(|| panic!("no symbol {v}"));
        assert_eq!(ty, elf::STT_TLS, "{v}");
        assert_eq!(shndx != 0, defined, "{v}");
        if defined {
            assert_eq!(img.symbols.iter().find(|s| s.name == v).unwrap().section, Some(tdata), "{v}");
        }
    }

    // 3. Our assembly, assembled.
    let ours = Assembler::new(&t).assemble(asm, None).unwrap();
    assert_eq!(elf::write(&ours.object, &t.machine).unwrap(), obj, "epitome-as made another object");
    let dir = std::env::temp_dir().join(format!("epitome-elf-tls-{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let (s, o) = (dir.join("tls.s"), dir.join("tls.o"));
    std::fs::write(&s, asm).unwrap();
    let Ok(out) = Command::new("clang").args(["--target=aarch64-linux-gnu", "-c", "-o"]).arg(&o).arg(&s).output()
    else {
        eprintln!("clang is not installed: not checked against its assembler");
        return;
    };
    assert!(out.status.success(), "{}", String::from_utf8_lossy(&out.stderr));
    let theirs = epitome_codegen::objdump::Image::read(&std::fs::read(&o).unwrap(), &t.machine).unwrap();
    let text =
        |i: &epitome_codegen::objdump::Image| i.sections.iter().find(|s| s.name == ".text").unwrap().data.clone();
    assert_eq!(text(&img), text(&theirs), "clang assembles our assembly to other code");
    assert_eq!(relocs, epitome_codegen::objdump::relocations(&theirs));
    let _ = std::fs::remove_dir_all(&dir);
}
