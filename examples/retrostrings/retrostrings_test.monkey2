#Import "../regal"

Using regal.retrostrings

' Functions:
Function Main:Void()
	Local str:= "This is a test."
	Local str_first_word:= Left(str, (Instr(str, " ") - 1))
	
	Print(str_first_word + " -> " + str)
End