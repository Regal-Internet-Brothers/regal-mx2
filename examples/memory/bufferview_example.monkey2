#Import "../regal"

Using regal.memory.bufferview
Using regal.memory.sizeof

Const INT_SIZE:= SizeOf<Int>()
Const _INT_SIZE:= INT_SIZE

' Functions:
Function Main:Void()
	Print("Allocating Source and Destination buffers...")
	
	Try
		Local i_val:Int
		Local i_size:= libc.sizeof<Int>(i_val)
		
		Print("SizeOf_Integer: " + IntArrayView.Type_Size + ", " + i_size + ", " + SizeOf<Int>() + ", " + INT_SIZE + ", " + _INT_SIZE)
		DebugStop()
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
	Catch E:Throwable
		'Print(E)
		Local ex:= E
		
		DebugStop()
		
		Print("Exception caught.")
	End Try
End

Function ReportView:Void(view:IntArrayView)
	For Local i:= 0 Until view.Length
		Print("[" + i + "]: " + view.Get(i))
	Next
End