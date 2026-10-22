#!/usr/bin/env python3
"""Finds each raw entry's AT&T template (see gen_xed.py): assembles one line
of every entry with epitome-as (the entries' templates are placeholders),
disassembles the object with llvm-objdump, and turns each line read back
into a template by putting the operands' names where their sample values
are. Entries llvm-objdump does not read (`(bad)`), or reads as a different
length, are reported and left out.

Usage: discover_att.py TARGET_DIR EPITOME_AS OBJDUMP > att.txt
"""

import re
import subprocess
import sys
import tempfile

target, epitome_as, objdump = sys.argv[1:4]

# Sample values: chosen apart from each other and from fixed registers.
REGS = {
    'r64': ['%rax', '%rcx', '%rdx', '%rbx', '%rsp', '%rbp', '%rsi', '%rdi'] + [f'%r{i}' for i in range(8, 16)],
    'r32': ['%eax', '%ecx', '%edx', '%ebx', '%esp', '%ebp', '%esi', '%edi'] + [f'%r{i}d' for i in range(8, 16)],
    'r16': ['%ax', '%cx', '%dx', '%bx', '%sp', '%bp', '%si', '%di'] + [f'%r{i}w' for i in range(8, 16)],
    'r8': ['%al', '%cl', '%dl', '%bl', '%spl', '%bpl', '%sil', '%dil'] + [f'%r{i}b' for i in range(8, 16)],
    'x': [f'%xmm{i}' for i in range(16)], 'y': [f'%ymm{i}' for i in range(16)],
    'xe': [f'%xmm{i}' for i in range(32)], 'ye': [f'%ymm{i}' for i in range(32)], 'z': [f'%zmm{i}' for i in range(32)],
    'k': [f'%k{i}' for i in range(8)], 'mm': [f'%mm{i}' for i in range(8)], 'st': [f'%st({i})' for i in range(8)],
    'seg': ['%es', '%cs', '%ss', '%ds', '%fs', '%gs'], 'cr': [f'%cr{i}' for i in range(16)],
    'dr': [f'%dr{i}' for i in range(16)], 'tmm': [f'%tmm{i}' for i in range(8)],
}
# The register each operand gets, by name: (in a class of 16 or more, of
# 8, of fewer).
# Low registers first, needing no REX bit, so that lengths compare fairly;
# then, for entries those do not fit, high ones.
PICKS = [{'r': (3, 3, 3), 'b': (2, 2, 2), 'n': (1, 1, 1), 'e': (5, 5, 4), 'k': (5, 5, 5)},
         {'r': (10, 3, 3), 'b': (8, 5, 4), 'n': (13, 6, 5), 'e': (12, 7, 2), 'k': (5, 5, 5)}]
IMMS = {'c': 0x2a, 'c2': 0x11}

entries = []
for path in sorted(__import__('glob').glob(target + '/*.ll')):
    for line in open(path):
        m = re.match(r'define void @(\w+)\((.*?)\) "enc"="[^"]*" "asm"="([^"]*)"', line)
        if not m or not m.group(3).startswith('xf'):
            continue
        name, params, asm = m.groups()
        ops = []
        for p in filter(None, params.split(', ')):
            pm = re.match(r'\w+ "(\w+)"(?:="(\w+)")? %([\w.]+)', p)
            ops.append(pm.groups())
        entries.append((name, ops, asm))


def value(kind, cls, op, pick=0):
    """The sample text of an operand, and how llvm-objdump writes it."""
    if kind == 'reg':
        regs = REGS[cls]
        if op.startswith('m.'):
            k = {'m.base': 6, 'm.index': 7}[op]
        else:
            pick = PICKS[pick][op]
            k = pick[0] if len(regs) >= 16 else pick[1] if len(regs) >= 8 else pick[2]
        return regs[k]
    if kind == 'imm':
        if op == 'm.disp':
            return '64'
        if op == 'm.scale':
            return '4'
        return str(IMMS[op])
    if kind == 'sym':
        return 'sym'
    return '.Lt'


def run(todo, pick):
    """Assembles the entries `todo` with registers `pick`, and reads them
    back: the bytes and lines read at each, and those that did not
    assemble."""
    lines = ['\t.text']
    for k in todo:
        name, ops, asm = entries[k]
        text = asm.split(' ', 1)[1] if ' ' in asm else ''
        for kind, cls, op in ops:
            v = f'e{k}' if kind == 'label' else value(kind, cls, op, pick)
            text = text.replace('{' + op + '}', v)
        # A symbol at each: llvm-objdump starts reading afresh there.
        lines.append(f'e{k}:\n\t{asm.split(" ", 1)[0]} {text}')
    with tempfile.TemporaryDirectory() as tmp:
        src, obj = f'{tmp}/s.s', f'{tmp}/s.o'
        open(src, 'w').write('\n'.join(lines) + '\n')
        r = subprocess.run([epitome_as, f'--target={target}', '--format=elf', '--max-errors=100000', '-o', obj, src],
                           capture_output=True, text=True)
        if r.returncode:
            # Leave out the lines that do not assemble, and go again.
            bad = {int(m) for m in re.findall(r'line (\d+):', r.stderr)}
            failed = {todo[(n - 2) // 2] for n in bad}
            if not failed:
                sys.exit(r.stderr)
            length, read, more = run([k for k in todo if k not in failed], pick)
            return length, read, failed | more
        dump = subprocess.run([objdump, '-d', '--no-show-raw-insn', obj], capture_output=True, text=True).stdout
        raw = subprocess.run([objdump, '-d', obj], capture_output=True, text=True).stdout
    # The bytes at each symbol (one instruction, with any prefix
    # llvm-objdump writes apart).
    length, read, cur = {}, {}, None
    for l in raw.splitlines():
        m = re.match(r'[0-9a-f]+ <e(\d+)>:', l)
        if m:
            cur = int(m.group(1))
            continue
        m = re.match(r'\s*[0-9a-f]+:\s+((?:[0-9a-f]{2} ?)+)', l)
        if m and cur is not None:
            length[cur] = length.get(cur, 0) + len(m.group(1).split())
    # Each symbol's instructions as read back: one, if it read our length.
    cur = None
    for l in dump.splitlines():
        m = re.match(r'[0-9a-f]+ <e(\d+)>:', l)
        if m:
            cur = int(m.group(1))
            read[cur] = []
            continue
        m = re.match(r'\s*[0-9a-f]+:\s*(.*)', l)
        if m and cur is not None:
            read[cur].append(m.group(1).split('#')[0].strip())
    return length, read, set()


length, read, failed = run(list(range(len(entries))), 0)
picked = {k: 0 for k in read}
if failed:
    l2, r2, failed = run(sorted(failed), 1)
    length.update(l2)
    read.update(r2)
    picked.update({k: 1 for k in r2})
for k in failed:
    sys.stderr.write(f'{entries[k][0]}: does not assemble with either set of registers\n')


def template(text, ops, pick):
    mn, *rest = text.split(None, 1)
    rest = rest[0].strip() if rest else ''
    while mn in ('lock', 'rep', 'repe', 'repne', 'data16', 'notrack') and rest:
        nxt, *rest = rest.split(None, 1)
        mn += ' ' + nxt
        rest = rest[0].strip() if rest else ''
    ops_text = []
    depth, cur = 0, ''
    for c in rest:
        if c in '({':
            depth += 1
        if c in ')}':
            depth -= 1
        if c == ',' and depth == 0:
            ops_text.append(cur.strip())
            cur = ''
        else:
            cur += c
    if cur.strip():
        ops_text.append(cur.strip())
    vals = {op: (kind, cls) for kind, cls, op in ops}
    out = []
    for t in ops_text:
        star = '*' if t.startswith('*') else ''
        t0 = t.lstrip('*')
        done = None
        for kind, cls, op in ops:
            if kind == 'reg' and not op.startswith('m.') and t0 == value(kind, cls, op, pick):
                done = '{' + op + '}'
            if kind == 'imm' and not op.startswith('m.') and re.fullmatch(r'\$(0x[0-9a-f]+|\d+)', t0) \
                    and int(t0[1:], 0) == IMMS[op]:
                done = '${' + op + '}'
            if kind == 'label' and re.match(r'(0x)?[0-9a-f]+( <.*>)?$', t0):
                done = '{' + op + '}'
        if done is None and 'm.base' in vals:
            if 'm.index' in vals and re.fullmatch(r'(%\w+:)?0x40\(%rsi,%rdi,4\)', t0):
                done = t0.split('0x40')[0] + '{m.disp}({m.base},{m.index},{m.scale})'
            elif 'm.index' not in vals and re.fullmatch(r'(%\w+:)?0x40\(%rsi\)', t0):
                done = t0.split('0x40')[0] + '{m.disp}({m.base})'
        if done is None and 'm.sym' in vals and re.fullmatch(r'(%\w+:)?(0x0)?\(%rip\)', t0):
            done = t0.split('(')[0].replace('0x0', '') + '{m.sym}(%rip)'
        if done is None and 'm.sym' in vals and re.fullmatch(r'(%\w+:)?(0x0)?\(%rip\)', t0):
            done = '{m.sym}(%rip)'
        out.append(star + (done if done is not None else t0))
    used = set(re.findall(r'\{([\w.]+)\}', ' '.join(out)))
    missing = [op for _, _, op in ops if op not in used and not (op.startswith('m.') and (
        ('m.base' in used) or ('m.sym' in used)))]
    if missing:
        return None, f'operands not found: {missing}'
    return (mn + (' ' + ', '.join(out) if out else '')), None


bad = 0
for k, (name, ops, asm) in enumerate(entries):
    got = read.get(k, [])
    # Prefixes llvm-objdump writes on lines of their own.
    while len(got) > 1 and got[0] in ('lock', 'rep', 'repe', 'repne', 'data16', 'notrack'):
        got = [got[0] + ' ' + got[1]] + got[2:]
    if len(got) != 1:
        sys.stderr.write(f'{name}: read back as {got}\n')
        bad += 1
        continue
    text = got[0]
    if text.startswith('(bad)') or text.startswith('<unknown>') or not text:
        sys.stderr.write(f'{name}: not read: {text}\n')
        bad += 1
        continue
    tpl, err = template(text, ops, picked.get(k, 0))
    if tpl is None:
        sys.stderr.write(f'{name}: `{text}`: {err}\n')
        bad += 1
        continue
    print(f'{name}\t{tpl}\t{length.get(k, 0)}')
sys.stderr.write(f'{len(entries)} entries, {bad} without a template\n')
