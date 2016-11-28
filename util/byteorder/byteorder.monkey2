Namespace regal.util.byteorder

' Functions:

' This specifies if this system is big-endian.
Function BigEndian:Bool()
	Local I:Int = 1
	
	I = (I Shr 31)
	
	If (I > 0) Then
		Return True
	Endif
	
	' Return the default response.
	Return False
End

' This specifies if this system is little-endian.
Function LittleEndian:Bool()
	Return (Not BigEndian())
End

Function NToHI:UInt(value:UInt)
	Return (((value Shr 24) & $000000FF) | ((value Shr 8) & $0000FF00) | ((value Shl 8) & $00FF0000) | ((value Shl 24) & $FF000000))
End

Function NToHS:UShort(value:UShort)
	Return ((((value & $000000FF) Shl 8) | ((value & $0000FF00) Shr 8)))
End

Function NToHL:ULong(value:ULong)
	Local raw:= Cast<UInt Ptr>(Varptr value)
	
	Local temp:= raw[0]
	
	raw[0] = raw[1]
	raw[1] = temp
	
	Return value
End

Function NToHF:Float(value:UInt)
	Local raw:= Cast<Float Ptr>(Varptr value)
	
	Return raw[0]
End

Function NToHD:Double(value:ULong)
	Local raw:= Cast<Double Ptr>(Varptr value)
	
	Return raw[0]
End

Function HToNI:UInt(value:UInt)
	Return NToHI(value)
End

Function HToNS:UShort(value:UShort)
	Return NToHS(value)
End

Function HToNL:ULong(value:ULong)
	Return NToHL(value)
End

Function HToNF:UInt(value:Float)
	Local raw:= Cast<UInt Ptr>(Varptr value)
	
	Return raw[0]
End

Function HToND:ULong(value:Double)
	Local raw:= Cast<ULong Ptr>(Varptr value)
	
	Return raw[0]
End