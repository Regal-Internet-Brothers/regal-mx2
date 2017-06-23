Namespace regal.util

'Using monkey.math

' Functions:
Function FlagMask<T>:T(Bits:T)
	Return (1 Shl Bits) ' Pow(2, BitNumber)
End

Function ToggleBit<T>:T(BitField:T, BitNumber:T, Value:Bool)
	Return ToggleBitMask(BitField, FlagMask(BitNumber), Value)
End

Function ToggleBitMask<T>:T(BitField:T, Mask:T, Value:Bool)
	If (Value) Then
		Return ActivateBitMask(BitField, Mask)
	Endif
	
	Return DeactivateBitMask(BitField, Mask)
End

Function ToggleBit<T>:T(BitField:T, BitNumber:T)
	Return ToggleBitMask(BitField, FlagMask(BitNumber)) ' Pow(2, BitNumber)
End

Function ToggleBitMask<T>:T(BitField:T, Mask:T)
	If (BitMaskActivated(BitField, Mask)) Then
		Return ToggleBitMask(BitField, Mask, False)
	Endif
	
	Return ToggleBitMask(BitField, Mask, True)
End

Function BitActivated<T>:Bool(BitField:T, BitNumber:T)
	Return BitMaskActivated(BitField, FlagMask(BitNumber)) ' Pow(2, BitNumber)
End

Function BitDeactivated<T>:Bool(BitField:T, BitNumber:T)
	Return (Not BitActivated(BitField, BitNumber))
End

Function BitMaskActivated<T>:Bool(BitField:T, Mask:T)
	Return ((BitField & Mask) <> 0)
End

Function BitMaskDeactivated<T>:Bool(BitField:T, Mask:T)
	Return (Not BitMaskActivated(BitField, Mask))
End

Function ActivateBit<T>:T(BitField:T, BitNumber:T)
	Return ActivateBitMask(BitField, FlagMask(BitNumber)) ' Pow(2, BitNumber)
End

Function DeactivateBit<T>:T(BitField:T, BitNumber:T)
	Return DeactivateBitMask(BitField, FlagMask(BitNumber)) ' Pow(2, BitNumber)
End

Function ActivateBitMask<T>:T(BitField:T, Mask:T)
	Return (BitField | Mask)
End

Function DeactivateBitMask<T>:T(BitField:T, Mask:T)
	Return (BitField & ~Mask) ' (BitField ~ Mask)
End