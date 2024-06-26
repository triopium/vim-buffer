runtime buffer.vim9.vim
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
function! buffer#CreateNewScratchForRedir(bufname)
	"Create new buffer"
	exe 'new' a:bufname
	:setlocal nu
	:setlocal buftype=nofile
	" :setlocal bufhidden=wipe
	:setlocal bufhidden=hide
	:setlocal noswapfile
endfunction

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

function! buffer#GoToScratchVertical(bufname,cols)
	let l:bfnr=bufwinnr(a:bufname)
	if  l:bfnr > 0
		"If buffer is visible, go to it and clear contents"
		exe l:bfnr . "wincmd w"
	else
		"Create new scratch buffer"
		exe  'topleft ' . a:cols . 'vnew ' a:bufname
		:setlocal buftype=nowrite
		:setlocal bufhidden=wipe
		:setlocal noswapfile nobuflisted nomodified
	endif
endfunction
""echo buffer#GoToScratchVertical("bufalo",10)

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
function! buffer#GoToWindow(nr)
	exe a:nr . "wincmd w"
endfunction

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
		set ma
		0put=l:list
		set noma
		
		""Higlight
		let l:hname='bufferListNr1'
		let l:patt='^' . l:borig . '\t' 
		exe 'highlight ' . l:hname . ' guifg=#32FF30'
		exe 'syn match ' . l:hname . ' ' . shellescape(l:patt)

		""Mapping
		exe 'nnoremap <buffer> <CR> :echo buffer#ExtractGoToBuffNr(' . l:worig . ')<CR>'
		nnoremap <buffer> d :call buffer#ExtractDellBuffer()<CR>
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
 

""CREATE OUTLINE LIST OF MARKUP FILE:
function! buffer#OutlineTxtMaker(patt,file)
	let l:bashc='grep -E ' . a:patt . ' -n ' . a:file
	let l:ls=systemlist(l:bashc)
	return l:ls
endfunction
"echo buffer#OutlineMaker("let")

""CREATE OUTLINE LIST UP TO LEVEL:
function! buffer#OutlineTxtMakerLevel(lv,file)
	if a:lv==1
		let l:lst=buffer#OutlineTxtMaker('^#[[:space:]]',a:file)
	elseif a:lv==2
		let l:lst=buffer#OutlineTxtMaker('^\(#\)\{1,2\}[[:space:]]',a:file)
	elseif a:lv==3
		let l:lst=buffer#OutlineTxtMaker('^\(#\)\{1,3\}[[:space:]]',a:file)
	elseif a:lv==4
		let l:lst=buffer#OutlineTxtMaker('^\(#\)\{1,4\}[[:space:]]',a:file)
	endif
	return l:lst
endfunction

""HIGLIGHT OUTLINE LIST:
function! buffer#OutlineTxtHighlight()
	setlocal conceallevel=3
	"Higlight line numbers
	let l:hname="OutlineLineNumbers"
	let l:patt='^\d\{-}\ze:'
	let l:hicommand='highlight ' . l:hname . ' guifg=#C89600'
	let l:mcommand='syn match ' . l:hname . ' ' . shellescape(l:patt) . ' conceal cchar=:'
	exe l:hicommand
	exe l:mcommand
	
	"Hilight bullets LV1
	let l:hname="OutlineBullet1"
	let l:patt=':\zs# .*'
	let l:hicommand='highlight ' . l:hname . ' guifg=#FF0000'
	let l:mcommand='syn match ' . l:hname . ' ' . shellescape(l:patt)
	exe l:hicommand
	exe l:mcommand

	"Hilight bullets LV2
	let l:hname="OutlineBullet2"
	let l:patt=':\zs## '
	let l:hicommand='highlight ' . l:hname . ' guifg=#F89600'
	let l:mcommand='syn match ' . l:hname . ' ' . shellescape(l:patt)
	exe l:hicommand
	exe l:mcommand

	"Hilight bullets LV3
	let l:hname="OutlineBullet3"
	let l:patt=':\zs### '
	let l:hicommand='highlight ' . l:hname . ' guifg=#889600'
	let l:mcommand='syn match ' . l:hname . ' ' . shellescape(l:patt)
	exe l:hicommand
	exe l:mcommand
endfunction

""OUTLINE LEVELS HIGLIGHT:
function! buffer#OutlineTxtShow()
	let l:lv=1
	let l:bufnr=bufnr("%")
	let l:worig=win_getid()
	let l:scname=expand('%') . '_outline'
	let l:file=expand('%:p')
	let l:lst=buffer#OutlineTxtMakerLevel(l:lv,l:file)
	call buffer#GoToScratchVertical(l:scname,30)
	let l:wscratch=winnr()
	0put=1
	1put=l:lst
	call buffer#OutlineTxtHighlight()
	
	"Buffer local mapping
	exe 'nnoremap <buffer> <silent> <cr> :echo buffer#OutlineGetLine(' . l:worig  . ',' . l:wscratch . ')<CR>'
	nnoremap <buffer> <silent> u :call buffer#OutlineTxtUpdateLevel()<CR>
	nnoremap <buffer> <silent> + :call buffer#OutlineTxtUpdateLevel('+')<CR>
	nnoremap <buffer> <silent> - :call buffer#OutlineTxtUpdateLevel('-')<CR>
endfunction

"UPDATE OUTLINE SCRATCH BUFFER:
function! buffer#OutlineTxtUpdateLevel(...)
	let l:lv = get(a:, 1, getline(1))
	let l:curlv=getline(1)
	if l:lv=='+' && l:curlv < 4
		let l:curlv+=1
	elseif l:lv=='-' && l:curlv > 1
		let l:curlv-=1
	endif
	let l:line=line('.')
	let l:file=expand('%:p')	
	let l:file=split(l:file,'_outline')[0]
	let l:lst=buffer#OutlineTxtMakerLevel(l:curlv,l:file)
	%d_
	0put=l:curlv
	1put=l:lst
	call buffer#OutlineTxtHighlight()
	exe l:line
endfunction


"GO TO LINE HELPER FOR OUTLINE SHOW:
function! buffer#OutlineGetLine(worig,wscratch)
	""woring - original window number
	""wscratch - scratch buffer window number
	""Extract number from line
	let l:pattl='^\d\{-}:'
	let l:line=getline('.')
	let l:matchl=matchstr(l:line,l:pattl)
	let l:matchl=substitute(l:matchl,':','','')
	call win_gotoid(a:worig)
	exe l:matchl
	normal! zt
	exe a:wscratch . " wincmd w"
endfunction


func! buffer#LSbuffers()
	let l:names=[]
	" for buf in getbufinfo({'buflisted':1})
	" for buf in getbufinfo({'listed':1})
	for buf in getbufinfo()
			" echo buf
		" call add(l:names,buf.name)
		call add(l:names,buf)
		return l:names
	endfor
	" return l:names
	" ls!
	" l:names=[]
	" for buf in getbufinfo()
		" call add(l:names,buf.name)
	" endfor
	" return l:names
endf

func buffer#QuicfixVisible()
	for wininfo in getwininfo()
		if wininfo.quickfix == 1
			return 1
		endif
	endfor
endf

func buffer#LocListVisible()
	for wininfo in getwininfo()
		if wininfo.loclist == 1
			return 1
		endif
	endfor
endf
	
func buffer#NERDTreeVisible()
" Check if nerdtree visible
	if exists("g:NERDTree") && g:NERDTree.IsOpen()
		return 1
  endif
	return 0
endf

func buffer#GetUnsavedFiles()
  let unsaved_files = []
  for bufnum in range(1, bufnr('$'))
    if buflisted(bufnum) && getbufvar(bufnum, "&modified")
      call add(unsaved_files, bufname(bufnum))
    endif
  endfor
  return unsaved_files
endf

func buffer#CloseBufferHelper()
	"Close nerdtree buffer if visible, the quickfix buffer, then current
	"buffer, if last buffer and files modified ask to save them else quit
	if buffer#LocListVisible() == 1
		lclose
		return
	endif

	if buffer#QuicfixVisible() == 1
		cclose 
		return
	endif

	if buffer#NERDTreeVisible() == 1
		NERDTreeClose
		return
	endif	

	if winnr('$') > 1
		close
		return
	endif

	let unsaved_files=buffer#GetUnsavedFiles()
	if len(unsaved_files) == 0
		quit
	endif
	
	"TREAT UNSAVED FILES
	echo "Unsaved files:"
	for file in unsaved_files
		echo ' - ' . file
	endfor

	let choice = confirm('Save all files and quit?', '&Yes\n&No', 1)
	if choice == 1
		wall
		quit	
	elseif choice != 1
		return
	endif
	return
endf
