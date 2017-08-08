Namespace regal.util.typeutil

' Functions:
Function GetTraits<T>:TypeTraits()
	Select (GetType<T>())
		' Integral types:
		
		' Signed:
		Case GetType<Byte>()
			Return TypeTraits.IntType(True)
		Case GetType<Short>()
			Return TypeTraits.IntType(True)
		Case GetType<Int>()
			Return TypeTraits.IntType(True)
		Case GetType<Long>()
			Return TypeTraits.IntType(True)
		
		' Unsigned:
		Case GetType<UByte>()
			Return TypeTraits.IntType(False)
		Case GetType<UShort>()
			Return TypeTraits.IntType(False)
		Case GetType<UInt>()
			Return TypeTraits.IntType(False)
		Case GetType<ULong>()
			Return TypeTraits.IntType(False)
		
		
		' Floating-point:
		Case GetType<Float>()
			Return TypeTraits.FloatType()
		Case GetType<Double>()
			Return TypeTraits.FloatType()
		
		
		' Other:
		Case GetType<String>()
			Return Null
		Case GetType<Bool>()
			Return Null
		
	End Select
	
	Return TypeTraits.ObjectType()
End

' Structures:
Struct TypeTraits
	' Functions:
	Function FloatType:TypeTraits()
		Local info:= New TypeTraits()
		
		info.has_infinity = True
		info.is_bounded = True
		
		Return info
	End
	
	Function IntType:TypeTraits(is_signed:Bool)
		Local info:= New TypeTraits()
		
		info.is_signed = is_signed
		info.is_integer = True
		info.is_exact = True
		info.is_bounded = True
		
		Return info
	End
	
	Function ObjectType:TypeTraits()
		Local info:= New TypeTraits()
		
		info.is_object = True
		
		Return info
	End
	
	' Fields:
	
	' Specifies if the type in question is a user-defined class or struct.
	Field is_object:Bool
	
	Field is_signed:Bool
	Field is_integer:Bool
	Field is_exact:Bool
	Field is_bounded:Bool
	
	Field has_infinity:Bool
End