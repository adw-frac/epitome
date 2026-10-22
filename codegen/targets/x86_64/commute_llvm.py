#!/usr/bin/env python3
"""Finds the VEX operations llvm-mc commutes: for each entry of three
registers whose last source is in ModRM.rm, assembles it with that source
xmm9 (needing VEX's three-byte form) and the other xmm1, and lists those
llvm-mc writes with the two-byte form (C5) with xmm9 in vvvv: it swapped
them.

Usage: commute_llvm.py ENTRIES.ll LLVM_MC LLVM_OBJDUMP > commute.txt
"""

import re
import subprocess
import sys
import tempfile

entries_ll, mc, objdump = sys.argv[1:4]
NAMES = {'x': '%xmm{}', 'y': '%ymm{}'}

probes = []
for line in open(entries_ll):
    m = re.match(r'define void @(\w+)\((.*?)\) "enc"="([^"]*)" "asm"="([^"]*)"', line)
    if not m:
        continue
    name, params, enc, asm = m.groups()
    ps = re.findall(r'"reg"="(\w+)" %(\w+)', params)
    if len(ps) != 3 or 'vex(' not in enc or not all(c in NAMES for c, _ in ps) or len(params.split(', ')) != 3:
        continue
    # o0 the rm source, o1 vvvv, o2 the destination (in ModRM.reg).
    if not re.search(r'rm:3=o0&7', enc) or 'vex(o2, 0, o0' not in enc:
        continue
    text = asm
    for (cls, op), k in zip(ps, (9, 1, 2)):
        text = text.replace('{' + op + '}', NAMES[cls].format(k))
    probes.append((name, text))

with tempfile.TemporaryDirectory() as tmp:
    open(f'{tmp}/s.s', 'w').write('\t.text\n' + ''.join(f'p{k}:\n\t{t}\n' for k, (_, t) in enumerate(probes)))
    subprocess.run([mc, '-triple=x86_64-linux-gnu', '-filetype=obj', '-o', f'{tmp}/s.o', f'{tmp}/s.s'],
                   capture_output=True)
    dump = subprocess.run([objdump, '-d', f'{tmp}/s.o'], capture_output=True, text=True).stdout

cur = None
first = {}
second = {}
for l in dump.splitlines():
    m = re.match(r'[0-9a-f]+ <p(\d+)>:', l)
    if m:
        cur = int(m.group(1))
        continue
    m = re.match(r'\s*[0-9a-f]+:\s+([0-9a-f]{2}) ([0-9a-f]{2})', l)
    if m and cur is not None and cur not in first:
        first[cur], second[cur] = m.group(1), int(m.group(2), 16)
# Swapped: two bytes, with xmm9 in vvvv (stored inverted: 6).
for k, (name, _) in enumerate(probes):
    if first.get(k) == 'c5' and (second[k] >> 3) & 15 == 6:
        print(name)
