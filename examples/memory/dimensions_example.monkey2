#Import "../regal"

Using regal.memory.dimensions

Using std.geom..

Function Main:Void()
	Local data_size:= New Vec2i(2, 2)
	
	Print("Allocating a 2D array with the size: (" + data_size.x + ", " + data_size.y + ")")
	
	Local data:= New Int[data_size.x, data_size.y]
	
	Print("Creating a 1D map of our array...")
	
	Local data1D:= OneDimensional(data)
	
	Print("The length of our 1D array-map is: " + data1D.Length)
	
	Print("Writing the following values to our array-map:~n")
	
	For Local i:= 0 Until data1D.Length
		Local value:= (i + i)
		
		data1D[i] = value
		
		Print("[" + i + "]: " + value)
	Next
	
	Print("~Reading back our values using our 2D array:~n")
	
	For Local y:= 0 Until data_size.y
		For Local x:= 0 Until data_size.x
			Print("[" + x + "," + y + "]: " + data[x, y])
		Next
	Next
End