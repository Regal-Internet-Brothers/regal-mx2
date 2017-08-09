Namespace regal.util.ioutil.memory

Using std.memory..

' Constant variable(s):
Private

' This acts as a general "automatic-value".
' This is only provided for legacy compatibility; do not
' use this value in code that was not built around it.
Const UTIL_AUTO:= -1

Public

' This is for situations where the length of something can be optional.
' This currently mirrors 'UTIL_AUTO' and its behavior.
' Please use better overloading practices if possible.
Const AUTOMATIC_LENGTH:= UTIL_AUTO

' Functions:
Function ResizeBuffer:DataBuffer(Buffer:DataBuffer, Size:Int=AUTOMATIC_LENGTH, CopyData:Bool=True, DiscardOldBuffer:Bool=False, OnlyWhenDifferentSizes:Bool=False)
	Local BufferAvailable:Bool = (Buffer <> Null)
	
	If (BufferAvailable And OnlyWhenDifferentSizes) Then
		If (Size <> AUTOMATIC_LENGTH And Buffer.Length = Size) Then
			Return Buffer
		Endif
	Endif
	
	If (Size = AUTOMATIC_LENGTH) Then
		Size = Buffer.Length
	Endif
	
	' Allocate a new data-buffer.
	Local B:= New DataBuffer(Size)
	
	' Copy the buffer's bytes over to 'B'.
	If (BufferAvailable) Then
		If (CopyData) Then
			' Copy the contents of 'Buffer' to the newly generated buffer-object.
			Buffer.CopyTo(B, 0, 0, Buffer.Length)
		Endif
		
		If (DiscardOldBuffer) Then
			' Discard the old buffer.
			Buffer.Discard()
		Endif
	Endif
	
	' Return the newly generated buffer.
	Return B
End