#loc = loc("./chisel/fir64/Fir64.hw.mlir":5:99)
"builtin.module"() ({
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assert$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Assume$Temporal"}> : () -> ()
  "sv.macro.decl"() <{sym_name = "layer$Verification$Cover$Temporal"}> : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_in : i8, input io_valid : i1, output io_out : i16>, parameters = [], result_locs = [#loc], sym_name = "Fir64"}> ({
  ^bb0(%arg1: !seq.clock, %arg2: i1, %arg3: i8, %arg4: i1):
    %0 = "hw.constant"() <{value = 0 : i2}> : () -> i2
    %1 = "hw.constant"() <{value = 83 : i15}> : () -> i15
    %2 = "hw.constant"() <{value = 46 : i14}> : () -> i14
    %3 = "hw.constant"() <{value = 9 : i12}> : () -> i12
    %4 = "hw.constant"() <{value = 223 : i16}> : () -> i16
    %5 = "hw.constant"() <{value = 186 : i16}> : () -> i16
    %6 = "hw.constant"() <{value = 149 : i16}> : () -> i16
    %7 = "hw.constant"() <{value = 112 : i15}> : () -> i15
    %8 = "hw.constant"() <{value = 75 : i15}> : () -> i15
    %9 = "hw.constant"() <{value = 38 : i14}> : () -> i14
    %10 = "hw.constant"() <{value = 215 : i16}> : () -> i16
    %11 = "hw.constant"() <{value = 178 : i16}> : () -> i16
    %12 = "hw.constant"() <{value = 141 : i16}> : () -> i16
    %13 = "hw.constant"() <{value = 104 : i15}> : () -> i15
    %14 = "hw.constant"() <{value = 67 : i15}> : () -> i15
    %15 = "hw.constant"() <{value = 30 : i13}> : () -> i13
    %16 = "hw.constant"() <{value = 244 : i16}> : () -> i16
    %17 = "hw.constant"() <{value = 207 : i16}> : () -> i16
    %18 = "hw.constant"() <{value = 170 : i16}> : () -> i16
    %19 = "hw.constant"() <{value = 133 : i16}> : () -> i16
    %20 = "hw.constant"() <{value = 96 : i15}> : () -> i15
    %21 = "hw.constant"() <{value = 59 : i14}> : () -> i14
    %22 = "hw.constant"() <{value = 22 : i13}> : () -> i13
    %23 = "hw.constant"() <{value = 236 : i16}> : () -> i16
    %24 = "hw.constant"() <{value = 199 : i16}> : () -> i16
    %25 = "hw.constant"() <{value = 162 : i16}> : () -> i16
    %26 = "hw.constant"() <{value = 125 : i15}> : () -> i15
    %27 = "hw.constant"() <{value = 88 : i15}> : () -> i15
    %28 = "hw.constant"() <{value = 51 : i14}> : () -> i14
    %29 = "hw.constant"() <{value = 14 : i12}> : () -> i12
    %30 = "hw.constant"() <{value = 228 : i16}> : () -> i16
    %31 = "hw.constant"() <{value = 191 : i16}> : () -> i16
    %32 = "hw.constant"() <{value = 154 : i16}> : () -> i16
    %33 = "hw.constant"() <{value = 117 : i15}> : () -> i15
    %34 = "hw.constant"() <{value = 80 : i15}> : () -> i15
    %35 = "hw.constant"() <{value = 43 : i14}> : () -> i14
    %36 = "hw.constant"() <{value = 6 : i11}> : () -> i11
    %37 = "hw.constant"() <{value = 220 : i16}> : () -> i16
    %38 = "hw.constant"() <{value = 183 : i16}> : () -> i16
    %39 = "hw.constant"() <{value = 146 : i16}> : () -> i16
    %40 = "hw.constant"() <{value = 109 : i15}> : () -> i15
    %41 = "hw.constant"() <{value = 72 : i15}> : () -> i15
    %42 = "hw.constant"() <{value = 35 : i14}> : () -> i14
    %43 = "hw.constant"() <{value = 249 : i16}> : () -> i16
    %44 = "hw.constant"() <{value = 212 : i16}> : () -> i16
    %45 = "hw.constant"() <{value = 175 : i16}> : () -> i16
    %46 = "hw.constant"() <{value = 138 : i16}> : () -> i16
    %47 = "hw.constant"() <{value = 101 : i15}> : () -> i15
    %48 = "hw.constant"() <{value = 27 : i13}> : () -> i13
    %49 = "hw.constant"() <{value = 241 : i16}> : () -> i16
    %50 = "hw.constant"() <{value = 204 : i16}> : () -> i16
    %51 = "hw.constant"() <{value = 167 : i16}> : () -> i16
    %52 = "hw.constant"() <{value = 130 : i16}> : () -> i16
    %53 = "hw.constant"() <{value = 93 : i15}> : () -> i15
    %54 = "hw.constant"() <{value = 56 : i14}> : () -> i14
    %55 = "hw.constant"() <{value = 19 : i13}> : () -> i13
    %56 = "hw.constant"() <{value = 233 : i16}> : () -> i16
    %57 = "hw.constant"() <{value = 196 : i16}> : () -> i16
    %58 = "hw.constant"() <{value = 159 : i16}> : () -> i16
    %59 = "hw.constant"() <{value = 122 : i15}> : () -> i15
    %60 = "hw.constant"() <{value = 85 : i15}> : () -> i15
    %61 = "hw.constant"() <{value = 48 : i14}> : () -> i14
    %62 = "hw.constant"() <{value = 11 : i12}> : () -> i12
    %63 = "hw.constant"() <{value = false}> : () -> i1
    %64 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %65 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %66 = "hw.constant"() <{value = 0 : i7}> : () -> i7
    %67 = "hw.constant"() <{value = 0 : i6}> : () -> i6
    %68 = "hw.constant"() <{value = 0 : i4}> : () -> i4
    %69 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %70 = "seq.firreg"(%133, %arg1, %arg2, %69) <{name = "taps_1"}> {firrtl.random_init_start = 0 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %71 = "seq.firreg"(%134, %arg1, %arg2, %69) <{name = "taps_2"}> {firrtl.random_init_start = 8 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %72 = "seq.firreg"(%135, %arg1, %arg2, %69) <{name = "taps_3"}> {firrtl.random_init_start = 16 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %73 = "seq.firreg"(%136, %arg1, %arg2, %69) <{name = "taps_4"}> {firrtl.random_init_start = 24 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %74 = "seq.firreg"(%137, %arg1, %arg2, %69) <{name = "taps_5"}> {firrtl.random_init_start = 32 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %75 = "seq.firreg"(%138, %arg1, %arg2, %69) <{name = "taps_6"}> {firrtl.random_init_start = 40 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %76 = "seq.firreg"(%139, %arg1, %arg2, %69) <{name = "taps_7"}> {firrtl.random_init_start = 48 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %77 = "seq.firreg"(%140, %arg1, %arg2, %69) <{name = "taps_8"}> {firrtl.random_init_start = 56 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %78 = "seq.firreg"(%141, %arg1, %arg2, %69) <{name = "taps_9"}> {firrtl.random_init_start = 64 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %79 = "seq.firreg"(%142, %arg1, %arg2, %69) <{name = "taps_10"}> {firrtl.random_init_start = 72 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %80 = "seq.firreg"(%143, %arg1, %arg2, %69) <{name = "taps_11"}> {firrtl.random_init_start = 80 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %81 = "seq.firreg"(%144, %arg1, %arg2, %69) <{name = "taps_12"}> {firrtl.random_init_start = 88 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %82 = "seq.firreg"(%145, %arg1, %arg2, %69) <{name = "taps_13"}> {firrtl.random_init_start = 96 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %83 = "seq.firreg"(%146, %arg1, %arg2, %69) <{name = "taps_14"}> {firrtl.random_init_start = 104 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %84 = "seq.firreg"(%147, %arg1, %arg2, %69) <{name = "taps_15"}> {firrtl.random_init_start = 112 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %85 = "seq.firreg"(%148, %arg1, %arg2, %69) <{name = "taps_16"}> {firrtl.random_init_start = 120 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %86 = "seq.firreg"(%149, %arg1, %arg2, %69) <{name = "taps_17"}> {firrtl.random_init_start = 128 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %87 = "seq.firreg"(%150, %arg1, %arg2, %69) <{name = "taps_18"}> {firrtl.random_init_start = 136 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %88 = "seq.firreg"(%151, %arg1, %arg2, %69) <{name = "taps_19"}> {firrtl.random_init_start = 144 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %89 = "seq.firreg"(%152, %arg1, %arg2, %69) <{name = "taps_20"}> {firrtl.random_init_start = 152 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %90 = "seq.firreg"(%153, %arg1, %arg2, %69) <{name = "taps_21"}> {firrtl.random_init_start = 160 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %91 = "seq.firreg"(%154, %arg1, %arg2, %69) <{name = "taps_22"}> {firrtl.random_init_start = 168 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %92 = "seq.firreg"(%155, %arg1, %arg2, %69) <{name = "taps_23"}> {firrtl.random_init_start = 176 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %93 = "seq.firreg"(%156, %arg1, %arg2, %69) <{name = "taps_24"}> {firrtl.random_init_start = 184 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %94 = "seq.firreg"(%157, %arg1, %arg2, %69) <{name = "taps_25"}> {firrtl.random_init_start = 192 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %95 = "seq.firreg"(%158, %arg1, %arg2, %69) <{name = "taps_26"}> {firrtl.random_init_start = 200 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %96 = "seq.firreg"(%159, %arg1, %arg2, %69) <{name = "taps_27"}> {firrtl.random_init_start = 208 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %97 = "seq.firreg"(%160, %arg1, %arg2, %69) <{name = "taps_28"}> {firrtl.random_init_start = 216 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %98 = "seq.firreg"(%161, %arg1, %arg2, %69) <{name = "taps_29"}> {firrtl.random_init_start = 224 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %99 = "seq.firreg"(%162, %arg1, %arg2, %69) <{name = "taps_30"}> {firrtl.random_init_start = 232 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %100 = "seq.firreg"(%163, %arg1, %arg2, %69) <{name = "taps_31"}> {firrtl.random_init_start = 240 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %101 = "seq.firreg"(%164, %arg1, %arg2, %69) <{name = "taps_32"}> {firrtl.random_init_start = 248 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %102 = "seq.firreg"(%165, %arg1, %arg2, %69) <{name = "taps_33"}> {firrtl.random_init_start = 256 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %103 = "seq.firreg"(%166, %arg1, %arg2, %69) <{name = "taps_34"}> {firrtl.random_init_start = 264 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %104 = "seq.firreg"(%167, %arg1, %arg2, %69) <{name = "taps_35"}> {firrtl.random_init_start = 272 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %105 = "seq.firreg"(%168, %arg1, %arg2, %69) <{name = "taps_36"}> {firrtl.random_init_start = 280 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %106 = "seq.firreg"(%169, %arg1, %arg2, %69) <{name = "taps_37"}> {firrtl.random_init_start = 288 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %107 = "seq.firreg"(%170, %arg1, %arg2, %69) <{name = "taps_38"}> {firrtl.random_init_start = 296 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %108 = "seq.firreg"(%171, %arg1, %arg2, %69) <{name = "taps_39"}> {firrtl.random_init_start = 304 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %109 = "seq.firreg"(%172, %arg1, %arg2, %69) <{name = "taps_40"}> {firrtl.random_init_start = 312 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %110 = "seq.firreg"(%173, %arg1, %arg2, %69) <{name = "taps_41"}> {firrtl.random_init_start = 320 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %111 = "seq.firreg"(%174, %arg1, %arg2, %69) <{name = "taps_42"}> {firrtl.random_init_start = 328 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %112 = "seq.firreg"(%175, %arg1, %arg2, %69) <{name = "taps_43"}> {firrtl.random_init_start = 336 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %113 = "seq.firreg"(%176, %arg1, %arg2, %69) <{name = "taps_44"}> {firrtl.random_init_start = 344 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %114 = "seq.firreg"(%177, %arg1, %arg2, %69) <{name = "taps_45"}> {firrtl.random_init_start = 352 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %115 = "seq.firreg"(%178, %arg1, %arg2, %69) <{name = "taps_46"}> {firrtl.random_init_start = 360 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %116 = "seq.firreg"(%179, %arg1, %arg2, %69) <{name = "taps_47"}> {firrtl.random_init_start = 368 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %117 = "seq.firreg"(%180, %arg1, %arg2, %69) <{name = "taps_48"}> {firrtl.random_init_start = 376 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %118 = "seq.firreg"(%181, %arg1, %arg2, %69) <{name = "taps_49"}> {firrtl.random_init_start = 384 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %119 = "seq.firreg"(%182, %arg1, %arg2, %69) <{name = "taps_50"}> {firrtl.random_init_start = 392 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %120 = "seq.firreg"(%183, %arg1, %arg2, %69) <{name = "taps_51"}> {firrtl.random_init_start = 400 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %121 = "seq.firreg"(%184, %arg1, %arg2, %69) <{name = "taps_52"}> {firrtl.random_init_start = 408 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %122 = "seq.firreg"(%185, %arg1, %arg2, %69) <{name = "taps_53"}> {firrtl.random_init_start = 416 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %123 = "seq.firreg"(%186, %arg1, %arg2, %69) <{name = "taps_54"}> {firrtl.random_init_start = 424 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %124 = "seq.firreg"(%187, %arg1, %arg2, %69) <{name = "taps_55"}> {firrtl.random_init_start = 432 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %125 = "seq.firreg"(%188, %arg1, %arg2, %69) <{name = "taps_56"}> {firrtl.random_init_start = 440 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %126 = "seq.firreg"(%189, %arg1, %arg2, %69) <{name = "taps_57"}> {firrtl.random_init_start = 448 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %127 = "seq.firreg"(%190, %arg1, %arg2, %69) <{name = "taps_58"}> {firrtl.random_init_start = 456 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %128 = "seq.firreg"(%191, %arg1, %arg2, %69) <{name = "taps_59"}> {firrtl.random_init_start = 464 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %129 = "seq.firreg"(%192, %arg1, %arg2, %69) <{name = "taps_60"}> {firrtl.random_init_start = 472 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %130 = "seq.firreg"(%193, %arg1, %arg2, %69) <{name = "taps_61"}> {firrtl.random_init_start = 480 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %131 = "seq.firreg"(%194, %arg1, %arg2, %69) <{name = "taps_62"}> {firrtl.random_init_start = 488 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %132 = "seq.firreg"(%195, %arg1, %arg2, %69) <{name = "taps_63"}> {firrtl.random_init_start = 496 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %133 = "comb.mux"(%arg4, %arg3, %70) <{twoState}> : (i1, i8, i8) -> i8
    %134 = "comb.mux"(%arg4, %70, %71) <{twoState}> : (i1, i8, i8) -> i8
    %135 = "comb.mux"(%arg4, %71, %72) <{twoState}> : (i1, i8, i8) -> i8
    %136 = "comb.mux"(%arg4, %72, %73) <{twoState}> : (i1, i8, i8) -> i8
    %137 = "comb.mux"(%arg4, %73, %74) <{twoState}> : (i1, i8, i8) -> i8
    %138 = "comb.mux"(%arg4, %74, %75) <{twoState}> : (i1, i8, i8) -> i8
    %139 = "comb.mux"(%arg4, %75, %76) <{twoState}> : (i1, i8, i8) -> i8
    %140 = "comb.mux"(%arg4, %76, %77) <{twoState}> : (i1, i8, i8) -> i8
    %141 = "comb.mux"(%arg4, %77, %78) <{twoState}> : (i1, i8, i8) -> i8
    %142 = "comb.mux"(%arg4, %78, %79) <{twoState}> : (i1, i8, i8) -> i8
    %143 = "comb.mux"(%arg4, %79, %80) <{twoState}> : (i1, i8, i8) -> i8
    %144 = "comb.mux"(%arg4, %80, %81) <{twoState}> : (i1, i8, i8) -> i8
    %145 = "comb.mux"(%arg4, %81, %82) <{twoState}> : (i1, i8, i8) -> i8
    %146 = "comb.mux"(%arg4, %82, %83) <{twoState}> : (i1, i8, i8) -> i8
    %147 = "comb.mux"(%arg4, %83, %84) <{twoState}> : (i1, i8, i8) -> i8
    %148 = "comb.mux"(%arg4, %84, %85) <{twoState}> : (i1, i8, i8) -> i8
    %149 = "comb.mux"(%arg4, %85, %86) <{twoState}> : (i1, i8, i8) -> i8
    %150 = "comb.mux"(%arg4, %86, %87) <{twoState}> : (i1, i8, i8) -> i8
    %151 = "comb.mux"(%arg4, %87, %88) <{twoState}> : (i1, i8, i8) -> i8
    %152 = "comb.mux"(%arg4, %88, %89) <{twoState}> : (i1, i8, i8) -> i8
    %153 = "comb.mux"(%arg4, %89, %90) <{twoState}> : (i1, i8, i8) -> i8
    %154 = "comb.mux"(%arg4, %90, %91) <{twoState}> : (i1, i8, i8) -> i8
    %155 = "comb.mux"(%arg4, %91, %92) <{twoState}> : (i1, i8, i8) -> i8
    %156 = "comb.mux"(%arg4, %92, %93) <{twoState}> : (i1, i8, i8) -> i8
    %157 = "comb.mux"(%arg4, %93, %94) <{twoState}> : (i1, i8, i8) -> i8
    %158 = "comb.mux"(%arg4, %94, %95) <{twoState}> : (i1, i8, i8) -> i8
    %159 = "comb.mux"(%arg4, %95, %96) <{twoState}> : (i1, i8, i8) -> i8
    %160 = "comb.mux"(%arg4, %96, %97) <{twoState}> : (i1, i8, i8) -> i8
    %161 = "comb.mux"(%arg4, %97, %98) <{twoState}> : (i1, i8, i8) -> i8
    %162 = "comb.mux"(%arg4, %98, %99) <{twoState}> : (i1, i8, i8) -> i8
    %163 = "comb.mux"(%arg4, %99, %100) <{twoState}> : (i1, i8, i8) -> i8
    %164 = "comb.mux"(%arg4, %100, %101) <{twoState}> : (i1, i8, i8) -> i8
    %165 = "comb.mux"(%arg4, %101, %102) <{twoState}> : (i1, i8, i8) -> i8
    %166 = "comb.mux"(%arg4, %102, %103) <{twoState}> : (i1, i8, i8) -> i8
    %167 = "comb.mux"(%arg4, %103, %104) <{twoState}> : (i1, i8, i8) -> i8
    %168 = "comb.mux"(%arg4, %104, %105) <{twoState}> : (i1, i8, i8) -> i8
    %169 = "comb.mux"(%arg4, %105, %106) <{twoState}> : (i1, i8, i8) -> i8
    %170 = "comb.mux"(%arg4, %106, %107) <{twoState}> : (i1, i8, i8) -> i8
    %171 = "comb.mux"(%arg4, %107, %108) <{twoState}> : (i1, i8, i8) -> i8
    %172 = "comb.mux"(%arg4, %108, %109) <{twoState}> : (i1, i8, i8) -> i8
    %173 = "comb.mux"(%arg4, %109, %110) <{twoState}> : (i1, i8, i8) -> i8
    %174 = "comb.mux"(%arg4, %110, %111) <{twoState}> : (i1, i8, i8) -> i8
    %175 = "comb.mux"(%arg4, %111, %112) <{twoState}> : (i1, i8, i8) -> i8
    %176 = "comb.mux"(%arg4, %112, %113) <{twoState}> : (i1, i8, i8) -> i8
    %177 = "comb.mux"(%arg4, %113, %114) <{twoState}> : (i1, i8, i8) -> i8
    %178 = "comb.mux"(%arg4, %114, %115) <{twoState}> : (i1, i8, i8) -> i8
    %179 = "comb.mux"(%arg4, %115, %116) <{twoState}> : (i1, i8, i8) -> i8
    %180 = "comb.mux"(%arg4, %116, %117) <{twoState}> : (i1, i8, i8) -> i8
    %181 = "comb.mux"(%arg4, %117, %118) <{twoState}> : (i1, i8, i8) -> i8
    %182 = "comb.mux"(%arg4, %118, %119) <{twoState}> : (i1, i8, i8) -> i8
    %183 = "comb.mux"(%arg4, %119, %120) <{twoState}> : (i1, i8, i8) -> i8
    %184 = "comb.mux"(%arg4, %120, %121) <{twoState}> : (i1, i8, i8) -> i8
    %185 = "comb.mux"(%arg4, %121, %122) <{twoState}> : (i1, i8, i8) -> i8
    %186 = "comb.mux"(%arg4, %122, %123) <{twoState}> : (i1, i8, i8) -> i8
    %187 = "comb.mux"(%arg4, %123, %124) <{twoState}> : (i1, i8, i8) -> i8
    %188 = "comb.mux"(%arg4, %124, %125) <{twoState}> : (i1, i8, i8) -> i8
    %189 = "comb.mux"(%arg4, %125, %126) <{twoState}> : (i1, i8, i8) -> i8
    %190 = "comb.mux"(%arg4, %126, %127) <{twoState}> : (i1, i8, i8) -> i8
    %191 = "comb.mux"(%arg4, %127, %128) <{twoState}> : (i1, i8, i8) -> i8
    %192 = "comb.mux"(%arg4, %128, %129) <{twoState}> : (i1, i8, i8) -> i8
    %193 = "comb.mux"(%arg4, %129, %130) <{twoState}> : (i1, i8, i8) -> i8
    %194 = "comb.mux"(%arg4, %130, %131) <{twoState}> : (i1, i8, i8) -> i8
    %195 = "comb.mux"(%arg4, %131, %132) <{twoState}> : (i1, i8, i8) -> i8
    %196 = "comb.concat"(%68, %arg3) : (i4, i8) -> i12
    %197 = "comb.mul"(%196, %62) <{twoState}> {sv.namehint = "products_0"} : (i12, i12) -> i12
    %198 = "comb.concat"(%67, %70) : (i6, i8) -> i14
    %199 = "comb.mul"(%198, %61) <{twoState}> {sv.namehint = "products_1"} : (i14, i14) -> i14
    %200 = "comb.concat"(%66, %71) : (i7, i8) -> i15
    %201 = "comb.mul"(%200, %60) <{twoState}> {sv.namehint = "products_2"} : (i15, i15) -> i15
    %202 = "comb.concat"(%66, %72) : (i7, i8) -> i15
    %203 = "comb.mul"(%202, %59) <{twoState}> {sv.namehint = "products_3"} : (i15, i15) -> i15
    %204 = "comb.concat"(%69, %73) : (i8, i8) -> i16
    %205 = "comb.mul"(%204, %58) <{twoState}> {sv.namehint = "products_4"} : (i16, i16) -> i16
    %206 = "comb.concat"(%69, %74) : (i8, i8) -> i16
    %207 = "comb.mul"(%206, %57) <{twoState}> {sv.namehint = "products_5"} : (i16, i16) -> i16
    %208 = "comb.concat"(%69, %75) : (i8, i8) -> i16
    %209 = "comb.mul"(%208, %56) <{twoState}> {sv.namehint = "products_6"} : (i16, i16) -> i16
    %210 = "comb.concat"(%65, %76) : (i5, i8) -> i13
    %211 = "comb.mul"(%210, %55) <{twoState}> {sv.namehint = "products_7"} : (i13, i13) -> i13
    %212 = "comb.concat"(%67, %77) : (i6, i8) -> i14
    %213 = "comb.mul"(%212, %54) <{twoState}> {sv.namehint = "products_8"} : (i14, i14) -> i14
    %214 = "comb.concat"(%66, %78) : (i7, i8) -> i15
    %215 = "comb.mul"(%214, %53) <{twoState}> {sv.namehint = "products_9"} : (i15, i15) -> i15
    %216 = "comb.concat"(%69, %79) : (i8, i8) -> i16
    %217 = "comb.mul"(%216, %52) <{twoState}> {sv.namehint = "products_10"} : (i16, i16) -> i16
    %218 = "comb.concat"(%69, %80) : (i8, i8) -> i16
    %219 = "comb.mul"(%218, %51) <{twoState}> {sv.namehint = "products_11"} : (i16, i16) -> i16
    %220 = "comb.concat"(%69, %81) : (i8, i8) -> i16
    %221 = "comb.mul"(%220, %50) <{twoState}> {sv.namehint = "products_12"} : (i16, i16) -> i16
    %222 = "comb.concat"(%69, %82) : (i8, i8) -> i16
    %223 = "comb.mul"(%222, %49) <{twoState}> {sv.namehint = "products_13"} : (i16, i16) -> i16
    %224 = "comb.concat"(%65, %83) : (i5, i8) -> i13
    %225 = "comb.mul"(%224, %48) <{twoState}> {sv.namehint = "products_14"} : (i13, i13) -> i13
    %226 = "comb.concat"(%66, %85) : (i7, i8) -> i15
    %227 = "comb.mul"(%226, %47) <{twoState}> {sv.namehint = "products_16"} : (i15, i15) -> i15
    %228 = "comb.concat"(%69, %86) : (i8, i8) -> i16
    %229 = "comb.mul"(%228, %46) <{twoState}> {sv.namehint = "products_17"} : (i16, i16) -> i16
    %230 = "comb.concat"(%69, %87) : (i8, i8) -> i16
    %231 = "comb.mul"(%230, %45) <{twoState}> {sv.namehint = "products_18"} : (i16, i16) -> i16
    %232 = "comb.concat"(%69, %88) : (i8, i8) -> i16
    %233 = "comb.mul"(%232, %44) <{twoState}> {sv.namehint = "products_19"} : (i16, i16) -> i16
    %234 = "comb.concat"(%69, %89) : (i8, i8) -> i16
    %235 = "comb.mul"(%234, %43) <{twoState}> {sv.namehint = "products_20"} : (i16, i16) -> i16
    %236 = "comb.concat"(%67, %90) : (i6, i8) -> i14
    %237 = "comb.mul"(%236, %42) <{twoState}> {sv.namehint = "products_21"} : (i14, i14) -> i14
    %238 = "comb.concat"(%66, %91) : (i7, i8) -> i15
    %239 = "comb.mul"(%238, %41) <{twoState}> {sv.namehint = "products_22"} : (i15, i15) -> i15
    %240 = "comb.concat"(%66, %92) : (i7, i8) -> i15
    %241 = "comb.mul"(%240, %40) <{twoState}> {sv.namehint = "products_23"} : (i15, i15) -> i15
    %242 = "comb.concat"(%69, %93) : (i8, i8) -> i16
    %243 = "comb.mul"(%242, %39) <{twoState}> {sv.namehint = "products_24"} : (i16, i16) -> i16
    %244 = "comb.concat"(%69, %94) : (i8, i8) -> i16
    %245 = "comb.mul"(%244, %38) <{twoState}> {sv.namehint = "products_25"} : (i16, i16) -> i16
    %246 = "comb.concat"(%69, %95) : (i8, i8) -> i16
    %247 = "comb.mul"(%246, %37) <{twoState}> {sv.namehint = "products_26"} : (i16, i16) -> i16
    %248 = "comb.concat"(%64, %96) : (i3, i8) -> i11
    %249 = "comb.mul"(%248, %36) <{twoState}> {sv.namehint = "products_27"} : (i11, i11) -> i11
    %250 = "comb.concat"(%67, %97) : (i6, i8) -> i14
    %251 = "comb.mul"(%250, %35) <{twoState}> {sv.namehint = "products_28"} : (i14, i14) -> i14
    %252 = "comb.concat"(%66, %98) : (i7, i8) -> i15
    %253 = "comb.mul"(%252, %34) <{twoState}> {sv.namehint = "products_29"} : (i15, i15) -> i15
    %254 = "comb.concat"(%66, %99) : (i7, i8) -> i15
    %255 = "comb.mul"(%254, %33) <{twoState}> {sv.namehint = "products_30"} : (i15, i15) -> i15
    %256 = "comb.concat"(%69, %100) : (i8, i8) -> i16
    %257 = "comb.mul"(%256, %32) <{twoState}> {sv.namehint = "products_31"} : (i16, i16) -> i16
    %258 = "comb.concat"(%69, %101) : (i8, i8) -> i16
    %259 = "comb.mul"(%258, %31) <{twoState}> {sv.namehint = "products_32"} : (i16, i16) -> i16
    %260 = "comb.concat"(%69, %102) : (i8, i8) -> i16
    %261 = "comb.mul"(%260, %30) <{twoState}> {sv.namehint = "products_33"} : (i16, i16) -> i16
    %262 = "comb.concat"(%68, %103) : (i4, i8) -> i12
    %263 = "comb.mul"(%262, %29) <{twoState}> {sv.namehint = "products_34"} : (i12, i12) -> i12
    %264 = "comb.concat"(%67, %104) : (i6, i8) -> i14
    %265 = "comb.mul"(%264, %28) <{twoState}> {sv.namehint = "products_35"} : (i14, i14) -> i14
    %266 = "comb.concat"(%66, %105) : (i7, i8) -> i15
    %267 = "comb.mul"(%266, %27) <{twoState}> {sv.namehint = "products_36"} : (i15, i15) -> i15
    %268 = "comb.concat"(%66, %106) : (i7, i8) -> i15
    %269 = "comb.mul"(%268, %26) <{twoState}> {sv.namehint = "products_37"} : (i15, i15) -> i15
    %270 = "comb.concat"(%69, %107) : (i8, i8) -> i16
    %271 = "comb.mul"(%270, %25) <{twoState}> {sv.namehint = "products_38"} : (i16, i16) -> i16
    %272 = "comb.concat"(%69, %108) : (i8, i8) -> i16
    %273 = "comb.mul"(%272, %24) <{twoState}> {sv.namehint = "products_39"} : (i16, i16) -> i16
    %274 = "comb.concat"(%69, %109) : (i8, i8) -> i16
    %275 = "comb.mul"(%274, %23) <{twoState}> {sv.namehint = "products_40"} : (i16, i16) -> i16
    %276 = "comb.concat"(%65, %110) : (i5, i8) -> i13
    %277 = "comb.mul"(%276, %22) <{twoState}> {sv.namehint = "products_41"} : (i13, i13) -> i13
    %278 = "comb.concat"(%67, %111) : (i6, i8) -> i14
    %279 = "comb.mul"(%278, %21) <{twoState}> {sv.namehint = "products_42"} : (i14, i14) -> i14
    %280 = "comb.concat"(%66, %112) : (i7, i8) -> i15
    %281 = "comb.mul"(%280, %20) <{twoState}> {sv.namehint = "products_43"} : (i15, i15) -> i15
    %282 = "comb.concat"(%69, %113) : (i8, i8) -> i16
    %283 = "comb.mul"(%282, %19) <{twoState}> {sv.namehint = "products_44"} : (i16, i16) -> i16
    %284 = "comb.concat"(%69, %114) : (i8, i8) -> i16
    %285 = "comb.mul"(%284, %18) <{twoState}> {sv.namehint = "products_45"} : (i16, i16) -> i16
    %286 = "comb.concat"(%69, %115) : (i8, i8) -> i16
    %287 = "comb.mul"(%286, %17) <{twoState}> {sv.namehint = "products_46"} : (i16, i16) -> i16
    %288 = "comb.concat"(%69, %116) : (i8, i8) -> i16
    %289 = "comb.mul"(%288, %16) <{twoState}> {sv.namehint = "products_47"} : (i16, i16) -> i16
    %290 = "comb.concat"(%65, %117) : (i5, i8) -> i13
    %291 = "comb.mul"(%290, %15) <{twoState}> {sv.namehint = "products_48"} : (i13, i13) -> i13
    %292 = "comb.concat"(%66, %118) : (i7, i8) -> i15
    %293 = "comb.mul"(%292, %14) <{twoState}> {sv.namehint = "products_49"} : (i15, i15) -> i15
    %294 = "comb.concat"(%66, %119) : (i7, i8) -> i15
    %295 = "comb.mul"(%294, %13) <{twoState}> {sv.namehint = "products_50"} : (i15, i15) -> i15
    %296 = "comb.concat"(%69, %120) : (i8, i8) -> i16
    %297 = "comb.mul"(%296, %12) <{twoState}> {sv.namehint = "products_51"} : (i16, i16) -> i16
    %298 = "comb.concat"(%69, %121) : (i8, i8) -> i16
    %299 = "comb.mul"(%298, %11) <{twoState}> {sv.namehint = "products_52"} : (i16, i16) -> i16
    %300 = "comb.concat"(%69, %122) : (i8, i8) -> i16
    %301 = "comb.mul"(%300, %10) <{twoState}> {sv.namehint = "products_53"} : (i16, i16) -> i16
    %302 = "comb.concat"(%67, %124) : (i6, i8) -> i14
    %303 = "comb.mul"(%302, %9) <{twoState}> {sv.namehint = "products_55"} : (i14, i14) -> i14
    %304 = "comb.concat"(%66, %125) : (i7, i8) -> i15
    %305 = "comb.mul"(%304, %8) <{twoState}> {sv.namehint = "products_56"} : (i15, i15) -> i15
    %306 = "comb.concat"(%66, %126) : (i7, i8) -> i15
    %307 = "comb.mul"(%306, %7) <{twoState}> {sv.namehint = "products_57"} : (i15, i15) -> i15
    %308 = "comb.concat"(%69, %127) : (i8, i8) -> i16
    %309 = "comb.mul"(%308, %6) <{twoState}> {sv.namehint = "products_58"} : (i16, i16) -> i16
    %310 = "comb.concat"(%69, %128) : (i8, i8) -> i16
    %311 = "comb.mul"(%310, %5) <{twoState}> {sv.namehint = "products_59"} : (i16, i16) -> i16
    %312 = "comb.concat"(%69, %129) : (i8, i8) -> i16
    %313 = "comb.mul"(%312, %4) <{twoState}> {sv.namehint = "products_60"} : (i16, i16) -> i16
    %314 = "comb.concat"(%68, %130) : (i4, i8) -> i12
    %315 = "comb.mul"(%314, %3) <{twoState}> {sv.namehint = "products_61"} : (i12, i12) -> i12
    %316 = "comb.concat"(%67, %131) : (i6, i8) -> i14
    %317 = "comb.mul"(%316, %2) <{twoState}> {sv.namehint = "products_62"} : (i14, i14) -> i14
    %318 = "comb.concat"(%66, %132) : (i7, i8) -> i15
    %319 = "comb.mul"(%318, %1) <{twoState}> {sv.namehint = "products_63"} : (i15, i15) -> i15
    %320 = "comb.concat"(%64, %197) : (i3, i12) -> i15
    %321 = "comb.concat"(%63, %199) : (i1, i14) -> i15
    %322 = "comb.add"(%320, %321) <{twoState}> {sv.namehint = "_io_out_T"} : (i15, i15) -> i15
    %323 = "comb.concat"(%63, %322) : (i1, i15) -> i16
    %324 = "comb.concat"(%63, %201) : (i1, i15) -> i16
    %325 = "comb.concat"(%63, %203) : (i1, i15) -> i16
    %326 = "comb.concat"(%64, %211) : (i3, i13) -> i16
    %327 = "comb.concat"(%0, %213) : (i2, i14) -> i16
    %328 = "comb.concat"(%63, %215) : (i1, i15) -> i16
    %329 = "comb.concat"(%64, %225) : (i3, i13) -> i16
    %330 = "comb.concat"(%0, %84, %67) : (i2, i8, i6) -> i16
    %331 = "comb.concat"(%63, %227) : (i1, i15) -> i16
    %332 = "comb.concat"(%0, %237) : (i2, i14) -> i16
    %333 = "comb.concat"(%63, %239) : (i1, i15) -> i16
    %334 = "comb.concat"(%63, %241) : (i1, i15) -> i16
    %335 = "comb.concat"(%65, %249) : (i5, i11) -> i16
    %336 = "comb.concat"(%0, %251) : (i2, i14) -> i16
    %337 = "comb.concat"(%63, %253) : (i1, i15) -> i16
    %338 = "comb.concat"(%63, %255) : (i1, i15) -> i16
    %339 = "comb.concat"(%68, %263) : (i4, i12) -> i16
    %340 = "comb.concat"(%0, %265) : (i2, i14) -> i16
    %341 = "comb.concat"(%63, %267) : (i1, i15) -> i16
    %342 = "comb.concat"(%63, %269) : (i1, i15) -> i16
    %343 = "comb.concat"(%64, %277) : (i3, i13) -> i16
    %344 = "comb.concat"(%0, %279) : (i2, i14) -> i16
    %345 = "comb.concat"(%63, %281) : (i1, i15) -> i16
    %346 = "comb.concat"(%64, %291) : (i3, i13) -> i16
    %347 = "comb.concat"(%63, %293) : (i1, i15) -> i16
    %348 = "comb.concat"(%63, %295) : (i1, i15) -> i16
    %349 = "comb.concat"(%69, %123) : (i8, i8) -> i16
    %350 = "comb.concat"(%0, %303) : (i2, i14) -> i16
    %351 = "comb.concat"(%63, %305) : (i1, i15) -> i16
    %352 = "comb.concat"(%63, %307) : (i1, i15) -> i16
    %353 = "comb.concat"(%68, %315) : (i4, i12) -> i16
    %354 = "comb.concat"(%0, %317) : (i2, i14) -> i16
    %355 = "comb.concat"(%63, %319) : (i1, i15) -> i16
    %356 = "comb.add"(%323, %324, %325, %205, %207, %209, %326, %327, %328, %217, %219, %221, %223, %329, %330, %331, %229, %231, %233, %235, %332, %333, %334, %243, %245, %247, %335, %336, %337, %338, %257, %259, %261, %339, %340, %341, %342, %271, %273, %275, %343, %344, %345, %283, %285, %287, %289, %346, %347, %348, %297, %299, %301, %349, %350, %351, %352, %309, %311, %313, %353, %354, %355) <{twoState}> {sv.namehint = "_io_out_T_62"} : (i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16, i16) -> i16
    "hw.output"(%356) : (i16) -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Fir64_Verification", verilogName = "layers_Fir64_Verification"}> : () -> ()
  "emit.file"() <{file_name = "verification/layers-Fir64-Verification.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Fir64_Verification>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Fir64_Verification, symbols = []}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Fir64_Verification_Assert", verilogName = "layers_Fir64_Verification_Assert"}> : () -> ()
  "emit.file"() <{file_name = "verification/assert/layers-Fir64-Verification-Assert.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Fir64_Verification_Assert>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Fir64_Verification_Assert, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Fir64-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Fir64_Verification_Assume", verilogName = "layers_Fir64_Verification_Assume"}> : () -> ()
  "emit.file"() <{file_name = "verification/assume/layers-Fir64-Verification-Assume.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Fir64_Verification_Assume>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Fir64_Verification_Assume, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Fir64-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "sv.macro.decl"() <{sym_name = "layers_Fir64_Verification_Cover", verilogName = "layers_Fir64_Verification_Cover"}> : () -> ()
  "emit.file"() <{file_name = "verification/cover/layers-Fir64-Verification-Cover.sv"}> ({
    "sv.ifdef"() <{cond = #sv<macro.ident @layers_Fir64_Verification_Cover>}> ({
    ^bb0:
    }, {
      "sv.macro.def"() <{format_string = "", macroName = @layers_Fir64_Verification_Cover, symbols = []}> : () -> ()
      "sv.include"() <{style = #sv<include_style local>, target = "layers-Fir64-Verification.sv"}> : () -> ()
    }) : () -> ()
  }) : () -> ()
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "Fir64_Class"}> ({
  ^bb0(%arg0: !om.basepath):
    "om.class.fields"() : () -> ()
  }) : () -> ()
}) : () -> ()

