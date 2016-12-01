Namespace regal.util.ioutil

' Imports:
Using regal.memory

Using std.stream
Using std.memory
Using std.collections

' Classes:
Class ChainStream Extends SpecializedChainStream<Stream> Final
	' Constructor(s):
	Method New(BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Super.New(BigEndian, CloseRights, Link)
	End
	
	Method New(Streams:Stream[], BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Super.New(Streams, BigEndian, CloseRights, Link)
	End
	
	Method New(Streams:Stack<Stream>, BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Super.New(Streams, BigEndian, CloseRights, Link)
	End
End

Class SpecializedChainStream<StreamType> Extends Stream
	' Constant variable(s):
	
	' Defaults:
	
	' Booleans / Flags:
	Const Default_BigEndian:Bool = False
	
	' Functions:
	Function SetByteOrder:ByteOrder(S:Stream, BigEndian:Bool)
		Local Order:= BoolToByteOrder(BigEndian)
		
		S.ByteOrder = Order
		
		Return Order
	End
	
	Function SetByteOrder:ByteOrder(Streams:Stack<Stream>, BigEndian:Bool)
		Local Order:= BoolToByteOrder(BigEndian)
		
		For Local S:= Eachin Streams
			S.ByteOrder = Order
		Next
		
		Return Order
	End
	
	' Constructor(s) (Public):
	Method New(BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Self.New(New Stack<StreamType>(), BigEndian, CloseRights, Link)
	End
	
	' All containers passed to these constructors should be assumed to be under this object's control:
	Method New(Streams:StreamType[], BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Self.New(New Stack<StreamType>(Streams), BigEndian, CloseRights, Link)
	End
	
	Method New(Streams:Stack<StreamType>, BigEndian:Bool=Default_BigEndian, CloseRights:Bool=True, Link:Int=0)
		Self.Chain = Streams
		Self.Link = Link
		
		Self.BigEndian = BigEndian
		Self.CanCloseStreams = CloseRights
		
		If (CloseRights) Then
			SetByteOrder(Streams, BigEndian)
		Endif
	End
	
	' Destructor(s):
	Method OnClose:Void() Override
		If (CanCloseStreams) Then
			For Local Node:= Eachin Chain
				Node.Close()
			Next
		Endif
		
		' Empty the stream-chain.
		Chain.Clear()
		
		Return
	End
	
	' Methods (Public):
	
	' This is pretty bloated, but it works:
	Method Seek:Void(Position:Int) Override
		Local Target:Int = -1
		Local BackwardOffset:Int = 0
		
		For Local I:= FinalChainIndex To 0 Step -1
			Local CL:= ChainLength(I)
			
			If (Position >= CL) Then
				Target = I
				BackwardOffset = CL
			Else
				Chain[I].Seek(0)
			Endif
		Next
		
		If (Target = -1) Then
			Return ' Self.Position
		Endif
		
		Link = Target
		
		CurrentLink.Seek(Position-BackwardOffset)
		
		Return ' Position
	End
	
	Method Read:Int(Buffer:Void Ptr, Count:Int) Override
		Local BytesRead:= CurrentLink.Read(Buffer, Count)
		
		If (Not OnFinalLink And BytesRead < Count) Then
			Link += 1
			
			Return (BytesRead + Read((Buffer+BytesRead), (Count-BytesRead)))
		Endif
		
		Return BytesRead
	End
	
	Method Write:Int(Buffer:Void Ptr, Count:Int) Override
		Local BytesWritten:= CurrentLink.Write(Buffer, Count)
		
		If (Not OnFinalLink And BytesWritten < Count) Then
			Link += 1
			
			Return (BytesWritten + Write((Buffer+BytesWritten), (Count-BytesWritten)))
		Endif
		
		Return BytesWritten
	End
	
	' Methods (Protected):
	Protected
	
	' The length of the chain as-of the link specified.
	Method ChainLength:Int(LinkPosition:Int)
		If (LinkPosition < 0 Or LinkPosition > LinkCount) Then
			Return 0
		Endif
		
		Local P:Int = 0
		
		For Local I:= 0 Until LinkPosition
			' Add the length of the previous link in the chain.
			P += Chain[I].Length
		Next
		
		Return (P + Chain[LinkPosition].Position)
	End
	
	Public
	
	' Properties (Public):
	
	' The active element of 'Chain';
	' the stream currently used for I/O.
	Property Link:Int()
		Return Self._Link
	Setter(Value:Int)
		Self._Link = Value
	End
	
	' This specifies if we are at the end of the stream.
	' This uses the final chain as a reference, as normal operations
	' will automatically move through each link in the chain.
	Property Eof:Bool() Override
		'Return CurrentLink.Eof
		Return FinalLink.Eof
	End
	
	' The overall length of this stream. (Bytes contained)
	Property Length:Int() Override
		Local L:Int = 0
		
		For Local Node:= Eachin Chain
			L += Node.Length
		Next
		
		Return L
	End
	
	' The current "virtual" position in the stream;
	' functions like a normal stream, use as you would normally.
	Property Position:Int() Override
		' Add the previous links' lengths to the current link's position.
		Return (ChainLength(Link))
	End
	
	' A public "accessor" for the internal "chain".
	' Mutation may result in undefined behavior; use at your own risk.
	Property Links:Stack<StreamType>()
		Return Chain
	End
	
	' The number of links in the internal "chain".
	Property LinkCount:Int()
		Return Chain.Length
	End
	
	' This specifies if we are currently
	' using the final link in the chain.
	Property OnFinalLink:Bool()
		Return (Link = FinalChainIndex)
	End
	
	' Properties (Protected):
	Protected
	
	' The final chain-index (Link) in the chain.
	Property FinalChainIndex:Int()
		Return Max(LinkCount-1, 0)
	End
	
	' The current stream-link in the chain. (Use at your own risk)
	Property CurrentLink:StreamType()
		Return Chain[Link]
	End
	
	' The final stream in the "chain". (Use at your own risk)
	Property FinalLink:StreamType()
		Return Chain[FinalChainIndex]
	End
	
	Public
	
	' Fields (Protected):
	Protected
	
	' A "chain" of streams representing
	' the data this stream delegates.
	Field Chain:Stack<StreamType>
	
	' See the 'Link' property for details.
	Field _Link:Int
	
	' Booleans / Flags:
	
	' This specifies if big-endian storage should be used/expected.
	Field BigEndian:Bool
	
	' This specifies if this object has the right to
	' close the elements of the internal "chain".
	Field CanCloseStreams:Bool = True
	
	Public
End