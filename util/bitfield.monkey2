Namespace regal.util.bitfield

' Imports:
Using monkey.math

' Functions:
Function FlagMask:ULong(Bits:ULong)
	Return (1 Shl Bits) ' Pow(2, BitNumber)
End

Function ToggleBit:Int(BitField:Int, BitNumber:Int, Value:Bool)
	Return ToggleBitMask(BitField, FlagMask(BitNumber), Value)
End

Function ToggleBitMask:Int(BitField:Int, Mask:Int, Value:Bool)
	If (Value) Then
		Return ActivateBitMask(BitField, Mask)
	Endif
	
	Return DeactivateBitMask(BitField, Mask)
End

Function ToggleBit:Int(BitField:Int, BitNumber:Int)
	Return ToggleBitMask(BitField, Pow(2, BitNumber))
End

Function ToggleBitMask:Int(BitField:Int, Mask:Int)
	If (BitMaskActivated(BitField, Mask)) Then
		Return ToggleBitMask(BitField, Mask, False)
	Endif
	
	Return ToggleBitMask(BitField, Mask, True)
End

Function BitActivated:Bool(BitField:Int, BitNumber:Int)
	Return BitMaskActivated(BitField, Pow(2, BitNumber))
End

Function BitDeactivated:Bool(BitField:Int, BitNumber:Int)
	Return (Not BitActivated(BitField, BitNumber))
End

Function BitMaskActivated:Bool(BitField:Int, Mask:Int)
	Return ((BitField & Mask) > 0)
End

Function BitMaskDeactivated:Bool(BitField:Int, Mask:Int)
	Return (Not BitMaskActivated(BitField, Mask))
End

Function ActivateBit:Int(BitField:Int, BitNumber:Int)
	Return ActivateBitMask(BitField, Pow(2, BitNumber))
End

Function DeactivateBit:Int(BitField:Int, BitNumber:Int)
	Return DeactivateBitMask(BitField, Pow(2, BitNumber))
End

Function ActivateBitMask:Int(BitField:Int, Mask:Int)
	Return (BitField | Mask)
End

Function DeactivateBitMask:Int(BitField:Int, Mask:Int)
	Return (BitField & ~Mask) ' (BitField ~ Mask)
End