FIRRTL version 7.0.0
circuit GCD :%[[
  {
    "class":"firrtl.transforms.DedupGroupAnnotation",
    "target":"~|GCD",
    "group":"GCD"
  }
]]
  layer Verification, bind, "verification" :
    layer Assert, bind, "verification/assert" :
      layer Temporal, inline :
    layer Assume, bind, "verification/assume" :
      layer Temporal, inline :
    layer Cover, bind, "verification/cover" :
      layer Temporal, inline :

  public module GCD : @[GCD.scala 10:7]
    input clock : Clock @[GCD.scala 10:7]
    input reset : UInt<1> @[GCD.scala 10:7]
    output io : { flip value1 : UInt<16>, flip value2 : UInt<16>, flip loadingValues : UInt<1>, outputGCD : UInt<16>, outputValid : UInt<1>} @[GCD.scala 11:14]

    reg x : UInt, clock @[GCD.scala 18:14]
    reg y : UInt, clock @[GCD.scala 19:14]
    node _T = gt(x, y) @[GCD.scala 20:10]
    when _T : @[GCD.scala 20:15]
      node _x_T = sub(x, y) @[GCD.scala 20:24]
      node _x_T_1 = tail(_x_T, 1) @[GCD.scala 20:24]
      connect x, _x_T_1 @[GCD.scala 20:19]
    else :
      node _y_T = sub(y, x) @[GCD.scala 21:25]
      node _y_T_1 = tail(_y_T, 1) @[GCD.scala 21:25]
      connect y, _y_T_1 @[GCD.scala 21:20]
    when io.loadingValues : @[GCD.scala 22:26]
      connect x, io.value1 @[GCD.scala 23:7]
      connect y, io.value2 @[GCD.scala 24:7]
    connect io.outputGCD, x @[GCD.scala 26:18]
    node _io_outputValid_T = eq(y, UInt<1>(0h0)) @[GCD.scala 27:23]
    connect io.outputValid, _io_outputValid_T @[GCD.scala 27:18]

