Namespace regal.util.ioutil

' Imports:
Using std.stream

' Classes:
Class WrapperStream<StreamType> Extends Stream
	' Constructor(s) (Protected):
	Protected
	
	Method New()
		' Nothing so far.
	End
	
	Public
	
	' Constructor(s) (Public):
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
		
		Super.OnClose()
		
		Return
	End

	' Methods (Public):
	Method Read:Int(Buffer:Void Ptr, Count:Int) Override
		Return InternalStream.Read(Buffer, Count)
	End
	
	Method Write:Int(Buffer:Void Ptr, Count:Int) Override
		Return InternalStream.Write(Buffer, Count)
	End
	
	Method Seek:Void(Input:Int) Override
		InternalStream.Seek(Input)
	End
	
	' Properties:
	Property Eof:Bool() Override ' Int
		Return InternalStream.Eof
	End
	
	Property Length:Int() Override
		Return InternalStream.Length
	End
	
	Property Position:Int() Override
		Return InternalStream.Position
	End
	
	Property Stream:StreamType()
		Return Self.InternalStream
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
	Operator To:String() Override
		Return "An invalid stream was given to a 'WrapperStream' object."
	End
	
	' Fields (Protected):
	Protected
	
	Field WrappedStream:Stream
	
	Public
End