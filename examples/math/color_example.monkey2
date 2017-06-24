#Import "../regal"

Using regal.math..

Function Main:Void()
	Local color_data:UInt = 0
	Local color_ptr:= Cast<UByte Ptr>(Varptr color_data)
	Local color_r:= 255
	Local color_g:= 123
	Local color_b:= 231
	Local color_a:= 200
	
	color_ptr[0] = color_r
	color_ptr[1] = color_g
	color_ptr[2] = color_b
	color_ptr[3] = color_a
	
	Print("Raw color value: " + color_data)
	
	Print("~nColor values (RGBA):")
	Print(color_r + ", " + color_g + ", " + color_b + ", " + color_a)
	Print(color_ptr[0] + ", " + color_ptr[1] + ", " + color_ptr[2] + ", " + color_ptr[3])
	Print("~n")
	Print(PixelToString(color_data))
End