Namespace regal.math

' Imports:
#Import "color"

' Functions:
Function Fib<T>:T(x:T)
	If (x = 0) Then
		Return 0
	Endif
	
	If (x = 1) Then
		Return 1
	Endif
	
	Return (Fib(x - 1) + Fib(x - 2))
End