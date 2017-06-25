#Import "../regal"

Using regal.memory.dimensions

Using std.geom..

Function Main:Void()
	Print("1D example:~n~n")
	
	Example_1D()
	
	Print("~n~n2D example:~n~n")
	
	Example_2D()
End

Function Example_1D:Void()
	Local data_size:= New Vec2i(2, 2)
	
	Print("Allocating a 2D array with the size: (" + data_size.x + ", " + data_size.y + ")")
	
	Local data:= New Int[data_size.x, data_size.y]
	
	Print("Creating a 1D view of our array...")
	
	Local data1D:= OneDimensional(data)
	
	Print("The length of our 1D array-view is: " + data1D.Length)
	
	Print("Writing the following values to our array-view:~n")
	
	For Local i:= 0 Until data1D.Length
		Local value:= (i + i)
	
		data1D[i] = value
	
		Print("[" + i + "]: " + value)
	Next
	
	Print("~nReading back our values using our original 2D array:~n")
	
	For Local y:= 0 Until data_size.y
		For Local x:= 0 Until data_size.x
			Print("[" + x + "," + y + "]: " + data[x, y])
		Next
	Next
End

Function Example_2D:Void()
	Local data_length:= 4
	
	Local data2d_size:= New Vec2i(2, 2) ' Sqrt(data_length)
	
	Print("Allocating a 1D array with the length: " + data_length)
	
	Local data:= New Int[data_length]
	
	Print("Creating a 2D view of our array...")
	
	Local data2D:= New TwoDim<Int[], Int>(data, data2d_size)
	
	Print("The size of our 2D array-view is: (" + data2D.Size.x + ", " + data2D.Size.y + ") {" + data2D.Length + "}")
	
	Print("Writing the following values to our original array:~n")
	
	For Local i:= 0 Until data_length
		Local value:= (i + 1)
		
		data[i] = value
		
		Print("[" + i + "]: " + value)
	Next
	
	Print("~nReading back our values using our 2D array-view:~n")
	
	For Local y:= 0 Until data2D.Height
		For Local x:= 0 Until data2D.Width
			Print2D(data2D, x, y)
		Next
	Next
End

Function Print2D<T>:Void(data:T, x:Int, y:Int)
	Print("[" + x + "," + y + "]: " + data[x, y])
End