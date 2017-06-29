#Import "../regal"

Using regal.memory..

Function Main:Void()
	Local entry_count:= 16
	
	Local data:= BufferPointer.Allocate<Int>(entry_count)
	Local view:= New IntArrayView(data)
	
	data.Clear()
	
	For Local i:= 0 Until view.Length
		view[i] = (i + 1)
	Next
	
	For Local i:= 0 Until view.Length
		Print(view[i])
	Next
	
	data.Discard()
End