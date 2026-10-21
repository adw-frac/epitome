//! Vector comparison masks as integers (`bitcast <N x i1> to iN`), at
//! widths that fit a register and ones that must be split, built by us,
//! linked with a C main, run, and checked against the bits worked out here.
//! On an AArch64 Mac with clang only.

use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

#[test]
fn comparison_masks_as_integers() {
    let ok = cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("needs clang on an AArch64 Mac; skipping");
        return;
    }
    let tmp = std::path::PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("masks");
    std::fs::create_dir_all(&tmp).unwrap();
    // mask_N(a, b): bit k set where a[k] == b[k], for N bytes.
    let mut ll = String::from("target triple = \"arm64-apple-macosx14.0.0\"\n");
    for n in [8, 16, 32, 64] {
        // pick_N(bits, a, b, out): out[k] = bit k ? a[k] : b[k].
        ll.push_str(&format!(
            "define void @pick_{n}(i{n} %bits, ptr %a, ptr %b, ptr %out) {{\n  %m = bitcast i{n} %bits to <{n} x i1>\n  \
             %x = load <{n} x i8>, ptr %a\n  %y = load <{n} x i8>, ptr %b\n  \
             %s = select <{n} x i1> %m, <{n} x i8> %x, <{n} x i8> %y\n  store <{n} x i8> %s, ptr %out\n  ret void\n}}\n"
        ));
        ll.push_str(&format!(
            "define i{n} @mask_{n}(ptr %a, ptr %b) {{\n  %x = load <{n} x i8>, ptr %a\n  %y = load <{n} x i8>, ptr %b\n  \
             %c = icmp eq <{n} x i8> %x, %y\n  %m = bitcast <{n} x i1> %c to i{n}\n  ret i{n} %m\n}}\n"
        ));
    }
    let t = Target::aarch64();
    let mut m = epitome_ir::parse_module(&ll).unwrap();
    let compiled = compile(&t, &mut m, &Options::default()).unwrap();
    std::fs::write(tmp.join("masks.o"), compiled.object_file(&t).unwrap()).unwrap();
    let main = r#"
#include <stdio.h>
#include <stdint.h>
uint8_t mask_8(const char *, const char *);
uint16_t mask_16(const char *, const char *);
uint32_t mask_32(const char *, const char *);
uint64_t mask_64(const char *, const char *);
void pick_8(uint8_t, const char *, const char *, char *);
void pick_16(uint16_t, const char *, const char *, char *);
void pick_32(uint32_t, const char *, const char *, char *);
void pick_64(uint64_t, const char *, const char *, char *);
int main(void) {
    char a[64], b[64];
    for (int i = 0; i < 64; i++) { a[i] = (char)i; b[i] = (char)((i * 7) % 5 == 0 ? i : i + 1); }
    printf("%llx %llx %llx %llx\n", (unsigned long long)mask_8(a, b), (unsigned long long)mask_16(a, b),
           (unsigned long long)mask_32(a, b), (unsigned long long)mask_64(a, b));
    char out[64];
    uint64_t pattern = 0x9a3c5f0e17d2b648ull;
    pick_8((uint8_t)pattern, a, b, out);
    for (int i = 0; i < 8; i++) printf("%d,", out[i]);
    pick_16((uint16_t)pattern, a, b, out);
    for (int i = 0; i < 16; i++) printf("%d,", out[i]);
    pick_32((uint32_t)pattern, a, b, out);
    for (int i = 0; i < 32; i++) printf("%d,", out[i]);
    pick_64(pattern, a, b, out);
    for (int i = 0; i < 64; i++) printf("%d,", out[i]);
    printf("\n");
    return 0;
}
"#;
    std::fs::write(tmp.join("main.c"), main).unwrap();
    let exe = tmp.join("masks");
    let built =
        Command::new("clang").arg(tmp.join("main.c")).arg(tmp.join("masks.o")).arg("-o").arg(&exe).output().unwrap();
    assert!(built.status.success(), "{}", String::from_utf8_lossy(&built.stderr));
    let out = Command::new(&exe).output().unwrap();
    let got = String::from_utf8_lossy(&out.stdout).trim().to_string();
    let bits = |n: u32| -> u64 { (0..n).filter(|i| (i * 7) % 5 == 0).fold(0u64, |m, i| m | 1 << i) };
    let a = |i: u64| i as i64;
    let b = |i: u64| if (i * 7) % 5 == 0 { i as i64 } else { i as i64 + 1 };
    let pattern: u64 = 0x9a3c5f0e17d2b648;
    let mut picks = String::new();
    for n in [8u64, 16, 32, 64] {
        for i in 0..n {
            picks.push_str(&format!("{},", if pattern >> i & 1 == 1 { a(i) } else { b(i) }));
        }
    }
    let want = format!("{:x} {:x} {:x} {:x}\n{picks}", bits(8), bits(16), bits(32), bits(64));
    assert_eq!(got, want);
}

/// Masks split across registers, up to 128 lanes (`prepare::wide_mask_bits`):
/// selects, reductions, bitcasts to and from `i128` and `i64`, loads and
/// stores of them, built by us and by clang from `tests/masks/wide.ll`, each
/// linked with `wide_main.c`: the two must print the same.
#[test]
fn wide_masks_as_clangs() {
    let ok = cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("needs clang on an AArch64 Mac; skipping");
        return;
    }
    let dir = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/masks");
    let tmp = std::path::PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("masks-wide");
    std::fs::create_dir_all(&tmp).unwrap();
    let ll = dir.join("wide.ll");
    let t = Target::aarch64();
    let mut m = epitome_ir::parse_module(&std::fs::read_to_string(&ll).unwrap()).unwrap();
    let ours = tmp.join("ours.o");
    std::fs::write(&ours, compile(&t, &mut m, &Options::default()).unwrap().object_file(&t).unwrap()).unwrap();
    let theirs = tmp.join("theirs.o");
    let st = Command::new("clang").arg("-O1").arg("-c").arg(&ll).arg("-o").arg(&theirs).status().unwrap();
    assert!(st.success());
    let mut out = Vec::new();
    for (name, obj) in [("ours", &ours), ("theirs", &theirs)] {
        let exe = tmp.join(name);
        let st = Command::new("clang").arg(obj).arg(dir.join("wide_main.c")).arg("-o").arg(&exe).status().unwrap();
        assert!(st.success());
        let o = Command::new(&exe).output().unwrap();
        assert!(o.status.success());
        out.push(String::from_utf8_lossy(&o.stdout).into_owned());
    }
    assert_eq!(out[0], out[1], "our build of wide.ll differs from clang's");
}
