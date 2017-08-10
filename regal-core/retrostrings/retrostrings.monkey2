Namespace regal.retrostrings

#Rem
	This library was created for the sake of restoring the original string-manipulation commands from BlitzBasic.
	This module is useful for porting programs from BlitzBasic and BlitzMax.
	
	If you find any bugs while using this module, please report them.
#End

Using regal.util.stringutil..

' Configuration:
Private

Struct CONFIG
	#Rem
		This standard has not yet been properly implemented.
		The idea behind this functionality is to only provide the
		original standard BlitzBasic commands, and their usual behavior.
		
		This can be problematic for other modules which use features and other
		behaviors which are not compatible/available with BlitzBasic's original implementation.
		
		Configure this with caution, if you're unsure (Which you generally should be), don't mess with this.
		
		If this is disabled, it means full functionality is available; don't worry about this variable.
	#End
	
	Const RETROSTRINGS_AUTHENTIC:= False ' True
	
	#Rem
		Enabling this will cause extra checks to take place to ensure that there
		isn't any issue with the input supplied to the commands of this module.
		
		Under normal situations, "strict-mode" is enabled,
		so 'RETROSTRINGS_AUTHENTIC' does not need to be check for this.
	#End
	
	Const RETROSTRINGS_STRICT:= True
	
	#Rem
		This currently has variable results, and could change.
		The idea behind this variable is to provide
		better configuration for what 'RETROSTRINGS_STRICT' applied.
		
		This functionality has yet to be properly implemented.
		Very few places (If any) actually use this.
	#End
	
	Const RETROSTRINGS_SAFE:= True
	
	#If __DEBUG__
		#Rem
			This is currently only defined when compiling in debug-mode.
			If this is disabled, errors detected within the module will be ignored silently,
			and possibly not even checked altogether (Unlikely; see 'RETROSTRINGS_STRICT').
		#End
		
		Const RETROSTRINGS_REPORT_ERRORS:= True
	#Else
		Const RETROSTRINGS_REPORT_ERRORS:= (RETROSTRINGS_AUTHENTIC Or RETROSTRINGS_SAFE)
	#End
End

Public

' Functions:

' Classic BlitzBasic-styled string-commands:
Function Left:String(Str:String, n:Int)
	If (CONFIG.RETROSTRINGS_SAFE) Then
		If (n = 0) Then
			Return ""
		Endif
	Endif
	
	If (CONFIG.RETROSTRINGS_STRICT Or CONFIG.RETROSTRINGS_SAFE) Then
		If (n < 0) Then
			If (CONFIG.RETROSTRINGS_REPORT_ERRORS) Then
				RuntimeError("Illegal function call.")
			Endif
			
			Return ""
		Endif
	Endif
	
	Return Str.Slice(0, Min(n, Len(Str)))
End

Function Right:String(Str:String, n:Int)
	If (n = 0) Then
		Return ""
	Endif
	
	If (CONFIG.RETROSTRINGS_STRICT Or CONFIG.RETROSTRINGS_SAFE) Then
		If (n < 0) Then
			If (CONFIG.RETROSTRINGS_REPORT_ERRORS) Then
				RuntimeError("Illegal function call.")
			Endif
			
			Return ""
		Endif
	Endif
	
	Return Str.Slice(-Min(n, Len(Str)))
End

Function Mid:String(Str:String, Pos:Int, Size:Int=-1)
	If (CONFIG.RETROSTRINGS_STRICT Or CONFIG.RETROSTRINGS_SAFE) Then
		If (Pos = 0) Then
			If (CONFIG.RETROSTRINGS_REPORT_ERRORS) Then
				'RuntimeError("Parameter must be greater than zero. ('Pos': " + Pos + ")")
				RuntimeError("Parameter must be greater than zero. ('Pos': 0")
			Endif
			
			Return ""
		Endif
	Endif
	
	If (Pos > Len(Str)) Then
		Return ""
	Endif
	
	Pos -= 1
	
	If (Size < 0) Then
		Return Str.Slice(Pos)
	Endif
	
	If (Pos < 0) Then
		Size += Pos
		
		Pos = 0
	Endif
	
	If (Pos+Size > Len(Str)) Then
		Size = Len(Str) - Pos
	Endif
	
	Return Str.Slice(Pos, (Pos+Size))
End

Function Len:Int(Str:String)
	Return Str.Length
End

Function Instr:Int(Str:String, Sub:String, Start:Int=1, Left:Bool=True)
	Return (Str.Find(Sub, (Start - 1)) + 1)
End

Function Lower:String(S:String)
	Return S.ToLower()
End

Function Upper:String(S:String)
	Return S.ToUpper()
End

Function LSet:String(Str:String, N:Int)
	If (CONFIG.RETROSTRINGS_SAFE Or CONFIG.RETROSTRINGS_REPORT_ERRORS) Then
		If (N < 0) Then
			If (CONFIG.RETROSTRINGS_REPORT_ERRORS) Then
				RuntimeError("Parameter must be positive. ('N': " + N + ")")
			Endif
			
			Return ""
		Endif
	Endif
	
	Return Str.Slice(0, N)
End

Function RSet:String(Str:String, N:Int)
	If (CONFIG.RETROSTRINGS_SAFE Or CONFIG.RETROSTRINGS_REPORT_ERRORS) Then
		If (N < 0) Then
			If (CONFIG.RETROSTRINGS_REPORT_ERRORS) Then
				RuntimeError("Parameter must be positive. ('N': " + N + ")")
			Endif
			
			Return ""
		Endif
	Endif
	
	Return Str.Slice(-N)
End

Function Replace:String(Str:String, Sub:String, ReplaceWith:String)
	Return Str.Replace(Sub, ReplaceWith)
End

Function Trim:String(Str:String)
	Return Str.Trim()
End

Function Chrs:String(In:Int[])
	Return String.FromChars(In)
End

Function Chr:String(In:Int)
	Return String.FromChar(In)
End

Function Asc:Int(Str:String)	
	Return Str[0]
End

Function Ascs:Int[](Str:String)
	Local Chars:= New Int[Str.Length]
	
	Str.ToCString(Chars.Data, Chars.Length)
	
	Return Chars
End

' The output of this command is completely defined by the implementation of 'retrostrings'.
' This could use either 'HexBE', or 'HexLE'. Usually, the version used is the fastest.
Function Hex:String(Value:Int)
	Return HexBE(Value)
End

Function Bin:String(Value:Int)
	If (CONFIG.RETROSTRINGS_AUTHENTIC) Then
		' Local variable(s):
		Local Buf:= New Int[32]
		
		For Local k:= 31 To 0 Step -1
			Buf[k] = (Value & 1) + ASCII_NUMBERS_POSITION
			
			Value Shr= 1
		Next
		
		Return String.FromChars(Buf)
	Else
		Return BitFieldAsString(Value)
	Endif
End

' This will return an offset version of the number specified,
' based on the standard ascii position of zero.
' The 'Number' argument should be less than 'ASCII_NUMBER_COUNT', and no smaller than zero.
Function NumberInAsc:Int(Number:Int=0)
	Return ASCII_NUMBERS_POSITION + (Abs(Number) Mod ASCII_NUMBER_COUNT)
	'(CONFIG.RETROSTRINGS_SAFE) ? (Abs(Number) Mod ASCII_NUMBER_COUNT) Else (Number Mod ASCII_NUMBER_COUNT)
End

Function LongHex:String(Value:Int) 
	Return Hex(Value)
End

Function LongBin:String(Value:Int)
	Return Bin(Value)
End