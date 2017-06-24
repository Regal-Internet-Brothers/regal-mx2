#Import "../regal"

Using regal.memory..

Function Main:Void()
	Local buffer:= New DataBuffer(1024)
	
	ClearBuffer(buffer, 0)
	
	Local view:= New ImageView(New BufferPointer(buffer), 1, 1)
	
	Print("BitsPerChannel: " + view.BitsPerChannel)
	
	'Method New(data:DataBuffer, channels:Int, depth:Int, offset:Int=0)
	
	Local be:= False ' True
	
	'DebugStop()
	
	Local entries:= 16
	
	For Local i:= 0 Until entries
		'view.Set(i, ((i + 1) Mod 2), be)
	Next
	
	Local vindex:= 0
	Local vindex_ptr:= Varptr vindex
	
	' Local-only lambda, do not use outside of this scope.
	Local add:= Lambda(value:Int)
		view.Set(vindex_ptr[0], value, be); vindex_ptr[0] += 1
	End
	
	add(1); add(1); add(0); add(1)
	add(1); add(0); add(1); add(1)
	
	add(0); add(1); add(1); add(1)
	add(1); add(0); add(0); add(1)
	
	Local val_a:= buffer.PeekUByte(0)
	Local val_b:= buffer.PeekUByte(1)
	
	Print("RAW: " + val_a + ", " + val_b)
	
	Local str:String
	
	Local out_be:= be
	
	Local final_index:= (vindex - 1) ' (entries - 1)
	
	For Local i:= 0 Until final_index
		If ((i Mod 8) = 0) Then
			str += "| "
		Elseif ((i Mod 4) = 0) Then
			str += " +  "
		Endif
		
		str += String(view.Get(i, out_be)) + ", "
	Next
	
	str += String(view.Get(final_index, out_be))
	
	Print(str)
End

Function ClearBuffer:Void(buffer:DataBuffer, value:Int=0)
	libc.memset(buffer.Data, value, buffer.Length)
End