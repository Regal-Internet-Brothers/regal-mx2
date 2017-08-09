#Import "../regal"

Using regal.util.ioutil..
Using std..

Function Main:Void()
	Local a:= WriteThenOpen("a.txt", "A")
	Local b:= WriteThenOpen("b.txt", "B")
	Local c:= WriteThenOpen("c.txt", "C")
	
	Local chain:= New ChainStream(New Stream[](a, b, c))
	
	Print("A: " + chain.ReadLine())
	Print("B: " + chain.ReadLine())
	Print("C: " + chain.ReadLine())
	
	chain.Close()
End

Function WriteThenOpen:Stream(path:String, value:String)
	Local file_out:= Stream.Open(path, "w")
	
	file_out.WriteLine(value)
	
	file_out.Close()
	
	Local file_in:= Stream.Open(path, "r")
	
	Return file_in
End