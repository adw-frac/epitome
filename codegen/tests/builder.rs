//! IR built in code (`epitome_ir::build`) and compiled by us: a loop with
//! phis, a call, memory and a select, linked with a C main and run. On an
//! AArch64 Mac with clang only.

use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};
use epitome_ir::module::{ICmpPred, Module};

#[test]
fn built_functions_run() {
    let ok = cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("needs clang on an AArch64 Mac; skipping");
        return;
    }
    let mut m = Module::default();
    m.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
    let i64t = m.types.int(64);
    let ptr = m.types.ptr(0);

    // i64 clamp(i64 x, i64 lo, i64 hi)
    let mut b = m.function("clamp", i64t, &[("x", i64t), ("lo", i64t), ("hi", i64t)]);
    let (x, lo, hi) = (b.param(0), b.param(1), b.param(2));
    b.block("entry");
    let below = b.icmp(ICmpPred::Slt, x, lo);
    let up = b.select(below, lo, x);
    let above = b.icmp(ICmpPred::Sgt, up, hi);
    let r = b.select(above, hi, up);
    b.ret(r);
    let clamp = b.finish().unwrap();

    // i64 sum_clamped(ptr p, i64 n): the sum of clamp(p[k], -10, 10).
    let mut b = m.function("sum_clamped", i64t, &[("p", ptr), ("n", i64t)]);
    let (p, n) = (b.param(0), b.param(1));
    let entry = b.block("entry");
    let body = b.new_block("loop");
    let done = b.new_block("done");
    let zero = b.const_int(i64t, 0);
    let empty = b.icmp(ICmpPred::Sle, n, zero);
    b.cond_br(empty, done, body);
    b.at(body);
    let k = b.phi(i64t, &[(zero, entry)]);
    let s = b.phi(i64t, &[(zero, entry)]);
    let at = b.gep(i64t, p, &[k]);
    let v = b.load(i64t, at);
    let (m10, p10) = (b.const_int(i64t, -10), b.const_int(i64t, 10));
    let c = b.call(clamp, &[v, m10, p10]).unwrap();
    let s1 = b.add(s, c);
    let one = b.const_int(i64t, 1);
    let k1 = b.add(k, one);
    b.add_incoming(k, k1, body);
    b.add_incoming(s, s1, body);
    let more = b.icmp(ICmpPred::Slt, k1, n);
    b.cond_br(more, body, done);
    b.at(done);
    let r = b.phi(i64t, &[(zero, entry), (s1, body)]);
    b.ret(r);
    b.finish().unwrap();

    let tmp = std::path::PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("builder");
    std::fs::create_dir_all(&tmp).unwrap();
    let t = Target::aarch64();
    let compiled = compile(&t, &mut m, &Options::default()).unwrap();
    std::fs::write(tmp.join("built.o"), compiled.object_file(&t).unwrap()).unwrap();
    std::fs::write(
        tmp.join("main.c"),
        "#include <stdio.h>\nlong clamp(long, long, long);\nlong sum_clamped(const long *, long);\n\
         int main(void) { long v[] = {3, -40, 25, 7, -2, 11};\n\
         printf(\"%ld %ld %ld %ld\\n\", clamp(5, 0, 3), clamp(-5, 0, 3), sum_clamped(v, 6), sum_clamped(v, 0)); return 0; }\n",
    )
    .unwrap();
    let exe = tmp.join("built");
    let built =
        Command::new("clang").arg(tmp.join("main.c")).arg(tmp.join("built.o")).arg("-o").arg(&exe).output().unwrap();
    assert!(built.status.success(), "{}", String::from_utf8_lossy(&built.stderr));
    let out = Command::new(&exe).output().unwrap();
    // 3 - 10 + 10 + 7 - 2 + 10 = 18
    assert_eq!(String::from_utf8_lossy(&out.stdout), "3 0 18 0\n");
}
