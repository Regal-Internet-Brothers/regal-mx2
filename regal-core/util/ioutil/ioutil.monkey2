Namespace regal.util.ioutil

#Import "chainstream"

Using std.stream
Using regal.memory.sizeof

' This applies 'Mask' to the contents of 'S' (XOR; useful for networking routines)
Function MaskStream:Void(S:Stream, Mask:UInt, Length:Int)
	Local DataPosition:= S.Position
	Local DataEnd:= (DataPosition + Length) ' S.Length
	
	DebugStop()
	
	While (DataPosition < DataEnd)
		Local DataRemaining:= (DataEnd - DataPosition)
		
		If (DataRemaining >= 4) Then
			Local Data:= S.ReadUInt()
			
			S.Seek(DataPosition)
			
			S.WriteInt(Data ~ Mask)
			
			DataPosition += SizeOf(Data)
		Elseif (DataRemaining >= 2) Then
			Local Data:= S.ReadUShort()
			
			S.Seek(DataPosition)
			
			S.WriteShort(Data ~ UShort(Mask))
			
			DataPosition += SizeOf(Data)
		Elseif (DataRemaining >= 1) Then
			Local Data:= S.ReadUByte()
			
			S.Seek(DataPosition)
			
			S.WriteShort(Data ~ UByte(Mask))
			
			DataPosition += SizeOf(Data)
		Endif
	Wend
	
	S.Seek(DataPosition)
	
	Return
End

Function SeekForward:Int(S:Stream, Bytes:Int)
	Local NewPosition:= (S.Position + Bytes)
	
	S.Seek(NewPosition)
	
	Return NewPosition
End

Function SeekBackward:Int(S:Stream, Bytes:Int)
	Local NewPosition:= (S.Position - Bytes)
	
	S.Seek(NewPosition)
	
	Return NewPosition
End

Function SeekBegin:Int(S:Stream)
	Local Position:= S.Position
	
	S.Seek(0)
	
	Return Position
End