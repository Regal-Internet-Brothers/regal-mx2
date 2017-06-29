#Import "../regal"

Using regal.memory.dataobject

Function Main:Void()
	Local value:Int = 10
	
	Local arr:= New ArrayObject<Int>(New Int[](value))
	Local obj:= New DataObject<Int>(value)
	
	Print("Value: " + Int(obj))
	Print("Array[0]: " + arr[0])
End