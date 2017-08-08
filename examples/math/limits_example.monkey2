#Import "../regal"

'Using regal.math..
Using regal.util.typeutil..

Function Main:Void()
	PrintLimits<Byte>()
	PrintLimits<UByte>()
	
	Print("")
	
	PrintLimits<Short>()
	PrintLimits<UShort>()
	
	Print("")
	
	PrintLimits<Int>()
	PrintLimits<UInt>()
	
	Print("")
	
	PrintLimits<Long>()
	PrintLimits<ULong>()
	
	Print("")
	
	PrintLimits<Float>()
	PrintLimits<Double>()
End

Function PrintLimits<T>:Void()
	Local limits:= GetLimits<T>()
	
	Print("Limits<" + GetType<T>().Name + "> : " + limits.Min + ", " + limits.Max)
End