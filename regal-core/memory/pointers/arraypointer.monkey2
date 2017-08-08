Namespace regal.memory.pointers

' Aliases:
Alias ArrayPointer<T>:ContainerPointer<T[], T>

' Structures:
Struct ContainerPointer<ContainerType, ValueType>
	Public
		' Constructor(s):
		Method New(data:ContainerType, index:Int, length:Int, dynamic_length:Bool)
			' Check for errors:
			
			'DebugAssert(..., "Invalid array-region specified")
			
			If (data = Null) Then
				Return
			Endif
			
			If (index < 0) Then
				Return
			Endif
			
			If (Not dynamic_length) Then
				If (index >= length) Then
					Return
				Endif
				
				If (data.Length = 0) Then
					Return
				Endif
				
				If (length > data.Length) Then
					Return
				Endif
			Endif
			
			Self.data = data
			Self.index = index
			Self.length = length
			
			Self.dynamic_length = dynamic_length
		End
		
		Method New(data:ContainerType, index:Int=0)
			Self.New(data, index, data.Length, True)
		End
		
		' Methods:
		
		' For absolute safety, debug asserts are performed on all access paths:
		Method Get:ValueType()
			Return Get(0)
		End
		
		Method Set:Void(value:ValueType)
			Set(0, value)
		End
		
		Method Get:ValueType(offset:Int)
			DebugAssert(ValidIndex(offset), "Invalid array index specified while reading")
			
			Return data[index + offset]
		End
		
		Method Set:Void(offset:Int, value:ValueType)
			DebugAssert(ValidIndex(offset), "Invalid array index specified while writing")
			
			data[index + offset] = value
		End
		
		Method ValidIndex:Bool(offset:Int=0)
			If (Length = 0) Then
				Return False
			Endif
			
			Local address:= (index + offset)
			
			Return (address >= 0 And address < Length)
		End
		
		' Operators:
		Operator To:ValueType()
			Return Get()
		End
		
		' Boolean casts are always safe.
		Operator To:Bool()
			Return (IsValid And Bool(Get()))
		End
		
		Operator[]:ValueType(offset:Int)
			Return Get(offset)
		End
		
		Operator[]=:Void(offset:Int, value:ValueType)
			Set(offset, value)
		End
		
		Operator+:ContainerPointer(pointer_diff:Int)
			DebugAssert(IsValid, "Attempted to add with an invalid array-pointer")
			
			Return New ContainerPointer<ContainerType, ValueType>(Data, (index + pointer_diff), Length, Dynamic)
		End
		
		Operator-:ContainerPointer(pointer_diff:Int)
			DebugAssert(IsValid, "Attempted to subtract with an invalid array-pointer")
			
			Return New ContainerPointer(Data, (index - pointer_diff), Length, Dynamic)
		End
		
		Operator<:Bool(pointer:ContainerPointer)
			If (Self.Data <> pointer.Data) Then
				Return False
			Endif
			
			Return (Self < pointer.Index)
		End
		
		Operator>:Bool(pointer:ContainerPointer)
			If (Self.Data <> pointer.Data) Then
				Return False
			Endif
			
			Return (Self > pointer.Index)
		End
		
		Operator=:Bool(index:Int)
			Return (Self.Index = index)
		End
		
		Operator<:Bool(index:Int)
			Return (Self.Index < index)
		End
		
		Operator >:Bool(index:Int)
			Return (Self.Index > index)
		End
		
		' Properties:
		
		' This specifies the container we're pointing to.
		Property Data:ContainerType()
			Return Self.data
		End
		
		' This specifies the index of this pointer.
		Property Index:Int()
			Return Self.index
		End
		
		' This specifies the length of 'Data'.
		Property Length:Int()
			If (Dynamic) Then
				Self.length = data.Length
			Endif
			
			Return Self.length
		End
		
		' This specifies if 'Length' is calculated dynamically.
		Property Dynamic:Bool()
			Return Self.dynamic_length
		End
		
		' This states if this pointer is considered valid.
		Property IsValid:Bool()
			Return ValidIndex(0)
		End
	Protected
		' Fields:
		
		' This contains a reference to the container we're pointing to.
		Field data:ContainerType
		
		' The specifies the index this pointer represents.
		Field index:Int ' UInt
		
		' The specifies the last verified length of 'data'.
		' If 'dynamic_length' is enabled, this is
		' updated every time 'Length' is used.
		Field length:Int ' UInt
		
		' This specifies if the length of 'data' is dynamic.
		Field dynamic_length:Bool
End