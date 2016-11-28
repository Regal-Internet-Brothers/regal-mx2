Namespace regal.memory.bufferview

Using regal.stringutil

Class InvalidViewOperation Extends Throwable Abstract ' InvalidBufferViewOperation
	' Functions:
	Function ConvertAddress:String(Address:UInt)
		Return HexBE(Address)
	End
	
	' Constructor(s):
	Method New(View:BufferView, Address:UInt, Count:UInt=0)
		Self.View = View
		Self.Address = Address
		Self.Count = Count
	End
	
	' Methods:
	Method To:String() Abstract
	
	' This reports the number of bytes the operation intended to work with.
	Method PostCount:String()
		Return "{" + Count + " bytes}"
	End
	
	' Fields:
	Field View:BufferView
	
	Field Address:UInt
	Field Count:UInt
End

Class InvalidViewMappingOperation Extends InvalidViewOperation
	' Constructor(s):
	Method New(View:BufferView, Offset:UInt, Count:UInt)
		Super.New(View, Offset, Count)
	End
	
	' Methods:
	Method To:String() Override
		Local Message:= "Failed to map a memory view at: " + ConvertAddress(Address)
		
		If (Count > 0) Then
			Return (Message + PostCount())
		Endif
		
		Return Message
	End
End

Class InvalidViewReadOperation Extends InvalidViewOperation ' InvalidBufferViewReadOperation
	' Constructor(s):
	Method New(View:BufferView, Address:UInt, Count:UInt=0)
		Super.New(View, Address, Count)
	End
	
	' Methods:
	Method To:String() Override
		Local Message:= "Attempted to read from invalid local memory address: " + ConvertAddress(Address)
		
		If (Count > 0) Then
			Return (Message + PostCount())
		Endif
		
		Return Message
	End
End

Class InvalidViewWriteOperation Extends InvalidViewOperation ' InvalidBufferViewWriteOperation
	' Constructor(s):
	Method New(View:BufferView, Address:UInt, Count:UInt=0)
		Super.New(View, Address, Count)
	End
	
	' Methods:
	Method To:String() Override
		Local Message:= "Attempted to perform an invalid write-operation on local address: " + ConvertAddress(Address)
		
		If (Count > 0) Then
			Return (Message + PostCount())
		Endif
		
		Return Message
	End
End