Namespace regal.math.trig

Function RadiansToDegrees:Double(x:Double)
	Const RADIAN_SCALAR:= (monkey.math.Pi / 180.0) ' 57.29577951308232
	
	Return (x * RADIAN_SCALAR)
End
 
Function DegreesToRadians:Double(x:Double)
	Const DEGREE_SCALAR:= (180.0 / Pi) ' 0.017453292519943295
	
	Return (x * DEGREE_SCALAR)
End
 
Function CosD:Double(x:Double)
	Return Cos(RadiansToDegrees(x))
End
 
Function SinD:Double(x:Double)
	Return Sin(RadiansToDegrees(x))
End