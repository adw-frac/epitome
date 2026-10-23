FIRRTL version 7.0.0
circuit Fir :%[[
  {
    "class":"firrtl.transforms.DedupGroupAnnotation",
    "target":"~|Fir",
    "group":"Fir"
  }
]]
  layer Verification, bind, "verification" :
    layer Assert, bind, "verification/assert" :
      layer Temporal, inline :
    layer Assume, bind, "verification/assume" :
      layer Temporal, inline :
    layer Cover, bind, "verification/cover" :
      layer Temporal, inline :

  public module Fir : @[Fir.scala 12:7]
    input clock : Clock @[Fir.scala 12:7]
    input reset : UInt<1> @[Fir.scala 12:7]
    output io : { flip in : UInt<8>, flip valid : UInt<1>, out : UInt<16>} @[Fir.scala 13:14]

    regreset taps_1 : UInt<8>, clock, reset, UInt<8>(0h0) @[Fir.scala 19:63]
    regreset taps_2 : UInt<8>, clock, reset, UInt<8>(0h0) @[Fir.scala 19:63]
    regreset taps_3 : UInt<8>, clock, reset, UInt<8>(0h0) @[Fir.scala 19:63]
    when io.valid : @[Fir.scala 20:18]
      connect taps_1, io.in @[Fir.scala 21:44]
      connect taps_2, taps_1 @[Fir.scala 21:44]
      connect taps_3, taps_2 @[Fir.scala 21:44]
    node products_0 = mul(io.in, UInt<1>(0h1)) @[Fir.scala 23:58]
    node products_1 = mul(taps_1, UInt<2>(0h3)) @[Fir.scala 23:58]
    node products_2 = mul(taps_2, UInt<2>(0h3)) @[Fir.scala 23:58]
    node products_3 = mul(taps_3, UInt<1>(0h1)) @[Fir.scala 23:58]
    node _io_out_T = add(products_0, products_1) @[Fir.scala 24:31]
    node _io_out_T_1 = add(_io_out_T, products_2) @[Fir.scala 24:31]
    node _io_out_T_2 = add(_io_out_T_1, products_3) @[Fir.scala 24:31]
    connect io.out, _io_out_T_2 @[Fir.scala 24:10]

