Namespace regal.memory.pointers

' Aliases:
Alias ArrayPointer<T>:ContainerPointer<T[], T>

' Structures:
Struct ContainerPointer<ContainerType, ValueType>
	Public
		' Constructor(s):
		Method New(data:ContainerType, index:Int, length:Int)
			'DebugAssert((index < length) And (data.Length > 0) And (length <= data.Length), "Invalid array-region specified")
			
			If ((index < length) And (data.Length > 0) And (length <= data.Length)) Then
				Self.data = data
				Self.index = index
				Self.length = length
			Endif
		End
		
		Method New(data:ContainerType, index:Int=0)
			Self.New(data, index, data.Length)
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
			If (length = 0) Then
				Return False
			Endif
			
			Local address:= (index + offset)
			
			Return (address >= 0 And address < length)
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
		
		Operator+:ContainerPointer<ContainerType, ValueType>(pointer_diff:Int)
			DebugAssert(IsValid, "Attempted to add with an invalid array-pointer")
			
			Return New ContainerPointer<ContainerType, ValueType>(data, (index + pointer_diff), length)
		End
		
		Operator-:ContainerPointer<ContainerType, ValueType>(pointer_diff:Int)
			DebugAssert(IsValid, "Attempted to subtract with an invalid array-pointer")
			
			Return New ContainerPointer<ContainerType, ValueType>(data, (index - pointer_diff), length)
		End
		
		' Properties:
		Property Data:ContainerType()
			Return Self.data
		End
		
		Property Index:Int()
			Return Self.index
		End
		
		Property Length:Int()
			Return Self.length
		End
		
		Property IsValid:Bool()
			Return ValidIndex(0)
		End
	Protected
		' Fields:
		Field data:ContainerType
		
		Field index:Int ' UInt
		Field length:Int ' UInt
End