#Import "../regal"

Using regal.memory..
Using regal.math..

Function Main:Void()
	Local fib_count:= 16
	
	Local int_view:= New IntArrayView(fib_count)
	Local int_array:= New Int[fib_count]
	
	StoreFib(int_view, fib_count)
	StoreFib(int_array, fib_count)
	
	Print("~nInteger view:~n")
	
	For Local value:= Eachin int_view
		Print(value)
	Next
	
	Print("~nInteger array:~n")
	
	For Local value:= Eachin int_array
		Print(value)
	Next
End

Function StoreFib<T>:Void(container:T, count:Int, container_offset:Int=0, fib_offset:Int=0)
	For Local i:= 0 Until count
		container[container_offset + i] = Fib(fib_offset + i + 1)
	Next
End