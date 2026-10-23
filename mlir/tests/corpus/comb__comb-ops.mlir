#loc = loc("./comb/comb-ops.mlir":3:9)
#loc1 = loc("./comb/comb-ops.mlir":3:23)
#loc2 = loc("./comb/comb-ops.mlir":3:37)
#loc3 = loc("./comb/comb-ops.mlir":3:51)
#loc4 = loc("./comb/comb-ops.mlir":3:66)
#loc5 = loc("./comb/comb-ops.mlir":4:9)
#loc6 = loc("./comb/comb-ops.mlir":4:24)
#loc7 = loc("./comb/comb-ops.mlir":4:39)
#loc8 = loc("./comb/comb-ops.mlir":4:53)
#loc9 = loc("./comb/comb-ops.mlir":4:68)
#loc10 = loc("./comb/comb-ops.mlir":5:9)
#loc11 = loc("./comb/comb-ops.mlir":5:24)
#loc12 = loc("./comb/comb-ops.mlir":5:38)
#loc13 = loc("./comb/comb-ops.mlir":5:53)
#loc14 = loc("./comb/comb-ops.mlir":6:9)
#loc15 = loc("./comb/comb-ops.mlir":6:23)
#loc16 = loc("./comb/comb-ops.mlir":6:37)
#loc17 = loc("./comb/comb-ops.mlir":6:50)
#loc18 = loc("./comb/comb-ops.mlir":6:63)
#loc19 = loc("./comb/comb-ops.mlir":6:77)
#loc20 = loc("./comb/comb-ops.mlir":7:9)
#loc21 = loc("./comb/comb-ops.mlir":7:23)
#loc22 = loc("./comb/comb-ops.mlir":8:9)
#loc23 = loc("./comb/comb-ops.mlir":8:26)
#loc24 = loc("./comb/comb-ops.mlir":8:40)
#loc25 = loc("./comb/comb-ops.mlir":8:55)
#loc26 = loc("./comb/comb-ops.mlir":8:70)
#loc27 = loc("./comb/comb-ops.mlir":9:9)
"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, input b : i8, input c : i1, input w : i12, output add : i8, output sub : i8, output mul : i8, output divu : i8, output divs : i8, output modu : i8, output mods : i8, output shl : i8, output shru : i8, output shrs : i8, output and3 : i8, output or2 : i8, output xor2 : i8, output not : i8, output ult : i1, output slt : i1, output eq : i1, output ne : i1, output uge : i1, output sgt : i1, output ceq : i1, output weq : i1, output parity : i1, output ext : i4, output cat : i20, output rep : i24, output mux : i8, output rev : i8>, parameters = [], result_locs = [#loc, #loc1, #loc2, #loc3, #loc4, #loc5, #loc6, #loc7, #loc8, #loc9, #loc10, #loc11, #loc12, #loc13, #loc14, #loc15, #loc16, #loc17, #loc18, #loc19, #loc20, #loc21, #loc22, #loc23, #loc24, #loc25, #loc26, #loc27], sym_name = "CombOps"}> ({
  ^bb0(%arg0: i8, %arg1: i8, %arg2: i1, %arg3: i12):
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    %1 = "comb.sub"(%arg0, %arg1) : (i8, i8) -> i8
    %2 = "comb.mul"(%arg0, %arg1) : (i8, i8) -> i8
    %3 = "comb.divu"(%arg0, %arg1) : (i8, i8) -> i8
    %4 = "comb.divs"(%arg0, %arg1) : (i8, i8) -> i8
    %5 = "comb.modu"(%arg0, %arg1) : (i8, i8) -> i8
    %6 = "comb.mods"(%arg0, %arg1) : (i8, i8) -> i8
    %7 = "comb.shl"(%arg0, %arg1) : (i8, i8) -> i8
    %8 = "comb.shru"(%arg0, %arg1) : (i8, i8) -> i8
    %9 = "comb.shrs"(%arg0, %arg1) : (i8, i8) -> i8
    %10 = "comb.and"(%arg0, %arg1, %arg0) : (i8, i8, i8) -> i8
    %11 = "comb.or"(%arg0, %arg1) : (i8, i8) -> i8
    %12 = "comb.xor"(%arg0, %arg1) : (i8, i8) -> i8
    %13 = "hw.constant"() <{value = -1 : i8}> : () -> i8
    %14 = "comb.xor"(%arg0, %13) : (i8, i8) -> i8
    %15 = "comb.icmp"(%arg0, %arg1) <{predicate = 6 : i64}> : (i8, i8) -> i1
    %16 = "comb.icmp"(%arg0, %arg1) <{predicate = 2 : i64}> : (i8, i8) -> i1
    %17 = "comb.icmp"(%arg0, %arg1) <{predicate = 0 : i64}> : (i8, i8) -> i1
    %18 = "comb.icmp"(%arg0, %arg1) <{predicate = 1 : i64}> : (i8, i8) -> i1
    %19 = "comb.icmp"(%arg0, %arg1) <{predicate = 9 : i64}> : (i8, i8) -> i1
    %20 = "comb.icmp"(%arg0, %arg1) <{predicate = 4 : i64}> : (i8, i8) -> i1
    %21 = "comb.icmp"(%arg0, %arg1) <{predicate = 10 : i64}> : (i8, i8) -> i1
    %22 = "comb.icmp"(%arg0, %arg1) <{predicate = 12 : i64}> : (i8, i8) -> i1
    %23 = "comb.parity"(%arg0) : (i8) -> i1
    %24 = "comb.extract"(%arg0) <{lowBit = 2 : i32}> : (i8) -> i4
    %25 = "comb.concat"(%arg0, %arg3) : (i8, i12) -> i20
    %26 = "comb.replicate"(%arg0) : (i8) -> i24
    %27 = "comb.mux"(%arg2, %arg0, %arg1) : (i1, i8, i8) -> i8
    %28 = "comb.reverse"(%arg0) : (i8) -> i8
    "hw.output"(%0, %1, %2, %3, %4, %5, %6, %7, %8, %9, %10, %11, %12, %14, %15, %16, %17, %18, %19, %20, %21, %22, %23, %24, %25, %26, %27, %28) : (i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i8, i1, i1, i1, i1, i1, i1, i1, i1, i1, i4, i20, i24, i8, i8) -> ()
  }) : () -> ()
}) : () -> ()

