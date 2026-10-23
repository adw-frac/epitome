#loc = loc("./firrtl/primops/PrimOps.parse.mlir":3:31)
#loc1 = loc("./firrtl/primops/PrimOps.parse.mlir":3:55)
#loc2 = loc("./firrtl/primops/PrimOps.parse.mlir":3:79)
#loc3 = loc("./firrtl/primops/PrimOps.parse.mlir":3:103)
#loc4 = loc("./firrtl/primops/PrimOps.parse.mlir":3:127)
#loc5 = loc("./firrtl/primops/PrimOps.parse.mlir":3:152)
#loc6 = loc("./firrtl/primops/PrimOps.parse.mlir":3:181)
#loc7 = loc("./firrtl/primops/PrimOps.parse.mlir":3:210)
#loc8 = loc("./firrtl/primops/PrimOps.parse.mlir":3:240)
#loc9 = loc("./firrtl/primops/PrimOps.parse.mlir":3:269)
#loc10 = loc("./firrtl/primops/PrimOps.parse.mlir":3:298)
#loc11 = loc("./firrtl/primops/PrimOps.parse.mlir":3:328)
#loc12 = loc("./firrtl/primops/PrimOps.parse.mlir":3:358)
#loc13 = loc("./firrtl/primops/PrimOps.parse.mlir":3:386)
#loc14 = loc("./firrtl/primops/PrimOps.parse.mlir":3:415)
#loc15 = loc("./firrtl/primops/PrimOps.parse.mlir":3:445)
#loc16 = loc("./firrtl/primops/PrimOps.parse.mlir":3:476)
#loc17 = loc("./firrtl/primops/PrimOps.parse.mlir":3:508)
#loc18 = loc("./firrtl/primops/PrimOps.parse.mlir":3:538)
#loc19 = loc("./firrtl/primops/PrimOps.parse.mlir":3:567)
#loc20 = loc("./firrtl/primops/PrimOps.parse.mlir":3:597)
#loc21 = loc("./firrtl/primops/PrimOps.parse.mlir":3:628)
#loc22 = loc("./firrtl/primops/PrimOps.parse.mlir":3:658)
#loc23 = loc("./firrtl/primops/PrimOps.parse.mlir":3:689)
#loc24 = loc("./firrtl/primops/PrimOps.parse.mlir":3:718)
#loc25 = loc("./firrtl/primops/PrimOps.parse.mlir":3:747)
#loc26 = loc("./firrtl/primops/PrimOps.parse.mlir":3:776)
#loc27 = loc("./firrtl/primops/PrimOps.parse.mlir":3:805)
#loc28 = loc("./firrtl/primops/PrimOps.parse.mlir":3:835)
#loc29 = loc("./firrtl/primops/PrimOps.parse.mlir":3:864)
#loc30 = loc("./firrtl/primops/PrimOps.parse.mlir":3:894)
#loc31 = loc("./firrtl/primops/PrimOps.parse.mlir":3:924)
#loc32 = loc("./firrtl/primops/PrimOps.parse.mlir":3:954)
#loc33 = loc("./firrtl/primops/PrimOps.parse.mlir":3:984)
#loc34 = loc("./firrtl/primops/PrimOps.parse.mlir":3:1014)
"builtin.module"() ({
  "firrtl.circuit"() <{annotations = [], name = "PrimOps"}> ({
    "firrtl.module"() <{annotations = [], convention = #firrtl<convention scalarized>, domainInfo = [], layers = [], portAnnotations = [], portDirections = array<i1: false, false, false, false, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true>, portLocations = [#loc, #loc1, #loc2, #loc3, #loc4, #loc5, #loc6, #loc7, #loc8, #loc9, #loc10, #loc11, #loc12, #loc13, #loc14, #loc15, #loc16, #loc17, #loc18, #loc19, #loc20, #loc21, #loc22, #loc23, #loc24, #loc25, #loc26, #loc27, #loc28, #loc29, #loc30, #loc31, #loc32, #loc33, #loc34], portNames = ["a", "b", "s", "t", "c", "o_add", "o_sub", "o_mul", "o_div", "o_rem", "o_sdiv", "o_srem", "o_lt", "o_slt", "o_pad", "o_spad", "o_asuint", "o_shl", "o_shr", "o_sshr", "o_dshl", "o_dshr", "o_sdshr", "o_cvt", "o_neg", "o_not", "o_and", "o_andr", "o_orr", "o_xorr", "o_cat", "o_bits", "o_head", "o_tail", "o_mux"], portSymbols = [], portTypes = [!firrtl.uint<8>, !firrtl.uint<4>, !firrtl.sint<8>, !firrtl.sint<4>, !firrtl.uint<1>, !firrtl.uint<9>, !firrtl.uint<9>, !firrtl.uint<12>, !firrtl.uint<8>, !firrtl.uint<4>, !firrtl.sint<9>, !firrtl.sint<4>, !firrtl.uint<1>, !firrtl.uint<1>, !firrtl.uint<12>, !firrtl.sint<12>, !firrtl.uint<8>, !firrtl.uint<11>, !firrtl.uint<5>, !firrtl.sint<5>, !firrtl.uint<23>, !firrtl.uint<8>, !firrtl.sint<8>, !firrtl.sint<9>, !firrtl.sint<9>, !firrtl.uint<8>, !firrtl.uint<8>, !firrtl.uint<1>, !firrtl.uint<1>, !firrtl.uint<1>, !firrtl.uint<13>, !firrtl.uint<5>, !firrtl.uint<3>, !firrtl.uint<5>, !firrtl.uint<8>], sym_name = "PrimOps"}> ({
    ^bb0(%arg0: !firrtl.uint<8>, %arg1: !firrtl.uint<4>, %arg2: !firrtl.sint<8>, %arg3: !firrtl.sint<4>, %arg4: !firrtl.uint<1>, %arg5: !firrtl.uint<9>, %arg6: !firrtl.uint<9>, %arg7: !firrtl.uint<12>, %arg8: !firrtl.uint<8>, %arg9: !firrtl.uint<4>, %arg10: !firrtl.sint<9>, %arg11: !firrtl.sint<4>, %arg12: !firrtl.uint<1>, %arg13: !firrtl.uint<1>, %arg14: !firrtl.uint<12>, %arg15: !firrtl.sint<12>, %arg16: !firrtl.uint<8>, %arg17: !firrtl.uint<11>, %arg18: !firrtl.uint<5>, %arg19: !firrtl.sint<5>, %arg20: !firrtl.uint<23>, %arg21: !firrtl.uint<8>, %arg22: !firrtl.sint<8>, %arg23: !firrtl.sint<9>, %arg24: !firrtl.sint<9>, %arg25: !firrtl.uint<8>, %arg26: !firrtl.uint<8>, %arg27: !firrtl.uint<1>, %arg28: !firrtl.uint<1>, %arg29: !firrtl.uint<1>, %arg30: !firrtl.uint<13>, %arg31: !firrtl.uint<5>, %arg32: !firrtl.uint<3>, %arg33: !firrtl.uint<5>, %arg34: !firrtl.uint<8>):
      %0 = "firrtl.add"(%arg0, %arg1) : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<9>
      %1 = "firrtl.node"(%0) <{annotations = [], name = "n_add", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<9>) -> !firrtl.uint<9>
      "firrtl.matchingconnect"(%arg5, %1) : (!firrtl.uint<9>, !firrtl.uint<9>) -> ()
      %2 = "firrtl.sub"(%arg0, %arg1) : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<9>
      %3 = "firrtl.node"(%2) <{annotations = [], name = "n_sub", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<9>) -> !firrtl.uint<9>
      "firrtl.matchingconnect"(%arg6, %3) : (!firrtl.uint<9>, !firrtl.uint<9>) -> ()
      %4 = "firrtl.mul"(%arg0, %arg1) : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<12>
      %5 = "firrtl.node"(%4) <{annotations = [], name = "n_mul", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<12>) -> !firrtl.uint<12>
      "firrtl.matchingconnect"(%arg7, %5) : (!firrtl.uint<12>, !firrtl.uint<12>) -> ()
      %6 = "firrtl.div"(%arg0, %arg1) : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<8>
      %7 = "firrtl.node"(%6) <{annotations = [], name = "n_div", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%arg8, %7) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      %8 = "firrtl.rem"(%arg0, %arg1) : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<4>
      %9 = "firrtl.node"(%8) <{annotations = [], name = "n_rem", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<4>) -> !firrtl.uint<4>
      "firrtl.matchingconnect"(%arg9, %9) : (!firrtl.uint<4>, !firrtl.uint<4>) -> ()
      %10 = "firrtl.div"(%arg2, %arg3) : (!firrtl.sint<8>, !firrtl.sint<4>) -> !firrtl.sint<9>
      %11 = "firrtl.node"(%10) <{annotations = [], name = "n_sdiv", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.sint<9>) -> !firrtl.sint<9>
      "firrtl.matchingconnect"(%arg10, %11) : (!firrtl.sint<9>, !firrtl.sint<9>) -> ()
      %12 = "firrtl.rem"(%arg2, %arg3) : (!firrtl.sint<8>, !firrtl.sint<4>) -> !firrtl.sint<4>
      %13 = "firrtl.node"(%12) <{annotations = [], name = "n_srem", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.sint<4>) -> !firrtl.sint<4>
      "firrtl.matchingconnect"(%arg11, %13) : (!firrtl.sint<4>, !firrtl.sint<4>) -> ()
      %14 = "firrtl.lt"(%arg0, %arg1) : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<1>
      %15 = "firrtl.node"(%14) <{annotations = [], name = "n_lt", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<1>) -> !firrtl.uint<1>
      "firrtl.matchingconnect"(%arg12, %15) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
      %16 = "firrtl.lt"(%arg2, %arg3) : (!firrtl.sint<8>, !firrtl.sint<4>) -> !firrtl.uint<1>
      %17 = "firrtl.node"(%16) <{annotations = [], name = "n_slt", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<1>) -> !firrtl.uint<1>
      "firrtl.matchingconnect"(%arg13, %17) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
      %18 = "firrtl.pad"(%arg1) <{amount = 12 : i32}> : (!firrtl.uint<4>) -> !firrtl.uint<12>
      %19 = "firrtl.node"(%18) <{annotations = [], name = "n_pad", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<12>) -> !firrtl.uint<12>
      "firrtl.matchingconnect"(%arg14, %19) : (!firrtl.uint<12>, !firrtl.uint<12>) -> ()
      %20 = "firrtl.pad"(%arg3) <{amount = 12 : i32}> : (!firrtl.sint<4>) -> !firrtl.sint<12>
      %21 = "firrtl.node"(%20) <{annotations = [], name = "n_spad", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.sint<12>) -> !firrtl.sint<12>
      "firrtl.matchingconnect"(%arg15, %21) : (!firrtl.sint<12>, !firrtl.sint<12>) -> ()
      %22 = "firrtl.asUInt"(%arg2) : (!firrtl.sint<8>) -> !firrtl.uint<8>
      %23 = "firrtl.node"(%22) <{annotations = [], name = "n_asuint", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%arg16, %23) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      %24 = "firrtl.shl"(%arg0) <{amount = 3 : i32}> : (!firrtl.uint<8>) -> !firrtl.uint<11>
      %25 = "firrtl.node"(%24) <{annotations = [], name = "n_shl", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<11>) -> !firrtl.uint<11>
      "firrtl.matchingconnect"(%arg17, %25) : (!firrtl.uint<11>, !firrtl.uint<11>) -> ()
      %26 = "firrtl.shr"(%arg0) <{amount = 3 : i32}> : (!firrtl.uint<8>) -> !firrtl.uint<5>
      %27 = "firrtl.node"(%26) <{annotations = [], name = "n_shr", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<5>) -> !firrtl.uint<5>
      "firrtl.matchingconnect"(%arg18, %27) : (!firrtl.uint<5>, !firrtl.uint<5>) -> ()
      %28 = "firrtl.shr"(%arg2) <{amount = 3 : i32}> : (!firrtl.sint<8>) -> !firrtl.sint<5>
      %29 = "firrtl.node"(%28) <{annotations = [], name = "n_sshr", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.sint<5>) -> !firrtl.sint<5>
      "firrtl.matchingconnect"(%arg19, %29) : (!firrtl.sint<5>, !firrtl.sint<5>) -> ()
      %30 = "firrtl.dshl"(%arg0, %arg1) : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<23>
      %31 = "firrtl.node"(%30) <{annotations = [], name = "n_dshl", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<23>) -> !firrtl.uint<23>
      "firrtl.matchingconnect"(%arg20, %31) : (!firrtl.uint<23>, !firrtl.uint<23>) -> ()
      %32 = "firrtl.dshr"(%arg0, %arg1) : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<8>
      %33 = "firrtl.node"(%32) <{annotations = [], name = "n_dshr", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%arg21, %33) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      %34 = "firrtl.dshr"(%arg2, %arg1) : (!firrtl.sint<8>, !firrtl.uint<4>) -> !firrtl.sint<8>
      %35 = "firrtl.node"(%34) <{annotations = [], name = "n_sdshr", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.sint<8>) -> !firrtl.sint<8>
      "firrtl.matchingconnect"(%arg22, %35) : (!firrtl.sint<8>, !firrtl.sint<8>) -> ()
      %36 = "firrtl.cvt"(%arg0) : (!firrtl.uint<8>) -> !firrtl.sint<9>
      %37 = "firrtl.node"(%36) <{annotations = [], name = "n_cvt", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.sint<9>) -> !firrtl.sint<9>
      "firrtl.matchingconnect"(%arg23, %37) : (!firrtl.sint<9>, !firrtl.sint<9>) -> ()
      %38 = "firrtl.neg"(%arg0) : (!firrtl.uint<8>) -> !firrtl.sint<9>
      %39 = "firrtl.node"(%38) <{annotations = [], name = "n_neg", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.sint<9>) -> !firrtl.sint<9>
      "firrtl.matchingconnect"(%arg24, %39) : (!firrtl.sint<9>, !firrtl.sint<9>) -> ()
      %40 = "firrtl.not"(%arg0) : (!firrtl.uint<8>) -> !firrtl.uint<8>
      %41 = "firrtl.node"(%40) <{annotations = [], name = "n_not", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%arg25, %41) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      %42 = "firrtl.and"(%arg0, %arg1) : (!firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<8>
      %43 = "firrtl.node"(%42) <{annotations = [], name = "n_and", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%arg26, %43) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
      %44 = "firrtl.andr"(%arg0) : (!firrtl.uint<8>) -> !firrtl.uint<1>
      %45 = "firrtl.node"(%44) <{annotations = [], name = "n_andr", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<1>) -> !firrtl.uint<1>
      "firrtl.matchingconnect"(%arg27, %45) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
      %46 = "firrtl.orr"(%arg0) : (!firrtl.uint<8>) -> !firrtl.uint<1>
      %47 = "firrtl.node"(%46) <{annotations = [], name = "n_orr", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<1>) -> !firrtl.uint<1>
      "firrtl.matchingconnect"(%arg28, %47) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
      %48 = "firrtl.xorr"(%arg0) : (!firrtl.uint<8>) -> !firrtl.uint<1>
      %49 = "firrtl.node"(%48) <{annotations = [], name = "n_xorr", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<1>) -> !firrtl.uint<1>
      "firrtl.matchingconnect"(%arg29, %49) : (!firrtl.uint<1>, !firrtl.uint<1>) -> ()
      %50 = "firrtl.cat"(%arg0, %arg1, %arg4) : (!firrtl.uint<8>, !firrtl.uint<4>, !firrtl.uint<1>) -> !firrtl.uint<13>
      %51 = "firrtl.node"(%50) <{annotations = [], name = "n_cat", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<13>) -> !firrtl.uint<13>
      "firrtl.matchingconnect"(%arg30, %51) : (!firrtl.uint<13>, !firrtl.uint<13>) -> ()
      %52 = "firrtl.bits"(%arg0) <{hi = 6 : i32, lo = 2 : i32}> : (!firrtl.uint<8>) -> !firrtl.uint<5>
      %53 = "firrtl.node"(%52) <{annotations = [], name = "n_bits", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<5>) -> !firrtl.uint<5>
      "firrtl.matchingconnect"(%arg31, %53) : (!firrtl.uint<5>, !firrtl.uint<5>) -> ()
      %54 = "firrtl.head"(%arg0) <{amount = 3 : i32}> : (!firrtl.uint<8>) -> !firrtl.uint<3>
      %55 = "firrtl.node"(%54) <{annotations = [], name = "n_head", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<3>) -> !firrtl.uint<3>
      "firrtl.matchingconnect"(%arg32, %55) : (!firrtl.uint<3>, !firrtl.uint<3>) -> ()
      %56 = "firrtl.tail"(%arg0) <{amount = 3 : i32}> : (!firrtl.uint<8>) -> !firrtl.uint<5>
      %57 = "firrtl.node"(%56) <{annotations = [], name = "n_tail", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<5>) -> !firrtl.uint<5>
      "firrtl.matchingconnect"(%arg33, %57) : (!firrtl.uint<5>, !firrtl.uint<5>) -> ()
      %58 = "firrtl.mux"(%arg4, %arg0, %arg1) : (!firrtl.uint<1>, !firrtl.uint<8>, !firrtl.uint<4>) -> !firrtl.uint<8>
      %59 = "firrtl.node"(%58) <{annotations = [], name = "n_mux", nameKind = #firrtl<name_kind interesting_name>}> : (!firrtl.uint<8>) -> !firrtl.uint<8>
      "firrtl.matchingconnect"(%arg34, %59) : (!firrtl.uint<8>, !firrtl.uint<8>) -> ()
    }) : () -> ()
  }) : () -> ()
}) : () -> ()

