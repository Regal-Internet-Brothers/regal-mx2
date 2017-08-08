Namespace regal.math

' Imports:
#Import "trig"
#Import "deltatime"
#Import "color"
#Import "limits"

' Functions:
Function Sq<T>:T(value:T)
	Return (value * value)
End

Function Fib<T>:T(x:T)
	If (x = 0) Then
		Return 0
	Endif
	
	If (x = 1) Then
		Return 1
	Endif
	
	Return (Fib(x - 1) + Fib(x - 2))
End

Function RoundUp<T>:T(value:T, multiple:T)
	If (multiple = 0) Then
		Return value
	Endif
	
	Local remainder:= (value Mod multiple)
	
	If (remainder = 0) Then
		Return value
	Endif
	
	Return (value + multiple - remainder)
End

Function FloatsEqual<T>:Bool(x:T, y:T, epsilon:T)
	Return (Abs(x - y) <= epsilon)
End