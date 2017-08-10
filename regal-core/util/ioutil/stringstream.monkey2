Namespace regal.util.ioutil

Using std.stream
Using std.memory

' Classes:
Class StringStream Extends PublicDataStream
	' Constant variable(s):
	Const SizeOf_Char:= 1 ' 2
	
	' ASCII:
	Const ASCII_CARRIAGE_RETURN:= 13
	Const ASCII_LINE_FEED:= 10
	
	Const ASCII_QUOTE:= 34
	
	' Defaults:
	Const Default_Size:= 1024 ' 4096 ' 1KB ' 4KB ' Global
	
	' Constructor(s):
	Method New(Message:String, FixByteOrder:Bool=False, InitSize:Int=Default_Size, SizeLimit:Int=NOLIMIT, SeekBack:Bool=False)
		Super.New(Max(InitSize, Message.Length*SizeOf_Char), FixByteOrder, True, SizeLimit)
		
		WriteString(Message)
		
		If (SeekBack) Then
			Seek(0)
		Endif
	End
	
	Method New(Size:Int=Default_Size, FixByteOrder:Bool=False, SizeLimit:Int=NOLIMIT)
		Super.New(Size, FixByteOrder, True, SizeLimit)
	End
	
	' Operator(s):
	Operator To:String()
		Return Echo()
	End
	
	' Methods:
	
	' This echoes the raw content of this stream.
	' To echo up to the current position, use 'EchoHere'.
	Method Echo:String()
		Local P:= Position
		
		Seek(0)
		
		Local Output:= ReadString()
		
		Seek(P)
		
		Return Output
	End
	
	' This echoes using the position specified.
	Method Echo:String(Position:Int)
		Local P:= Self.Position
		
		Seek(0)
		
		Local Output:= ReadString()
		
		Seek(P)
		
		Return Output
	End
	
	' This echoes using the current position.
	Method EchoHere:String()
		Return Echo(Self.Position)
	End
	
	Method WriteChar:Void(Value:Int)
		WriteByte(Value)
		'WriteShort(Value)
		
		Return
	End
	
	Method WriteChars:Void(Chars:Int[], Offset:Int, Length:Int)
		' Not the most optimal, but it works:
		For Local I:= Offset Until Length
			WriteChar(Chars[I])
		Next
		
		Return
	End
	
	Method WriteChars:Void(Chars:Int[], Offset:Int=0)
		WriteChars(Chars, Offset, Chars.Length)
		
		Return
	End
	
	Method EndLine:Void()
		WriteChar(ASCII_CARRIAGE_RETURN)
		WriteChar(ASCII_LINE_FEED)
		
		Return
	End
	
	Method WriteQuote:Void()
		WriteChar(ASCII_QUOTE)
		
		Return
	End
End