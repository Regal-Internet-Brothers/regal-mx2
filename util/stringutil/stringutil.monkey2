Namespace regal.util.stringutil

#Import "ascii"
'#Import "symbols"

' Imports:
Using regal.util.byteorder

' Functions:
Function InQuotes:String(Input:String)
	Return "~q" + Input + "~q"
End

Function InSingleQuotes:String(Input:String)
	Return "'" + Input + "'"
End

Function YesNo:String(Value:Bool)
	Return ((Value) ? "Yes" Else "No")
End

Function BitFieldAsString:String(BitField:ULong)
	Return StringFromChars(BitFieldToChars(BitField, New Int[64]))
End

Function BitFieldAsString:String(BitField:ULong, Character:String, Character_Offset:Int=0)
	Return BitFieldAsString(BitField, Character[Character_Offset])
End

Function BitFieldAsString:String(BitField:ULong, SeparatorChar:Int)
	Return StringFromChars(BitFieldToChars(BitField, New Int[63], SeparatorChar))
End

Function BitFieldToChars:Int[](BitField:ULong, Chars:Int[])
	For Local I:= 63 To 0 Step -1
		Chars[I] = (BitField & 1) + ASCII_NUMBERS_POSITION
		
		BitField = (BitField Shr 1)
	Next
	
	Return Chars
End

Function BitFieldToChars:Int[](BitField:ULong, Chars:Int[], SeparatorChar:Int)
	For Local I:= 63 To 0 Step -2
		Chars[I-1] = (BitField & 1) + ASCII_NUMBERS_POSITION
		
		If (I < 63) Then
			Chars[I] = SeparatorChar
		Endif
		
		BitField = (BitField Shr 1)
	Next
	
	Return Chars
End

#Rem
	This command will get things right most of the time,
	but it doesn't have a dictionary, so it's not perfect.
	
	This really depends on how the word is pronounced,
	but at least vowels will always be properly handled.
#End

Function AOrAn:String(Input:String)
	' Constant variable(s):
	Const An:String = "an"
	Const A:String = "a"
	
	' Local variable(s):
	Local LI:= Input.ToLower()
	
	' Check for English vowels:
	If (LI.StartsWith("a")) Then Return An
	If (LI.StartsWith("e")) Then Return An
	If (LI.StartsWith("i")) Then Return An
	If (LI.StartsWith("o")) Then Return An
	If (LI.StartsWith("u")) Then Return An
	
	' Return the default response.
	Return A
End

' This converts a boolean to a string representation.
Function BoolToString:String(In:Bool)
	If (In) Then
		Return "True"
	Endif
	
	Return "False"
End

' This implementation returns 'True' upon receiving "unparsable" data.
' The only exception being blank strings, they are always considered 'False'.
Function StringToBool:Bool(In:String)
	' Constant variable(s):
	Const ASCII_LOWER_F:= ASCII_CHARACTER_LOWERCASE_POSITION+5
	Const ASCII_LOWER_N:= ASCII_CHARACTER_LOWERCASE_POSITION+13
	
	' Check for errors:
	If (In.Length = 0) Then
		Return False
	Endif
	
	' Local variable(s):
	Local In_Lower:= ToLower(In[0]) ' (ToLower(In)[0])
	
	Return (In_Lower <> ASCII_LOWER_N And In_Lower <> ASCII_LOWER_F And In_Lower <> ASCII_CHARACTER_0)
End

Function ToLower:String(S:String)
	Return S.ToLower()
End

Function ToUpper:String(S:String)
	Return S.ToUpper()
End

Function ToLower:Int(CharacterCode:Int)
	If (CharacterCode >= ASCII_CHARACTER_UPPERCASE_POSITION And CharacterCode <= ASCII_CHARACTERS_UPPERCASE_END) Then
		Return (CharacterCode + ASCII_CASE_DELTA)
	Endif
	
	Return CharacterCode
End

Function ToUpper:Int(CharacterCode:Int)
	If (CharacterCode >= ASCII_CHARACTER_LOWERCASE_POSITION And CharacterCode <= ASCII_CHARACTERS_LOWERCASE_END) Then
		Return (CharacterCode - ASCII_CASE_DELTA)
	Endif
	
	Return CharacterCode
End

Function HexLE:String(Value:Int)
	Return HexBE(HToNI(Value))
End

' This command may be overhauled at a later date.
Function HexBE:String(Value:Int)
	' Local variable(s):
	Local Buf:= New Byte[8]
	
	For Local k:= 7 To 0 Step -1
		Local n:Int = (Value & 15) + ASCII_NUMBERS_POSITION
		
		If (n > ASCII_CHARACTER_9) Then
			n += (ASCII_CHARACTER_UPPERCASE_POSITION-ASCII_CHARACTER_9-1)
		Endif
		
		Buf[k] = n
		
		Value = (Value Shr 4)
	Next
	
	Return StringFromChars(Buf)
End

Function StringFromChars<T>:String(Characters:T[])
	Return String.FromCString(Characters.Data, Characters.Length)
End