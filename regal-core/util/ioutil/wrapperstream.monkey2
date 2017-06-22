Namespace regal.util.ioutil

' Imports:
Using std.stream

' Classes:
Class WrapperStream<StreamType> Extends Stream
	' Constructor(s):
	Method New(S:StreamType, ThrowOnInvalid:Bool=True)
		If (ThrowOnInvalid) Then
			If (S = Null) Then
				Throw New InvalidWrapperStream(Self, S)
			Endif
		Endif
		
		Self.InternalStream = S
	End
	
	' Destructor(s):
	Method OnClose:Void() Override
		InternalStream.Close()
		
		Return
	End

	' Methods (Public):
	Method Read:Int(Buffer:DataBuffer, Offset:Int, Count:Int) Override
		Return InternalStream.Read(Buffer, Offset, Count)
	End
	
	Method Write:Int(Buffer:DataBuffer, Offset:Int, Count:Int) Override
		Return InternalStream.Write(Buffer, Offset, Count)
	End
	
	' Properties:
	Property Eof:Int() Override
		Return InternalStream.Eof
	End
	
	Property Length:Int() Override
		Return InternalStream.Length
	End
	
	Property Position:Int() Override
		Return InternalStream.Position() ' Position
	End
	
	Property Stream:StreamType()
		Return Self.InternalStream
	End
	
	Property ByteOrder:ByteOrder()
		Return InternalStream.ByteOrder
	Setter(Order:ByteOrder)
		InternalStream.ByteOrder = Order
	End
	
	' Fields (Protected):
	Protected
	
	Field InternalStream:StreamType
	
	Public
End

' Exceptions:
Class InvalidWrapperStream Extends StreamError
	' Constructor(s):
	Method New(Instance:Stream, WrappedStream:Stream=Null)
		Super.New(Instance)
		
		Self.WrappedStream = WrappedStream
	End
	
	' Operators:
	Operator To:String()
		Return "An invalid stream was given to a 'WrapperStream' object."
	End
	
	' Fields (Protected):
	Protected
	
	Field WrappedStream:Stream
	
	Public
End