" author: vaskoiii
" description: ubuntu vim/gvim unified configuration with emphasis on spacebar as the leader key, reusing existing tabs (no windows), and integrated file navigation ie) <space><tab>

" note
" - not using chorded keys (only sequences) to avoid conflicts with other programs keymaps
" - intentionally using as few colors as possible to ease setup with tmux and other integrations

" tmux integration
" vi ~/.tmux.conf
"  set -s escape-time 0
"  set-window-option -g mode-keys vi
" ubuntu global tmux is at:
"  /etc/tmux.conf

" general
colorscheme murphy
set showcmd
set nobackup
set noswapfile
set nowritebackup
set wildmenu
" use with :nohl
set hlsearch

" essay writing
noremap j gj
noremap k gk
noremap $ g$
noremap ^ g^
noremap 0 g0
" inverting
noremap gj j
noremap gk k
noremap g$ $
noremap g^ ^
noremap g0 0
" know also
" (
" )
" {
" }

" invisibles
set list
set listchars=tab:▸\ ,eol:¬
" makes the | and cursor hard to see in the help =(
hi specialkey ctermfg=darkgray
hi nontext ctermfg=darkgray

" only instance without 'noremap'
map <space> \
noremap <leader>w :write<cr>
noremap <leader>q :quit<cr>

" tab changing
noremap <leader>. :tabnext<cr>
noremap <leader>, :tabprevious<cr>

" console adaptation for tab drop
" https://github.com/ohjames/tabdrop/blob/master/plugin/tabdrop.vim
function! CtermTabDrop(file)
	let visible = {}
	let path = fnamemodify(a:file, ':p')
	for t in range(1, tabpagenr('$'))
		for b in tabpagebuflist(t)
			if fnamemodify(bufname(b), ':p') == path
					exec "tabnext " . t
				return
			endif
		endfor
	endfor
	if bufname('') == '' && &modified == 0
		exec "edit " . a:file
	else
		exec "tabnew " . a:file
	end
endfunction

" mimic what happens when doing gf but with: tab drop
function! GfTabDrop(sg1)
	let bl1 = 2
	" findfile works even if :pwd is something weird
	let lt2 = findfile(a:sg1, "", -1)
	for sg2 in lt2
		if (bl1 == 2)
			if filereadable(sg2)
				call CtermTabDrop(sg2)
				let bl1 = 1
			elseif isdirectory(sg2)
				call CtermTabDrop(sg2)
				let bl1 = 1
			endif
		endif
	endfor
	" help expand
	" expand("%:p:h") works with prefixed relative paths
	if (bl1 == 2)
		let sg3 = expand("%:p:h")."/".a:sg1
		if filereadable(sg3)
			call CtermTabDrop(sg3)
			let bl1 = 1
		elseif isdirectory(sg3)
			call CtermTabDrop(sg3)
			let bl1 = 1
		endif
	endif
	" check what was literally passed in
	if (bl1 == 2)
		if filereadable(a:sg1)
			call CtermTabDrop(a:sg1)
			let bl1 = 1
		elseif isdirectory(a:sg1)
			call CtermTabDrop(a:sg1)
			let bl1 = 1
		endif
	endif
	" print error message if all attempts failed
	if bl1 == 2
		echom "no file exists && no dir exists for: ".a:sg1
	endif
endfunction

" vimscripting
noremap <leader>ev :call GfTabDrop($MYVIMRC)<cr>
noremap <leader>sv :source $MYVIMRC<cr>
if has('gui_running')
	noremap <leader>eg :tab drop $MYGVIMRC<cr>
	noremap <leader>sg :source $MYGVIMRC<cr>
endif

" needs the double expand if dealing with ~ (not sure if it hurts anything)
noremap <leader><space> :call GfTabDrop(expand(expand("<cfile>")))<cr>

" help behaves differently than all other files
noremap <leader>h yiw :tab help <c-r>"
noremap <leader>g <c-]><cr>

" nicer tabline
set showtabline=2
hi TabLineFill ctermfg=gray ctermbg=black
hi TabLine ctermfg=black ctermbg=gray cterm=none
hi TabLineSel ctermfg=darkgray ctermbg=gray cterm=bold,reverse
if (has('gui_running'))
	set guitablabel=%t
	set guioptions=egt
	hi nontext guifg=#333333
	hi specialkey guifg=#333333
endif

" nicer statusline
set statusline=
set statusline+=%7*\[%n] " buffernr
set statusline+=%1*\ %<%F\  " File + path
set statusline+=%2*\ %y\  " FileType
set statusline+=%3*\ %{''.(&fenc!=''?&fenc:&enc).''} " Encoding
set statusline+=%3*\ %{(&bomb?\",BOM\":\"\")}\  " Encoding2
set statusline+=%4*\ %{&ff}\  " FileFormat (dos/unix..) 
set statusline+=%5*\ %{&spelllang}\%{HighlightSearch()}\  " Spellanguage & Highlight on?
set statusline+=%8*\ %=\ row:%l/%L\ (%03p%%)\  " Rownumber/total (%)
set statusline+=%9*\ col:%03c\  " Colnr
set statusline+=%0*\ \ %m%r%w\ %P\ \  " Modified? Readonly? Top/bot.
function! HighlightSearch()
	if &hls
		return 'H'
	else
		return ''
	endif
endfunction
if has('gui_running')
	" 16 color gvim equivalent
	hi User1 guifg=#000000 guibg=#800000
	hi User2 guifg=#000000 guibg=#808000
	hi User3 guifg=#000000 guibg=#808000
	hi User4 guifg=#000000 guibg=#008000
	hi User5 guifg=#000000 guibg=#008000
	hi User7 guifg=#c0c0c0 guibg=#800000 gui=bold
	hi User8 guifg=#000000 guibg=#008080
	hi User9 guifg=#000000 guibg=#8700af
	hi User0 guifg=#c0c0c0 guibg=#0000ff
else
	" portable cterm config
	" help xterm-color
	hi User1 ctermfg=white ctermbg=darkred
	hi User2 ctermfg=black ctermbg=brown
	hi User3 ctermfg=black ctermbg=brown
	hi User4 ctermfg=black ctermbg=darkgreen
	hi User5 ctermfg=black ctermbg=darkgreen
	hi User7 ctermfg=white ctermbg=darkred cterm=bold
	hi User8 ctermfg=white ctermbg=darkcyan
	hi User9 ctermfg=white ctermbg=darkmagenta
endif
hi statusline ctermfg=darkblue ctermbg=white
set modeline
set ls=2

" custom tabline
" do not open too many tabs (overflows)
" http://vim.1045645.n5.nabble.com/cut-off-complete-file-path-of-tabnames-td1184306.html
if exists("+showtabline")
	function! MyTabLine()
		let s = ''
		let t = tabpagenr()
		let i = 1
		while i <= tabpagenr('$')
			let buflist = tabpagebuflist(i)
			let winnr = tabpagewinnr(i)
			let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
			let b1 = bufname(buflist[winnr - 1])
			let file = fnamemodify(b1, ':p:t')
			if file == ''
				let file = '[No Name]'
				" need to override if it is a directory
				if isdirectory(b1)
					" ideally it would just be the topmost directory name listed
					let file = fnamemodify(b1, ':p:.')
					" let file = fnamemodify(b1, ':p:h')
					if file == ''
						let file = '[Working Dir]'
					endif
				endif
			endif
			let s .= ' '
			let s .= file
			if getbufvar(b1, "&modified")
				let s .= '*'
			endif
			let s .= ' '
			let i = i + 1
		endwhile
		let s .= '%T%#TabLineFill#%='
		let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
		return s
	endfunction
	set stal=2
	set tabline=%!MyTabLine()
endif 

" syntax highlighting for mysql \e command
if has("autocmd")
	augroup sql
		autocmd!
		autocmd BufNew,BufEnter /tmp/sql* setlocal filetype=sql
	augroup END
endif

" netrw file handling invocation
command! -nargs=1 -complete=file CTD call CtermTabDrop(<q-args>)
" makes you focus on the bottom of the screen / uses tab completion / typing ..
" noremap <leader><tab> :CTD %:h
" makes you focus on the top of the screen / no tab completion / using enter with .. highlighed
noremap <leader><tab> :call GfTabDrop('')<cr>
let g:netrw_banner=0

" insert mode indicator
" if using tmux do:
" vi ~/.tmux.conf
"  set -s escape-time 0
set number 
if has('gui_running')
	" 16 color gvim equivalent
	au InsertEnter * hi LineNr guifg=lightgreen
	au InsertLeave * hi LineNr guifg=yellow
else
	au InsertEnter * hi LineNr ctermfg=lightgreen
	au InsertLeave * hi LineNr ctermfg=yellow
	set ttimeoutlen=10
	augroup FastEscape
		autocmd!
		au InsertEnter * set timeoutlen=0
		au InsertLeave * set timeoutlen=1000
	augroup END
endif
