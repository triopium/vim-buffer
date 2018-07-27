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

""GET BUFFER NAMES WITH FULL PATH:
function! buffer#BuffersGetAllNames()
	let l:names=[]
	for buf in getbufinfo()
		call add(l:names,buf.name)
	endfor
	return l:names
endfunction
""echo buffer#BuffersGetAllNames()
"
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

""EXTRACT DIR FROM FILE PATH:
function! buffer#ExtractFileDirs(list)
	let l:dirs=[]
	for l:dir in a:list
		let l:sub=matchstr(l:dir,'.*/')
		call add(l:dirs,l:sub)
	endfor
	return l:dirs
endfunction
"
""EXTRACT FILE NAME FROM FILE PATH:
function! buffer#ExtractFileNames(list)
	let l:files=[]
	for l:buf in a:list
		let l:sub=matchstr(l:buf,'/.*/\zs.*')
		call add(l:files,l:sub)
	endfor
	return l:files
endfunction

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
		exe  a:lines . 'new ' a:bufname
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

""SHOW BUFFER LIST INFO:
function! buffer#BufferListChanger()
	let l:worig=winnr()
	let l:borig=bufnr('%')
	let l:bufname="buffer_changer"
	let l:bfnr=bufwinnr(l:bufname)
	if  l:bfnr > 0
		"If buffer is visible, go to it and clear contents"
		exe l:bfnr . "wincmd w"
	else
		"Create new scratch buffer"
		exe 'new ' l:bufname
		:setlocal buftype=nowrite
		:setlocal bufhidden=wipe
		:setlocal noswapfile nobuflisted nomodified
		let l:list=buffer#BufferListConstruct()
		0put=l:list
		
		""Higlight
		let l:hname='bufferListNr1'
		let l:patt='^' . l:borig . '\t' 
		exe 'highlight ' . l:hname . ' guifg=#32FF30'
		exe 'syn match ' . l:hname . ' ' . shellescape(l:patt)

		""Mapping
		exe 'nnoremap <CR> :echo buffer#ExtractGoToBuffNr(' . l:worig . ')<CR>'
		nnoremap d :call buffer#ExtractDellBuffer()<CR>
	endif
endfunction
""silent call buffer#BufferListChanger()

""CONSTRUCT BUFFER INFO:
function! buffer#BufferListConstruct()
	let l:buff=buffer#BuffersGetListedNames()
	let l:fdirs=buffer#ExtractFileDirs(l:buff)
	let l:fnames=buffer#ExtractFileNames(l:buff)
	let l:buffnr=buffer#BuffersGetListedNumbers()
	let l:patt='^' . $HOME
	let l:fdirs=array#ListSubstitute(l:fdirs,l:patt,'~','g')
	let l:count=len(l:buffnr)
	let l:lines=[]
	for l:i in range(0,l:count-1)
		let l:line=l:buffnr[l:i] . "\t" . l:fnames[l:i] . "\t" .
					\ l:fdirs[l:i]
		call add(l:lines,l:line)
	endfor
	return l:lines
endfunction
""call buffer#BufferListConstruct()

""EXTRACT BUFFER NUMBER FROM LIST AND GO TO BUFFER:
function! buffer#ExtractGoToBuffNr(worig)
	let l:line=getline('.')
	let l:bnr=matchstr(l:line,'\d*')
	bw
	call buffer#GoToWindow(a:worig) 
	silent exe 'b ' . l:bnr
endfunction
""echo buffer#ExtracBuffNr()

""EXTRACT BUFFER NUMBER FROM LIST AND DELETE BUFFER:
function! buffer#ExtractDellBuffer()
	let l:line=getline('.')
	let l:bnr=matchstr(l:line,'\d*')
	normal! dd
	exe 'bw ' . l:bnr
endfunction
""echo buffer#ExtracBuffNr()
