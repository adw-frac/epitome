//! Finding which rules match an instruction, without trying them one by
//! one.
//!
//! Every pattern is flattened in preorder into a path of symbols: an
//! operation, a literal, "any constant" or "anything", and all the paths
//! are stored in one trie, a *discrimination tree*. `add(sub(x, C1), C2)`
//! becomes the path `add sub * C C`.
//!
//! To match, the instruction's own operand tree is walked in the same
//! preorder alongside the trie. At each step only the edges that can match
//! the value in hand are followed: its operation, a literal it equals,
//! "any constant" if it is one, and "anything". "Anything" skips the
//! value's whole operand tree. The work depends on how deep the patterns
//! are and how many of them share a prefix with the instruction, not on the
//! total number of rules. A rule that adds a new top-level operation adds
//! one edge at the root, not one more pattern to try on every instruction.
//!
//! The trie checks only the shape. A variable used twice, and a rule's
//! condition, are checked afterwards, for the few rules that reach a leaf.
//!
//! The tree knows nothing about the IR: the combiner describes values to it
//! through `Subject`. Extending combines to memory operations or control
//! flow means adding operations to `Head`, not changing the matcher.

use crate::fx::FxHashMap as HashMap;

use draconian_ir::module::{ConstId, Value};

use super::dsl::{Head, Lit, Pat, Rule};

/// How the matcher sees a value.
pub enum Shape {
    /// An instruction it can look inside: its operation and operands.
    Op(Head, [Value; 3]),
    Const(ConstId),
    /// Anything else: an argument, or an instruction no rule names.
    Opaque,
}

pub trait Subject {
    fn shape(&self, v: Value) -> Shape;
    /// Every literal the constant equals. An integer equals at most two:
    /// its value read as unsigned and read as signed (`255` and `-1` for
    /// an `i8` of all ones). Keeping this short is what makes matching a
    /// constant independent of how many literals the rules use.
    fn lits(&self, c: ConstId) -> Vec<Lit>;
    /// An integer constant a `C` variable can bind to.
    fn is_int_const(&self, c: ConstId) -> bool;
}

/// One way of writing a rule's pattern; commutative operations give
/// several.
pub struct Variant {
    pub rule: usize,
    /// For each capture, in preorder, the variable it binds.
    pub slots: Vec<usize>,
}

#[derive(Default)]
struct Node {
    heads: HashMap<Head, usize>,
    lits: HashMap<Lit, usize>,
    any_const: Option<usize>,
    any: Option<usize>,
    /// Variants whose path ends here.
    leaves: Vec<usize>,
}

/// A candidate match: the variant, and what its variables captured.
pub struct Match {
    pub variant: usize,
    /// Values for the captures, in preorder.
    pub captures: Vec<Value>,
    /// The instructions matched by operations below the root, which may
    /// become unused when the root is replaced.
    pub interior: Vec<Value>,
}

pub struct Matcher {
    pub rules: Vec<Rule>,
    pub variants: Vec<Variant>,
    nodes: Vec<Node>,
}

impl Matcher {
    pub fn new(rules: Vec<Rule>) -> Matcher {
        let mut m = Matcher { rules: Vec::new(), variants: Vec::new(), nodes: vec![Node::default()] };
        for (r, rule) in rules.iter().enumerate() {
            let mut seen: Vec<Pat> = Vec::new();
            for pat in commuted(&rule.pat) {
                if seen.contains(&pat) {
                    continue;
                }
                let mut slots = Vec::new();
                collect_slots(&pat, &mut slots);
                let v = m.variants.len();
                m.variants.push(Variant { rule: r, slots });
                m.insert(&pat, v);
                seen.push(pat);
            }
        }
        m.rules = rules;
        m
    }

    fn child(&mut self, node: usize, pick: impl Fn(&mut Node) -> &mut Option<usize>) -> usize {
        if let Some(c) = *pick(&mut self.nodes[node]) {
            return c;
        }
        let c = self.nodes.len();
        self.nodes.push(Node::default());
        *pick(&mut self.nodes[node]) = Some(c);
        c
    }

    fn insert(&mut self, pat: &Pat, variant: usize) {
        let mut path = Vec::new();
        flatten(pat, &mut path);
        let mut node = 0;
        for sym in path {
            node = match sym {
                Sym::Head(h) => match self.nodes[node].heads.get(&h) {
                    Some(&c) => c,
                    None => {
                        let c = self.nodes.len();
                        self.nodes.push(Node::default());
                        self.nodes[node].heads.insert(h, c);
                        c
                    }
                },
                Sym::Lit(l) => match self.nodes[node].lits.get(&l) {
                    Some(&c) => c,
                    None => {
                        let c = self.nodes.len();
                        self.nodes.push(Node::default());
                        self.nodes[node].lits.insert(l, c);
                        c
                    }
                },
                Sym::AnyConst => self.child(node, |n| &mut n.any_const),
                Sym::Any => self.child(node, |n| &mut n.any),
            };
        }
        self.nodes[node].leaves.push(variant);
    }

    /// Every candidate match for the instruction `root`, best first: rules
    /// earlier in the file come first.
    pub fn find(&self, s: &dyn Subject, root: Value) -> Vec<Match> {
        let Shape::Op(head, ops) = s.shape(root) else { return Vec::new() };
        self.find_op(s, head, ops)
    }

    /// Like `find`, for an instruction given by its operation and operands
    /// rather than its value, such as a branch, which has none. A block
    /// operand is passed as the block's label.
    pub fn find_op(&self, s: &dyn Subject, head: Head, ops: [Value; 3]) -> Vec<Match> {
        let mut out = Vec::new();
        let Some(&start) = self.nodes[0].heads.get(&head) else { return out };
        let mut todo: Vec<Value> = ops[..head.arity()].iter().rev().copied().collect();
        let mut captures = Vec::new();
        let mut interior = Vec::new();
        self.walk(s, start, &mut todo, &mut captures, &mut interior, &mut out);
        out.sort_by_key(|m| (self.variants[m.variant].rule, m.variant));
        out
    }

    fn walk(
        &self,
        s: &dyn Subject,
        node: usize,
        todo: &mut Vec<Value>,
        captures: &mut Vec<Value>,
        interior: &mut Vec<Value>,
        out: &mut Vec<Match>,
    ) {
        let n = &self.nodes[node];
        let Some(v) = todo.pop() else {
            for &variant in &n.leaves {
                out.push(Match { variant, captures: captures.clone(), interior: interior.clone() });
            }
            return;
        };
        if let Some(c) = n.any {
            captures.push(v);
            self.walk(s, c, todo, captures, interior, out);
            captures.pop();
        }
        match s.shape(v) {
            Shape::Op(head, ops) => {
                if let Some(&c) = n.heads.get(&head) {
                    let k = head.arity();
                    todo.extend(ops[..k].iter().rev());
                    interior.push(v);
                    self.walk(s, c, todo, captures, interior, out);
                    interior.pop();
                    todo.truncate(todo.len() - k);
                }
            }
            Shape::Const(c) => {
                if !n.lits.is_empty() {
                    for lit in s.lits(c) {
                        if let Some(&child) = n.lits.get(&lit) {
                            self.walk(s, child, todo, captures, interior, out);
                        }
                    }
                }
                if let Some(child) = n.any_const
                    && s.is_int_const(c)
                {
                    captures.push(v);
                    self.walk(s, child, todo, captures, interior, out);
                    captures.pop();
                }
            }
            Shape::Opaque => {}
        }
        todo.push(v);
    }

    /// The number of trie nodes, for statistics.
    pub fn size(&self) -> usize {
        self.nodes.len()
    }
}

#[derive(Clone, Copy)]
enum Sym {
    Head(Head),
    Lit(Lit),
    AnyConst,
    Any,
}

fn flatten(p: &Pat, out: &mut Vec<Sym>) {
    match p {
        Pat::Var(_) | Pat::Block(_) => out.push(Sym::Any),
        Pat::Const(_) => out.push(Sym::AnyConst),
        Pat::Lit(l) => out.push(Sym::Lit(*l)),
        Pat::Op(h, args) => {
            out.push(Sym::Head(*h));
            args.iter().for_each(|a| flatten(a, out));
        }
    }
}

fn collect_slots(p: &Pat, out: &mut Vec<usize>) {
    match p {
        Pat::Var(v) | Pat::Const(v) | Pat::Block(v) => out.push(*v),
        Pat::Lit(_) => {}
        Pat::Op(_, args) => args.iter().for_each(|a| collect_slots(a, out)),
    }
}

/// Every way of writing `p` with the operands of commutative operations in
/// either order.
fn commuted(p: &Pat) -> Vec<Pat> {
    match p {
        Pat::Op(h, args) => {
            let mut combos: Vec<Vec<Pat>> = vec![Vec::new()];
            for a in args {
                let options = commuted(a);
                combos = combos
                    .into_iter()
                    .flat_map(|c| options.iter().map(move |o| [c.clone(), vec![o.clone()]].concat()))
                    .collect();
            }
            let mut out = Vec::new();
            for c in combos {
                if h.is_commutative() {
                    out.push(Pat::Op(*h, vec![c[1].clone(), c[0].clone()]));
                }
                out.push(Pat::Op(*h, c));
            }
            out.reverse();
            out
        }
        p => vec![p.clone()],
    }
}

#[cfg(test)]
mod tests {
    use draconian_ir::module::{BinOp, LocalId};

    use super::super::dsl::parse_rules;
    use super::*;

    /// A toy subject: locals 0.. are described by a table; constants hold
    /// their value in their id.
    struct Toy(Vec<Shape2>);
    #[derive(Clone, Copy)]
    enum Shape2 {
        Op(Head, [Value; 3]),
        Arg,
    }
    impl Subject for Toy {
        fn shape(&self, v: Value) -> Shape {
            match v {
                Value::Local(l) => match self.0[l.index()] {
                    Shape2::Op(h, o) => Shape::Op(h, o),
                    Shape2::Arg => Shape::Opaque,
                },
                Value::Const(c) => Shape::Const(c),
                _ => Shape::Opaque,
            }
        }
        fn lits(&self, c: ConstId) -> Vec<Lit> {
            vec![Lit::Int(c.0 as i64)]
        }
        fn is_int_const(&self, _: ConstId) -> bool {
            true
        }
    }

    #[test]
    fn finds_matches_through_the_tree() {
        let rules = parse_rules(
            "a: add(x, 0) -> x\n\
             b: add(x, x) -> shl(x, 1)\n\
             c: add(sub(x, C1), C2) -> add(x, C2 - C1)\n\
             d: mul(x, 1) -> x",
        )
        .unwrap();
        let m = Matcher::new(rules);
        let l = |i| Value::Local(LocalId(i));
        let k = |v| Value::Const(ConstId(v));
        let add = Head::Bin(BinOp::Add);
        let sub = Head::Bin(BinOp::Sub);
        // %0 = arg, %1 = sub %0, 1, %2 = add %1, 1, %3 = add %0, %0, %4 = add 0, %0
        let toy = Toy(vec![
            Shape2::Arg,
            Shape2::Op(sub, [l(0), k(1), l(0)]),
            Shape2::Op(add, [l(1), k(1), l(0)]),
            Shape2::Op(add, [l(0), l(0), l(0)]),
            Shape2::Op(add, [k(0), l(0), l(0)]),
        ]);
        let names = |root| -> Vec<String> {
            m.find(&toy, root).iter().map(|x| m.rules[m.variants[x.variant].rule].name.clone()).collect()
        };
        // `add(%1, 1)` has the shape of `add(x, x)` too; the two `x`s are
        // compared after the tree, by the combiner.
        assert_eq!(names(l(2)), vec!["b", "c"]);
        // Rule b matches the shape; the repeated `x` is checked later.
        assert_eq!(names(l(3)), vec!["b"]);
        // Commuted: `add(0, x)` matches `add(x, 0)`.
        assert_eq!(names(l(4)), vec!["a", "b"]);
    }
}
