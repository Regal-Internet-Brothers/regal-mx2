Namespace regal.memory.dataobject

' Classes:
Class DataObject<T>
	Public
		' Constructor(s):
		Method New(data:T=Null)
			Self.data = data
		End
		
		' Operators:
		Operator To:T()
			Return Self.data
		End
	Protected
		' Fields:
		Field data:T
End

Class ArrayObject<T> Extends DataObject<T[]>
	' Aliases:
	Alias ArrayType:T[]
	
	' Constructor(s):
	Method New(data:ArrayType=Null)
		Super.New(data)
	End
	
	#Rem
	Method New(count:Int)
		Self.New(New T[count])
	End
	#End
	
	' Methods:
	Method Pointer:Pointer<T>()
		Return data.Data
	End
	
	' Operators:
	Operator[]:T(index:Int)
		Return data[index]
	End
	
	Operator[]=(index:Int, value:T)
		data[index] = value
	End
	
	' Properties:
	Property Length:Int()
		Return data.Length
	End
End