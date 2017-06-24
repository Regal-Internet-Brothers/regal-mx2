Namespace regal.memory

' Imports:
#Import "exceptions"

#Import "bufferview/bufferview"
#Import "byteorder/byteorder"
#Import "sizeof/sizeof"

' Aliases:
Alias Pointer<T>:T Ptr
Alias MemoryPointer:Void Ptr ' Pointer<Void> ' Pointer<UByte>

' Structures:
Struct BufferPointer
	Public
		' Functions:
		Function FromArray<T>:BufferPointer(data:T[], length:Int)
			Return New BufferPointer(data.Data, length, False)
		End
		
		Function FromArray<T>:BufferPointer(data:T[])
			Return FromArray(data, data.Length)
		End
		
		Function GetBytePointer:Pointer<UByte>(base_address:MemoryPointer, byte_offset:Int) ' UInt
			Return (Cast<Pointer<UByte>>(base_address) + byte_offset)
		End
		
		' This produces a new 'BufferPointer' with the
		' contents of 'buffer', but without ownership rights.
		' Unlike the 'Reference' command, this will produce an
		' empty object if 'owner_buffer' doesn't have ownership rights.
		Function Share:BufferPointer(owner_buffer:BufferPointer)
			If (Not owner_buffer.OwnsData) Then
				Return Null
			Endif
			
			Return Reference(owner_buffer)
		End
		
		' This produces a copy of 'buffer' without ownership rights.
		Function Reference:BufferPointer(buffer:BufferPointer)
			Return New BufferPointer(buffer.data, buffer.length, False)
		End
		
		' Constructor(s):
		
		' NOTE: This is an unsafe memory allocation routine.
		' This will manually allocate a buffer of 'count' size
		' in bytes on the heap, then return a 'BufferPointer'
		' with ownership rights to said memory.
		' In order to deallocate this memory, use 'Discard'.
		' Usage of this overload is not recommended.
		Method New(count:Int) ' UInt
			Self.New(libc.malloc(count), count, True)
		End
		
		Method New(data:MemoryPointer, length:Int, owns_data:Bool)
			__Set(data, length, (data <> Null And owns_data))
		End
		
		Method New(buffer:DataBuffer, length:Int, offset:Int=0)
			Self.New((buffer.Data + offset), length, False)
		End
		
		Method New(data:DataBuffer)
			Self.New(data, data.Length)
		End
		
		#Rem
			Method New(count:Int)
				Self.data = libc.malloc(count)
				Self.length = count
				Self.owns_data = True
			End
		#End
		
		' Operators:
		
		#Rem
			Operator To:MemoryPointer()
				Return Self.data
			End
		#End
		
		#Rem
			' In the event we own data, discard it.
			Operator=:Void(value:BufferPointer)
				If (OwnsData) Then
					Discard()
				Endif
				
				Self.__Set(value.data, value.length, False)
			End
		#End
		
		#Rem
			Operator To:Pointer<UByte>()
				Return Cast<Pointer<UByte>>(Self.data)
			End
		#End
		
		Method To<T>:Pointer<T>()
			Return Cast<Pointer<T>>(Self.data)
		End
		
		' Methods:
		Method GetBytePointer:Pointer<UByte>(byte_offset:Int) ' UInt
			Return GetBytePointer(Self.data, byte_offset)
		End
		
		Method Poke<T>:Void(byte_offset:Int, value:T)
			If (data = Null) Then
				Return
			Endif
			
			Local poke_pointer:= Cast<Pointer<T>>(GetBytePointer(byte_offset))
			
			poke_pointer[0] = value
		End
		
		Method Peek<T>:T(byte_offset:Int)
			If (data = Null) Then
				Return Null
			Endif
			
			Local peek_pointer:= Cast<Pointer<T>>(GetBytePointer(byte_offset))
			
			Return peek_pointer[0]
		End
		
		Method CopyTo:Void(dst:MemoryPointer, srcOffset:Int, dstOffset:Int, count:Int)
			DebugAssert((srcOffset >= 0) And ((srcOffset + count) <= length) And (dstOffset >= 0))
			
			libc.memmove(GetBytePointer(dst, dstOffset), GetBytePointer(srcOffset), count)
		End
		
		Method CopyTo:Void(dst:BufferPointer, srcOffset:Int, dstOffset:Int, count:Int)
			DebugAssert((dstOffset + count) <= dst.length)
			
			CopyTo(dst.data, srcOffset, dstOffset, count)
		End
		
		' Destructor(s):
		
		#Rem
			This performs an unsafe memory deallocation.
			
			This operation will fail if this buffer-pointer
			does not own the memory associated.
			
			Manual memory allocation is not recommended,
			but when it can't be avoided, use this.
		#End
		
		Method Discard:Bool()
			If (Not Self.owns_data) Then ' Or Self.data = Null
				Return False
			Endif
			
			libc.free(Self.data)
			
			Self.data = Null
			Self.owns_data = False
			Self.length = 0
			
			Return True
		End
		
		' Properties:
		Property OwnsData:Bool()
			Return Self.owns_data
		End
		
		Property IsNull:Bool()
			Return (Data = Null)
		End
		
		Property Data:MemoryPointer()
			Return Self.data
		End
		
		Property Length:Int() ' UInt
			Return Self.length
		End
	Private
		' Constructor(s):
		Method __Set:Void(data:MemoryPointer, length:Int, owns_data:Bool) Final
			Self.data = data
			Self.length = length
			Self.owns_data = owns_data
		End
	Protected
		' Fields:
		Field data:MemoryPointer
		Field length:Int ' UInt
		
		Field owns_data:Bool
End