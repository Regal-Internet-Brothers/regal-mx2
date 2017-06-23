#Import "../regal"

Using regal.memory.bufferview

' Functions:
Function Main:Void()
	Local buffer:= New ShortArrayView(512)
	
	Local indices:= New UInt[](0, 1)
	Local values:= New Int[](1234, 5678)
	Local itemCount:= values.Length ' 2
	
	Print("Storing the following values at the indices posted:")
	
	For Local i:= 0 Until itemCount
		Print("[" + indices[i] + "]: " + values[i])
		
		buffer.Set(indices[i], values[i])
	Next
	
	Print("Retrieving values:")
	
	RetrieveValues(buffer, 0, itemCount)
	
	Print("Clearing the first entry of the buffer...")
	
	buffer.Clear(0, 1)
	
	Print("Retrieving values again:")
	
	RetrieveValues(buffer, 0, itemCount)
	
	Print("Clearing the entire buffer...")
	
	buffer.Clear()
	
	Print("Retrieving values again (Should be zero-initialized):")
	
	RetrieveValues(buffer, 0, itemCount)
End

Function RetrieveValues<ViewType>:Void(buffer:ViewType, offset:Int, itemCount:Int)
	For Local i:= offset Until itemCount
		Print("[" + i + "]: " + buffer.Get(i))
	Next
End