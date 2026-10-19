"""Checks the AArch64 description against Arm's machine-readable
specification, and says how much of the instruction set it covers.

Arm publishes the A-profile architecture as JSON (AARCHMRS, the open-source
package, under the BSD 3-clause license), from the A-Profile Architecture
Exploration Tools downloads at developer.arm.com. Download it and run:

    python3 codegen/targets/aarch64/check_mrs.py path/to/Instructions.json [--missing]

Each entry's encoding (its literal bits, from "enc") must lie inside one of
Arm's A64 encodings: its literal bits must include that encoding's fixed
bits, with the same values. An entry whose literal bits lie inside none is
an error. One that leaves as a field a bit Arm fixes is reported (it can
still be right, if its expressions only ever make Arm's value), and so is
one whose mnemonic is neither Arm's for that encoding nor an alias's.

Then: how many of Arm's encodings the description covers, by kind (base,
floating point and SIMD, the optional extensions, SVE, SME). With
--missing, the base encodings not covered are listed.

The exit status is 1 if there are errors.
"""
import collections
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def arm_encodings(spec):
    """Each A64 encoding: its name, group, fixed bits (mask and value), the
    features it needs, and its mnemonics (its own, then its aliases')."""
    a64 = next(s for s in spec["instructions"] if s["name"] == "A64")
    out = []

    def features(cond):
        found = set()

        def walk(x):
            if isinstance(x, dict):
                if x.get("_type") == "AST.Identifier" and str(x.get("value", "")).startswith("FEAT_"):
                    found.add(x["value"])
                for y in x.values():
                    walk(y)
            elif isinstance(x, list):
                for y in x:
                    walk(y)

        walk(cond)
        return found

    def mnemonic(node):
        for s in (node.get("assembly") or {}).get("symbols", []):
            if s["_type"] == "Instruction.Symbols.Literal":
                return s["value"].split()[0].split(".")[0].lower()
        return "?"

    def walk(node, mask, value, path, feats):
        for f in (node.get("encoding") or {}).get("values", []):
            start, width = f["range"]["start"], f["range"]["width"]
            v = f["value"]["value"].strip("'")
            for k, ch in enumerate(v):
                bit = start + width - 1 - k
                if ch in "01":
                    mask |= 1 << bit
                    if ch == "1":
                        value |= 1 << bit
        feats = feats | features(node.get("condition"))
        if node["_type"] == "Instruction.Instruction":
            names = {mnemonic(node)}
            names |= {mnemonic(c) for c in node.get("children") or [] if c["_type"] == "Instruction.InstructionAlias"}
            out.append(dict(name=node["name"], group=path[1] if len(path) > 1 else "", path=path,
                            mask=mask, value=value, feats=feats, mnemonics=names))
            return
        for c in node.get("children") or []:
            walk(c, mask, value, path + [c["name"]], feats)

    walk(a64, 0, 0, ["A64"], set())
    return out


def kind(e):
    if e["group"] == "sve":
        return "SVE"
    if e["group"] == "sme":
        return "SME"
    f = e["feats"] - {"FEAT_AA64"}
    if e["group"] == "simd_dp" or f & {"FEAT_AdvSIMD", "FEAT_FP"}:
        return "FP and SIMD"
    if not f:
        return "base"
    return "optional extensions"


def our_entries():
    """Each entry of the description with an encoding: its name, file,
    literal bits (mask and value), the bits its fields hold, and its
    mnemonic."""
    out = []
    for path in sorted(glob.glob(os.path.join(HERE, "*.ll"))):
        for line in open(path):
            m = re.match(r'define .*?@([A-Za-z0-9_.]+)\(.*?"enc"="([^"]*)"', line)
            if not m:
                continue
            name, enc = m.groups()
            asm = re.search(r'"asm"="([^"]*)"', line)
            mnem = asm.group(1).split()[0].split(".")[0].split("{")[0].lower() if asm else ""
            mask = value = 0
            pos = 32
            for tok in enc.split():
                if re.fullmatch(r"[01]+", tok):
                    for ch in tok:
                        pos -= 1
                        mask |= 1 << pos
                        if ch == "1":
                            value |= 1 << pos
                else:
                    pos -= int(re.match(r"[A-Za-z0-9_]+:s?(\d+)", tok).group(1))
            if pos != 0:
                sys.exit(f"{name}: an encoding of {32 - pos} bits")
            out.append(dict(name=name, file=os.path.basename(path), mask=mask, value=value, mnemonic=mnem))
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) != 1:
        sys.exit(__doc__)
    spec = json.load(open(args[0]))
    print(f"Arm's specification: {spec['_meta']['version']['ref']}")
    arm = arm_encodings(spec)
    ours = our_entries()
    errors = []
    looser = []
    misnamed = []
    covered = collections.defaultdict(list)
    for o in ours:
        inside = [a for a in arm if a["mask"] & o["mask"] == a["mask"] and o["value"] & a["mask"] == a["value"]]
        if not inside:
            # Agreeing where both fix bits, but leaving some of Arm's as a
            # field: the one sharing the most fixed bits.
            near = [a for a in arm if (o["value"] ^ a["value"]) & o["mask"] & a["mask"] == 0]
            if not near:
                errors.append(f"{o['file']}: {o['name']} lies inside no Arm encoding")
                continue
            most = max(bin(a["mask"] & o["mask"]).count("1") for a in near)
            near = [a for a in near if bin(a["mask"] & o["mask"]).count("1") == most]
            if len(near) != 1:
                errors.append(f"{o['file']}: {o['name']} could be any of {', '.join(a['name'] for a in near)}")
                continue
            looser.append((o, near[0]))
            inside = near
        best = max(inside, key=lambda a: bin(a["mask"]).count("1"))
        covered[best["name"]].append(o["name"])
        # `sxtl2` is Arm's `SXTL{2}`: the second half, by the Q bit.
        names = best["mnemonics"] | {m + "2" for m in best["mnemonics"]}
        if o["mnemonic"] and o["mnemonic"] not in names:
            misnamed.append(f"{o['file']}: {o['name']} is written `{o['mnemonic']}`, "
                            f"Arm's {best['name']} is {'/'.join(sorted(best['mnemonics']))}")

    total = collections.Counter(k for k in map(kind, arm))
    have = collections.Counter(kind(a) for a in arm if a["name"] in covered)
    print(f"\n{len(ours)} entries; {len(arm)} A64 encodings in Arm's specification\n")
    print(f"{'':22s} covered")
    for k in ["base", "FP and SIMD", "optional extensions", "SVE", "SME"]:
        print(f"{k:22s} {have[k]:5d} of {total[k]:5d}")
    print(f"{'all':22s} {sum(have.values()):5d} of {sum(total.values()):5d}")
    if looser:
        print(f"\n{len(looser)} entries leave as a field bits Arm fixes:")
        for o, a in looser:
            bits = a["mask"] & ~o["mask"]
            print(f"  {o['file']}: {o['name']} ({a['name']}; bits {bits:#010x})")
    if misnamed:
        print(f"\n{len(misnamed)} entries with another mnemonic than Arm's:")
        for m in misnamed:
            print("  " + m)
    if "--missing" in sys.argv:
        print("\nBase encodings not covered:")
        by = collections.defaultdict(list)
        for a in arm:
            if kind(a) == "base" and a["name"] not in covered:
                by[a["path"][2] if len(a["path"]) > 2 else a["group"]].append(a["name"])
        for g, names in sorted(by.items()):
            print(f"  {g}: {' '.join(names)}")
    if errors:
        print(f"\n{len(errors)} errors:")
        for e in errors:
            print("  " + e)
        sys.exit(1)


main()
