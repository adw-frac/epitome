FIRRTL version 7.0.0
circuit Counter :%[[
  {
    "class":"firrtl.transforms.DedupGroupAnnotation",
    "target":"~|Counter",
    "group":"Counter"
  }
]]
  layer Verification, bind, "verification" :
    layer Assert, bind, "verification/assert" :
      layer Temporal, inline :
    layer Assume, bind, "verification/assume" :
      layer Temporal, inline :
    layer Cover, bind, "verification/cover" :
      layer Temporal, inline :

  public module Counter : @[Counter.scala 10:7]
    input clock : Clock @[Counter.scala 10:7]
    input reset : UInt<1> @[Counter.scala 10:7]
    output io : { flip en : UInt<1>, count : UInt<8>} @[Counter.scala 11:14]

    regreset reg : UInt<8>, clock, reset, UInt<8>(0h0) @[Counter.scala 15:20]
    when io.en : @[Counter.scala 16:15]
      node _reg_T = add(reg, UInt<1>(0h1)) @[Counter.scala 16:28]
      node _reg_T_1 = tail(_reg_T, 1) @[Counter.scala 16:28]
      connect reg, _reg_T_1 @[Counter.scala 16:21]
    connect io.count, reg @[Counter.scala 17:12]

