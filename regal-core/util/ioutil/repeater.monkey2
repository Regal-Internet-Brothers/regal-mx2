Namespace regal.util.ioutil

' Imports (Public):
Using std.stream
Using std.memory

'Using regal.memory..

' Aliases:
Alias Repeater:SpecializedRepeater<Stream, Stream>

' Classes:
Class SpecializedRepeater<InputStreamType, OutputStreamType> Extends WrapperStream<InputStreamType>
	' Constructor(s) (Public):
	Method New(SynchronizedFinish:Bool=True, CanCloseOutputStreams:Bool=False)
		Self._SynchronizedFinish = SynchronizedFinish
		Self.CloseOutputStreams = CanCloseOutputStreams
		
		MakeStreamContainer()
	End
	
	Method New(Streams:Stack<OutputStreamType>, SynchronizedFinish:Bool=True, CanCloseOutputStreams:Bool=False)
		Self._SynchronizedFinish = SynchronizedFinish
		Self.CloseOutputStreams = CanCloseOutputStreams
		
		Self.Streams = Streams
	End
	
	Method New(InputStream:InputStreamType, SynchronizedFinish:Bool=True, CanCloseInputStream:Bool=False, CanCloseOutputStreams:Bool=False)
		Self.InputStream = InputStream
		
		Self._SynchronizedFinish = SynchronizedFinish
		Self.CloseInputStream = CanCloseInputStream
		Self.CloseOutputStreams = CanCloseOutputStreams
		
		MakeStreamContainer()
	End
	
	Method New(InputStream:InputStreamType, Streams:Stack<OutputStreamType>, SynchronizedFinish:Bool=True, CanCloseInputStream:Bool=False, CanCloseOutputStreams:Bool=False)
		Self.InputStream = InputStream
		Self.Streams = Streams
		
		Self._SynchronizedFinish = SynchronizedFinish
		Self.CloseInputStream = CanCloseInputStream
		Self.CloseOutputStreams = CanCloseOutputStreams
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method MakeStreamContainer:Void()
		Self.Streams = New Stack<OutputStreamType>()
		
		Return
	End
	
	Public
	
	' Destructor(s):
	
	' This will automatically close the appropriate streams as directed.
	' Closing with this command is considered "unprotected", but should
	' be done when finished with this stream repeater.
	Method OnClose:Void() Override
		If (HasInputStream And CloseInputStream) Then
			Super.OnClose()
		Endif
		
		If (CloseOutputStreams) Then
			For Local S:= Eachin Streams
				S.Close()
			Next
		Endif
		
		Streams.Clear()
		
		Return
	End
	
	' Methods:
	
	' This may be used to add an output stream to this repeater.
	Method Add:Void(S:OutputStreamType)
		Streams.Push(S)
		
		Return
	End
	
	' This may be used to remove an output stream from this repeater.
	Method Remove:Void(S:OutputStreamType)
		Streams.RemoveEach(S)
		
		Return
	End
	
	' Without an 'InputStream', this will seek using the internal "virtual output position".
	' If 'InputStream' is available, seeking will be performed on that instead.
	Method Seek:Void(Position:Int) Override ' Int
		If (Not HasInputStream) Then
			OutputSeek(Position)
		Else
			Super.Seek(Position) ' InputStream.Seek(Position) ' Return
		Endif
		
		Return ' Position
	End
	
	Method OutputSeek:Int(Position:Int)
		Local Diff:Int = (Position-OutputPosition)
			
		If (Diff = 0) Then
			Return OutputPosition
		Endif
		
		For Local S:= Eachin Streams
			S.Seek(S.Position+Diff) ' S.Skip
		Next
		
		OutputPosition = Max(OutputPosition + Diff, 0)
		
		Return OutputPosition
	End
	
	' If an 'InputStream' is available, this may be used to transfer
	' 'Count' bytes from that stream to all of the output streams.
	Method TransferFromInput:Int(Count:Int)
		Local TempBuffer:= New DataBuffer(Count)
		
		ReadAll(TempBuffer, 0, Count)
		
		' TODO: Remove this cast; workaround for a compiler bug.
		Local BytesTransferred:= Cast<Stream>(Self).Write(TempBuffer, 0, Count) ' WriteAll
		
		TempBuffer.Discard()
		
		Return BytesTransferred
	End
	
	' This will transfer all data available from 'InputStream'; use with caution.
	Method TransferInput:Int()
		Local InputData:= ReadAll()
		
		' TODO: Remove this cast; workaround for a compiler bug.
		Cast<Stream>(Self).Write(InputData, 0, InputData.Length) ' WriteAll
		
		Local BytesTransferred:= InputData.Length
		
		InputData.Discard()
		
		Return BytesTransferred
	End
	
	Method Write:Int(Buffer:Void Ptr, Count:Int) Override
		Local MaxBytesTransferred:= 0
		
		For Local S:= Eachin Streams
			Local Transferred:Int = 0
			Local ShouldClose:Bool = False ' S.Eof
			
			' TODO: Remove this cast; workaround for a compiler bug.
			Transferred = Cast<Stream>(S).Write(Buffer, Count)
			
			If (Transferred <> Count) Then ' Transferred < Count
				ShouldClose = True
			Endif
			
			If (ShouldClose) Then ' Or (S.Length-S.Position) <= 0
				Remove(S)
				
				If (CloseOutputStreams) Then
					Try
						S.Close()
					Catch E:StreamError
						' Nothing so far.
					End
				Endif
			Endif
			
			MaxBytesTransferred = Max(MaxBytesTransferred, Transferred)
		Next
		
		OutputPosition += MaxBytesTransferred
		
		Return MaxBytesTransferred
	End
	
	' Properties (Public):
	
	' This provides direct access to the 'InternalStream' property;
	' basically, this is what we use for input operations.
	' If a different stream is specified, and we have the right
	' to close the current stream, it will be closed.
	Property InputStream:InputStreamType()
		Return InternalStream
	Setter(Input:InputStreamType)
		If (Input <> InternalStream) Then
			If (CloseInputStream) Then
				InternalStream.Close()
			Endif
		
			InternalStream = Input
		Endif
		
		Return
	End
	
	' This specifies if the minimum or maximum end-points of the output-streams should be used.
	Property SynchronizedFinish:Bool()
		Return Self._SynchronizedFinish
	End
	
	' This specifies if we have an 'InputStream'.
	Property HasInputStream:Bool()
		Return (InputStream <> Null)
	End
	
	' This property states if ANY stream has reached its end.
	' The only exception to this rule is output-streams,
	' where the 'SynchronizedFinish' flag dictates behavior.
	Property Eof:Bool() Override ' Int
		If (HasInputStream) Then
			If (Super.Eof) Then
				Return True
			Endif
		Endif
		
		Local Result:Bool = False
		
		For Local S:= Eachin Streams
			Local Response:= S.Eof
			
			If (SynchronizedFinish) Then
				If (Response) Then
					Return True ' Response
				Endif
			Else
				' TODO: Test this behavior.
				If (Response) Then
					Result = (Result And Response) ' Or
				Endif
			Endif
		Next
		
		Return Result
	End
	
	' This will return the length of 'InputStream' if available.
	' If not, the 'OutputLength' property will be used.
	Property Length:Int() Override
		If (Not HasInputStream) Then
			Return OutputLength
		Endif
		
		Return Super.Length ' InputStream.Length
	End
	
	' If 'InputStream' is available, it will be returned.
	' If not, 'OutputPosition' will be returned instead.
	Property Position:Int() Override
		If (Not HasInputStream) Then
			Return OutputPosition
		Endif
		
		Return Super.Position ' InputStream.Position
	End
	
	' This retrieves the largest length of the output-streams.
	Property MaximumLength:Int()
		Local L:= 0
		
		For Local S:= Eachin Streams
			L = Max(L, S.Length)
		Next
		
		Return L
	End
	
	' This retrieves the smallest length of the output-streams.
	Property MinimumLength:Int()
		Local L:= Streams.Top.Length
		
		For Local S:= Eachin Streams
			L = Min(L, S.Length)
		Next
		
		Return L
	End
	
	' This provides the "virtual output position".
	Property OutputPosition:Int()
		Return Self._Position
	' PROTECTED:
	Setter(Input:Int)
		Self._Position = Input
	End
	
	' This provides the desired length of the output-streams. (Based on 'SynchronizedFinish')
	Property OutputLength:Int()
		If (SynchronizedFinish) Then
			Return MinimumLength
		Endif
		
		Return MaximumLength
	End
	
	' Fields (Public):
	
	' Caution should be taken when modifying these fields:
	Field CloseInputStream:Bool
	Field CloseOutputStreams:Bool
	
	' Fields (Protected):
	Protected
	
	' A container of streams used for output.
	Field Streams:Stack<OutputStreamType>
	
	' The "virtual output position" of this stream.
	Field _Position:Int
	
	' Booleans / Flags:
	
	' See the 'SynchronizedFinish' property for details.
	Field _SynchronizedFinish:Bool
	
	Public
End