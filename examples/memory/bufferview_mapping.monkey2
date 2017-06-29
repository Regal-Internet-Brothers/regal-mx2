#Import "<std>"
#Import "../regal"

Using std.memory..

Using regal.memory.sizeof
Using regal.memory.bufferview

' Functions:
Function Main:Void()
	' This specifies then number of elements we'll be allocating.
	Local count:= 4
	
	' Allocate 'Count' 16-bit integers.
	Local rawBuffer:= New DataBuffer(count * SizeOf_Short)
	
	' Allocate a view of 16-bit integers starting at the beginning of 'RawBuffer'.
	Local baseView:= New ShortArrayView(rawBuffer)
	
	' Calculate an index to begin our 'OffsetView' object on.
	Local offsetIndex:= (count / 4) ' Max(1, ...)
	
	' Get the index before 'OffsetIndex' for the sake of demonstration.
	Local demoIndex:= (offsetIndex - 1)
	
	' Create a view of 16-bit integers starting 'OffsetIndex' 16-bit integers from the beginning of 'RawBuffer'. (Converted to bytes from indices)
	Local offsetView:= New ShortArrayView(rawBuffer, (count / 2), baseView.IndexToAddress(offsetIndex)) ' (OffsetIndex * 2)
	
	For Local i:= 0 Until count
		baseView.Set(i, (i + 1)) ' 1, 2, 3, ...
	Next
	
	Print("The length of 'BaseView' is: (" + baseView.Length + ") {Size: " + baseView.Size + "}")
	Print("The length of 'OffsetView' is: (" + offsetView.Length + ") {Size: " + offsetView.Size + "}")
	Print("")
	
	Print("Printing the contents of 'BaseView':")
	
	ReportView(baseView)
	
	Print("")
	
	Print("Printing the contents of 'OffsetView':")
	
	ReportView(offsetView)
	
	Print("")
	Print("//// CONTENTS \\\\")
	
	Print("BaseView[" + demoIndex + "]: " + baseView.Get(demoIndex))
	Print("OffsetView[0]: " + offsetView.Get(0))
	
	demoIndex += 1 ' <-- 'offsetIndex'
	
	Print("BaseView[" + demoIndex + "]: " + baseView.Get(demoIndex))
	
	Print("~nClearing 'OffsetView'...~n")
	
	offsetView.Clear()
	
	Print("Printing the contents of 'BaseView':")
	
	ReportView(baseView)
End

Function ReportView<ViewType>:Void(view:ViewType) ' IntArrayView
	For Local i:= 0 Until view.Length
		Print("[" + i + "]: " + view.Get(i))
	Next
End