Namespace regal.memory.bitfield

'Using monkey.math

' Functions:

' This reverses the bit-order in the byte specified.
' Example (Bits): 011 = 110
Function ReverseByte:Long(b:Long)
	b = (b & $FF)
	
	b = Lsr((b & $F0), 4) | Lsl((b & $0F), 4)
	b = Lsr((b & $CC), 2) | Lsl((b & $33), 2)
	b = Lsr((b & $AA), 1) | Lsl((b & $55), 1)
	
	Return b
End

' This returns the number of bytes needed to hold 'bits'.
Function BitDepthInBytes:Int(bits:Int) ' UInt
	Return ((bits + 7) / 8)
End

Function FlagMask<T>:T(Bits:T)
	Return (1 Shl Bits) ' Pow(2, BitNumber)
End

Function Lsl:ULong(value:ULong, shift_amount:ULong)
	Return (value Shl shift_amount)
End

Function Lsr:ULong(value:ULong, shift_amount:ULong)
	Return (value Shr shift_amount)
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