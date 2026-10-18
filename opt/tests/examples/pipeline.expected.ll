; @fact: recursion: 1 call(s) now push a frame on an explicit stack (values saved per frame: 1)
; @fact: combine: sub_const x2
; @main: inlined @fact: cost 24, bonus 8, threshold 100
; @fact: deleted, no longer used


define i32 @main() {
entry:
  %frames.i = alloca { ptr, ptr, [64 x { i64 }] }
  %savedstack = call ptr @llvm.stacksave.p0()
  store ptr null, ptr %frames.i
  br label %rec.header.i

rec.header.i:                                     ; preds = %recur.i, %entry
  %n.i = phi i64 [ 10, %entry ], [ %m.i, %recur.i ]
  %chunk.top.i = phi ptr [ %frames.i, %entry ], [ %chunk.i, %recur.i ]
  %index.top.i = phi i32 [ 0, %entry ], [ %index.next.i, %recur.i ]
  %chunk.full.i = icmp eq i32 %index.top.i, 64
  br i1 %chunk.full.i, label %rec.grow.i, label %entry.i

rec.grow.i:                                       ; preds = %rec.header.i
  %sp.i = call ptr @llvm.stacksave.p0()
  %chunk.new.i = alloca { ptr, ptr, [64 x { i64 }] }
  store ptr %chunk.top.i, ptr %chunk.new.i
  %chunk.sp.i = getelementptr inbounds { ptr, ptr, [64 x { i64 }] }, ptr %chunk.new.i, i32 0, i32 1
  store ptr %sp.i, ptr %chunk.sp.i
  br label %entry.i

entry.i:                                          ; preds = %rec.grow.i, %rec.header.i
  %chunk.i = phi ptr [ %chunk.top.i, %rec.header.i ], [ %chunk.new.i, %rec.grow.i ]
  %index.i = phi i32 [ %index.top.i, %rec.header.i ], [ 0, %rec.grow.i ]
  %base.i = icmp ule i64 %n.i, 1
  br i1 %base.i, label %one.i, label %recur.i

recur.i:                                          ; preds = %entry.i
  %m.i = add i64 %n.i, -1
  %frame0.i = getelementptr inbounds { ptr, ptr, [64 x { i64 }] }, ptr %chunk.i, i32 0, i32 2, i32 %index.i
  store i64 %n.i, ptr %frame0.i
  %index.next.i = add nuw i32 %index.i, 1
  br label %rec.header.i

one.i:                                            ; preds = %entry.i
  br label %rec.return.i

rec.return.i:                                     ; preds = %rec.pop.i, %one.i
  %chunk1.i = phi ptr [ %chunk.pop.i, %rec.pop.i ], [ %chunk.i, %one.i ]
  %index1.i = phi i32 [ %index.prev.i, %rec.pop.i ], [ %index.i, %one.i ]
  %result.i = phi i64 [ %p.i, %rec.pop.i ], [ 1, %one.i ]
  %chunk.empty.i = icmp eq i32 %index1.i, 0
  br i1 %chunk.empty.i, label %rec.underflow.i, label %rec.pop.i

rec.underflow.i:                                  ; preds = %rec.return.i
  %chunk.prev.i = load ptr, ptr %chunk1.i
  %stack.empty.i = icmp eq ptr %chunk.prev.i, null
  br i1 %stack.empty.i, label %return.i, label %rec.shrink.i

return.i:                                         ; preds = %rec.underflow.i
  call void @llvm.stackrestore.p0(ptr %savedstack)
  %x = trunc i64 %result.i to i32
  ret i32 %x

rec.shrink.i:                                     ; preds = %rec.underflow.i
  %chunk.sp1.i = getelementptr inbounds { ptr, ptr, [64 x { i64 }] }, ptr %chunk1.i, i32 0, i32 1
  %saved.sp.i = load ptr, ptr %chunk.sp1.i
  call void @llvm.stackrestore.p0(ptr %saved.sp.i)
  br label %rec.pop.i

rec.pop.i:                                        ; preds = %rec.shrink.i, %rec.return.i
  %chunk.pop.i = phi ptr [ %chunk1.i, %rec.return.i ], [ %chunk.prev.i, %rec.shrink.i ]
  %index.pop.i = phi i32 [ %index1.i, %rec.return.i ], [ 64, %rec.shrink.i ]
  %index.prev.i = add i32 %index.pop.i, -1
  %frame.i = getelementptr inbounds { ptr, ptr, [64 x { i64 }] }, ptr %chunk.pop.i, i32 0, i32 2, i32 %index.prev.i
  %n.saved.i = load i64, ptr %frame.i
  %p.i = mul i64 %n.saved.i, %result.i
  br label %rec.return.i
}

declare ptr @llvm.stacksave.p0()

declare void @llvm.stackrestore.p0(ptr)
