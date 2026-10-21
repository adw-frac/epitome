FIRRTL version 6.0.0
; One output per primitive operation, written by hand from the spec,
; to see how firtool lowers each to comb. Output widths follow the
; result-width table of the spec; nodes keep the inferred width.
circuit PrimOps :
  public module PrimOps :
    input a : UInt<8>
    input b : UInt<4>
    input s : SInt<8>
    input t : SInt<4>
    input c : UInt<1>
    output o_add : UInt<9>
    output o_sub : UInt<9>
    output o_mul : UInt<12>
    output o_div : UInt<8>
    output o_rem : UInt<4>
    output o_sdiv : SInt<9>
    output o_srem : SInt<4>
    output o_lt : UInt<1>
    output o_slt : UInt<1>
    output o_pad : UInt<12>
    output o_spad : SInt<12>
    output o_asuint : UInt<8>
    output o_shl : UInt<11>
    output o_shr : UInt<5>
    output o_sshr : SInt<5>
    output o_dshl : UInt<23>
    output o_dshr : UInt<8>
    output o_sdshr : SInt<8>
    output o_cvt : SInt<9>
    output o_neg : SInt<9>
    output o_not : UInt<8>
    output o_and : UInt<8>
    output o_andr : UInt<1>
    output o_orr : UInt<1>
    output o_xorr : UInt<1>
    output o_cat : UInt<13>
    output o_bits : UInt<5>
    output o_head : UInt<3>
    output o_tail : UInt<5>
    output o_mux : UInt<8>
    node n_add = add(a, b)
    connect o_add, n_add
    node n_sub = sub(a, b)
    connect o_sub, n_sub
    node n_mul = mul(a, b)
    connect o_mul, n_mul
    node n_div = div(a, b)
    connect o_div, n_div
    node n_rem = rem(a, b)
    connect o_rem, n_rem
    node n_sdiv = div(s, t)
    connect o_sdiv, n_sdiv
    node n_srem = rem(s, t)
    connect o_srem, n_srem
    node n_lt = lt(a, b)
    connect o_lt, n_lt
    node n_slt = lt(s, t)
    connect o_slt, n_slt
    node n_pad = pad(b, 12)
    connect o_pad, n_pad
    node n_spad = pad(t, 12)
    connect o_spad, n_spad
    node n_asuint = asUInt(s)
    connect o_asuint, n_asuint
    node n_shl = shl(a, 3)
    connect o_shl, n_shl
    node n_shr = shr(a, 3)
    connect o_shr, n_shr
    node n_sshr = shr(s, 3)
    connect o_sshr, n_sshr
    node n_dshl = dshl(a, b)
    connect o_dshl, n_dshl
    node n_dshr = dshr(a, b)
    connect o_dshr, n_dshr
    node n_sdshr = dshr(s, b)
    connect o_sdshr, n_sdshr
    node n_cvt = cvt(a)
    connect o_cvt, n_cvt
    node n_neg = neg(a)
    connect o_neg, n_neg
    node n_not = not(a)
    connect o_not, n_not
    node n_and = and(a, b)
    connect o_and, n_and
    node n_andr = andr(a)
    connect o_andr, n_andr
    node n_orr = orr(a)
    connect o_orr, n_orr
    node n_xorr = xorr(a)
    connect o_xorr, n_xorr
    node n_cat = cat(a, b, c)
    connect o_cat, n_cat
    node n_bits = bits(a, 6, 2)
    connect o_bits, n_bits
    node n_head = head(a, 3)
    connect o_head, n_head
    node n_tail = tail(a, 3)
    connect o_tail, n_tail
    node n_mux = mux(c, a, b)
    connect o_mux, n_mux
