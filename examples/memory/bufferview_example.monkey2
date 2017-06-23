#Import "../regal"

Using regal.memory.bufferview
Using regal.memory.sizeof

' Functions:
Function Main:Void()
	Local buffer:= New ShortArrayView(16)
	
	Print("The allocated buffer is " + buffer.Size + " bytes long, and " + buffer.Length + " elements in length.")
	
	Local value:= 134
	Local index:= 12
	
	Print("")
	
	Print("Storing the value '" + value + "' at index " + index + ".")
	
	buffer.Set(index, value)
	
	Print("Retrieving the value stored at index " + index + ":")
	
	Local retValue:= buffer.Get(index)
	
	Print(retValue)
	
	Print("")
	
	If (value = retValue) Then
		Print("| Both values match. |")
		Print("// (" + retValue + ") \\")
	Else
		Print(": The value retreived does not match the original value :")
		Print("\\ {" + String(value) + " vs. " + String(retValue) + "} //")
	Endif
	
	Print("~nSquaring the value stored at index " + index + ":")
	
	Local current:= buffer.Get(index)
	Local square:= buffer.Sq(index)
	
	Print(String(current) + " -> " + String(square))
	
	Local newData:= New Int[buffer.Length] ' 0, 2, 4, 6, 8, ...
	
	For Local i:= 0 Until newData.Length
		newData[i] = (i * 2)
	Next
	
	buffer.SetArray(0, newData, newData.Length)
	
	Local newTestIndex:= 3
	
	Print("~nChecking index " + newTestIndex + ":~n")
	
	Local newValue:= newData[newTestIndex]
	Local newRetValue:= buffer.Get(newTestIndex)
	Local newRetValueAlt:= buffer.GetArray(newTestIndex, 1)[0]
	
	Print("NewData[" + newTestIndex + "] = " + newValue)
	Print("Buffer[" + newTestIndex + "] = " + newRetValue)
	Print("Alternate access of Buffer[" + newTestIndex + "] = " + newRetValueAlt)
	
	Print("")
	
	If (newValue = newRetValue) Then
		Print("| Both values are the same. |")
	Else
		Print(": The two values are different. :")
	Endif
End