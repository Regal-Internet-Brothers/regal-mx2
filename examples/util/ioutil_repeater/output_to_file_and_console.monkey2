#Import "../../regal"

Using regal.util.ioutil..
Using std..

' Functions:
Function Main:Void()
	' Open two streams, one to standard-out, and one to a file on-disk.
	Local Console:= New StandardIOStream()
	Local File:= Stream.Open("output.txt", "w")
	
	' Give this repeater close-rights.
	Local Output:= New Repeater(False, True)
	
	' Add our output-streams to the repeater.
	Output.Add(Console)
	Output.Add(File)
	
	' Output to the repeater:
	Output.WriteLine("The following is output from a repeater:")
	Output.WriteLine("Hello, World.")
	Output.WriteLine("This is a test.")
	Output.WriteLine("Testing complete.")
	
	' Close all streams; 'Console', 'File', and 'Output'.
	Output.Close()
End