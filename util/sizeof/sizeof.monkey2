Namespace regal.util.sizeof

' Constant variable(s):
Const SizeOf_Long:= SizeOf<Long>() ' 8
Const SizeOf_Int:= SizeOf<Int>() ' 4
Const SizeOf_Short:= SizeOf<Short>() ' 2
Const SizeOf_Byte:= SizeOf<Byte>() ' 1

Const SizeOf_Float:= SizeOf<Float>() ' 4
Const SizeOf_Double:= SizeOf<Double>() ' 8

Const SizeOf_SizeT:= SizeOf<libc.size_t>() ' libc.sizeof<libc.size_t>(0)

Const SizeOf_Integer:= SizeOf_Int
Const SizeOf_FloatingPoint:= SizeOf_Float ' SizeOf_Double

Const SizeOf_Byte_InBits:= 8

' Functions:
Function SizeOf<T>:libc.size_t(value:T)
	Return libc.sizeof<T>(value)
End

Function SizeOf<T>:libc.size_t()
	Local nil:T
	
	Return SizeOf<T>(nil) ' libc.sizeof<T>(nil)
End

Function SizeOf_InBits<T>:libc.size_t()
	Return (SizeOf<T>() * SizeOf_Byte_InBits)
End