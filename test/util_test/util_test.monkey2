#Import "../../util/util"

Using regal.util.stringutil
Using regal.util.byteorder
Using regal.util.sizeof

' Functions:
Function Main:Void()
	EndianTests()
	ByteOrderTests(32)
	SizeOfTests()
	StringUtilTests()
	
	FinishTesting()
End

' Constant variable(s):
Const FINAL_TEST_HEADER:= "TESTING PROCESS FINISHED"

' General:
Function TestAnnounce:Void(name:String)
	Global LAST_TEST:String
	
	If (LAST_TEST.Length > 0 And LAST_TEST <> name And name <> FINAL_TEST_HEADER) Then
		Print("~n| ( TEST COMPLETED ) |~n")
	Endif
	
	Print("~n| {" + name + "} |~n")
	
	LAST_TEST = name
End

Function FinishTesting:Void()
	TestAnnounce(FINAL_TEST_HEADER)
End

' Endian functions:
Function EndianTests:Void()
	TestAnnounce("ENDIAN TEST")
	
	Print("Is this system little-endian? " + YesNo(LittleEndian()))
End

' Byte-order functions:
Function ByteOrderTests:Void(value:UInt)
	TestAnnounce("BYTE-ORDER TEST")
	
	Print("Original value: " + value + " { " + HexBE(value) + " | " + HexLE(value) + " }")
	
	TestByteOrderFunctions(value, HToNI, NToHI)
	TestByteOrderFunctions(ULong(value * 8), HToNL, NToHL)
	TestByteOrderFunctions(UShort(value / 4), HToNS, NToHS)
	TestByteOrderFunctions(Float(value) + 0.5, HToNF, NToHF)
	TestByteOrderFunctions(Double(value) + 0.5, HToND, NToHD)
End

Function TestByteOrderFunctions<T, BE, LE>:Void(value:T, toBE:BE, toLE:LE) ' T(T)
	Local value_be:= toBE(value)
	Local value_le:= toLE(value_be)
	
	Print(value + " | " + value_be + " (" + value_le + ")")
End

' Size-of functions:
Function SizeOfTests:Void()
	TestAnnounce("SIZE-OF TEST")
	
	Print(SizeOf<Long>())
	Print(SizeOf<Int>())
	Print(SizeOf<Short>())
	Print(SizeOf<Byte>())
	Print(SizeOf<Float>())
	Print(SizeOf<Double>())
End

' String utility functions:
Function StringUtilTests:Void()
	TestAnnounce("STRING-UTIL TEST")
	
	Print(InQuotes("In quotes."))
	
	Local bool_out:= False
	
	Print("'bool_out' is '" + BoolToString(True) + "' in string-format.")
	
	Local bool_string:String = "Yes"
	
	Print("Is " + InQuotes(bool_string) + " a confirmation value? " + YesNo(StringToBool(bool_string)))
	
	Local a_an_word:= "apple"
	
	Print("Should I use 'a' or 'an' when describing " + InQuotes(a_an_word) + "? Survey says: " + InSingleQuotes(AOrAn(a_an_word)))
End