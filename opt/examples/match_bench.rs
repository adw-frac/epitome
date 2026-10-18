//! How matching time grows with the number of rules.
//!
//! `cargo run --release --example match_bench`
//!
//! Builds a random expression DAG of 100,000 operations, then matches every
//! operation against the standard rules plus N random extra rules, two
//! ways: with the discrimination tree, and by trying each rule's pattern in
//! turn. The tree's time per instruction should barely move as N grows;
//! trying each rule grows with N.

use std::time::Instant;

use smaugian_ir::module::{BinOp, ConstId, LocalId, Value};
use smaugian_opt::combine::dsl::{Head, Lit, Pat, parse_rules};
use smaugian_opt::combine::tree::{Matcher, Shape, Subject};

struct Lcg(u64);
impl Lcg {
    fn next(&mut self) -> u64 {
        self.0 = self.0.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        self.0 >> 33
    }
    fn below(&mut self, n: u64) -> u64 {
        self.next() % n
    }
}

const OPS: [BinOp; 7] = [BinOp::Add, BinOp::Sub, BinOp::Xor, BinOp::Mul, BinOp::And, BinOp::Or, BinOp::Shl];

/// A DAG of binary operations. Local `i` is node `i`; a constant's id is
/// its value.
struct Dag(Vec<(Head, [Value; 3])>);

impl Subject for Dag {
    fn shape(&self, v: Value) -> Shape {
        match v {
            Value::Local(l) => {
                let (h, ops) = self.0[l.index()];
                Shape::Op(h, ops)
            }
            Value::Const(c) => Shape::Const(c),
            Value::Metadata(_) => Shape::Opaque,
        }
    }
    fn lits(&self, c: ConstId) -> Vec<Lit> {
        vec![Lit::Int(c.0 as i64)]
    }
    fn is_int_const(&self, _: ConstId) -> bool {
        true
    }
}

fn dag(n: usize, rng: &mut Lcg) -> Dag {
    let mut nodes = Vec::with_capacity(n);
    for i in 0..n {
        let operand = |rng: &mut Lcg| {
            if i == 0 || rng.below(3) == 0 {
                Value::Const(ConstId(rng.below(16) as u32))
            } else {
                Value::Local(LocalId((i - 1 - rng.below(i.min(8) as u64) as usize) as u32))
            }
        };
        let op = OPS[rng.below(OPS.len() as u64) as usize];
        let (a, b) = (operand(rng), operand(rng));
        nodes.push((Head::Bin(op), [a, b, Value::Const(ConstId(0))]));
    }
    Dag(nodes)
}

/// A random pattern of depth up to 3. Literal leaves are values the DAG
/// never uses (at least 1000), so they occupy the tree without firing.
///
/// With `general`, a third of the leaves are variables, so many patterns
/// genuinely match the shape of most instructions. Otherwise patterns look
/// like real combine rules: mostly literals, with variables only where the
/// literals run out.
fn random_rule(k: usize, rng: &mut Lcg, general: bool) -> String {
    fn pat(depth: u32, rng: &mut Lcg, general: bool) -> String {
        if depth == 0 || rng.below(3) == 0 {
            let var = if general { rng.below(3) < 2 } else { rng.below(8) == 0 };
            return if var {
                if rng.below(2) == 0 { "x".into() } else { "y".into() }
            } else {
                (1000 + rng.below(1_000_000)).to_string()
            };
        }
        let op = OPS[rng.below(OPS.len() as u64) as usize].keyword();
        format!("{op}({}, {})", pat(depth - 1, rng, general), pat(depth - 1, rng, general))
    }
    let op = OPS[rng.below(OPS.len() as u64) as usize].keyword();
    format!("extra{k}: {op}({}, {}) -> 0", pat(2, rng, general), pat(2, rng, general))
}

/// Matching by trying one pattern after another.
fn naive(s: &Dag, p: &Pat, v: Value) -> bool {
    match p {
        Pat::Var(_) | Pat::Block(_) => true,
        Pat::Const(_) => matches!(v, Value::Const(_)),
        Pat::Lit(l) => matches!(v, Value::Const(c) if s.lits(c).contains(l)),
        Pat::Op(h, args) => match s.shape(v) {
            Shape::Op(h2, ops) if h2 == *h => args.iter().zip(ops).all(|(a, o)| naive(s, a, o)),
            _ => false,
        },
    }
}

fn main() {
    let standard = std::fs::read_to_string(concat!(env!("CARGO_MANIFEST_DIR"), "/rules/combine.rules")).unwrap();
    let mut rng = Lcg(7);
    let subject = dag(100_000, &mut rng);
    let roots: Vec<Value> = (0..subject.0.len()).map(|i| Value::Local(LocalId(i as u32))).collect();
    for general in [false, true] {
        println!(
            "\n{} extra rules:\n{:>8} {:>10} {:>12} {:>14} {:>16} {:>18}",
            if general { "General" } else { "Specific" },
            "rules",
            "variants",
            "tree nodes",
            "matches/inst",
            "tree ns/inst",
            "one-by-one ns/inst"
        );
        for extra in [0usize, 100, 1_000, 10_000, 100_000] {
            let mut text = standard.clone();
            for k in 0..extra {
                text.push_str(&random_rule(k, &mut rng, general));
                text.push('\n');
            }
            let rules = parse_rules(&text).unwrap();
            let n = rules.len();
            let m = Matcher::new(rules);

            let t = Instant::now();
            let mut found = 0;
            for &r in &roots {
                found += m.find(&subject, r).len();
            }
            let tree = t.elapsed().as_nanos() as f64 / roots.len() as f64;

            // Trying every rule is slow with many rules: time a sample.
            let sample = &roots[..roots.len().min(2_000_000 / n.max(1)).max(100)];
            let t = Instant::now();
            let mut found_naive = 0;
            for &r in sample {
                found_naive += m.rules.iter().filter(|rule| naive(&subject, &rule.pat, r)).count();
            }
            let one_by_one = t.elapsed().as_nanos() as f64 / sample.len() as f64;
            let per = found as f64 / roots.len() as f64;
            println!("{n:>8} {:>10} {:>12} {per:>14.1} {tree:>16.0} {one_by_one:>18.0}", m.variants.len(), m.size());
            let _ = found_naive;
        }
    }
}
