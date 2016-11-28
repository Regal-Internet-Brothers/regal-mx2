Namespace regal.util.stringutil

#Import "ascii"
#Import "symbols"
#Import "observe"

' Imports:
Using regal.util.byteorder

' Functions:
Function InQuotes:String(Input:String)
	Return symbols.Quote + Input + symbols.Quote
End

Function InSingleQuotes:String(Input:String)
	Return symbols.SingleQuote + Input + symbols.SingleQuote
End

Function YesNo:String(Value:Bool)
	Return ((Value) ? "Yes" Else "No")
End

Function BitFieldAsString<T>:String(BitField:T)
	Local buffer:= New Byte[SizeOf_InBits<T>()]
	
	BitFieldToChars<T, Byte>(BitField, buffer)
	
	Return StringFromChars(buffer)
End

Function BitFieldToChars<T, CharType>:Void(BitField:T, Chars:CharType[])
	For Local I:= (Chars.Length - 1) To 0 Step -1
		Chars[I] = (ASCII_NUMBERS_POSITION + (BitField & 1))
		
		BitField = (BitField Shr 1)
	Next
	
	Return
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

Function ShortenedFloat:String(F:Double, Precision:Int=1)
	' This is done so we don't divide by zero.
	Precision = Max(Precision, 1)
	
	Local X:= Pow(10.0, Double(Precision))
	
	F *= X
	
	Return String(Floor(F + (Sgn(F) * 0.5)) / X)
End

Function SmartClip:String(Input:String, Symbol:Int)
	Return SmartClip(Input, Symbol, Input.Length)
End

Function SmartClip:String(Input:String, Symbol:Int, Length:Int)
	' Local variable(s):
	Local FinalChar:= (Length - 1)
	
	Local XClip:Int
	Local YClip:Int
	
	If (Input[0] = Symbol) Then
		XClip = 1
	Else
		XClip = 0
	Endif
	
	If (Input[FinalChar] = Symbol) Then
		YClip = FinalChar
	Else
		YClip = Length
	Endif
	
	If (XClip <> 0 Or YClip <> 0) Then
		Return Input.Slice(XClip, YClip)
	Endif
	
	Return Input
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
	Local Output:String
	
	For Local Character:= Eachin Characters
		Output += String.FromChar(Character)
	Next
	
	Return Output
End