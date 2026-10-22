; The AArch64 description: CRC32 and the cryptographic extensions (AES,
; SHA-1, SHA-256, SHA-512), as LLVM's intrinsics for them name them. The
; conventions are in 00-base.ll; the encodings are Arm's (as 80-asm.ll's).
; Each is used only where its feature is on (crc, aes, sha2, sha3: LLVM's
; names, as "target-features" give them).

; CRC32: the checksum so far, updated with a byte, halfword, word or doubleword.
define i32 @CRC32B(i32 "reg"="w" %n, i32 "reg"="w" %m) "feature"="crc" "enc"="00011010110 m:5 010000 n:5 d:5" "asm"="crc32b {d}, {n}, {m}" {
  %r = call i32 @llvm.aarch64.crc32b(i32 %n, i32 %m)
  ret i32 %r
}

declare i32 @llvm.aarch64.crc32b(i32, i32)

define i32 @CRC32H(i32 "reg"="w" %n, i32 "reg"="w" %m) "feature"="crc" "enc"="00011010110 m:5 010001 n:5 d:5" "asm"="crc32h {d}, {n}, {m}" {
  %r = call i32 @llvm.aarch64.crc32h(i32 %n, i32 %m)
  ret i32 %r
}

declare i32 @llvm.aarch64.crc32h(i32, i32)

define i32 @CRC32W(i32 "reg"="w" %n, i32 "reg"="w" %m) "feature"="crc" "enc"="00011010110 m:5 010010 n:5 d:5" "asm"="crc32w {d}, {n}, {m}" {
  %r = call i32 @llvm.aarch64.crc32w(i32 %n, i32 %m)
  ret i32 %r
}

declare i32 @llvm.aarch64.crc32w(i32, i32)

define i32 @CRC32CB(i32 "reg"="w" %n, i32 "reg"="w" %m) "feature"="crc" "enc"="00011010110 m:5 010100 n:5 d:5" "asm"="crc32cb {d}, {n}, {m}" {
  %r = call i32 @llvm.aarch64.crc32cb(i32 %n, i32 %m)
  ret i32 %r
}

declare i32 @llvm.aarch64.crc32cb(i32, i32)

define i32 @CRC32CH(i32 "reg"="w" %n, i32 "reg"="w" %m) "feature"="crc" "enc"="00011010110 m:5 010101 n:5 d:5" "asm"="crc32ch {d}, {n}, {m}" {
  %r = call i32 @llvm.aarch64.crc32ch(i32 %n, i32 %m)
  ret i32 %r
}

declare i32 @llvm.aarch64.crc32ch(i32, i32)

define i32 @CRC32CW(i32 "reg"="w" %n, i32 "reg"="w" %m) "feature"="crc" "enc"="00011010110 m:5 010110 n:5 d:5" "asm"="crc32cw {d}, {n}, {m}" {
  %r = call i32 @llvm.aarch64.crc32cw(i32 %n, i32 %m)
  ret i32 %r
}

declare i32 @llvm.aarch64.crc32cw(i32, i32)

define i32 @CRC32X(i32 "reg"="w" %n, i64 "reg"="x" %m) "feature"="crc" "enc"="10011010110 m:5 010011 n:5 d:5" "asm"="crc32x {d}, {n}, {m}" {
  %r = call i32 @llvm.aarch64.crc32x(i32 %n, i64 %m)
  ret i32 %r
}

declare i32 @llvm.aarch64.crc32x(i32, i64)

define i32 @CRC32CX(i32 "reg"="w" %n, i64 "reg"="x" %m) "feature"="crc" "enc"="10011010110 m:5 010111 n:5 d:5" "asm"="crc32cx {d}, {n}, {m}" {
  %r = call i32 @llvm.aarch64.crc32cx(i32 %n, i64 %m)
  ret i32 %r
}

declare i32 @llvm.aarch64.crc32cx(i32, i64)

; AES: a round's substitution and key, and its column mixing.
define <16 x i8> @AESE(<16 x i8> "reg"="q" "tied" %old, <16 x i8> "reg"="q" %n) "feature"="aes" "enc"="0100111000101000010010 n:5 d:5" "asm"="aese {d:16b}, {n:16b}" {
  %r = call <16 x i8> @llvm.aarch64.crypto.aese(<16 x i8> %old, <16 x i8> %n)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.crypto.aese(<16 x i8>, <16 x i8>)

define <16 x i8> @AESD(<16 x i8> "reg"="q" "tied" %old, <16 x i8> "reg"="q" %n) "feature"="aes" "enc"="0100111000101000010110 n:5 d:5" "asm"="aesd {d:16b}, {n:16b}" {
  %r = call <16 x i8> @llvm.aarch64.crypto.aesd(<16 x i8> %old, <16 x i8> %n)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.crypto.aesd(<16 x i8>, <16 x i8>)

define <16 x i8> @AESMC(<16 x i8> "reg"="q" %n) "feature"="aes" "enc"="0100111000101000011010 n:5 d:5" "asm"="aesmc {d:16b}, {n:16b}" {
  %r = call <16 x i8> @llvm.aarch64.crypto.aesmc(<16 x i8> %n)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.crypto.aesmc(<16 x i8>)

define <16 x i8> @AESIMC(<16 x i8> "reg"="q" %n) "feature"="aes" "enc"="0100111000101000011110 n:5 d:5" "asm"="aesimc {d:16b}, {n:16b}" {
  %r = call <16 x i8> @llvm.aarch64.crypto.aesimc(<16 x i8> %n)
  ret <16 x i8> %r
}

declare <16 x i8> @llvm.aarch64.crypto.aesimc(<16 x i8>)

; SHA-256: two rounds' hash updates, and the schedule's.
define <4 x i32> @SHA256H(<4 x i32> "reg"="q" "tied" %old, <4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "enc"="01011110000 m:5 010000 n:5 d:5" "asm"="sha256h {d}, {n}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.crypto.sha256h(<4 x i32> %old, <4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.crypto.sha256h(<4 x i32>, <4 x i32>, <4 x i32>)

define <4 x i32> @SHA256H2(<4 x i32> "reg"="q" "tied" %old, <4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "enc"="01011110000 m:5 010100 n:5 d:5" "asm"="sha256h2 {d}, {n}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.crypto.sha256h2(<4 x i32> %old, <4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.crypto.sha256h2(<4 x i32>, <4 x i32>, <4 x i32>)

define <4 x i32> @SHA256SU1(<4 x i32> "reg"="q" "tied" %old, <4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "enc"="01011110000 m:5 011000 n:5 d:5" "asm"="sha256su1 {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.crypto.sha256su1(<4 x i32> %old, <4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.crypto.sha256su1(<4 x i32>, <4 x i32>, <4 x i32>)

define <4 x i32> @SHA256SU0(<4 x i32> "reg"="q" "tied" %old, <4 x i32> "reg"="q" %n) "feature"="sha2" "enc"="0101111000101000001010 n:5 d:5" "asm"="sha256su0 {d:4s}, {n:4s}" {
  %r = call <4 x i32> @llvm.aarch64.crypto.sha256su0(<4 x i32> %old, <4 x i32> %n)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.crypto.sha256su0(<4 x i32>, <4 x i32>)

; SHA-1: the hash's update by choose, parity and majority (the fifth word
; of the hash in an s register), its rotation, and the schedule's.
define <4 x i32> @sha1c.w(<4 x i32> "reg"="q" "tied" %old, i32 "reg"="w" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "recipe"="sha1c.expand" {
  %r = call <4 x i32> @llvm.aarch64.crypto.sha1c(<4 x i32> %old, i32 %n, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @sha1c.expand(<4 x i32> %old, i32 %n, <4 x i32> %m) {
  %e = call float @FMOVSW(i32 %n)
  %r = call <4 x i32> @SHA1C(<4 x i32> %old, float %e, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @SHA1C(<4 x i32> "reg"="q" "tied" %old, float "reg"="s" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "enc"="01011110000 m:5 000000 n:5 d:5" "asm"="sha1c {d}, {n}, {m:4s}" "nomatch" {
  ret <4 x i32> %old
}

declare <4 x i32> @llvm.aarch64.crypto.sha1c(<4 x i32>, i32, <4 x i32>)

define <4 x i32> @sha1p.w(<4 x i32> "reg"="q" "tied" %old, i32 "reg"="w" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "recipe"="sha1p.expand" {
  %r = call <4 x i32> @llvm.aarch64.crypto.sha1p(<4 x i32> %old, i32 %n, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @sha1p.expand(<4 x i32> %old, i32 %n, <4 x i32> %m) {
  %e = call float @FMOVSW(i32 %n)
  %r = call <4 x i32> @SHA1P(<4 x i32> %old, float %e, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @SHA1P(<4 x i32> "reg"="q" "tied" %old, float "reg"="s" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "enc"="01011110000 m:5 000100 n:5 d:5" "asm"="sha1p {d}, {n}, {m:4s}" "nomatch" {
  ret <4 x i32> %old
}

declare <4 x i32> @llvm.aarch64.crypto.sha1p(<4 x i32>, i32, <4 x i32>)

define <4 x i32> @sha1m.w(<4 x i32> "reg"="q" "tied" %old, i32 "reg"="w" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "recipe"="sha1m.expand" {
  %r = call <4 x i32> @llvm.aarch64.crypto.sha1m(<4 x i32> %old, i32 %n, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @sha1m.expand(<4 x i32> %old, i32 %n, <4 x i32> %m) {
  %e = call float @FMOVSW(i32 %n)
  %r = call <4 x i32> @SHA1M(<4 x i32> %old, float %e, <4 x i32> %m)
  ret <4 x i32> %r
}

define <4 x i32> @SHA1M(<4 x i32> "reg"="q" "tied" %old, float "reg"="s" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "enc"="01011110000 m:5 001000 n:5 d:5" "asm"="sha1m {d}, {n}, {m:4s}" "nomatch" {
  ret <4 x i32> %old
}

declare <4 x i32> @llvm.aarch64.crypto.sha1m(<4 x i32>, i32, <4 x i32>)

define <4 x i32> @SHA1SU0(<4 x i32> "reg"="q" "tied" %old, <4 x i32> "reg"="q" %n, <4 x i32> "reg"="q" %m) "feature"="sha2" "enc"="01011110000 m:5 001100 n:5 d:5" "asm"="sha1su0 {d:4s}, {n:4s}, {m:4s}" {
  %r = call <4 x i32> @llvm.aarch64.crypto.sha1su0(<4 x i32> %old, <4 x i32> %n, <4 x i32> %m)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.crypto.sha1su0(<4 x i32>, <4 x i32>, <4 x i32>)

define <4 x i32> @SHA1SU1(<4 x i32> "reg"="q" "tied" %old, <4 x i32> "reg"="q" %n) "feature"="sha2" "enc"="0101111000101000000110 n:5 d:5" "asm"="sha1su1 {d:4s}, {n:4s}" {
  %r = call <4 x i32> @llvm.aarch64.crypto.sha1su1(<4 x i32> %old, <4 x i32> %n)
  ret <4 x i32> %r
}

declare <4 x i32> @llvm.aarch64.crypto.sha1su1(<4 x i32>, <4 x i32>)

define i32 @sha1h.w(i32 "reg"="w" %n) "feature"="sha2" "recipe"="sha1h.expand" {
  %r = call i32 @llvm.aarch64.crypto.sha1h(i32 %n)
  ret i32 %r
}

define i32 @sha1h.expand(i32 %n) {
  %e = call float @FMOVSW(i32 %n)
  %h = call float @SHA1H(float %e)
  %r = call i32 @FMOVWS(float %h)
  ret i32 %r
}

define float @SHA1H(float "reg"="s" %n) "feature"="sha2" "enc"="0101111000101000000010 n:5 d:5" "asm"="sha1h {d}, {n}" "nomatch" {
  ret float %n
}

declare i32 @llvm.aarch64.crypto.sha1h(i32)

; SHA-512: two rounds' hash updates, and the schedule's.
define <2 x i64> @SHA512H(<2 x i64> "reg"="q" "tied" %old, <2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="sha3" "enc"="11001110011 m:5 100000 n:5 d:5" "asm"="sha512h {d}, {n}, {m:2d}" {
  %r = call <2 x i64> @llvm.aarch64.crypto.sha512h(<2 x i64> %old, <2 x i64> %n, <2 x i64> %m)
  ret <2 x i64> %r
}

declare <2 x i64> @llvm.aarch64.crypto.sha512h(<2 x i64>, <2 x i64>, <2 x i64>)

define <2 x i64> @SHA512H2(<2 x i64> "reg"="q" "tied" %old, <2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="sha3" "enc"="11001110011 m:5 100001 n:5 d:5" "asm"="sha512h2 {d}, {n}, {m:2d}" {
  %r = call <2 x i64> @llvm.aarch64.crypto.sha512h2(<2 x i64> %old, <2 x i64> %n, <2 x i64> %m)
  ret <2 x i64> %r
}

declare <2 x i64> @llvm.aarch64.crypto.sha512h2(<2 x i64>, <2 x i64>, <2 x i64>)

define <2 x i64> @SHA512SU1(<2 x i64> "reg"="q" "tied" %old, <2 x i64> "reg"="q" %n, <2 x i64> "reg"="q" %m) "feature"="sha3" "enc"="11001110011 m:5 100010 n:5 d:5" "asm"="sha512su1 {d:2d}, {n:2d}, {m:2d}" {
  %r = call <2 x i64> @llvm.aarch64.crypto.sha512su1(<2 x i64> %old, <2 x i64> %n, <2 x i64> %m)
  ret <2 x i64> %r
}

declare <2 x i64> @llvm.aarch64.crypto.sha512su1(<2 x i64>, <2 x i64>, <2 x i64>)

define <2 x i64> @SHA512SU0(<2 x i64> "reg"="q" "tied" %old, <2 x i64> "reg"="q" %n) "feature"="sha3" "enc"="1100111011000000100000 n:5 d:5" "asm"="sha512su0 {d:2d}, {n:2d}" {
  %r = call <2 x i64> @llvm.aarch64.crypto.sha512su0(<2 x i64> %old, <2 x i64> %n)
  ret <2 x i64> %r
}

declare <2 x i64> @llvm.aarch64.crypto.sha512su0(<2 x i64>, <2 x i64>)
