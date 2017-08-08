#Import "../regal"

#Import "<std>"

Using regal.memory.pointers..
Using std..

Function Main:Void()
	Local data_count:= 4
	Local data:= New IntStack()
	
	Local data_pointer:= New ContainerPointer<IntStack, Int>(data)
	
	For Local i:= 0 Until data_count
		data.Push((i * i))
	Next
	
	For Local i:= 0 Until data_count
		Print(data_pointer.Get())
		
		data_pointer += 1
	Next
End