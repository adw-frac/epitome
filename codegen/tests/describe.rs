//! Checks of the AArch64 description itself.

use draconian_codegen::enc::Env;
use draconian_codegen::target::{Kind, Target};

/// Every instruction encodes and decodes back to itself, for registers and
/// immediates spread over their ranges.
#[test]
fn encodings_round_trip() {
    let t = Target::aarch64();
    let imms: &[i64] = &[
        0,
        1,
        2,
        3,
        4,
        7,
        8,
        12,
        16,
        31,
        32,
        48,
        63,
        255,
        256,
        4095,
        4096,
        65535,
        -1,
        -8,
        -256,
        0xff,
        0xff00,
        0x5555_5555,
    ];
    let mut checked = 0;
    for ins in &t.instrs {
        let names = ins.operand_names();
        for (k, &imm) in imms.iter().enumerate() {
            let mut env = Env::new();
            for (j, o) in ins.operands.iter().enumerate() {
                let v = match o.kind {
                    Kind::Reg(_) => ((j * 7 + k * 3) % 31) as i64,
                    Kind::Imm => imm,
                    Kind::Label => 4 * (imm % 1000),
                    Kind::Sym => 0,
                    Kind::Cond => t.conds[k % t.conds.len()].value,
                };
                env.insert(o.name.clone(), v);
            }
            for o in ins.operands.iter().filter(|o| o.tied) {
                env.insert(o.name.clone(), env["d"]);
            }
            let vals: Vec<Option<i64>> =
                ins.operands.iter().map(|o| if o.kind == Kind::Imm { Some(env[&o.name]) } else { None }).collect();
            if !ins.fits(&vals) {
                continue;
            }
            let word = ins.enc.encode(&env).unwrap();
            let back = ins.decode(word).unwrap_or_else(|| panic!("{}: {word:08x} does not decode", ins.name));
            for n in &names {
                if ins.operands.iter().any(|o| o.name == *n && o.kind == Kind::Sym) {
                    continue;
                }
                let m = ins.operands.iter().find(|o| o.name == *n).map_or(64, |o| o.bits);
                let mask = if m >= 64 { u64::MAX } else { (1u64 << m) - 1 };
                assert_eq!(back[n] as u64 & mask, env[n] as u64 & mask, "{}: operand {n} of {word:08x}", ins.name);
            }
            checked += 1;
        }
    }
    assert!(checked > 1000, "{checked}");
}

/// Each recipe's instructions, by their bodies, compute what the IR they
/// replace computes.
#[test]
fn recipes_are_right() {
    let t = Target::aarch64();
    let samples: &[u64] = &[
        0,
        1,
        2,
        3,
        5,
        7,
        100,
        0x7fff_ffff,
        0x8000_0000,
        0xffff_ffff,
        0xffff_fffe,
        0x8000_0000_0000_0000,
        u64::MAX,
        0x1234_5678_9abc_def0,
    ];
    let recipes = t.recipe_trees().unwrap();
    assert!(recipes.len() >= 10);
    for (name, bits, want, got) in recipes {
        let mut tried = 0;
        let n = bits.len();
        let mut idx = vec![0usize; n];
        loop {
            let args: Vec<u64> = idx
                .iter()
                .zip(&bits)
                .map(|(&i, &b)| samples[i] & if b >= 64 { u64::MAX } else { (1u64 << b) - 1 })
                .collect();
            if let Some(w) = t.eval_tree(&want, &args) {
                let g = t.eval_tree(&got, &args);
                assert_eq!(Some(w), g, "{name} on {args:x?}");
                tried += 1;
            }
            let mut k = 0;
            while k < n {
                idx[k] += 1;
                if idx[k] < samples.len() {
                    break;
                }
                idx[k] = 0;
                k += 1;
            }
            if k == n {
                break;
            }
        }
        assert!(tried > 0, "{name}");
    }
}

#[test]
fn table_is_built() {
    let t = Target::aarch64();
    assert!(t.patterns.len() > 500);
    // Comparisons and branches were combined.
    assert!(t.patterns.iter().any(|p| p.name == "CMPWrr+Bcc.lt"));
    // TST clears the carry, so it is not combined with conditions reading it.
    assert!(!t.patterns.iter().any(|p| p.name == "TSTWrr+Bcc.hs"));
    assert!(t.patterns.iter().any(|p| p.name == "TSTWrr+Bcc.eq"));
}

#[test]
fn built_in_files_are_the_directory() {
    // Every .ll file in targets/aarch64, in name order, is in the built-in
    // list, so a new file is not left out; and the directory loads as the
    // built-in description does.
    let dir = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("targets/aarch64");
    let mut names: Vec<String> = std::fs::read_dir(&dir)
        .unwrap()
        .map(|e| e.unwrap().file_name().to_string_lossy().into_owned())
        .filter(|n| n.ends_with(".ll"))
        .collect();
    names.sort();
    let built_in: Vec<&str> = draconian_codegen::target::AARCH64_FILES.iter().map(|f| f.0).collect();
    assert_eq!(names, built_in);
    let from_dir = Target::load_path(dir.to_str().unwrap()).unwrap();
    let t = Target::aarch64();
    assert_eq!(from_dir.instrs.len(), t.instrs.len());
    assert_eq!(from_dir.patterns.len(), t.patterns.len());
}

#[test]
fn errors_name_their_file() {
    let e =
        Target::load_files(&[("a.ll", "%nzcv = type { i64, i64 }\n"), ("b.ll", "\ndefine nonsense\n")]).err().unwrap();
    assert!(e.starts_with("b.ll:2:"), "{e}");
}
