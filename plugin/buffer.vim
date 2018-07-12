"GET MAXIMUM LINE WIDTH IN BUFFER:"
function! buffer#LinesWidthMax()
	let l:lines=getline(1,'$')
	let l:maxwidth=max(map(l:lines,'strdisplaywidth(v:val)'))
	return l:maxwidth
endfunction
""echo buffer#LinesWidthMax()

""GET NUMBER OF LISTED BUFFERS:
function! buffer#BuffersGetListed()
	return len(getbufinfo({'buflisted':1}))
endfunction
""echo buffer#BuffersGetListed()
""echo getbufinfo({'buflisted':1})

""GET BUFFER NAMES WITH FULL PATH:
function! buffer#BuffersGetListedNames()
	let l:names=[]
	for buf in getbufinfo({'buflisted':1})
		call add(l:names,buf.name)
	endfor
	return l:names
endfunction
""echo buffer#BuffersGetListedNames()

""GET BUFFER NUMBERS:
""returns list of buffer numbers
function! buffer#BuffersGetListedNumbers()
	let l:bufnrs=[]
	for buf in getbufinfo({'buflisted':1})
		call add(l:bufnrs,buf.bufnr)
	endfor
	return l:bufnrs
endfunction
""echo buffer#BuffersGetListedNumbers()

""GET BUFFER DIRECTORIES:
function! buffer#BufferGetListedDirs()
	let l:dirs=[]
	for buf in getbufinfo({'buflisted':1})
		""echo buf.name
		let l:sub=matchstr(buf.name,'.*/')
		call add(l:dirs,l:sub)
	endfor
	return l:dirs
endfunction
""echo buffer#BufferGetListedDirs()

""DELETE ALL OTHER BUFFERS:
function! buffer#DeleteAllOther()
	let l:curbuffer=bufnr('%')
	for l:i in buffer#BuffersGetListedNumbers()
		if l:i != l:curbuffer
			exe "bw " . l:i
		endif
	endfor
endfunction
""echo buffer#DeleteAllOther()

""CREATE SCRATCH BUFFER:
function! buffer#CreateNewScratch(bufname)
		"Create new buffer"
		exe 'new' a:bufname
		:setlocal buftype=nowrite
		:setlocal bufhidden=hide
		:setlocal noswapfile
endfunction

function! buffer#GoToScratch(bufname,lines)
	let l:bfnr=bufwinnr(a:bufname)
	if  l:bfnr > 0
	"If buffer is visible, go to it and clear contents"
		exe l:bfnr . "wincmd w"
	else
		"Create new scratch buffer"
		exe  a:lines . 'new' a:bufname
		:setlocal buftype=nowrite
		:setlocal bufhidden=wipe
		:setlocal noswapfile nobuflisted nomodified
	endif
endfunction
""echo buffer#GoToScratch("bufalo",10)

""TOGGLE CONCEAL CURSOR:
function! buffer#ConcealCursorToggle()
	if &concealcursor == ''
		setlocal concealcursor=nc
	else
		setlocal concealcursor=
	endif
endfunction
""call buffer#ConcealCursorToggle()

"Go to window number"
fu! buffer#GoToWindow(nr)
	exe a:nr . "wincmd w"
endf
