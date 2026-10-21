#loc = loc("./firrtl/primops/PrimOps.hw.mlir":2:86)
#loc1 = loc("./firrtl/primops/PrimOps.hw.mlir":2:102)
#loc2 = loc("./firrtl/primops/PrimOps.hw.mlir":2:118)
#loc3 = loc("./firrtl/primops/PrimOps.hw.mlir":2:135)
#loc4 = loc("./firrtl/primops/PrimOps.hw.mlir":2:151)
#loc5 = loc("./firrtl/primops/PrimOps.hw.mlir":2:167)
#loc6 = loc("./firrtl/primops/PrimOps.hw.mlir":2:184)
#loc7 = loc("./firrtl/primops/PrimOps.hw.mlir":2:201)
#loc8 = loc("./firrtl/primops/PrimOps.hw.mlir":2:216)
#loc9 = loc("./firrtl/primops/PrimOps.hw.mlir":2:232)
#loc10 = loc("./firrtl/primops/PrimOps.hw.mlir":2:249)
#loc11 = loc("./firrtl/primops/PrimOps.hw.mlir":2:267)
#loc12 = loc("./firrtl/primops/PrimOps.hw.mlir":2:286)
#loc13 = loc("./firrtl/primops/PrimOps.hw.mlir":2:303)
#loc14 = loc("./firrtl/primops/PrimOps.hw.mlir":2:319)
#loc15 = loc("./firrtl/primops/PrimOps.hw.mlir":2:336)
#loc16 = loc("./firrtl/primops/PrimOps.hw.mlir":2:354)
#loc17 = loc("./firrtl/primops/PrimOps.hw.mlir":2:371)
#loc18 = loc("./firrtl/primops/PrimOps.hw.mlir":2:389)
#loc19 = loc("./firrtl/primops/PrimOps.hw.mlir":2:405)
#loc20 = loc("./firrtl/primops/PrimOps.hw.mlir":2:421)
#loc21 = loc("./firrtl/primops/PrimOps.hw.mlir":2:437)
#loc22 = loc("./firrtl/primops/PrimOps.hw.mlir":2:453)
#loc23 = loc("./firrtl/primops/PrimOps.hw.mlir":2:470)
#loc24 = loc("./firrtl/primops/PrimOps.hw.mlir":2:486)
#loc25 = loc("./firrtl/primops/PrimOps.hw.mlir":2:503)
#loc26 = loc("./firrtl/primops/PrimOps.hw.mlir":2:520)
#loc27 = loc("./firrtl/primops/PrimOps.hw.mlir":2:537)
#loc28 = loc("./firrtl/primops/PrimOps.hw.mlir":2:554)
#loc29 = loc("./firrtl/primops/PrimOps.hw.mlir":2:571)
"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, input b : i4, input s : i8, input t : i4, input c : i1, output o_add : i9, output o_sub : i9, output o_mul : i12, output o_div : i8, output o_rem : i4, output o_sdiv : i9, output o_srem : i4, output o_lt : i1, output o_slt : i1, output o_pad : i12, output o_spad : i12, output o_asuint : i8, output o_shl : i11, output o_shr : i5, output o_sshr : i5, output o_dshl : i23, output o_dshr : i8, output o_sdshr : i8, output o_cvt : i9, output o_neg : i9, output o_not : i8, output o_and : i8, output o_andr : i1, output o_orr : i1, output o_xorr : i1, output o_cat : i13, output o_bits : i5, output o_head : i3, output o_tail : i5, output o_mux : i8>, parameters = [], result_locs = [#loc, #loc1, #loc2, #loc3, #loc4, #loc5, #loc6, #loc7, #loc8, #loc9, #loc10, #loc11, #loc12, #loc13, #loc14, #loc15, #loc16, #loc17, #loc18, #loc19, #loc20, #loc21, #loc22, #loc23, #loc24, #loc25, #loc26, #loc27, #loc28, #loc29], sym_name = "PrimOps"}> ({
  ^bb0(%arg1: i8, %arg2: i4, %arg3: i8, %arg4: i4, %arg5: i1):
    %0 = "hw.constant"() <{value = -1 : i8}> : () -> i8
    %1 = "hw.constant"() <{value = 0 : i9}> : () -> i9
    %2 = "hw.constant"() <{value = 0 : i19}> : () -> i19
    %3 = "hw.constant"() <{value = 0 : i15}> : () -> i15
    %4 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %5 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %6 = "hw.constant"() <{value = 0 : i4}> : () -> i4
    %7 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %8 = "hw.constant"() <{value = false}> : () -> i1
    %9 = "comb.concat"(%8, %arg1) : (i1, i8) -> i9
    %10 = "comb.concat"(%7, %arg2) : (i5, i4) -> i9
    %11 = "comb.add"(%9, %10) <{twoState}> {sv.namehint = "n_add"} : (i9, i9) -> i9
    %12 = "comb.sub"(%9, %10) <{twoState}> {sv.namehint = "n_sub"} : (i9, i9) -> i9
    %13 = "comb.concat"(%6, %arg1) : (i4, i8) -> i12
    %14 = "comb.concat"(%5, %arg2) : (i8, i4) -> i12
    %15 = "comb.mul"(%13, %14) <{twoState}> {sv.namehint = "n_mul"} : (i12, i12) -> i12
    %16 = "comb.concat"(%6, %arg2) : (i4, i4) -> i8
    %17 = "comb.divu"(%arg1, %16) <{twoState}> {sv.namehint = "n_div"} : (i8, i8) -> i8
    %18 = "comb.modu"(%arg1, %16) <{twoState}> {sv.namehint = "n_rem"} : (i8, i8) -> i8
    %19 = "comb.extract"(%18) <{lowBit = 0 : i32}> {sv.namehint = "n_rem"} : (i8) -> i4
    %20 = "comb.extract"(%arg3) <{lowBit = 7 : i32}> : (i8) -> i1
    %21 = "comb.concat"(%20, %arg3) : (i1, i8) -> i9
    %22 = "comb.extract"(%arg4) <{lowBit = 3 : i32}> : (i4) -> i1
    %23 = "comb.replicate"(%22) : (i1) -> i5
    %24 = "comb.concat"(%23, %arg4) : (i5, i4) -> i9
    %25 = "comb.divs"(%21, %24) <{twoState}> {sv.namehint = "n_sdiv"} : (i9, i9) -> i9
    %26 = "comb.replicate"(%22) : (i1) -> i4
    %27 = "comb.concat"(%26, %arg4) : (i4, i4) -> i8
    %28 = "comb.mods"(%arg3, %27) <{twoState}> {sv.namehint = "n_srem"} : (i8, i8) -> i8
    %29 = "comb.extract"(%28) <{lowBit = 0 : i32}> {sv.namehint = "n_srem"} : (i8) -> i4
    %30 = "comb.icmp"(%arg1, %16) <{predicate = 6 : i64, twoState}> {sv.namehint = "n_lt"} : (i8, i8) -> i1
    %31 = "comb.icmp"(%arg3, %27) <{predicate = 2 : i64, twoState}> {sv.namehint = "n_slt"} : (i8, i8) -> i1
    %32 = "comb.replicate"(%22) : (i1) -> i8
    %33 = "comb.concat"(%32, %arg4) : (i8, i4) -> i12
    %34 = "comb.concat"(%arg1, %4) {sv.namehint = "n_shl"} : (i8, i3) -> i11
    %35 = "comb.extract"(%arg1) <{lowBit = 3 : i32}> {sv.namehint = "n_shr"} : (i8) -> i5
    %36 = "comb.extract"(%arg3) <{lowBit = 3 : i32}> : (i8) -> i5
    %37 = "comb.concat"(%3, %arg1) : (i15, i8) -> i23
    %38 = "comb.concat"(%2, %arg2) : (i19, i4) -> i23
    %39 = "comb.shl"(%37, %38) <{twoState}> {sv.namehint = "n_dshl"} : (i23, i23) -> i23
    %40 = "comb.shru"(%arg1, %16) <{twoState}> {sv.namehint = "n_dshr"} : (i8, i8) -> i8
    %41 = "comb.shrs"(%arg3, %16) <{twoState}> {sv.namehint = "n_sdshr"} : (i8, i8) -> i8
    %42 = "comb.sub"(%1, %9) <{twoState}> {sv.namehint = "n_neg"} : (i9, i9) -> i9
    %43 = "comb.xor"(%arg1, %0) <{twoState}> {sv.namehint = "n_not"} : (i8, i8) -> i8
    %44 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> : (i8) -> i4
    %45 = "comb.and"(%44, %arg2) <{twoState}> : (i4, i4) -> i4
    %46 = "comb.concat"(%6, %45) : (i4, i4) -> i8
    %47 = "comb.icmp"(%arg1, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "n_andr"} : (i8, i8) -> i1
    %48 = "comb.icmp"(%arg1, %5) <{predicate = 1 : i64, twoState}> {sv.namehint = "n_orr"} : (i8, i8) -> i1
    %49 = "comb.parity"(%arg1) <{twoState}> {sv.namehint = "n_xorr"} : (i8) -> i1
    %50 = "comb.concat"(%arg1, %arg2, %arg5) {sv.namehint = "n_cat"} : (i8, i4, i1) -> i13
    %51 = "comb.extract"(%arg1) <{lowBit = 2 : i32}> {sv.namehint = "n_bits"} : (i8) -> i5
    %52 = "comb.extract"(%arg1) <{lowBit = 5 : i32}> {sv.namehint = "n_head"} : (i8) -> i3
    %53 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> {sv.namehint = "n_tail"} : (i8) -> i5
    %54 = "comb.mux"(%arg5, %arg1, %16) <{twoState}> {sv.namehint = "n_mux"} : (i1, i8, i8) -> i8
    "hw.output"(%11, %12, %15, %17, %19, %25, %29, %30, %31, %14, %33, %arg3, %34, %35, %36, %39, %40, %41, %9, %42, %43, %46, %47, %48, %49, %50, %51, %52, %53, %54) : (i9, i9, i12, i8, i4, i9, i4, i1, i1, i12, i12, i8, i11, i5, i5, i23, i8, i8, i9, i9, i8, i8, i1, i1, i1, i13, i5, i3, i5, i8) -> ()
  }) : () -> ()
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "PrimOps_Class"}> ({
  ^bb0(%arg0: !om.basepath):
    "om.class.fields"() : () -> ()
  }) : () -> ()
}) : () -> ()

