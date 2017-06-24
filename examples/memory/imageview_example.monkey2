#Import "../regal"

Using regal.memory..
Using regal.math..
Using regal.util.stringutil..

Function Main:Void()
	' Allocate a large enough data-buffer (1KB should do).
	Local buffer:= New DataBuffer(1024)
	
	' Allocate an image-view of the buffer we allocated.
	Local view:= New ImageView(New BufferPointer(buffer), 1, 1)
	
	' Zero-initialize the buffer we allocated.
	view.Data.Clear()
	
	' This index will be used to assign bit-values.
	Local vindex:= 0
	
	' This pointer is used by our lambda in order to modify 'vindex'.
	Local vindex_ptr:= Varptr vindex
	
	' Local-only lambda, do not use outside of this scope.
	Local add:= Lambda(value:Int)
		view.Set(vindex_ptr[0], value); vindex_ptr[0] += 1
	End
	
	' Specify bits for our data-buffer:
	add(1); add(1); add(0); add(1)
	add(1); add(0); add(1); add(1)
	
	add(0); add(1); add(1); add(1)
	add(1); add(0); add(0); add(1)
	
	add(0); add(1); add(0); add(1)
	add(1); add(1); add(0); add(1)
	
	add(1); add(1); add(1); add(1)
	add(0); add(1); add(0); add(0)
	
	' Print the bytes and bits of our buffer:
	Local split_stride:= 4
	Local bit_count:= RoundUp(vindex, split_stride)
	
	Print("BYTES: " + RepresentBytes(view.Data, Max((vindex / 8), 1)))
	Print("BITS: " + RepresentBits(view, bit_count, split_stride, True))
	Print("RAW:  " + RepresentBits(view, bit_count, 0, False))
	
	' Discard our buffer.
	buffer.Discard()
End