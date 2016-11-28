Namespace regal.memory

' This is used to catch (And throw) an unspecific allocation exception.
Class AllocationException Extends Throwable
	' Constructor(s):
	Method New(RequestedSize:UInt)
		Self.RequestedSize = RequestedSize
	End
	
	' Methods:
	Method To:String() Virtual
		Return "An error occurred while allocating a dynamic area of memory. {" + RequestedSize + " bytes}"
	End
	
	' Fields:
	Field RequestedSize:UInt
End

' This is used to catch (And throw) specific allocation exceptions.
Class BulkAllocationException<ContainerType> Extends AllocationException
	' Constructor(s):
	Method New(Data:ContainerType=Null, Size:UInt)
		Super.New(Size)
		
		Self.Data = Data
	End
	
	' Fields:
	Field Data:ContainerType
End