#Import "<std>"

#Import "../../memory/memory"
#Import "../../util/util"

Using regal.memory.bufferview

' Functions:
Function Main:Void()
	Local Source:= New IntArrayView(4)
	Local Destination:= New ByteArrayView(2)
	
	'Source.Clear(127)
	
	For Local I:= 0 Until Source.Length
		Source.Set(I, (I * I))
	Next
	
	Destination.Copy(Source)
	
	Print("Source:")
	ReportView(Source)
	
	Print("Destination:")
	ReportView(Destination)
End

Function ReportView:Void(View:IntArrayView)
	For Local I:= 0 Until View.Length
		Print("[" + I + "]: " + View.Get(I))
	Next
	
	Return
End