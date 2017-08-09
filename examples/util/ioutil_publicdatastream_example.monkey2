#Import "../regal"

Using regal.util.ioutil..
Using std.time..

' Functions:
Function Main:Void()
	' Constant variable(s):
	Const Numbers:= 2048
	
	' Local variable(s):
	Local StartTime:= Millisecs()
	
	For Local Test:= 1 To 10 ' 8192
		' Local variable(s):
		Local S:= New PublicDataStream(Numbers*4) ' SizeOf_Integer
		Local B:= New DataBuffer(S.DataLength)
		Local D:= New DataStream(B)
		
		For Local I:= 1 To Numbers
			S.WriteInt(I)
		Next
		
		S.TransferTo(D)
		D.Seek(0)
		
		S.Close()
		
		Local Number:Int = 1
		
		While (Not D.Eof)
			If (D.ReadInt() <> Number) Then
				Print("Critical failure.")
				
				libc.exit_(-1); Return
			Endif
			
			Number += 1
		Wend
		
		D.Close()
		B.Discard()
	Next
	
	Local TimeTaken:= (Millisecs()-StartTime)
	
	Print("That took " + TimeTaken + "ms.")
End