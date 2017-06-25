Namespace regal.memory.dimensions

Using std.geom..

' Functions:
Function OneDimensional<T>:OneDim<T[,], T>(data:T[,], length:Vec2i, offset:Vec2i, sub_offset:Bool)
	Local range:Vec2i
	
	If (Not sub_offset) Then
		range = (offset + length)
	Else
		range = (length - offset)
	Endif
	
	DebugAssert(((range.x <= data.GetSize(0)) And (range.y <= data.GetSize(1))), "Index out of range")
	
	Return New OneDim<T[,], T>(data, length, offset, sub_offset)
End

Function OneDimensional<T>:OneDim<T[,], T>(data:T[,], offset:Vec2i=Null)
	Return OneDimensional(data, New Vec2i(data.GetSize(0), data.GetSize(1)), offset, True)
End

' Structures:

' A 1D view of a 2D type.
Struct OneDim<ContainerType, ValueType>
	Public
		' Functions:
		Function FlatLength:Int(width:Int, height:Int)
			Return (width * height)
		End
		
		Function FlatLength:Int(lengths:Vec2i)
			Return FlatLength(lengths.x, lengths.y)
		End
		
		' Constructor(s):
		
		' If 'sub_offset' is enabled, the 'length' argument will be reduced by 'offset'.
		' If disabled, 'length' is assumed as the expected length of this view.
		Method New(data:ContainerType, length:Vec2i, offset:Vec2i, sub_offset:Bool=False)
			If (sub_offset) Then
				length -= offset
			Endif
			
			Self.data = data
			Self.length = length
			Self.offset = offset
		End
		
		' Methods:
		
		' This provides the corresponding indices for 'index', before offsetting.
		Method GetRawIndices:Vec2i(index:Int) ' UInt
			Return New Vec2i((index Mod Width), (index / Width))
		End
		
		' This provides the corresponding indices for 'index', after offsetting.
		' These indices are presumed to work when used on 'data'.
		Method GetIndices:Vec2i(index:Int) ' UInt
			Return (GetRawIndices(index) + offset)
		End
		
		' Operators:
		Operator []:ValueType(index:Int) ' UInt
			DebugAssert((index < Length), "Index out of range")
			
			Local indices:= GetIndices(index)
			
			Return data[indices.x, indices.y]
		End
		
		Operator []=(index:Int, value:ValueType)
			Local indices:= GetIndices(index)
			
			data[indices.x, indices.y] = value
		End
		
		' Properties:
		Property Data:ContainerType()
			Return data
		End
		
		Property Length:Int()
			Return FlatLength(length) ' Width, Height
		End
		
		Property Offset:Vec2i()
			Return offset
		End
		
		Property Width:Int()
			Return length.x
		End
		
		Property Height:Int()
			Return length.y
		End
	Protected
		' Fields:
		Field data:ContainerType
		
		Field length:Vec2i
		Field offset:Vec2i
End