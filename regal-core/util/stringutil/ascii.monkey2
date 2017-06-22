Namespace regal.util.stringutil

' Constant variable(s):

' This represents the number of characters
' representing numbers in the ascii-table.
Const ASCII_NUMBER_COUNT:Int = 10

Const ASCII_LETTER_COUNT:Int = 26

' These are mainly used for internal routines, such as hexadecimal conversion:
Const ASCII_NUMBERS_POSITION:Int = 48

Const ASCII_CHARACTER_0:= ASCII_NUMBERS_POSITION
Const ASCII_CHARACTER_1:= ASCII_CHARACTER_0 + 1
Const ASCII_CHARACTER_2:= ASCII_CHARACTER_1 + 1
Const ASCII_CHARACTER_3:= ASCII_CHARACTER_2 + 1
Const ASCII_CHARACTER_4:= ASCII_CHARACTER_3 + 1
Const ASCII_CHARACTER_5:= ASCII_CHARACTER_4 + 1
Const ASCII_CHARACTER_6:= ASCII_CHARACTER_5 + 1
Const ASCII_CHARACTER_7:= ASCII_CHARACTER_6 + 1
Const ASCII_CHARACTER_8:= ASCII_CHARACTER_7 + 1
Const ASCII_CHARACTER_9:= ASCII_CHARACTER_8 + 1

Const ASCII_CHARACTER_UPPERCASE_POSITION:= 65
Const ASCII_CHARACTER_LOWERCASE_POSITION:= 97

' The distance between upper and lower case characters.
Const ASCII_CASE_DELTA:= (ASCII_CHARACTER_LOWERCASE_POSITION-ASCII_CHARACTER_UPPERCASE_POSITION) ' Abs(...)

' The final characters in the ASCII alphabet.
Const ASCII_CHARACTERS_UPPERCASE_END:= ASCII_CHARACTER_UPPERCASE_POSITION+ASCII_LETTER_COUNT
Const ASCII_CHARACTERS_LOWERCASE_END:= ASCII_CHARACTER_LOWERCASE_POSITION+ASCII_LETTER_COUNT

' Other ASCII characters:
Const ASCII_LINE_FEED:= 10
Const ASCII_CARRIAGE_RETURN:= 13
Const ASCII_CHARACTER_SPACE:= 32