#Import "../regal"

Using regal.memory..
Using regal.util.stringutil..

Function Main:Void()
	Local buffer:= New DataBuffer(1024)
	
	ClearBuffer(buffer, 0)
	
	Local view:= New ImageView(New BufferPointer(buffer), 1, 1)
	
	Local vindex:= 0
	Local vindex_ptr:= Varptr vindex
	
	' Local-only lambda, do not use outside of this scope.
	Local add:= Lambda(value:Int)
		view.Set(vindex_ptr[0], value); vindex_ptr[0] += 1
	End
	
	add(1); add(1); add(0); add(1)
	add(1); add(0); add(1); add(1)
	
	add(0); add(1); add(1); add(1)
	add(1); add(0); add(0); add(1)
	
	add(0); add(1); add(0); add(1)
	add(1); add(1); add(0); add(1)
	
	add(1); add(1); add(1); add(1)
	add(0); add(1); add(0); add(0)
	
	Print(RepresentBytes(view.Data, Max((vindex / 8), 1)))
	Print(RepresentBits(view, vindex))
End

Function ClearBuffer:Void(buffer:DataBuffer, value:Int=0)
	libc.memset(buffer.Data, value, buffer.Length)
End