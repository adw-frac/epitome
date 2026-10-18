; @walk: recursion: 1 call(s) now push a frame on an explicit stack (values saved per frame: 1)
; @walk: combine: sub_const x1


declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)

define i32 @walk(i32 %n.arg) {
entry.rec:
  br label %entry

entry:                                            ; preds = %recur, %entry.rec
  %n = phi i32 [ %n.arg, %entry.rec ], [ %m, %recur ]
  %frame.top = phi ptr [ null, %entry.rec ], [ %frame0, %recur ]
  %buf = alloca [4 x i32]
  call void @llvm.memset.p0.i64(ptr %buf, i8 0, i64 16, i1 false)
  store i32 %n, ptr %buf
  %stop = icmp eq i32 %n, 0
  br i1 %stop, label %done, label %recur

recur:                                            ; preds = %entry
  %m = add i32 %n, -1
  %sp = call ptr @llvm.stacksave.p0()
  %frame0 = alloca { ptr, ptr, ptr }
  store ptr %frame.top, ptr %frame0
  %frame.sp = getelementptr inbounds { ptr, ptr, ptr }, ptr %frame0, i32 0, i32 1
  store ptr %sp, ptr %frame.sp
  %frame.slot = getelementptr inbounds { ptr, ptr, ptr }, ptr %frame0, i32 0, i32 2
  store ptr %buf, ptr %frame.slot
  br label %entry

done:                                             ; preds = %entry
  br label %rec.return

rec.return:                                       ; preds = %rec.pop, %done
  %result = phi i32 [ %sum, %rec.pop ], [ 0, %done ]
  %frame = phi ptr [ %frame.prev, %rec.pop ], [ %frame.top, %done ]
  %stack.empty = icmp eq ptr %frame, null
  br i1 %stack.empty, label %return, label %rec.pop

return:                                           ; preds = %rec.return
  ret i32 %result

rec.pop:                                          ; preds = %rec.return
  %frame.prev = load ptr, ptr %frame
  %frame.sp1 = getelementptr inbounds { ptr, ptr }, ptr %frame, i32 0, i32 1
  %saved.sp = load ptr, ptr %frame.sp1
  %frame.slot1 = getelementptr inbounds { ptr, ptr, ptr }, ptr %frame, i32 0, i32 2
  %buf.saved = load ptr, ptr %frame.slot1
  call void @llvm.stackrestore.p0(ptr %saved.sp)
  %mine = load i32, ptr %buf.saved
  %sum = add i32 %result, %mine
  br label %rec.return
}

define i32 @main() {
entry:
  %x = call i32 @walk(i32 10)
  ret i32 %x
}

declare ptr @llvm.stacksave.p0()

declare void @llvm.stackrestore.p0(ptr)
