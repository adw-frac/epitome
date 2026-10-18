; @f: recursion: 1 call(s) now push a frame on an explicit stack (values saved per frame: 1)
; @f: combine: sub_const x2


@fmt = private constant [4 x i8] c"%d\0A\00"

declare i32 @printf(ptr, ...)

define internal i32 @f(i32 %n.arg) {
entry.rec:
  %frames = alloca { ptr, ptr, [64 x { i32 }] }
  store ptr null, ptr %frames
  br label %rec.header

rec.header:                                       ; preds = %rec, %entry.rec
  %n = phi i32 [ %n.arg, %entry.rec ], [ %a, %rec ]
  %chunk.top = phi ptr [ %frames, %entry.rec ], [ %chunk, %rec ]
  %index.top = phi i32 [ 0, %entry.rec ], [ %index.next, %rec ]
  %chunk.full = icmp eq i32 %index.top, 64
  br i1 %chunk.full, label %rec.grow, label %entry

rec.grow:                                         ; preds = %rec.header
  %sp = call ptr @llvm.stacksave.p0()
  %chunk.new = alloca { ptr, ptr, [64 x { i32 }] }
  store ptr %chunk.top, ptr %chunk.new
  %chunk.sp = getelementptr inbounds { ptr, ptr, [64 x { i32 }] }, ptr %chunk.new, i32 0, i32 1
  store ptr %sp, ptr %chunk.sp
  br label %entry

entry:                                            ; preds = %rec.grow, %rec.header
  %chunk = phi ptr [ %chunk.top, %rec.header ], [ %chunk.new, %rec.grow ]
  %index = phi i32 [ %index.top, %rec.header ], [ 0, %rec.grow ]
  switch i32 %n, label %rec [
    i32 0, label %done
    i32 1, label %done
  ]

rec:                                              ; preds = %entry
  %a = add i32 %n, -1
  %frame0 = getelementptr inbounds { ptr, ptr, [64 x { i32 }] }, ptr %chunk, i32 0, i32 2, i32 %index
  store i32 %n, ptr %frame0
  %index.next = add nuw i32 %index, 1
  br label %rec.header

done:                                             ; preds = %rec.pop, %entry
  %chunk1 = phi ptr [ %chunk, %entry ], [ %chunk, %entry ], [ %chunk.pop, %rec.pop ]
  %index1 = phi i32 [ %index, %entry ], [ %index, %entry ], [ %index.prev, %rec.pop ]
  %p = phi i32 [ 0, %entry ], [ 0, %entry ], [ %s, %rec.pop ]
  %chunk.empty = icmp eq i32 %index1, 0
  br i1 %chunk.empty, label %rec.underflow, label %rec.pop

rec.underflow:                                    ; preds = %done
  %chunk.prev = load ptr, ptr %chunk1
  %stack.empty = icmp eq ptr %chunk.prev, null
  br i1 %stack.empty, label %return, label %rec.shrink

return:                                           ; preds = %rec.underflow
  ret i32 %p

rec.shrink:                                       ; preds = %rec.underflow
  %chunk.sp1 = getelementptr inbounds { ptr, ptr, [64 x { i32 }] }, ptr %chunk1, i32 0, i32 1
  %saved.sp = load ptr, ptr %chunk.sp1
  call void @llvm.stackrestore.p0(ptr %saved.sp)
  br label %rec.pop

rec.pop:                                          ; preds = %rec.shrink, %done
  %chunk.pop = phi ptr [ %chunk1, %done ], [ %chunk.prev, %rec.shrink ]
  %index.pop = phi i32 [ %index1, %done ], [ 64, %rec.shrink ]
  %index.prev = add i32 %index.pop, -1
  %frame = getelementptr inbounds { ptr, ptr, [64 x { i32 }] }, ptr %chunk.pop, i32 0, i32 2, i32 %index.prev
  %n.saved = load i32, ptr %frame
  %s = add i32 %p, %n.saved
  br label %done
}

define i32 @main() {
  %v = call i32 @f(i32 100)
  %1 = call i32 (ptr, ...) @printf(ptr @fmt, i32 %v)
  ret i32 0
}

declare ptr @llvm.stacksave.p0()

declare void @llvm.stackrestore.p0(ptr)
