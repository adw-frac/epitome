# coldgen.py N SEED OUT.ll [TRIPLE]: N distinct functions of cold-code shape, each
# called once per round by a driver (cold.c) through the table @funcs.
# Each takes a state (ptr to i64s) and returns an i64: field loads and
# stores, arithmetic, diamonds of branches, and calls of helpers with
# several arguments (so that values live across calls).
import sys, random
n, seed, out = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
R = random.Random(seed)
L = [f'target triple = "{sys.argv[4]}"'] if len(sys.argv) > 4 else []
L.append('declare i64 @helper2(i64, i64)')
L.append('declare i64 @helper4(i64, i64, i64, i64)')
L.append('declare void @note(ptr, i64)')
ops = ['add', 'sub', 'xor', 'and', 'or', 'mul', 'shl', 'lshr']
for k in range(n):
    b = []
    cnt = [0]
    def v():
        cnt[0] += 1
        return f'%v{cnt[0]}'
    vals = []
    def pick():
        return R.choice(vals[-6:]) if R.random() < .8 or len(vals) < 7 else R.choice(vals)
    blocks = []
    cur = ['entry:']
    for j in range(R.randint(3, 6)):
        x = v(); g = v()
        off = R.randint(0, 15)
        cur.append(f'  {g} = getelementptr inbounds i64, ptr %s, i64 {off}')
        cur.append(f'  {x} = load i64, ptr {g}, align 8')
        vals.append(x)
    nb = R.randint(2, 5)
    for d in range(nb):
        # Straight-line work, sometimes a call.
        for j in range(R.randint(4, 10)):
            r = R.random()
            x = v()
            if r < .15:
                a, c = pick(), pick()
                cur.append(f'  {x} = call i64 @helper2(i64 {a}, i64 {c})')
            elif r < .22:
                args = ', '.join(f'i64 {pick()}' for _ in range(4))
                cur.append(f'  {x} = call i64 @helper4({args})')
            elif r < .3:
                g = v()
                cur.append(f'  {g} = getelementptr inbounds i64, ptr %s, i64 {R.randint(0,15)}')
                cur.append(f'  store i64 {pick()}, ptr {g}, align 8')
                cur.append(f'  {x} = add i64 {pick()}, {R.randint(1,99)}')
            else:
                op = R.choice(ops)
                c = str(R.randint(1, 13)) if op in ('shl', 'lshr') or R.random() < .4 else pick()
                cur.append(f'  {x} = {op} i64 {pick()}, {c}')
            vals.append(x)
        # A diamond: a compare, two arms, a phi.
        c = v(); t = f'd{d}t'; e = f'd{d}e'; m = f'd{d}m'
        cur.append(f'  {c} = icmp {R.choice(["ult","sgt","eq","ne"])} i64 {pick()}, {R.randint(0,1000) if R.random()<.5 else pick()}')
        cur.append(f'  br i1 {c}, label %{t}, label %{e}')
        blocks.append(cur)
        x1 = v(); x2 = v()
        a1, a2 = pick(), pick()
        if R.random() < .3:
            blocks.append([f'{t}:', f'  {x1} = call i64 @helper2(i64 {a1}, i64 {a2})', f'  br label %{m}'])
        else:
            blocks.append([f'{t}:', f'  {x1} = {R.choice(ops[:5])} i64 {a1}, {a2}', f'  br label %{m}'])
        if R.random() < .2:
            blocks.append([f'{e}:', f'  call void @note(ptr %s, i64 {a2})', f'  {x2} = sub i64 {a2}, {a1}', f'  br label %{m}'])
        else:
            blocks.append([f'{e}:', f'  {x2} = xor i64 {a2}, {R.randint(1,9999)}', f'  br label %{m}'])
        p = v()
        cur = [f'{m}:', f'  {p} = phi i64 [ {x1}, %{t} ], [ {x2}, %{e} ]']
        vals.append(p)
    acc = vals[-1]
    for x in R.sample(vals, min(4, len(vals))):
        y = v(); cur.append(f'  {y} = add i64 {acc}, {x}'); acc = y
    cur.append(f'  ret i64 {acc}')
    blocks.append(cur)
    L.append(f'define i64 @f{k}(ptr %s) {{')
    for bl in blocks:
        L.extend(bl)
    L.append('}')
L.append(f'@funcs = global [{n} x ptr] [' + ', '.join(f'ptr @f{k}' for k in range(n)) + ']')
L.append(f'@nfuncs = global i64 {n}')
open(out, 'w').write('\n'.join(L) + '\n')
