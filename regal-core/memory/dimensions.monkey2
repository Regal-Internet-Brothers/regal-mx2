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

' A 2D view of a 1D type.
Struct TwoDim<ContainerType, ValueType>
	Public
		' Constructor(s):
		
		' If 'sub_offset' is enabled, the 'size' argument will be reduced by 'offset'.
		' If disabled, 'size' is assumed as the expected size of this view.
		Method New(data:ContainerType, size:Vec2i, offset:Int=0, sub_offset:Bool=False)
			If (sub_offset) Then
				size -= offset
			Endif
			
			Self.data = data
			Self.size = size
			Self.offset = offset
		End
		
		' Methods:
		Method GetSize:Int(index:Int)
			Select (index)
				Case 0
					Return Size.x
				Case 1
					Return Size.y
			End Select
			
			Return 0
		End
		
		' This provides the corresponding index for 'indices', before offsetting.
		Method GetRawIndex:Int(indices:Vec2i) ' UInt
			Return (indices.x + (indices.y * Width))
		End
		
		' This provides the corresponding indices for 'index', after offsetting.
		' These indices are presumed to work when used on 'data'.
		Method GetIndex:Int(indices:Vec2i) ' UInt
			Return (GetRawIndex(indices) + offset)
		End
		
		' Operators:
		Operator []:ValueType(x:Int, y:Int) ' UInt
			Local indices:= New Vec2i(x, y)
			
			DebugAssert((indices < Size), "Index out of range")
			
			Local index:= GetIndex(indices)
			
			Return data[index]
		End
		
		Operator []=(x:Int, y:Int, value:ValueType)
			Local indices:= New Vec2i(x, y)
			
			DebugAssert((indices < Size), "Index out of range")
			
			Local index:= GetIndex(indices)
			
			data[index] = value
		End
		
		' Properties:
		Property Data:ContainerType()
			Return data
		End
		
		Property Length:Int()
			Return data.Length
		End
		
		Property Size:Vec2i()
			Return size
		End
		
		Property Offset:Int()
			Return offset
		End
		
		Property Width:Int()
			Return size.x
		End
		
		Property Height:Int()
			Return size.y
		End
	Protected
		' Fields:
		Field data:ContainerType
		
		Field size:Vec2i
		Field offset:Int
End

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
		Method New(data:ContainerType, length:Vec2i, offset:Vec2i=Null, sub_offset:Bool=False)
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
			DebugAssert((index < Length), "Index out of range")
			
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