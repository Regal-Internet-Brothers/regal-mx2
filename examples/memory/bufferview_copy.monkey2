#Import "../regal"

Using regal.memory.bufferview

' Functions:
Function Main:Void()
	Print("Allocating Source and Destination buffers...")
	
	Local source:= New IntArrayView(4)
	Local destination:= New ByteArrayView(2)
	
	'Source.Clear(127)
	
	Print("Assigning the contents of Source..")
	
	For Local i:= 0 Until source.Length
		source.Set(i, (i * i))
	Next
	
	Print("Copying from Source to Destination...")
	
	destination.Copy(source)
	
	Print("Operations complete; displaying results:")
	
	Print("Source:")
	ReportView(source)
	
	Print("Destination:")
	ReportView(destination)
End

Function ReportView<ViewType>:Void(view:ViewType)
	For Local i:= 0 Until view.Length
		Print("[" + i + "]: " + view.Get(i))
	Next
End