#Import "../regal"

Using regal.memory.pointers..

Function Main:Void()
	Local data_count:= 4
	
	Print("Allocating an array of " + data_count + " integers.")
	
	Local data:= New Int[data_count]
	
	Print("Creating an array-pointer to our newly allocated array.")
	
	Local data_pointer:= New ArrayPointer<Int>(data)
	
	Print("Populating our array with values ranging from 1 to " + data_count + "...")
	
	For Local i:= 0 Until data_count ' data.Length
		data[i] = (i + 1)
	Next
	
	Print("~nArray contents:~n")
	
	PrintArray(data)
	
	Print("~nMultiplying each element by 2, using our array-pointer...")
	
	For Local i:= 0 Until data_pointer.Length ' data_count
		data_pointer[i] *= 2
	Next
	
	Print("~nNow displaying array-pointer contents using incrementation:~n")
	
	For Local i:= 0 Until data_pointer.Length ' data_count ' data.Length
		PrintIndexedValue<Int>(data_pointer, i)
		
		data_pointer += 1
	Next
	
	If (data_pointer = Null) Then
		Print("~nSince we've finished incrementing through the entire array, our array-pointer is null.")
	Endif
End

Function PrintArray<ArrayType>:Void(data:ArrayType)
	For Local index:= 0 Until data.Length
		PrintAtIndex(data, index)
	Next
End

Function PrintAtIndex<ArrayType>:Void(data:ArrayType, index:Int)
	PrintIndexedValue(data[index], index)
End

Function PrintIndexedValue<T>:Void(data:T, display_index:Int=0)
	Print("[" + display_index + "]: " + data)
End