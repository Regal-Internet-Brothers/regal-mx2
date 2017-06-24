Namespace regal.memory.bufferview

' Imports:
#Import "exceptions"

Using regal.memory.sizeof
Using regal.memory.pointers
'Using regal.memory.byteorder

Using std.memory
Using std.resource
Using std.collections..

' Constant variable(s) (Private):
Private

Const MAX_VIEW_ELEMENTS:UInt = 0 ' -1

Public

' Interfaces:
Interface BufferView
	' Methods:
	' Nothing so far.
	
	' Properties:
	Property Data:BufferPointer()
	Property Offset:UInt()
End

Interface ElementView Extends BufferView
	' Methods:
	
	' This converts 'Index' into a "raw address";
	' used for internal memory operations.
	' For details, view the 'ArrayView.OffsetIndexToAddress' command.
	Method IndexToRawAddress:UInt(Index:UInt)
	
	' Properties:
	Property Data:BufferPointer()
	
	' This supplies the raw size of this view.
	' For details, view the 'ArrayView.Size' property.
	Property Size:UInt()
	
	' This specifies the size of each element in this view.
	Property ElementSize:UInt()
End

' Classes:
Class ArrayView<ValueType> Extends Resource Implements ElementView Abstract ' BufferView
	' Constant variable(s) (Public):
	' Nothing so far.
	
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
			* The 'ElementCount' argument(s) is/are bound by the amount of memory given to the view.
				This means the segment of a buffer that you intend to map must be at least the
				length you specify, scaled according to the requested size for each element.
				
				An invalid size will result in an exception.
	#End
	
	Method New(ElementSize:UInt, ElementCount:UInt)
		Self.ElementSize = ElementSize
		
		InitializeCustomBuffer(ElementSize, ElementCount)
	End
	
	Method New(ElementSize:UInt, Data:BufferPointer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Self.Offset = OffsetInBytes
		Self.ElementSize = ElementSize
		
		Self._Data = Data
		
		Self.Size = GetSize(Data, ElementSize, ElementCount)
	End
	
	' The 'ExtraOffset' argument is used to offset from the 'View' object's offset.
	Method New(ElementSize:UInt, View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Self.ElementSize = ElementSize
		
		Self.Offset = (View.Offset + ExtraOffset)
		
		Self._Data = View.Data
		
		Self.Size = GetSize(Self.Data, ElementSize, ElementCount)
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method New(ElementCount:UInt)
		Self.New(SizeOf<ValueType>(), ElementCount)
	End
	
	Public
	
	' Constructor(s) (Private):
	Private
	
	Method GetSize:UInt(Data:BufferPointer, ElementSize:UInt, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		If (ElementCount = MAX_VIEW_ELEMENTS) Then
			Return Data.Length
		Endif
		
		Local IntendedSize:= (ElementCount * ElementSize) ' CountInBytes(ElementCount)
		
		' Make sure the intended size is correct.
		If (IntendedSize < ElementSize Or IntendedSize > Data.Length) Then
			' The intended size is either too large, or too small.
			Throw New InvalidViewMappingOperation(Self, Offset, IntendedSize)
		Endif
		
		Return IntendedSize
	End
	
	' NOTE: It is considered unsafe to call this constructor before assigning a value to the 'ElementSize' property.
	Method InitializeCustomBuffer:Void(ElementSize:UInt, ElementCount:UInt) Final
		If (ElementSize = 0 Or ElementCount = 0) Then
			Throw New BulkAllocationException<BufferView>(Self, 0) ' IntendedSize
		Endif
		
		Local IntendedSize:= (ElementCount * ElementSize)
		
		Self._Data = New BufferPointer(IntendedSize) ' CountInBytes(ElementCount)
		
		Self.Offset = 0
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
	
	' If overridden, these methods must respect the 'Offset' property:
	Method Get:ValueType(Index:UInt) ' Virtual
		Return GetRaw(Offset + IndexToAddress(Index))
	End
	
	Method Set:Void(Index:UInt, Value:ValueType) ' Virtual
		SetRaw(Offset + IndexToAddress(Index), Value)
		
		Return
	End
	
	' This performs a raw memory transfer/copy from this view to 'Output'.
	' This means the output is not casted, but rather a mapped copy of the data.
	Method Transfer:Bool(InputIndex:UInt, Output:ElementView, OutputIndex:Int, Count:UInt) ' ArrayView
		Return ViewTransfer<ArrayView, ElementView>(Self, InputIndex, Output, OutputIndex, Count) ' ArrayView<ValueType>
	End
	
	' This performs an element-level transfer/copy from 'Input' to this view.
	' This means that each element is casted from their source type/size to the destination type/size.
	Method Copy:Bool(Index:UInt, Input:ArrayView, InputIndex:Int, Count:UInt) ' ArrayView<ValueType>
		Return ViewCopy<ArrayView, ArrayView>(Input, InputIndex, Self, Index, Count) ' ArrayView<ValueType>
	End
	
	Method Copy:Bool(Index:UInt, Input:ArrayView, InputIndex:Int=0)
		Return Copy(Index, Input, InputIndex, Min(Self.Length, Input.Length))
	End
	
	Method Copy:Bool(Input:ArrayView)
		Return Copy(0, Input, 0)
	End
	
	' This returns 'False' if the bounds specified are considered invalid.
	Method GetArray:Bool(Index:UInt, Output:ValueType[], Count:UInt, OutputOffset:UInt=0)
		' Calculate the end-point we'll be reaching.
		Local ByteBounds:= OffsetIndexToAddress(Index+Count)
		
		' Make sure the end-point fits within our buffer-segment.
		If (ByteBounds > Size) Then
			Return False
		Endif
		
		' This will be used to store our current write-location in 'Output'.
		Local OutputPosition:= OutputOffset
		
		' The current raw address in the internal buffer.
		Local Address:= OffsetIndexToAddress(Index)
		
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
	Method SetArray:Bool(Index:UInt, Input:ValueType[], Count:UInt, InputOffset:UInt=0)
		' Calculate the end-point we'll be reaching.
		Local ByteBounds:= OffsetIndexToAddress(Index+Count)
		
		' Make sure the end-point fits within our buffer-segment.
		If (ByteBounds > Size) Then
			Return False
		Endif
		
		' This will store our current position in the 'Input' array.
		Local InputPosition:= InputOffset
		
		' The current raw address in the internal buffer.
		Local Address:= OffsetIndexToAddress(Index)
		
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
	
	Method SetArray:Bool(Index:UInt, Input:ValueType[])
		Return SetArray(Index, Input, Input.Length)
	End
	
	' TODO: Optimize this overload to bypass index conversion.
	Method SetArray:Bool(Input:ValueType[])
		Return SetArray(0, Input)
	End
	
	' This returns 'False' if the bounds specified are considered invalid.
	Method Clear:Bool(Index:UInt, Count:UInt, Value:ValueType)
		' Calculate the end-point we'll be reaching.
		Local ByteBounds:= OffsetIndexToAddress(Index+Count)
		
		' Make sure the end-point fits within our buffer-segment.
		If (ByteBounds > ViewBounds) Then
			Return False
		Endif
		
		' The current raw address in the internal buffer.
		Local Address:= OffsetIndexToAddress(Index)
		
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
	
	#Rem
		The result of this method is a non-convertible raw address.
		By definition, this address may not be used with commands like
		'AddressToIndex', as the value would be skewed.
		
		To fix this address for such commands, subtract a stored result gathered
		from the 'Offset' property at the time this method was called.
		
		Because the value of 'Offset' can be changed, you must always ensure that
		the offset you apply to restore the appropriate value corresponds with the
		original value associated with this object's 'Offset' property.
		
		This type of address manipulation is not recommended,
		and should be avoided wherever possible.
	#End
	
	Method OffsetIndexToAddress:UInt(Index:UInt) Final
		Return (IndexToAddress(Index) + Offset)
	End
	
	' This method is an extension, which should only be used when converting
	' a value from a real address to a convertible address.
	' This command is not recommended, and is subject to deletion.
	Method __OffsetAddressToIndex:UInt(_Address:UInt) Final
		Return AddressToIndex(_Address - Offset)
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
	
	' This method wraps 'OffsetIndexToAddress' for compatibility with the 'ElementView' interface.
	Method IndexToRawAddress:UInt(Index:UInt) Final
		Return OffsetIndexToAddress(Index)
	End
	
	Method SetRaw:Void(Address:UInt, Value:ValueType) Final
		Local ElementSize:= Self.ElementSize
		
		If ((Address + ElementSize) > ViewBounds) Then ' Address < 0
			Throw New InvalidViewWriteOperation(Self, Address, ElementSize)
		Endif
		
		SetRaw_Unsafe(Address, Value)
		
		Return
	End
	
	Method GetRaw:ValueType(Address:UInt) Final
		Local ElementSize:= Self.ElementSize
		
		If ((Address + ElementSize) > ViewBounds) Then ' Address < 0
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
	' This is mainly useful for raw bounds checks that already account for offsets.
	' For a good example of this, view the 'GetArray' command's implementation(s).
	Property ViewBounds:UInt()
		Return (Size + Offset)
	End
	
	' This returns the raw size of the internal buffer area (In bytes), without adjusting for offsets.
	' This is useful when the literal size (In bytes) of this view is required.
	Property Size:UInt()
		Return Self._Size ' UInt(Data.Length)
	Setter(Value:UInt)
		Self._Size = Value
	End
	
	' This specifies the size of an element.
	Property ElementSize:UInt()
		Return Self._ElementSize
	Setter(Value:UInt)
		Self._ElementSize = Value
	End
	
	' This provides access to the internal buffer-offset.
	' Note: This is already accounted for when calculating 'Size'.
	Property Offset:UInt()
		Return Self._Offset
	Setter(Value:UInt)
		Self._Offset = Value
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
	' Constructor(s) (Public):
	Method New(ElementSize:UInt, ElementCount:UInt)
		Super.New(ElementSize, ElementCount)
	End
	
	Method New(ElementSize:UInt, Data:BufferPointer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(ElementSize, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(ElementSize:UInt, View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(ElementSize, View, ElementCount, ExtraOffset)
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method New(ElementCount:UInt)
		Super.New(ElementCount)
	End
	
	Public
	
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

Class IntArrayView Extends MathArrayView<Int> ' ArrayView<Long> ' Int ' LongArrayView
	' Constant variable(s):
	Const Type_Size:= SizeOf<Int>() ' 4
	
	' Constructor(s) (Public):
	Method New(Count:UInt)
		Super.New(Type_Size, Count)
		'Super.New(Count)
	End
	
	Method New(Data:BufferPointer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method New(Type_Size:UInt, ElementCount:UInt)
		Super.New(Type_Size, ElementCount)
	End
	
	Method New(Type_Size:UInt, Data:BufferPointer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(Type_Size:UInt, View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	Public
	
	' Methods (Protected):
	Protected
	
	#Rem
		Method GetRaw_Unsafe:Int(Address:UInt) Override
			Return Data.Peek<Int>(Address)
		End
		
		Method SetRaw_Unsafe:Void(Address:UInt, Value:Int) Override
			Data.Poke<Int>(Address, Value)
			
			Return
		End
	#End
	
	Public
End

Class ShortArrayView Extends IntArrayView ' MathArrayView<Short>
	' Constant variable(s):
	Const Type_Size:= SizeOf<Short>()
	
	' Constructor(s) (Public):
	Method New(Count:UInt)
		Super.New(Type_Size, Count)
	End
	
	Method New(Data:BufferPointer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method New(Type_Size:UInt, ElementCount:UInt)
		Super.New(Type_Size, ElementCount)
	End
	
	Method New(Type_Size:UInt, Data:BufferPointer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(Type_Size:UInt, View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	Public
	
	' Methods (Protected):
	Protected
	
	Method GetRaw_Unsafe:Int(Address:UInt) Override ' Final ' Short
		Return Data.Peek<Short>(Address)
	End
	
	Method SetRaw_Unsafe:Void(Address:UInt, Value:Int) Override ' Final ' Short
		Data.Poke<Short>(Address, Value)
		
		Return
	End
	
	Public
End

Class ByteArrayView Extends ShortArrayView ' MathArrayView<Byte>
	' Constant variable(s):
	Const Type_Size:= SizeOf<Byte>() ' 1
	
	' Constructor(s):
	Method New(Count:UInt)
		Super.New(Type_Size, Count)
	End
	
	Method New(Data:BufferPointer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	' Methods (Public):
	
	' These two methods follow the integrity rules of 'Offset':
	#Rem
		Method Get:Int(Address:UInt) Override ' Byte
			Return GetRaw(Offset + Address)
		End
		
		Method Set:Void(Address:UInt, Value:Int) Override ' Byte
			SetRaw(Offset + Address, Value)
			
			Return
		End
	#End
	
	#Rem
		Method IndexToAddress:UInt(Address:UInt) ' Index:UInt
			Return Address
		End
		
		Method AddressToIndex:UInt(Address:UInt)
			Return Address
		End
	#End
	
	' Methods (Protected):
	Protected
	
	Method GetRaw_Unsafe:Int(Address:UInt) Override ' Final ' Byte
		Return Data.Peek<Byte>(Address)
	End
	
	Method SetRaw_Unsafe:Void(Address:UInt, Value:Int) Override ' Final ' Byte
		Data.Poke<Byte>(Address, Value)
		
		Return
	End
	
	Public
End

Class FloatArrayView Extends MathArrayView<Float> ' DoubleArrayView
	' Constant variable(s):
	Const Type_Size:= SizeOf<Float>() ' 4 ' 8
	
	' Constructor(s):
	Method New(Count:UInt)
		Super.New(Type_Size, Count)
	End
	
	Method New(Data:BufferPointer, OffsetInBytes:UInt=0, ElementCount:UInt=MAX_VIEW_ELEMENTS)
		Super.New(Type_Size, Data, OffsetInBytes, ElementCount)
	End
	
	Method New(View:BufferView, ElementCount:UInt=MAX_VIEW_ELEMENTS, ExtraOffset:UInt=0)
		Super.New(Type_Size, View, ElementCount, ExtraOffset)
	End
	
	' Methods (Protected):
	Protected
	
	Method GetRaw_Unsafe:Float(Address:UInt) Override ' Final ' Double
		Return Data.Peek<Float>(Address)
	End
	
	Method SetRaw_Unsafe:Void(Address:UInt, Value:Float) Override ' Final ' Double
		Data.Poke<Float>(Address, Value)
		
		Return
	End
	
	Public
End

' Functions:

#Rem
	This performs a raw memory copy from one view to another.
	
	Address translations are performed before copy-operations
	take place, and are checked accordingly.
	
	The 'Count' argument specifies the number of elements to be copied from 'Input'.
	
	If preliminary bounds checks fail, this command will return 'False'.
#End

Function ViewTransfer<A, B>:Bool(Input:A, InputIndex:UInt, Output:B, OutputIndex:Int, Count:UInt) ' ArrayView ' ElementView
	' Get the appropriate element size.
	Local ElementSize:= Input.ElementSize ' Min(Input.ElementSize, Output.ElementSize)
	Local BytesToTransfer:= (ElementSize * Count)
	
	' Calculate the end-points we'll be reaching:
	Local InByteBounds:= Input.IndexToRawAddress(InputIndex + Count)
	Local OutByteBounds:= Output.IndexToRawAddress(OutputIndex) + BytesToTransfer ' Output.IndexToRawAddress(OutputIndex + Count)
	
	' Make sure the end-points fit within our buffer segments:
	If (InByteBounds > Input.Size Or OutByteBounds > Output.Size) Then
		Return False
	Endif
	
	' The starting raw address in the output buffer.
	Local OutputAddress:= Output.IndexToRawAddress(OutputIndex)
	
	' The starting raw address in the input buffer.
	Local InputAddress:= Input.IndexToRawAddress(InputIndex)
	
	' Perform a raw memory copy from 'Input.Data' to 'Output.Data'.
	Input.Data.CopyTo(Output.Data, InputAddress, OutputAddress, BytesToTransfer)
	
	' Return the default response.
	Return True
End

' This performs an element-level copy from one view to another.
' If preliminary bounds checks fail, this command will return 'False'.
Function ViewCopy<A, B>:Bool(Input:A, InputIndex:UInt, Output:B, OutputIndex:Int, Count:UInt) ' ArrayView ' ElementView
	' Calculate the appropriate element size.
	Local InElementSize:= Input.ElementSize
	Local OutElementSize:= Output.ElementSize
	
	' Calculate the end-points we'll be reaching:
	Local InByteBounds:= Input.IndexToRawAddress(InputIndex + Count)
	Local OutByteBounds:= Output.IndexToRawAddress(OutputIndex + Count)
	
	' Make sure the end-points fit within our buffer segments:
	If (InByteBounds > Input.Size Or OutByteBounds > Output.Size) Then
		Return False
	Endif
	
	' The starting raw address in the output buffer.
	Local OutputAddress:= Output.IndexToRawAddress(OutputIndex)
	
	' The starting raw address in the input buffer.
	Local InputAddress:= Input.IndexToRawAddress(InputIndex)
	
	' Continue until we've reached our described bounds:
	While (InputAddress < InByteBounds)
		#Rem
			If (OutputAddress >= OutByteBounds) Then
				Exit
			Endif
		#End
		
		' Copy the value located at 'InputAddress' into the output at 'OutputAddress'.
		Output.SetRaw_Unsafe(OutputAddress, Input.GetRaw_Unsafe(InputAddress))
		
		' Move forward by one entry on each address:
		InputAddress += InElementSize
		OutputAddress += OutElementSize
	Wend
	
	' Return the default response.
	Return True
End