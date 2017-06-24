Namespace regal.math

Using regal.memory.sizeof

' This command is a helper function for the inverse position of a byte inside of an integer.
Function ProcessColorLocation:UInt(Point:Byte)
	Return (SizeOf_InBits<Int>() - (SizeOf_InBits<UByte>() * (Point + 1))) ' ((SizeOf_Integer_InBits-SizeOf_Octet_InBits)-(SizeOf_Octet_InBits*Point))
End

' NOTE: This command will produce incorrect color values without all characters present in the encode-string.
Function PixelToString:String(Pixel:UInt, Encoding:String="ARGB")
	' Ensure the encoding is always described as uppercase.
	'Encoding = Encoding.ToUpper()
	
	Local R:= ((Pixel Shr ProcessColorLocation(Encoding.Find("R"))) & $000000FF)
	Local G:= ((Pixel Shr ProcessColorLocation(Encoding.Find("G"))) & $000000FF)
	Local B:= ((Pixel Shr ProcessColorLocation(Encoding.Find("B"))) & $000000FF)
	Local A:= ((Pixel Shr ProcessColorLocation(Encoding.Find("A"))) & $000000FF)
	
	' Return the encoded color-string:
	Return ("R: " + R + ", G: " + G + ", B: " + B + ", A: " + A)
End