Namespace regal.util.ioutil

Using std.stream

' Classes:
Class StreamError Extends Throwable
	Method New(S:Stream)
		Self.Stream = S
	End
	
	' Operator(s):
	Operator To:String() Virtual
		Return "Unknown stream error."
	End
	
	' Fields:
	Field Stream:Stream
End

Class InvalidOpenOperation Extends StreamError
	' Constructor(s):
	Method New(S:Stream)
		Super.New(S)
	End
	
	' Operator(s):
	Operator To:String() Override
		Return "Unable to open stream."
	End
End

Class UnsupportedStreamOperation Extends StreamError
	' Constructor(s):
	Method New(S:Stream)
		Super.New(S)
	End
	
	' Operator(s):
	Operator To:String() Override
		Return "Stream operation unsupported."
	End
End