Namespace regal.util.sizeof

' Constant variable(s):
Const SizeOf_Int:= libc.sizeof<Int>(0)
Const SizeOf_Short:= libc.sizeof<Short>(0)
Const SizeOf_Byte:= libc.sizeof<Byte>(0)
Const SizeOf_Float:= libc.sizeof<Float>(0.0)
Const SizeOf_Double:= libc.sizeof<Double>(0.0)

Const SizeOf_SizeT:= libc.sizeof<libc.size_t>(0)

Const SizeOf_Integer:= SizeOf_Int
Const SizeOf_FloatingPoint:= SizeOf_Float ' SizeOf_Double

' Functions:
Function SizeOf<T>:libc.size_t(value:T)
	Return libc.sizeof<T>(value)
End

Function SizeOf<T>:libc.size_t()
	Local nil:T
	
	Return SizeOf<T>(nil) ' libc.sizeof<T>(nil)
End