//! Alias analysis answers on hand-written functions.

use smaugian_ir::module::*;
use smaugian_opt::aa::{AliasResult, BasicAa, Location};
use smaugian_opt::ctx::{Intrinsics, parallel_phase};

use AliasResult::*;

const SRC: &str = r#"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
%pair = type { i32, i64 }

@g = global [8 x i32] zeroinitializer
@h = global i32 0

declare ptr @malloc(i64)
declare noalias ptr @fresh(i64)
declare void @escape(ptr)
declare void @touch_args(ptr) memory(argmem: readwrite)
declare i32 @reads_only(ptr) memory(read)
declare i32 @pure(i32) memory(none)

define void @f(ptr %p, ptr %q, ptr noalias %r, i64 %i) {
  %a = alloca [4 x i32]
  %b = alloca %pair
  %esc = alloca i32
  %a0 = getelementptr inbounds [4 x i32], ptr %a, i64 0, i64 0
  %a1 = getelementptr inbounds [4 x i32], ptr %a, i64 0, i64 1
  %ai = getelementptr inbounds [4 x i32], ptr %a, i64 0, i64 %i
  %i1 = add i64 %i, 1
  %ai1 = getelementptr inbounds [4 x i32], ptr %a, i64 0, i64 %i1
  %b0 = getelementptr inbounds %pair, ptr %b, i32 0, i32 0
  %b1 = getelementptr inbounds %pair, ptr %b, i32 0, i32 1
  %g2 = getelementptr inbounds [8 x i32], ptr @g, i64 0, i64 2
  %m = call ptr @fresh(i64 16)
  %n = call ptr @malloc(i64 16)
  %p4 = getelementptr inbounds i8, ptr %p, i64 4
  store i32 1, ptr %a0
  store i32 2, ptr %b0
  call void @escape(ptr %esc)
  call void @touch_args(ptr %p)
  %x = call i32 @reads_only(ptr %q)
  %y = call i32 @pure(i32 %x)
  ret void
}
"#;

fn local(f: &Function, name: &str) -> Value {
    let i = f.locals.iter().position(|l| l.name.as_deref() == Some(name)).unwrap_or_else(|| panic!("no %{name}"));
    Value::Local(LocalId(i as u32))
}

fn global(m: &Module, name: &str, sh: &smaugian_opt::ctx::Shared) -> Value {
    let g = m.globals.iter().position(|x| x.name.as_deref() == Some(name)).unwrap();
    sh.global_ref(GlobalId(g as u32))
}

#[test]
fn alias_answers() {
    let mut m = smaugian_ir::parse_module(SRC).unwrap();
    let fid = GlobalId(m.globals.iter().position(|g| g.name.as_deref() == Some("f")).unwrap() as u32);
    let snapshot = smaugian_ir::parse_module(SRC).unwrap();
    parallel_phase(&mut m, Intrinsics::default(), |sh| {
        let f = sh.take(fid);
        let aa = BasicAa::new(sh, &f);
        let at = |name: &str, size: u64| Location { ptr: local(&f, name), size: Some(size) };
        let g = |name: &str, size: u64| Location { ptr: global(&snapshot, name, sh), size: Some(size) };
        let unknown = |name: &str| Location { ptr: local(&f, name), size: None };
        let cases: Vec<(&str, Location, Location, AliasResult)> = vec![
            ("same pointer", at("a0", 4), at("a0", 4), MustAlias),
            ("first element is the alloca", at("a0", 4), at("a", 4), MustAlias),
            ("neighbouring elements", at("a0", 4), at("a1", 4), NoAlias),
            ("overlapping sizes", at("a0", 8), at("a1", 4), PartialAlias),
            ("a[i] and a[i+1]", at("ai", 4), at("ai1", 4), NoAlias),
            ("a[i] and a[1]: unknown i", at("ai", 4), at("a1", 4), MayAlias),
            ("struct fields at offsets 0 and 8", at("b0", 4), at("b1", 8), NoAlias),
            ("two allocas", at("a0", 4), at("b0", 4), NoAlias),
            ("alloca and global", at("a1", 4), g("h", 4), NoAlias),
            ("two globals", g("g", 4), g("h", 4), NoAlias),
            ("element of a global", g("g", 4), at("g2", 4), NoAlias),
            ("noalias call result and alloca", at("m", 4), at("a0", 4), NoAlias),
            ("noalias argument and other argument", at("r", 4), at("p", 4), NoAlias),
            ("two plain arguments", at("p", 4), at("q", 4), MayAlias),
            ("argument and a local that does not escape", at("p", 4), at("b0", 4), NoAlias),
            ("argument and a local that escapes", at("p", 4), at("esc", 4), MayAlias),
            ("plain call result and argument", at("n", 4), at("p", 4), MayAlias),
            ("argument and an offset of itself", at("p", 4), at("p4", 4), NoAlias),
            ("unknown sizes, different offsets", unknown("p"), unknown("p4"), MayAlias),
        ];
        let mut wrong = Vec::new();
        for (what, x, y, want) in cases {
            let got = aa.alias(&f, x, y);
            let back = aa.alias(&f, y, x);
            if got != want || back != want {
                wrong.push(format!("{what}: want {want:?}, got {got:?} (and {back:?} the other way)"));
            }
        }
        // Calls.
        let call_to = |callee: &str| {
            f.insts_in_order()
                .map(|i| &f.insts[i.index()])
                .find(|inst| inst.op.call().is_some_and(|c| sh.direct_callee(c) == global_id(&snapshot, callee)))
                .unwrap()
        };
        let mr = |callee: &str, loc: Location| {
            let r = aa.mod_ref(&f, call_to(callee), loc);
            (r.mods, r.refs)
        };
        // (what, (mods, refs) found, (mods, refs) wanted)
        type Check<'a> = (&'a str, (bool, bool), (bool, bool));
        let checks: Vec<Check> = vec![
            ("unknown call and a local that does not escape", mr("escape", at("b0", 4)), (false, false)),
            ("unknown call and the local it was given", mr("escape", at("esc", 4)), (true, true)),
            ("unknown call and a global", mr("escape", g("h", 4)), (true, true)),
            ("argmem call and its argument", mr("touch_args", at("p", 4)), (true, true)),
            ("argmem call and a noalias argument", mr("touch_args", at("r", 4)), (false, false)),
            ("argmem call and a global", mr("touch_args", g("h", 4)), (true, true)),
            ("read-only call", mr("reads_only", g("h", 4)), (false, true)),
            ("memory(none) call", mr("pure", g("h", 4)), (false, false)),
        ];
        for (what, got, want) in checks {
            if got != want {
                wrong.push(format!("{what}: want mods/refs {want:?}, got {got:?}"));
            }
        }
        assert!(wrong.is_empty(), "{}", wrong.join("\n"));
        sh.publish(fid, f);
    });
}

fn global_id(m: &Module, name: &str) -> Option<GlobalId> {
    m.globals.iter().position(|g| g.name.as_deref() == Some(name)).map(|i| GlobalId(i as u32))
}
