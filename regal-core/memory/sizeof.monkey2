Namespace regal.memory.sizeof

' Constant variable(s):
Const SizeOf_Long:= 8 ' SizeOf<Long>() ' 8
Const SizeOf_Int:= 4 ' SizeOf<Int>() ' 4
Const SizeOf_Short:= 2 ' SizeOf<Short>() ' 2
Const SizeOf_Byte:= 1 ' SizeOf<Byte>() ' 1

Const SizeOf_Float:= 4 ' SizeOf<Float>() ' 4
Const SizeOf_Double:= 8 ' SizeOf<Double>() ' 8

'Const SizeOf_SizeT:= SizeOf<libc.size_t>() ' libc.sizeof<libc.size_t>(0)

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