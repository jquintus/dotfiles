"*******************************************************************************
" Configure variables
"*******************************************************************************
let PersonalVimRc = "~/.vimrc"
let PersonalVimDir="~/OneDrive/bin/config/vimfiles/"

nmap <F3> :execute 'source' PersonalVimRc<cr>
nmap <s-F3> :execute 'e' PersonalVimRc<cr>

nmap <leader>sv :execute 'source' PersonalVimRc<cr>
nmap <leader>ev :execute 'e' PersonalVimRc<cr>

"*******************************************************************************
" Mac Specific Stuff
" <D-j> : this maps the "command key + j"
"*******************************************************************************
" To set colors up in ITerm
" https://tomlankhorst.nl/iterm-tmux-vim-true-color/
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
execute pathogen#infect()
filetype plugin indent on
syntax on

nnoremap <D-cr> :set fu!<cr>
nnoremap <D-j> <c-w>j
nnoremap <D-h> <c-w>h
nnoremap <D-k> <c-w>k
nnoremap <D-l> <c-w>l

"*******************************************************************************
" Load in dependencies
" Still trying to figure out how to get this to work well
"*******************************************************************************

" exec "source " . $PersonalVimDir . "vimrc.helloworld.txt"

"*******************************************************************************
" Create directories
"*******************************************************************************
if !isdirectory($HOME."/.vim_backup")
    call mkdir($HOME."/.vim_backup", "p")
endif

if !isdirectory($HOME."/.vim_undo")
    call mkdir($HOME."/.vim_undo", "p")
endif

if !isdirectory($HOME."/OneDrive/bin/config/vimfiles")
    call mkdir($HOME."/OneDrive/bin/config/vimfiles", "p")
endif
"*******************************************************************************
" Sets
"*******************************************************************************

map <c-j> <c-w>j
map <c-h> <c-w>h
map <c-k> <c-w>k
map <c-l> <c-w>l

set hlsearch                 " Turn on search highlighting
set smartcase                " Ignore case in searches until you start typing caps
set ignorecase               " Ignore case in searches
set incsearch                " Highlight as you type search strings

set nocompatible

set nowrap                   " By default, don't do word wrap
set linebreak                " Don't just wrap at the last character, only wrap at words
set breakindent              " Match the main line's indent when doing a soft wrap
set breakindentopt=shift:4   " Additional indent when doing a soft wrap 

set shiftwidth=4
set tabstop=4
set expandtab

set backup                   " keep backup copies
set backupdir=~/.vim_backup  " save all backups in one directory (if you get "E303: Unable to open swap file for Â[No Name]Â, recovery impossible" then just make the directory ~/backup
set directory=~/.vim_backup  " put swaps files here too
set undodir=~/.vim_undo      " put swaps files here too
set backupext=.bak           " don't use that weird ~ extension
set ruler                    " show column/row count (on by default)

set showcmd                  " show key sequence in status line

set guioptions +=bh          " b=> bottom scrollbar; h=> quick scrollbar
set guioptions -=L           " Removing L fixes the problem where gVim changes size and moves when a tab is opened or closed http://stackoverflow.com/questions/13251522/why-does-gvim-resize-and-reposition-itself-after-some-actions
set diffopt +=vertical       " Diff with vertical split
set guifont=Menlo-Regular:h16

set encoding=utf-8
color desert

set autoread                 " Automatically reload a file when it has been changed on disk

let mapleader=" "

"*******************************************************************************
"Keyboard mappings
"*******************************************************************************
"open/reread config file
nmap <c-F3> :source ~/_vimrc<cr>
nmap <cs-F3> :e ~/_vimrc<cr>

nmap <F5> :e!<cr>zz
nmap <s-F5> :e!<cr>Gzz

"Remove highlights when you hit enter
nmap <cr> :noh<cr>j

"Tab Completion in edit mode
map <tab> :bn<cr>
map <s-tab> :bp<cr>

" Cycle between tabs
map <c-tab> :tabNext<cr>
map <F10> :tabnew<cr>
map <c-n> :tabnew<cr>
map <s-F10> :tabclose<cr>
map <c-F10> :tabclose!<cr>

" Simple Edits: next + do-again, down + do-again
map <F6> n.
map <s-F6> nn.
map <F7> j.

" Sort uniques
map <m-space> <esc>:sort u<cr>:echo "Sorted"<cr>
map <leader>r :g/^/m0<cr>:echo "Reversed all lines in file"<cr>

map <F4> <c-h>:diffthis<cr><c-l>:diffthis<cr>

" Copy the entire file to the clipboard and return to the current line
map <c-space> <esc>mzggVG"*y`z:delmarks c<cr>:echo "File copied to clipboard"<cr>

"J/K work on word wrapped lines now
nnoremap j gj
nnoremap k gk

"Filtering
map <leader>v :v::d<cr>
map <leader>g :g::d<cr>

" ok, this one is kinda complicated
"==================================
"    Map leader-y to copy all lines that match the current search to the default buffer
"    qyq              Clear out the Y register
"    my               Create a mark so we can come back here later
"    :g::y Y          Copy all lines that match the current search to the Y buffer
"    :let @+ =@y      Copy the content of the Y buffer to the default buffer
"    `y               Move the cursor back to the starting position
map <leader>y qyqmy:g::y Y<cr>:let @+ =@y<cr>`y

" Prevail over shift-happy fingers.
cabbr Wq wq
cabbr qw wq
cabbr Qw wq
cabbr Wqa wqa
cabbr W w
cabbr WQ wq

"*******************************************************************************
" Configure <TAB> to tab-completion when at the end of a word
"*******************************************************************************
function! InsertTabWrapper()
      let col = col('.') - 1
      if !col || getline('.')[col - 1] !~ '\k'
          return "\<tab>"
      else
          return "\<c-n>"
      endif
endfunction

function! InsertShiftTabWrapper()
      let col = col('.') - 1
      if !col || getline('.')[col - 1] !~ '\k'
          return "\<s-tab>"
      else
          return "\<c-n>"
      endif
endfunction

inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-r>=InsertShiftTabWrapper()<cr>

"-----------------------------------------------------------
"Toggle Word Wrap with <F2>
"-----------------------------------------------------------
nmap <F2> :setlocal wrap!<cr>
nmap <s-F2> :slocalet wrap!<cr> :slocalet lbr!<cr>
nmap <c-F2> gq}

"-----------------------------------------------------------
"Syntax Highlighting
"-----------------------------------------------------------
nmap <F11> :call ToggleSyntax()<cr>

function! ToggleSyntax()
	if !exists("b:syntax")
		let b:syntax=0
	endif

	if b:syntax==0
		let b:syntax=1
		setlocal syntax=cs
    echo "Setting syntax to C#"
	elseif b:syntax == 1
		let b:syntax=2
		setlocal syntax=xml
    echo "Setting syntax to Xml"
	elseif b:syntax == 2
		let b:syntax=3
		setlocal syntax=sqlanywhere
    echo "Setting syntax to Sql"
	elseif b:syntax == 3
		let b:syntax=4
		setlocal syntax=javascript
    echo "Setting syntax to JavaScript"
	elseif b:syntax == 4
		let b:syntax=5
		setlocal syntax=json
    echo "Setting syntax to Json"
	elseif b:syntax == 5
		let b:syntax=6
		setlocal syntax=java
    echo "Setting syntax to Java"
	elseif b:syntax == 6
		let b:syntax=7
		setlocal syntax=python
    echo "Setting syntax to Python"
	else
		let b:syntax=0
		setlocal syntax=off
    echo "Turning off syntax highlighting"
	endif
endfunction

let b:syntax=0
"-----------------------------------------------------------

"*******************************************************************************
" Search for selected text with * and #
"*******************************************************************************

function! s:VSetSearch()
  let temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = temp
endfunction

vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

"******************************************************************************
" Alt-period replay the last ex command
"*******************************************************************************
map <m-.> :<up><cr>

"*******************************************************************************
"Hidden "One particularly useful setting is hidden. Its name isn't too descriptive,
"though. It hides buffers instead of closing them. This means that you can
"have unwritten changes to a file and open a new file using :e, without being
"forced to write or undo your changes first. Also, undo buffers and marks are
"preserved while the buffer is open. This is an absolute must-have.
"*******************************************************************************
set hidden

"*******************************************************************************
" http://www.rayninfo.co.uk/vimtips.html
"*******************************************************************************
" Insert the line number at the begining/end of a line
nmap <leader>ln :%s/^/\=line('.'). ' '<cr>
 ":%s/$/\=line('.'). ' '

"*******************************************************************************
" Stolen from mswin.vim
"*******************************************************************************
" CTRL-X and SHIFT-Del are Cut
vnoremap <C-X> "+x
vnoremap <S-Del> "+x

" CTRL-C and CTRL-Insert are Copy
vnoremap <C-C> "+y
vnoremap <C-Insert> "+y

" CTRL-V and SHIFT-Insert are Paste
"map <C-V> "+gP
"vnoremap <S-Insert>"+gP

"cmap <C-V> <C-R>+
cmap <S-Insert> <C-R>+
"cmap \| <C-R>+  " this mapping makes it impossible to do or regexes when
"searching

" CTRL-A is copy all
map <M-A> mcggVG"+y'c:delmarks c<cr>:echo "File copied to clipboard"<cr>

" The surface keyboard doesn't have an insert button
" so I'll have to get used to using c-v to paste
" like some sort of heathen.

" CTRL-V and SHIFT-Insert are Paste
"map <C-V>   	"+gP
map <S-Insert>  	"+gP

" Pasting blockwise and linewise selections is not possible in Insert and
" Visual mode without the +virtualedit feature.  They are pasted as if they
" were characterwise instead.
" Uses the paste.vim autoload script.

exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']

imap <S-Insert> 	<C-V>
vmap <S-Insert> 	<C-V>

"*******************************************************************************
" Delete all buffers that aren't displayed in tabs/windows and aren't modified
" https://www.reddit.com/r/vim/comments/4b9hg5/weekly_vim_tips_and_tricks_thread_2/d17gofm
"*******************************************************************************
function! s:wipeout()
  let tpbl=[]
  call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
  let wiped = 0
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1 && !getbufvar(v:val,"&mod")')
    " echom buf
    silent execute 'bwipeout!' buf
    let wiped += 1
  endfor
  echom wiped . ' buffers deleted'
endfunction
command! Wipeout call s:wipeout()


"*******************************************************************************
" Special file type handling
"*******************************************************************************

" JSON syntax highlighting using javascript
" Stolen from http://www.codeography.com/2010/07/13/json-syntax-highlighting-in-vim.html
autocmd! BufRead,BufNewFile *.json set filetype=json

nmap <F12> :1,$ ! jq "." -<cr>:set syntax=json<cr>


autocmd! BufRead,BufNewFile *.vssettings set filetype=xml

autocmd BufNewFile,BufRead *.xaml setf xml

autocmd BufRead,BufNewFile *.fsproj set filetype=xml

"*******************************************************************************
" Auto highlight current word when idle
"*******************************************************************************
" http://vim.wikia.com/wiki/Auto_highlight_current_word_when_idle
"
" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type <leader>/ to toggle highlighting on/off. (i.e, space then backslash)
"*******************************************************************************
nnoremap <leader>/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: off'
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=500
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction

"*******************************************************************************
" Notes
"*******************************************************************************

" edit my notes file
nmap <leader>b :next $HOME/OneDrive/bin/config/vimfiles/notes.bat<cr>
nmap <leader>c :next $HOME/OneDrive/bin/config/vimfiles/notes.cs<cr>
nmap <leader>j :next $HOME/OneDrive/bin/config/vimfiles/notes.json<cr>
nmap <leader>m :next $HOME/OneDrive/bin/config/vimfiles/notes.md<cr>
nmap <leader>s :next $HOME/OneDrive/bin/config/vimfiles/notes.sql<cr>
nmap <leader>t :next $HOME/OneDrive/bin/config/vimfiles/notes.txt<cr>
nmap <leader>e :next $HOME/OneDrive/bin/config/vimfiles/notes_encrypted.txt<cr>
nmap <leader>x :next $HOME/OneDrive/bin/config/vimfiles/notes.xml<cr>
nmap <leader>d :next $HOME/OneDrive/bin/config/vimfiles/destiny_notes.txt<cr>

nmap t? :call ShowQuickFiles()<cr>

function! ShowQuickFiles()
    echo '<leader>b => notes.bat'
    echo '<leader>c => notes.cs'
    echo '<leader>j => notes.json'
    echo '<leader>m => notes.md'
    echo '<leader>s => notes.sql'
    echo '<leader>t => notes.txt'
    echo '<leader>x => notes.xml'
endfunction

"*******************************************************************************
" Markdown
" https://stackoverflow.com/questions/9985360/vim-plugin-for-adding-external-links
"*******************************************************************************
nnoremap <Leader>4 ciw[<C-r>"](<Esc>"*pli)<Esc>
vnoremap <Leader>4 c[<C-r>"](<Esc>"*pli)<Esc>

nnoremap , ciw[<C-r>"](<Esc>"*pli)<Esc>
vnoremap , c[<C-r>"](<Esc>"*pli)<Esc>

set rtp+=/usr/local/opt/fzf
let g:fzf_history_dir = '~/.vimfzf-history'


"*******************************************************************************
" Running psql in vim
"*******************************************************************************
"command! LocalDB left vertical 30split | terminal localdb

command! LocalDB leftabove vertical 30split | terminal localdb
command! Foo leftabove vertical 30split | terminal localdb
command! Bar topleft vertical 30vsplit | wincmd H | terminal localdb
