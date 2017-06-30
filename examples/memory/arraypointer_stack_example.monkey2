#Import "../regal"

#Import "<std>"

Using regal.memory.pointers..
Using std..

Function Main:Void()
	Local data_count:= 4
	Local data:= New IntStack()
	
	Local data_pointer:= New ContainerPointer<IntStack, Int>(data)
	
	For Local i:= 0 Until data_count
		data.Push((i + 1))
	Next
	
	For Local i:= 0 Until data_count
		Print(Int(data_pointer))
		
		data_pointer += 1
	Next
End