; @sum: recursion: 1 call(s) now push a frame on an explicit stack (values saved per frame: 1)


%node = type { i32, ptr }

@n3 = global %node { i32 30, ptr null }
@n2 = global %node { i32 20, ptr @n3 }
@n1 = global %node { i32 10, ptr @n2 }

define i32 @sum(ptr %list.arg, i32 %depth) {
entry.rec:
  %frames = alloca { ptr, ptr, [64 x { i32 }] }
  store ptr null, ptr %frames
  br label %rec.header

rec.header:                                       ; preds = %more, %entry.rec
  %list = phi ptr [ %list.arg, %entry.rec ], [ %next, %more ]
  %chunk.top = phi ptr [ %frames, %entry.rec ], [ %chunk, %more ]
  %index.top = phi i32 [ 0, %entry.rec ], [ %index.next, %more ]
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
  %end = icmp eq ptr %list, null
  br i1 %end, label %empty, label %more

more:                                             ; preds = %entry
  %value = load i32, ptr %list
  %next.addr = getelementptr inbounds %node, ptr %list, i32 0, i32 1
  %next = load ptr, ptr %next.addr
  %frame0 = getelementptr inbounds { ptr, ptr, [64 x { i32 }] }, ptr %chunk, i32 0, i32 2, i32 %index
  store i32 %value, ptr %frame0
  %index.next = add nuw i32 %index, 1
  br label %rec.header

empty:                                            ; preds = %entry
  br label %rec.return

rec.return:                                       ; preds = %rec.pop, %empty
  %chunk1 = phi ptr [ %chunk.pop, %rec.pop ], [ %chunk, %empty ]
  %index1 = phi i32 [ %index.prev, %rec.pop ], [ %index, %empty ]
  %result = phi i32 [ %total, %rec.pop ], [ 0, %empty ]
  %chunk.empty = icmp eq i32 %index1, 0
  br i1 %chunk.empty, label %rec.underflow, label %rec.pop

rec.underflow:                                    ; preds = %rec.return
  %chunk.prev = load ptr, ptr %chunk1
  %stack.empty = icmp eq ptr %chunk.prev, null
  br i1 %stack.empty, label %return, label %rec.shrink

return:                                           ; preds = %rec.underflow
  ret i32 %result

rec.shrink:                                       ; preds = %rec.underflow
  %chunk.sp1 = getelementptr inbounds { ptr, ptr, [64 x { i32 }] }, ptr %chunk1, i32 0, i32 1
  %saved.sp = load ptr, ptr %chunk.sp1
  call void @llvm.stackrestore.p0(ptr %saved.sp)
  br label %rec.pop

rec.pop:                                          ; preds = %rec.shrink, %rec.return
  %chunk.pop = phi ptr [ %chunk1, %rec.return ], [ %chunk.prev, %rec.shrink ]
  %index.pop = phi i32 [ %index1, %rec.return ], [ 64, %rec.shrink ]
  %index.prev = sub nuw i32 %index.pop, 1
  %frame = getelementptr inbounds { ptr, ptr, [64 x { i32 }] }, ptr %chunk.pop, i32 0, i32 2, i32 %index.prev
  %value.saved = load i32, ptr %frame
  %scaled = mul i32 %value.saved, %depth
  %total = add i32 %scaled, %result
  br label %rec.return
}

define i32 @main() {
entry:
  %x = call i32 @sum(ptr @n1, i32 2)
  ret i32 %x
}

declare ptr @llvm.stacksave.p0()

declare void @llvm.stackrestore.p0(ptr)
