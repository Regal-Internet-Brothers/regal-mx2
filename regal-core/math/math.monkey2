Namespace regal.math

' Imports:
#Import "trig"
#Import "color"

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

Function FloatsEqual<T>:Bool(x:T, y:T, epsilon:T)
	Return (Abs(x - y) <= epsilon)
End