#Import "../../util/util"
#Import "../../memory/memory"

' Imports:
Using regal.util.stringutil
Using regal.util.ioutil

Using regal.memory.sizeof
Using regal.memory.byteorder

Using std.memory

' Functions:
Function Main:Void()
	EndianTests()
	ByteOrderTests(32)
	SizeOfTests()
	StringUtilTests()
	StreamUtilTests()
	
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
	
	Print("Type sizes:")
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
	
	Local bitfield:= 1023
	
	Print("Converting bitfield to string: " + BitFieldAsString<Short>(bitfield))
	
	Local short_float:= 10.456
	
	Print("Shortening " + InSingleQuotes(short_float) + " as " + ShortenedFloat(short_float, 2))
End

' Stream utilities:
Function StreamUtilTests:Void()
	TestAnnounce("I/O-UTIL TEST")
	
	Local a:= New DataBuffer(SizeOf_Int)
	Local b:= New DataBuffer(SizeOf_Int)
	
	Local aStream:= New DataStream(a)
	Local bStream:= New DataStream(b)
	
	Local chain:= New ChainStream(New Stream[](aStream, bStream), False, True)
	
	Local a_value:= 123
	Local b_value:= 456
	
	chain.WriteInt(a_value)
	chain.WriteInt(b_value)
	
	Print("A: " + a.PeekInt(0) + " | " + a_value + " | End-Of-Stream: " + BoolToString(aStream.Eof))
	Print("B: " + b.PeekInt(0) + " | " + b_value + " | End-Of-Stream: " + BoolToString(bStream.Eof))
	
	chain.Close()
	
	a.Discard()
	b.Discard()
End