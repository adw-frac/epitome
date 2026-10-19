target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"

@g = global i32 7

declare void @opaque()

declare i32 @reads(ptr) memory(read)

declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)

define i32 @straight(ptr %p, ptr %q) {
entry:
  %a = alloca [4 x i32]
  %b = alloca i32
  %a0 = getelementptr inbounds [4 x i32], ptr %a, i64 0, i64 0
  %a1 = getelementptr inbounds [4 x i32], ptr %a, i64 0, i64 1
  ; 1 = MemoryDef(liveOnEntry) -- writes over liveOnEntry
  store i32 1, ptr %a0
  ; 2 = MemoryDef(1) -- writes over liveOnEntry
  store i32 2, ptr %a1
  ; 3 = MemoryDef(2) -- writes over liveOnEntry
  store i32 3, ptr %b
  ; 4 = MemoryDef(3) -- writes over liveOnEntry
  store i32 4, ptr %p
  ; MemoryUse(4) -- clobbered by 1
  %x = load i32, ptr %a0
  ; MemoryUse(4) -- clobbered by 4
  %y = load i32, ptr %q
  ; MemoryUse(4)
  %r = call i32 @reads(ptr %q)
  ; 5 = MemoryDef(4)
  call void @opaque()
  ; MemoryUse(5) -- clobbered by 5
  %z = load i32, ptr %p
  ; MemoryUse(5) -- clobbered by 2
  %w = load i32, ptr %a1
  %s1 = add i32 %x, %y
  %s2 = add i32 %z, %w
  %s3 = add i32 %s1, %s2
  ret i32 %s3
}

define i32 @diamond(i1 %c, ptr %p, ptr noalias %n) {
entry:
  ; 1 = MemoryDef(liveOnEntry) -- writes over liveOnEntry
  store i32 0, ptr %n
  br i1 %c, label %then, label %else

then:                                             ; preds = %entry
  ; 3 = MemoryDef(1) -- writes over liveOnEntry
  store i32 1, ptr %p
  br label %join

else:                                             ; preds = %entry
  ; 2 = MemoryDef(1) -- writes over liveOnEntry
  store i32 2, ptr %p
  br label %join

join:                                             ; preds = %else, %then
  ; 4 = MemoryPhi({%then,3},{%else,2})
  ; MemoryUse(4) -- clobbered by 4
  %v = load i32, ptr %p
  ; MemoryUse(4) -- clobbered by 1
  %u = load i32, ptr %n
  %t = add i32 %v, %u
  ret i32 %t
}

define i32 @loop(i64 %n) {
entry:
  %buf = alloca [16 x i32]
  ; 1 = MemoryDef(liveOnEntry) -- writes over liveOnEntry
  store i32 5, ptr @g
  br label %head

head:                                             ; preds = %head, %entry
  ; 2 = MemoryPhi({%entry,1},{%head,3})
  %i = phi i64 [ 0, %entry ], [ %i1, %head ]
  %e = getelementptr inbounds [16 x i32], ptr %buf, i64 0, i64 %i
  ; 3 = MemoryDef(2) -- writes over 2
  store i32 9, ptr %e
  %i1 = add i64 %i, 1
  %c = icmp ult i64 %i1, %n
  br i1 %c, label %head, label %exit

exit:                                             ; preds = %head
  ; MemoryUse(3) -- clobbered by 1
  %v = load i32, ptr @g
  ret i32 %v
}

define i32 @copies(ptr noalias %dst, ptr noalias %src, ptr noalias %other) {
entry:
  ; 1 = MemoryDef(liveOnEntry) -- writes over liveOnEntry
  store i32 1, ptr %other
  ; 2 = MemoryDef(1)
  call void @llvm.memcpy.p0.p0.i64(ptr %dst, ptr %src, i64 16, i1 false)
  %d4 = getelementptr inbounds i8, ptr %dst, i64 4
  %d32 = getelementptr inbounds i8, ptr %dst, i64 32
  ; MemoryUse(2) -- clobbered by 2
  %x = load i32, ptr %d4
  ; MemoryUse(2) -- clobbered by liveOnEntry
  %y = load i32, ptr %d32
  ; MemoryUse(2) -- clobbered by 1
  %o = load i32, ptr %other
  ; 3 = MemoryDef(2) -- writes over liveOnEntry
  %v = load volatile i32, ptr %src
  %s = add i32 %x, %y
  %t = add i32 %s, %o
  %u = add i32 %t, %v
  ret i32 %u
}

define i32 @carried(ptr %a, ptr %p, i64 %n) {
entry:
  br label %head

head:                                             ; preds = %head, %entry
  ; 1 = MemoryPhi({%entry,liveOnEntry},{%head,2})
  %i = phi i64 [ 0, %entry ], [ %i1, %head ]
  %e = getelementptr inbounds i32, ptr %a, i64 %i
  ; MemoryUse(1) -- clobbered by 1
  %x = load i32, ptr %e
  ; MemoryUse(1) -- clobbered by 1
  %y = load i32, ptr %p
  ; 2 = MemoryDef(1) -- writes over 1
  store i32 %x, ptr %e
  %i1 = add i64 %i, 1
  %c = icmp ult i64 %i1, %n
  br i1 %c, label %head, label %exit

exit:                                             ; preds = %head
  ; MemoryUse(2) -- clobbered by 2
  %z = load i32, ptr %p
  ret i32 %z
}
