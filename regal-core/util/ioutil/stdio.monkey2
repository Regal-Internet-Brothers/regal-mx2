Namespace regal.util.ioutil

' Imports:

' Native:
#Import "native/standardio.h"


Using std.stream
'Using libc..


' External bindings:
Extern

' Constant variable(s):
Const _O_BINARY:Int

' Functions:
Function freopen:SystemFile(filename:CString, mode:CString, stream:SystemFile)

Function _fileno:Int(stream:SystemFile)
Function _setmode:Int(fd:Int, mode:Int) ' fd:SystemFile

Public

' Aliases:
Alias SystemFile:libc.FILE Ptr

' Classes:
Class StandardIOStream Extends Stream
	Public
		' Class configuration:
		Struct CONFIG
			Const CLEAR_IMPLEMENTED:= True ' False
			
			Const BINARY_HACK:= False
			Const WINNT_STD_REOPENHACK:= False
			
			'Const BINARY_HACK:= True
			
			'#If __TARGET__ = "windows"
			'Const WINNT_STD_REOPENHACK:= True
			'#End
		End
		
		' Functions:
		Function OpenFile:SystemFile(path:String, fmode:String)
			Return libc.fopen(path, fmode)
		End
		
		Function CloseFile:Bool(file:SystemFile)
			If (file = Null) Then
				Return False
			Endif
			
			libc.fclose(file)
			
			Return True
		End
		
		Function FilePosition:Int(file:SystemFile)
			Return libc.ftell(file)
		End
		
		Function SeekFile:Int(file:SystemFile, position:Int)
			Return libc.fseek(file, position, libc.SEEK_SET)
		End
		
		Function SeekFileEnd:Int(file:SystemFile)
			Return libc.fseek(file, 0, libc.SEEK_END)
		End
		
		Function ReadFile:Int(file:SystemFile, buffer:Void Ptr, count:Int)
			Return libc.fread(buffer, 1, count, file)
		End
		
		Function WriteFile:Int(file:SystemFile, buffer:Void Ptr, count:Int)
			Return libc.fwrite(buffer, 1, count, file)
		End
		
		Function FlushFile:Bool(file:SystemFile)
			If (file = Null) Then
				Return False
			Endif
			
			libc.fflush(file)
			
			Return True
		End
		
		' Constructor(s):
		Method New(errorInfo:Bool= False)
			If (Not errorInfo) Then
				If (Not _Open()) Then
					Throw New InvalidOpenOperation(Self)
				Endif
			Else
				If (Not _ErrOpen()) Then
					Throw New InvalidOpenOperation(Self)
				Endif
				
				'Throw New UnsupportedStreamOperation(Self)
			Endif
		End
		
		Method New(path:String, mode:String, fallback:Bool=False)
			Local realMode:= mode
			
			If (realMode = "a") Then
				realMode = "u"
			Endif
			
			If (Not _Open(path, realMode, fallback)) Then
				Throw New InvalidOpenOperation(Self)
			Endif
			
			If (mode = "a") Then
				Seek(Length)
			Endif
		End
		
		Method New(input:SystemFile, output:SystemFile, owns_input:Bool, owns_output:Bool)
			Self.input = input
			Self.output = output
			
			Self.owns_input = owns_input
			Self.owns_output = owns_output
			
			If (Not HasFileOpen) Then
				Throw New InvalidOpenOperation(Self)
			Endif
		End
		
		Method _Open:Bool(rawOpen:Bool=False)
			If (Not rawOpen And HasFileOpen) Then
				Return False
			Endif
			
			If (input = Null) Then
				If (Not CONFIG.BINARY_HACK) Then
					If (Not CONFIG.WINNT_STD_REOPENHACK) Then
						freopen(0, "rb", libc.stdin)
					Else
						freopen("CONIN$", "rb", libc.stdin)
					Endif
				Else
					_setmode(_fileno(libc.stdin), _O_BINARY)
				Endif
				
				Self.input = libc.stdin
			Endif
			
			If (output = Null) Then
				If (Not CONFIG.BINARY_HACK) Then
					If (Not CONFIG.WINNT_STD_REOPENHACK) Then
						freopen(0, "wb", libc.stdout)
					Else
						freopen("CONOUT$", "wb", libc.stdout)
					Endif
				Else
					_setmode(_fileno(libc.stdout), _O_BINARY)
				Endif
				
				Self.output = libc.stdout
			Endif
			
			Self.owns_input = True
			Self.owns_output = True
			
			Return True
		End
		
		' If 'fallback' is enabled, the other overload of 'Open' will be called; default standard I/O streams.
		Method _Open:Bool(path:String, mode:String, fallback:Bool=False)
			If (HasFileOpen) Then
				Return False
			Endif
			
			Local isInput:Bool = False
			Local isOutput:Bool = False
			Local moveToEnd:Bool = False
			
			Local fmode:String
			
			Select (mode)
				Case "r"
					fmode = "rb"
					
					isInput = True
				Case "w"
					fmode = "wb"
					
					isOutput = True
				Case "u"
					fmode = "rb+"
					
					isInput = True
					isOutput = True
				Default
					Return False
			End Select
			
			Local file:= OpenFile(path, fmode)
			
			If (file = Null And mode = "u") Then
				file = OpenFile(path, "wb+")
				
				If (file = Null) Then
					Return False
				Endif
				
				isOutput = True
				isInput = False
			Endif
			
			' Seek to the end in order to tell the length:
			SeekFileEnd(file)
			
			Self._length = FilePosition(file)
			
			' Seek back to the beginning.
			SeekFile(file, 0)
			
			' Set the initial position to zero.
			Self._position = 0
			
			If (isInput) Then
				Self.input = file
			Endif
			
			If (isOutput) Then
				Self.output = file
			Endif
			
			If (Not fallback Or Not _Open(True)) Then
				If (Self.input = Null And Self.output = Null) Then
					CloseFile(file)
					
					Return False
				Endif
			Endif
			
			Self.owns_input = True
			Self.owns_output = True
			
			Return True
		End
		
		Method _ErrOpen:Bool()
			If (HasFileOpen) Then
				Return False
			Endif
		
			Self.input = libc.stderr
			Self.output = input
			
			Return True
		End
		
		' Destructor(s):
		Method OnClose:Void() Override
			If (Not HasFileOpen) Then
				Return
			Endif
			
			If (Self.owns_input) Then
				If (Self.input <> libc.stdin) Then
					CloseFile(Self.input)
				Endif
			Endif
			
			If (Self.owns_output) Then
				If ((Self.output <> Self.input) And (Self.output <> libc.stdout And Self.output <> libc.stderr)) Then
					CloseFile(output)
				Endif
			Endif
			
			Self.input = Null
			Self.output = Null
			
			Self._position = 0
			Self._length = 0
			
			Self.owns_input = False
			Self.owns_output = False
		End
		
		' Methods:
		Method Flush:Void()
			FlushFile(Self.input)
			FlushFile(Self.output)
		End
		
		Method Clear:Void()
			If (CONFIG.CLEAR_IMPLEMENTED) Then
				If (Self.output = libc.stdout) Then
					libc.system("cls")
				Endif
			Endif
		End
		
		Method Seek:Void(position:Int) Override ' Int
			If (InputError) Then
				Return ' 0
			Endif
			
			SeekFile(Self.input, position)
			
			Self._position = FilePosition(Self.input)
			
			'Return Self._position
		End
		
		Method Read:Int(buffer:Void Ptr, count:Int) Override
			If (InputError) Then
				Return 0
			Endif
			
			Local bytesRead:= ReadFile(Self.input, buffer, count)
			
			Self._position += bytesRead
			
			Return bytesRead
		End
		
		Method Write:Int(buffer:Void Ptr, count:Int) Override
			If (OutputError) Then
				Return 0
			Endif
			
			Local bytesWritten:= WriteFile(Self.output, buffer, count)
			
			Self._position += bytesWritten
			
			If (Self._position > Self._length) Then
				Self._length = Self._position
			Endif
			
			Return bytesWritten
		End
		
		' Properties:
		Property Eof:Bool() Override
			If (InputError) Then
				Return True ' -1
			Endif
			
			Return (Position = Length)
		End
		
		Property Length:Int() Override
			Return Self._length
		End
		
		Property Position:Int() Override
			Return Self._position
		End
		
		Property HasFileOpen:Bool()
			Return (Not InputError Or Not OutputError)
		End
		
		Property InputError:Bool()
			Return (Self.input = Null)
		End
		
		Property OutputError:Bool()
			Return (Self.output = Null)
		End
		
		Property IsDuplex:Bool()
			Return Not (InputError Or OutputError)
		End
		
		Property OwnsInput:Bool()
			Return Self.owns_input
		End
		
		Property OwnsOutput:Bool()
			Return Self.owns_output
		End
	Protected
		' Fields:
		Field input:SystemFile
		Field output:SystemFile
		
		Field _position:Int
		Field _length:Int
		
		' Flags:
		Field owns_input:Bool
		Field owns_output:Bool
End