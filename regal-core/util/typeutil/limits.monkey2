Namespace regal.util.typeutil

Using regal.math

' Functions:
Function GetLimits<T>:NumericLimits<T>()
	Select (GetType<T>())
		' Integral types:
		
		' Signed:
		Case GetType<Byte>()
			Return NumericLimits<T>.SIntLimit(BYTE_MIN, BYTE_MAX)
		Case GetType<Short>()
			Return NumericLimits<T>.SIntLimit(SHORT_MIN, SHORT_MAX)
		Case GetType<Int>()
			Return NumericLimits<T>.SIntLimit(INT_MIN, INT_MAX)
		Case GetType<Long>()
			Return NumericLimits<T>.SIntLimit(LONG_MIN, LONG_MAX)
		
		' Unsigned:
		Case GetType<UByte>()
			Return NumericLimits<T>.UIntLimit(UBYTE_MAX)
		Case GetType<UShort>()
			Return NumericLimits<T>.UIntLimit(USHORT_MAX)
		Case GetType<UInt>()
			Return NumericLimits<T>.UIntLimit(UINT_MAX)
		Case GetType<ULong>()
			Return NumericLimits<T>.UIntLimit(ULONG_MAX)
		
		
		' Floating-point:
		Case GetType<Float>()
			Return NumericLimits<T>.FloatLimit(FLOAT_MIN, FLOAT_MAX)
		Case GetType<Double>()
			Return NumericLimits<T>.FloatLimit(DOUBLE_MIN, DOUBLE_MAX)
		
		
		' Other:
		Case GetType<Bool>()
			Return New NumericLimits<T>(Cast<T>(0), Cast<T>(1)) ' 0, 1
	End Select
	
	Return Null
End

' Structures:
Struct NumericLimits<T>
	Public
		' Functions:
		Function IntLimit:NumericLimits(min:T, max:T, is_signed:Bool)
			Return New NumericLimits(min, max, is_signed, True)
		End
		
		Function SIntLimit:NumericLimits(min:T, max:T)
			Return IntLimit(min, max, True)
		End
		
		Function UIntLimit:NumericLimits(max:T)
			Return IntLimit(Cast<T>(0), max, False)
		End
		
		Function FloatLimit:NumericLimits(min:T, max:T)
			Return New NumericLimits(min, max, False, False)
		End
		
		' Constructor(s):
		Method New(min:T, max:T, is_signed:Bool=False, is_integer:Bool=False)
			Self.min = min
			Self.max = max
			
			Self.is_signed = is_signed
			Self.is_integer = is_integer
		End
		
		' Properties:
		Property Min:T()
			Return Self.min
		End
		
		Property Max:T()
			Return Self.max
		End
		
		Property IsInteger:Bool()
			Return Self.is_integer
		End
		
		Property IsSigned:Bool()
			Return Self.is_signed
		End
	Private
		' Fields:
		Field min:T, max:T
		
		Field is_signed:Bool
		Field is_integer:Bool
		
		'Field traits:TypeTraits
End