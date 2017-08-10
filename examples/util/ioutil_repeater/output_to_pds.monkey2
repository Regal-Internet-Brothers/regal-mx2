#Import "../../regal"

Using regal.util.ioutil..
Using std..

' Functions:
Function Main:Void()
	Local Integers:= 10
	Local BSize:= Integers*SizeOf_Integer
	
	Local ABuffer:= New DataBuffer(BSize)
	Local BBuffer:= New DataBuffer(BSize)
	
	Local A:= New PublicDataStream(ABuffer, BSize)
	Local B:= New PublicDataStream(BBuffer, BSize)
	
	Local Out:= New Repeater(False, False)
	
	Out.Add(A)
	Out.Add(B)
	
	For Local I:= 1 To Integers
		Out.WriteInt(I)
	Next
	
	Out.Close()
	
	A.Seek(0)
	B.Seek(0)
	
	For Local I:= 1 To Integers
		Print(A.ReadInt() + " | " + B.ReadInt())
	Next
End