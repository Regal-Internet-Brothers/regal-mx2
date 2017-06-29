Namespace regal.memory.bufferview

' Imports:
#Import "exceptions"

Using regal.memory.sizeof
Using regal.memory.pointers
'Using regal.memory.byteorder

Using std.memory
Using std.resource

Using std.collections..

' Aliases:
Alias IntArrayView:MathArrayView<Int>
Alias ShortArrayView:MathArrayView<Short>
Alias ByteArrayView:MathArrayView<Byte>

Alias FloatArrayView:MathArrayView<Float>
Alias DoubleArrayView:MathArrayView<Double>

' Classes:
Class ArrayView<ValueType> Extends Resource Abstract
	' Structures:
	Struct Iterator ' Implements IIterator<ValueType> ' T
		Private
			' Fields:
			Field _view:ArrayView
			Field _index:Int ' UInt
	
			' Methods:
			Method AssertCurrent()
				DebugAssert((_index < _view.Length), "Invalid view iterator")
			End
	
			' Constructor(s):
			Method New(view:ArrayView, index:Int)
				_view = view
				_index = index
			End
		Public
			' Properties:
			Property AtEnd:Bool()
				Return _index >= _view.Length
			End
			
			Property Current:ValueType()
				AssertCurrent()
				
				Return _view[_index]
			Setter(current:ValueType)
				AssertCurrent()
				
				_view[_index] = current
			End
			
			' Methods:
			Method Bump:Void()
				AssertCurrent()
	
				_index+=1
			End
			
			' TODO: Fix 'Erase' and 'Insert':
			
			Method Erase:Void()
				AssertCurrent()
	
				_view[_index] = 0
			End
			
			Method Insert:Void(value:ValueType)
				DebugAssert(_index <= _view.Length, "Invalid view iterator")
	
				'_view.Insert(_index, value)
				_view[_index] = value
			End
	End
	
	' Constructor(s) (Public):
	
	#Rem
		NOTES:
			* The length of data-buffers are bound by the amount of memory given to the view.
				This means the segment of a buffer that you intend to map must be at least the
				length you specify, scaled according to the requested size for each element.
				
				An invalid size will result in an exception.
	#End
	
	Method New(ElementCount:UInt)
		InitializeCustomBuffer(ElementCount)
	End
	
	Method New(DataPointer:BufferPointer)
		' Make sure the intended size is correct.
		If (DataPointer.Length < ElementSize) Then
			' The intended size is too small.
			Throw New InvalidViewMappingOperation(Self, DataPointer.Length)
		Endif
		
		Self._Data = DataPointer
		Self.Size = DataPointer.Length
	End
	
	Method New(DataPointer:BufferPointer, OffsetInBytes:UInt)
		Self.New(New BufferPointer(DataPointer.GetBytePointer(OffsetInBytes), (DataPointer.Length - OffsetInBytes), DataPointer.OwnsData))
	End
	
	Method New(Data:DataBuffer, ElementCount:UInt, OffsetInBytes:UInt=0)
		Local ElementAllocSize:= (ElementCount * ElementSize)
		Local Buffer:= New BufferPointer(Data, ElementAllocSize, OffsetInBytes)
		
		Self._Data = Buffer
		
		' Make sure the intended size is correct.
		If (ElementAllocSize < ElementSize Or ElementAllocSize > Data.Length) Then
			' The intended size is either too large, or too small.
			Throw New InvalidViewMappingOperation(Self, ElementAllocSize)
		Endif
		
		Self.Size = ElementAllocSize
	End
	
	Method New(Data:DataBuffer)
		Self.New(Data, (Data.Length / ElementSize))
	End
	
	' Constructor(s) (Private):
	Private
	
	' NOTE: It is considered unsafe to call this constructor before assigning a value to the 'ElementSize' property.
	Method InitializeCustomBuffer:Void(ElementCount:UInt)
		If (ElementSize = 0 Or ElementCount = 0) Then
			Throw New BulkAllocationException<Resource>(Self, 0) ' IntendedSize
		Endif
		
		Local IntendedSize:= (ElementCount * ElementSize)
		
		Self._Data = New BufferPointer(IntendedSize) ' CountInBytes(ElementCount)
		
		Self.Size = Self.Data.Length
	End
	
	Public
	
	' Operator(s):
	Operator[]:ValueType(Index:Int) ' UInt
		Return Get(Index)
	End
	
	Operator[]=:Void(Index:Int, Value:ValueType) ' UInt
		Set(Index, Value)
	End
	
	' Methods (Public):
	Method All:Iterator()
		Return New Iterator(Self, 0)
	End
	
	Method Get:ValueType(Index:UInt)
		Return GetRaw(IndexToAddress(Index))
	End
	
	Method Set:Void(Index:UInt, Value:ValueType)
		SetRaw(IndexToAddress(Index), Value)
		
		Return
	End
	
	#Rem
		This performs a raw memory copy from one view to another.
		This means the output is not casted, but rather a mapped copy of the data.
		
		Address translations are performed before copy-operations
		take place, and are checked accordingly.
		
		The 'Count' argument specifies the number of elements to be copied from this view.
		
		If preliminary bounds checks fail, this command will return 'False'.
	#End
	
	Method Transfer<ElementView>:Bool(InputIndex:UInt, Output:ElementView, OutputIndex:Int, Count:UInt) ' ArrayView
		' Get the appropriate element size.
		Local ElementSize:= Self.ElementSize ' Min(Self.ElementSize, Output.ElementSize)
		Local BytesToTransfer:= (ElementSize * Count)
		
		' Calculate the end-points we'll be reaching:
		Local InByteBounds:= Self.IndexToAddress(InputIndex + Count)
		Local OutByteBounds:= Output.IndexToAddress(OutputIndex) + BytesToTransfer ' Output.IndexToAddress(OutputIndex + Count)
		
		' Make sure the end-points fit within our buffer segments:
		If (InByteBounds > Self.Size Or OutByteBounds > Output.Size) Then
			Return False
		Endif
		
		' The starting raw address in the output buffer.
		Local OutputAddress:= Output.IndexToAddress(OutputIndex)
		
		' The starting raw address in the input buffer.
		Local InputAddress:= Self.IndexToAddress(InputIndex)
		
		' Perform a raw memory copy from 'Self.Data' to 'Output.Data'.
		Self.Data.CopyTo(Output.Data, InputAddress, OutputAddress, BytesToTransfer)
		
		' Return the default response.
		Return True
	End
	
	' This performs an element-level transfer/copy from 'Input' to this view.
	' This means that each element is casted from their source type/size to the destination type/size.
	' If preliminary bounds checks fail, this command will return 'False'.
	Method Copy<ElementView>:Bool(OutputIndex:UInt, Input:ElementView, InputIndex:Int, Count:UInt) ' ArrayView<ValueType>
		' Calculate the appropriate element size.
		Local InElementSize:= Input.ElementSize
		Local OutElementSize:= Self.ElementSize
		
		' Calculate the end-points we'll be reaching:
		Local InByteBounds:= Input.IndexToAddress(InputIndex + Count)
		Local OutByteBounds:= Self.IndexToAddress(OutputIndex + Count)
		
		' Make sure the end-points fit within our buffer segments:
		If (InByteBounds > Input.Size Or OutByteBounds > Self.Size) Then
			Return False
		Endif
		
		' The starting raw address in the output buffer.
		Local OutputAddress:= Self.IndexToAddress(OutputIndex)
		
		' The starting raw address in the input buffer.
		Local InputAddress:= Input.IndexToAddress(InputIndex)
		
		' Continue until we've reached our described bounds:
		While (InputAddress < InByteBounds)
			#Rem
				If (OutputAddress >= OutByteBounds) Then
					Exit
				Endif
			#End
			
			' Copy the value located at 'InputAddress' into the output at 'OutputAddress'.
			Self.SetRaw_Unsafe(OutputAddress, Input.GetRaw_Unsafe(InputAddress))
			
			' Move forward by one entry on each address:
			InputAddress += InElementSize
			OutputAddress += OutElementSize
		Wend
		
		' Return the default response.
		Return True
	End
	
	Method Copy<ElementView>:Bool(Index:UInt, Input:ElementView, InputIndex:Int=0)
		Return Copy(Index, Input, InputIndex, Min(Self.Length, Input.Length))
	End
	
	Method Copy<ElementView>:Bool(Input:ElementView)
		Return Copy(0, Input, 0)
	End
	
	' This returns 'False' if the bounds specified are considered invalid.
	Method GetArray<ArrayType>:Bool(Index:UInt, Output:ArrayType, Count:UInt, OutputOffset:UInt=0)
		' Calculate the end-point we'll be reaching.
		Local ByteBounds:= IndexToAddress(Index+Count)
		
		' Make sure the end-point fits within our buffer-segment.
		If (ByteBounds > Size) Then
			Return False
		Endif
		
		' This will be used to store our current write-location in 'Output'.
		Local OutputPosition:= OutputOffset
		
		' The current raw address in the internal buffer.
		Local Address:= IndexToAddress(Index)
		
		' Continue until we've reached our described bounds.
		While (Address < ByteBounds)
			' Copy the value located at 'Address' into the output.
			Output[OutputPosition] = GetRaw_Unsafe(Address)
			
			' Move to the next target-location for the output-data.
			OutputPosition += 1
			
			' Move forward by one entry.
			Address += ElementSize
		Wend
		
		' Return the default response.
		Return True
	End
	
	Method GetArray:ValueType[](Index:UInt, Count:UInt, _ArrOff:UInt=0)
		Local Output:= New ValueType[_ArrOff + Count]
		
		If (Not GetArray(Index, Output, Count, _ArrOff)) Then
			Return Null
		Endif
		
		Return Output
	End
	
	Method GetArray:ValueType[]()
		Return GetArray(0, Length)
	End
	
	' This returns 'False' if the bounds specified are considered invalid.
	Method SetArray<ArrayType>:Bool(Index:UInt, Input:ArrayType, Count:UInt, InputOffset:UInt=0)
		' Calculate the end-point we'll be reaching.
		Local ByteBounds:= IndexToAddress(Index+Count)
		
		' Make sure the end-point fits within our buffer-segment.
		If (ByteBounds > Size) Then
			Return False
		Endif
		
		' This will store our current position in the 'Input' array.
		Local InputPosition:= InputOffset
		
		' The current raw address in the internal buffer.
		Local Address:= IndexToAddress(Index)
		
		' The amount 'Address' will move by on each iteration.
		Local Stride:= ElementSize
		
		' Continue until we've reached our described bounds.
		While (Address < ByteBounds)
			' Write a value at the current address using an entry from the input-data.
			SetRaw_Unsafe(Address, Input[InputPosition])
			
			' Move to the next entry in the input-data.
			InputPosition += 1
			
			' Move forward by one entry.
			Address += Stride
		Wend
		
		' Return the default response.
		Return True
	End
	
	Method SetArray<ArrayType>:Bool(Index:UInt, Input:ArrayType)
		Return SetArray(Index, Input, Input.Length)
	End
	
	' TODO: Optimize this overload to bypass index conversion.
	Method SetArray<ArrayType>:Bool(Input:ArrayType)
		Return SetArray(0, Input)
	End
	
	' This returns 'False' if the bounds specified are considered invalid.
	Method Clear:Bool(Index:UInt, Count:UInt, Value:ValueType)
		' Calculate the end-point we'll be reaching.
		Local ByteBounds:= IndexToAddress(Index+Count)
		
		' Make sure the end-point fits within our buffer-segment.
		If (ByteBounds > Size) Then
			Return False
		Endif
		
		' The current raw address in the internal buffer.
		Local Address:= IndexToAddress(Index)
		
		' The amount 'Address' will move by on each iteration.
		Local Stride:= ElementSize
		
		' Continue until we've reached our described bounds.
		While (Address < ByteBounds)
			' Clear an entry at our current location in the buffer.
			SetRaw(Address, Value)
			
			' Move forward by one entry.
			Address += Stride
		Wend
		
		' Return the default response.
		Return True
	End
	
	' This calls 'Clear' using a value of 'Null'.
	Method Clear:Bool(Index:UInt, Count:UInt)
		Return Clear(Index, Count, Null)
	End
	
	' This clears the entire view using the value specified.
	Method Clear:Bool(Value:ValueType)
		Return Clear(0, Length, Value)
	End
	
	' TODO: Optimize this overload to bypass either index conversion or standard assignment.
	Method Clear:Bool()
		Return Clear(Null)
	End
	
	Method Add:ValueType(Index:UInt, Value:ValueType)
		Local Result:= (Get(Index) + Value)
		
		Set(Index, Result)
		
		Return Result
	End
	
	Method Subtract:ValueType(Index:UInt, Value:ValueType)
		Return Add(Index, -Value)
	End
	
	' This supplies the raw size of 'Count' elements in bytes.
	Method CountInBytes:UInt(Count:Int)
		Return IndexToAddress(Count) ' (Count * ElementSize)
	End
	
	' This converts an index to a raw address for use with the internal buffer.
	Method IndexToAddress:UInt(Index:UInt)
		If (ElementSize = 1) Then
			Return Index
		Endif
		
		Return (Index * ElementSize)
	End
	
	' This converts a raw address to an index.
	Method AddressToIndex:UInt(Address:UInt)
		If (ElementSize = 1) Then
			Return Address
		Endif
		
		Return (Address / ElementSize)
	End
	
	' Methods (Protected):
	Protected
	
	' These two methods operate on raw addresses.
	' This means the input should not be an index,
	' nor should it be a non-offset address.
	' Implementations should not bother with out-of-bounds checks.
	Method GetRaw_Unsafe:ValueType(RawAddress:UInt) Virtual
		Return Data.Peek<ValueType>(RawAddress)
	End
	
	Method SetRaw_Unsafe:Void(RawAddress:UInt, Value:ValueType) Virtual
		Data.Poke<ValueType>(RawAddress, Value)
	End
	
	' Implemented:
	Method SetRaw:Void(Address:UInt, Value:ValueType) Final
		Local ElementSize:= Self.ElementSize
		
		If ((Address + ElementSize) > Size) Then ' Address < 0
			Throw New InvalidViewWriteOperation(Self, Address, ElementSize)
		Endif
		
		SetRaw_Unsafe(Address, Value)
		
		Return
	End
	
	Method GetRaw:ValueType(Address:UInt) Final
		Local ElementSize:= Self.ElementSize
		
		If ((Address + ElementSize) > Size) Then ' Address < 0
			Throw New InvalidViewReadOperation(Self, Address, ElementSize)
		Endif
		
		Return GetRaw_Unsafe(Address)
	End
	
	Method OnDiscard:Void() Override
		Self._Data.Discard()
	End
	
	Public
	
	' Properties (Public):
	
	' This provides the number of elements in this view.
	Property Length:UInt()
		If (ElementSize = 1) Then
			Return Size
		Endif
		
		Return (Size / ElementSize)
	End
	
	' This describes the address of the absolute furthest into the internal buffer this view reaches.
	' This is mainly useful for raw bounds checks.
	' For a good example of this, view the 'GetArray' command's implementation(s).
	Property Size:UInt()
		Return Self._Size ' UInt(Data.Length)
	Setter(Value:UInt)
		Self._Size = Value
	End
	
	' This provides access to the internal buffer.
	Property Data:BufferPointer()
		Return Self._Data
	#Rem
		Setter(Value:BufferPointer)
			Self._Data.Discard() ' Discard()
			
			Self._Data = BufferPointer.Reference(Value)
			
			Self.Offset = 0
			'Self.Size = GetSize(Self._Data, ElementSize, ElementCount)
	#End
	End
	
	' This specifies the size of an element.
	Property ElementSize:UInt() ' Int
		Return SizeOf<ValueType>()
	End
	
	Property OwnsData:Bool()
		Return Self.Data.OwnsData
	End
	
	' Fields (Protected):
	Protected
	
	Field _ElementSize:UInt ' Int
	Field _Offset:UInt ' Int
	Field _Size:UInt ' Int
	
	Field _Data:BufferPointer
	
	Public
End

' This is an intermediate class which defines mathematical routines for both integral and floating-point types.
Class MathArrayView<ValueType> Extends ArrayView<ValueType> ' Abstract
	' Constructor(s):
	Method New(ElementCount:UInt)
		Super.New(ElementCount)
	End
	
	Method New(Data:BufferPointer, OffsetInBytes:UInt)
		Super.New(Data, OffsetInBytes)
	End
	
	Method New(Data:BufferPointer)
		Super.New(Data)
	End
	
	Method New(Data:DataBuffer, ElementCount:UInt, OffsetInBytes:UInt=0)
		Super.New(Data, ElementCount, OffsetInBytes)
	End
	
	Method New(Data:DataBuffer)
		Super.New(Data)
	End
	
	' Methods:
	
	' This increments the value located at 'Index' by one.
	Method Increment:ValueType(Index:UInt)
		Return Add(Index, Cast<ValueType>(1))
	End
	
	' This decrements the value located at 'Index' by one.
	Method Decrement:ValueType(Index:UInt)
		Return Subtract(Index, Cast<ValueType>(1))
	End
	
	' This multiplies the value located at 'Index' using the value specified.
	' The result is written into memory, then returned.
	Method Multiply:ValueType(Index:UInt, Value:ValueType)
		Local Result:= (Get(Index) * Value)
		
		Set(Index, Result)
		
		Return Result
	End
	
	' This divides the value located at 'Index' using the value specified.
	' The result is written into memory, then returned.
	Method Divide:ValueType(Index:UInt, Value:ValueType)
		Local Result:= (Get(Index) / Value)
		
		Set(Index, Result)
		
		Return Result
	End
	
	' This squares the value located at 'Index'.
	' The result is both returned by the method, and
	' written into memory at the specified location.
	Method Sq:ValueType(Index:UInt) ' Square
		Local Value:= Get(Index)
		Local Result:= (Value * Value)
		
		Set(Index, Result)
		
		Return Result
	End
	
	' This calculates the square-root of the value located at 'Index'.
	' The result is both returned by this method, and
	' written into memory at the specified location.
	Method Sqrt:ValueType(Index:UInt) ' SquareRoot
		Local Result:= Sqrt(Get(Index))
		
		Set(Index, Result)
		
		Return Result
	End
End