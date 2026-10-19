//! The combiner's arithmetic and bit steps (linear combinations,
//! reassociation, demanded and known bits, funnel shifts) against an
//! evaluator: random straight-line functions over two parameters and
//! constants, values used once or many times, must compute the same before
//! and after the combiner, on sample inputs.

use draconian_ir::module::*;
use draconian_ir::types::Type;
use draconian_opt::pipeline::{self, Options};
use draconian_opt::recursion::RecursionMode;

struct Rng(u64);

impl Rng {
    fn next(&mut self) -> u64 {
        self.0 = self.0.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        self.0 >> 33
    }
    fn below(&mut self, n: u64) -> u64 {
        self.next() % n
    }
}

/// A function `@f` of `n` instructions of width `w`.
fn generate(rng: &mut Rng, w: u32, n: usize) -> String {
    let mut body = String::new();
    let mut values: Vec<String> = vec!["%a".into(), "%b".into()];
    for k in 0..n {
        let pick = |rng: &mut Rng, values: &[String]| -> String {
            if rng.below(5) == 0 {
                format!("{}", rng.below(9) as i64 - 4)
            } else {
                // Mostly recent values, so that most are used once.
                let back = (rng.below(3) as usize).min(values.len() - 1);
                let at = if rng.below(4) == 0 { rng.below(values.len() as u64) as usize } else { values.len() - 1 - back };
                values[at].clone()
            }
        };
        let line = match rng.below(6) {
            0 | 1 => format!("add i{w} {}, {}", pick(rng, &values), pick(rng, &values)),
            2 | 3 => format!("sub i{w} {}, {}", pick(rng, &values), pick(rng, &values)),
            4 => format!("mul i{w} {}, {}", pick(rng, &values), rng.below(7) as i64 - 3),
            _ => format!("shl i{w} {}, {}", pick(rng, &values), rng.below(w.min(5) as u64)),
        };
        body.push_str(&format!("  %v{k} = {line}\n"));
        values.push(format!("%v{k}"));
    }
    format!("define i{w} @f(i{w} %a, i{w} %b) {{\n{body}  ret i{w} %v{}\n}}\n", n - 1)
}

/// `@f` on two inputs; `None` if a shift is by the width or more (poison).
fn eval(m: &Module, a: u64, b: u64) -> Option<u64> {
    let (_, f) = m.functions().find(|(g, _)| m.global(*g).name.as_deref() == Some("f")).unwrap();
    let w = match m.types.get(f.locals[f.params[0].local.index()].ty) {
        Type::Int(w) => *w,
        _ => unreachable!(),
    };
    let mask = if w >= 64 { u64::MAX } else { (1u64 << w) - 1 };
    let mut vals = vec![0u64; f.locals.len()];
    vals[f.params[0].local.index()] = a & mask;
    vals[f.params[1].local.index()] = b & mask;
    let get = |vals: &[u64], v: Value| -> u64 {
        match v {
            Value::Local(l) => vals[l.index()],
            Value::Const(c) => match &m.consts.get(c).kind {
                ConstKind::Int(k) => k.low_u64(),
                ConstKind::Zero => 0,
                k => panic!("constant {k:?}"),
            },
            v => panic!("operand {v:?}"),
        }
    };
    assert_eq!(f.layout.len(), 1, "straight-line code stays one block");
    for &i in &f.blocks[f.layout[0].index()].insts {
        match &f.insts[i.index()].op {
            Op::Binary { op, lhs, rhs, .. } => {
                let (x, y) = (get(&vals, *lhs), get(&vals, *rhs));
                let r = match op {
                    BinOp::Add => x.wrapping_add(y),
                    BinOp::Sub => x.wrapping_sub(y),
                    BinOp::Mul => x.wrapping_mul(y),
                    BinOp::Shl if y < w as u64 => x << y,
                    BinOp::Shl => return None,
                    BinOp::LShr if y < w as u64 => x >> y,
                    BinOp::AShr if y < w as u64 => (((x << (64 - w)) as i64 >> (64 - w)) >> y) as u64,
                    BinOp::LShr | BinOp::AShr => return None,
                    BinOp::And => x & y,
                    BinOp::Or => x | y,
                    BinOp::Xor => x ^ y,
                    op => panic!("{op:?}"),
                };
                vals[f.insts[i.index()].result.unwrap().index()] = r & mask;
            }
            Op::Cast { op, value, .. } => {
                let x = get(&vals, *value);
                let to = f.insts[i.index()].result.unwrap();
                let tw = match m.types.get(f.locals[to.index()].ty) {
                    Type::Int(b) => *b,
                    _ => unreachable!(),
                };
                let tm = if tw >= 64 { u64::MAX } else { (1u64 << tw) - 1 };
                let r = match op {
                    CastOp::Trunc | CastOp::ZExt => x & tm,
                    _ => panic!("{op:?}"),
                };
                vals[to.index()] = r;
            }
            Op::Call(call) => {
                let a: Vec<u64> = call.args.iter().map(|a| get(&vals, a.value)).collect();
                let k = a[2] % w as u64;
                let r = if k == 0 { a[0] } else { (a[0] << k) | (a[1] >> (w as u64 - k)) };
                vals[f.insts[i.index()].result.unwrap().index()] = r & mask;
            }
            Op::Ret(Some(v)) => return Some(get(&vals, *v)),
            op => panic!("{op:?}"),
        }
    }
    unreachable!()
}

#[test]
fn arithmetic_steps_keep_values() {
    let mut rng = Rng(7);
    let opts = Options {
        inline: false,
        cse: false,
        memory: false,
        mem2reg: false,
        sroa: false,
        simplifycfg: false,
        loops: false,
        recursion: RecursionMode::Off,
        threads: 1,
        ..Options::default()
    };
    let samples: Vec<u64> = vec![0, 1, 2, 3, 5, 0x7f, 0x80, 0xff, 0x7fff_ffff, 0x8000_0000, u64::MAX, 0x1234_5678_9abc_def0];
    let (mut before, mut after) = (0usize, 0usize);
    for case in 0..400 {
        let w = [8, 32, 64][case % 3];
        let n = 2 + rng.below(14) as usize;
        let src = generate(&mut rng, w, n);
        let original = draconian_ir::parse_module(&src).unwrap();
        let mut m = draconian_ir::parse_module(&src).unwrap();
        pipeline::run(&mut m, &opts);
        let count = |m: &Module| m.functions().map(|(_, f)| f.layout.iter().map(|b| f.blocks[b.index()].insts.len()).sum::<usize>()).sum::<usize>();
        before += count(&original);
        after += count(&m);
        for &a in &samples {
            for &b in &samples {
                let Some(want) = eval(&original, a, b) else { continue };
                let got = eval(&m, a, b);
                assert_eq!(got, Some(want), "f({a:#x}, {b:#x}) on\n{src}\nbecame\n{m}");
            }
        }
    }
    // The steps do something: fewer instructions overall.
    assert!(after < before, "{before} instructions became {after}");
}

/// A function `@f` of `n` instructions on `i64`, packing and unpacking
/// halves as SROA does, with shifts, masks and `trunc`/`zext` pairs.
fn generate_bits(rng: &mut Rng, n: usize) -> String {
    let masks = ["4294967295", "-4294967296", "255", "-256", "65280", "1", "-1"];
    let mut body = String::new();
    let mut values: Vec<String> = vec!["%a".into(), "%b".into()];
    let mut t = 0;
    for k in 0..n {
        let pick = |rng: &mut Rng, values: &[String]| -> String {
            let back = (rng.below(3) as usize).min(values.len() - 1);
            let at = if rng.below(3) == 0 { rng.below(values.len() as u64) as usize } else { values.len() - 1 - back };
            values[at].clone()
        };
        let x = pick(rng, &values);
        let line = match rng.below(9) {
            0 => format!("and i64 {x}, {}", masks[rng.below(masks.len() as u64) as usize]),
            1 | 2 => format!("or i64 {x}, {}", pick(rng, &values)),
            3 => format!("xor i64 {x}, {}", pick(rng, &values)),
            4 => format!("shl i64 {x}, {}", [8, 16, 32, 48][rng.below(4) as usize]),
            5 => format!("lshr i64 {x}, {}", [8, 16, 32, 48][rng.below(4) as usize]),
            6 => format!("ashr i64 {x}, {}", [8, 32][rng.below(2) as usize]),
            7 => format!("add i64 {x}, {}", pick(rng, &values)),
            _ => {
                let narrow = [8, 16, 32][rng.below(3) as usize];
                body.push_str(&format!("  %t{t} = trunc i64 {x} to i{narrow}\n"));
                let line = format!("zext i{narrow} %t{t} to i64");
                t += 1;
                line
            }
        };
        body.push_str(&format!("  %v{k} = {line}\n"));
        values.push(format!("%v{k}"));
    }
    format!("define i64 @f(i64 %a, i64 %b) {{\n{body}  ret i64 %v{}\n}}\n", n - 1)
}

#[test]
fn bit_steps_keep_values() {
    let mut rng = Rng(11);
    let opts = Options {
        inline: false,
        cse: false,
        memory: false,
        mem2reg: false,
        sroa: false,
        simplifycfg: false,
        loops: false,
        tailmark: false,
        recursion: RecursionMode::Off,
        threads: 1,
        ..Options::default()
    };
    let samples: Vec<u64> =
        vec![0, 1, 0xff, 0x80, 0x1234_5678_9abc_def0, 0xffff_ffff, 0xffff_ffff_0000_0000, u64::MAX, 0x8000_0000_0000_0000];
    let (mut before, mut after, mut steps) = (0usize, 0usize, 0usize);
    for _ in 0..500 {
        let n = 2 + rng.below(12) as usize;
        let src = generate_bits(&mut rng, n);
        let original = draconian_ir::parse_module(&src).unwrap();
        let mut m = draconian_ir::parse_module(&src).unwrap();
        let report = pipeline::run(&mut m, &opts);
        steps += ["(demanded bits)", "(known bits)", "(funnel shift)"].iter().map(|k| report.combines.fired.get(*k).copied().unwrap_or(0)).sum::<usize>();
        let count = |m: &Module| {
            m.functions().map(|(_, f)| f.layout.iter().map(|b| f.blocks[b.index()].insts.len()).sum::<usize>()).sum::<usize>()
        };
        before += count(&original);
        after += count(&m);
        for &a in &samples {
            for &b in &samples {
                let Some(want) = eval(&original, a, b) else { continue };
                let got = eval(&m, a, b);
                assert_eq!(got, Some(want), "f({a:#x}, {b:#x}) on\n{src}\nbecame\n{m}");
            }
        }
    }
    assert!(after < before, "{before} instructions became {after}");
    assert!(steps > 100, "only {steps} demanded-bits, known-bits and funnel steps");
}
