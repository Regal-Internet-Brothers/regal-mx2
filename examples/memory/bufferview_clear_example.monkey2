#Import "../regal"

Using regal.memory.bufferview

' Functions:
Function Main:Void()
	Local Buffer:= New ShortArrayView(512)
	
	Local Indices:= New UInt[](0, 1)
	Local Values:= New Int[](1234, 5678)
	Local ItemCount:= Values.Length ' 2
	
	Print("Storing the following values at the indices posted:")
	
	For Local I:= 0 Until ItemCount
		Print("[" + Indices[I] + "]: " + Values[I])
		
		Buffer.Set(Indices[I], Values[I])
	Next
	
	Print("Retrieving values:")
	
	RetrieveValues(Buffer, 0, ItemCount)
	
	Print("Clearing the first entry of the buffer...")
	
	Buffer.Clear(0, 1)
	
	Print("Retrieving values again:")
	
	RetrieveValues(Buffer, 0, ItemCount)
	
	Print("Clearing the entire buffer...")
	
	Buffer.Clear()
	
	Print("Retrieving values again (Should be zero-initialized):")
	
	RetrieveValues(Buffer, 0, ItemCount)
End

Function RetrieveValues:Void(Buffer:ShortArrayView, Offset:Int, ItemCount:Int) ' Buffer:IntArrayView
	For Local I:= Offset Until ItemCount
		Print("[" + I + "]: " + Buffer.Get(I))
	Next
End