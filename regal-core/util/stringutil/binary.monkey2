Namespace regal.util.stringutil

Using regal.math..
Using regal.memory..

' Functions:
Function HexLE:String(Value:Int)
	Return HexBE(HToNI(Value))
End

' This command may be overhauled at a later date.
Function HexBE:String(Value:Int)
	' Local variable(s):
	Local Buf:= New Int[8] ' Byte[8]
	
	For Local k:= 7 To 0 Step -1
		Local n:Int = (Value & 15) + ASCII_NUMBERS_POSITION
		
		If (n > ASCII_CHARACTER_9) Then
			n += (ASCII_CHARACTER_UPPERCASE_POSITION-ASCII_CHARACTER_9-1)
		Endif
		
		Buf[k] = n
		
		Value = (Value Shr 4)
	Next
	
	Return String.FromChars(Buf)
End

Function BitFieldAsString<T>:String(BitField:T)
	Local buffer:= New Int[SizeOf_InBits<T>()]
	
	BitFieldToChars<T, Int>(BitField, buffer) ' Byte
	
	Return String.FromChars(buffer)
End

Function BitFieldToChars<T, CharType>:Void(BitField:T, Chars:CharType[])
	For Local I:= (Chars.Length - 1) To 0 Step -1
		Chars[I] = (ASCII_NUMBERS_POSITION + (BitField & 1))
		
		BitField = (BitField Shr 1)
	Next
	
	Return
End

Function RepresentBytes:String(buffer:BufferPointer, count:Int)
	Local str:String = "[ " + buffer.Peek<UByte>(0)
	
	For Local byte_index:= 1 Until count
		str += " | "
		str += buffer.Peek<UByte>(byte_index)
	Next
	
	str += " ]"
	
	Return str
End

Function RepresentBits:String(view:ImageView, count:Int)
	count = RoundUp(count, 4)
	
	Local str:String = "[" + view.Get(0)
	
	For Local i:= 1 Until count
		If ((i Mod 8) = 0) Then
			str += "]  ["
		Elseif ((i Mod 4) = 0) Then
			str += "|"
		Endif
	
		str += String(view.Get(i))
	Next
	
	str += "]"
	
	Return str
End

Function ShortenedFloat:String(F:Double, Precision:Int=1)
	' This is done so we don't divide by zero.
	Precision = Max(Precision, 1)
	
	Local X:= Pow(10.0, Double(Precision))
	
	F *= X
	
	Return String(Floor(F + (Sgn(F) * 0.5)) / X)
End