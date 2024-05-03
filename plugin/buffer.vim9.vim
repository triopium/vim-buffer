vim9script

# g:BufferCurrentSelectedString return current selected string on oneline
def g:BufferCurrentSelectedString(): string
	return getline("'<")[col("'<") - 1 : col("'>") - 1]
enddef
