#Import "../regal"

Using regal.util

' This demo inserts bits into a bitfield, then reads them back.
Function Main:Void()
	Local bits:= 0
	
	Const bit_count:= 16
	Const bit_stride:= 3
	
	For Local i:= 0 Until bit_count
		If (bit_stride = 1 Or (i Mod bit_stride) = 0) Then
			bits = ActivateBit(bits, i)
		Endif
	Next
	
	Local bit_str:String
	
	For Local i:= 0 Until bit_count
		If (BitActivated(bits, i)) Then
			bit_str += "1"
		Else
			bit_str += "0"
		Endif
	Next
	
	Print("Bits: " + bit_str)
End