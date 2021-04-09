" ALL IN ONE VIM CONFIG

" ditch the vi stuff:
if &compatible
    set nocompatible
endif

"~~~plugins~~~
call plug#begin('~/.vim/plugged')

" my plugins
Plug 'eluum/vim-autopair'

" other plugins
Plug 'morhetz/gruvbox'
" Plug 'xuhdev/vim-latex-live-preview'
Plug 'justinmk/vim-syntax-extra'
Plug 'tikhomirov/vim-glsl' 
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter'

call plug#end()
"~~~~~~~~~~~~
"
"~~~Plugin Settings and Bindings~~~
" shader syntax coloring
autocmd! BufNewFile,BufRead *.vs,*.fs set ft=glsl
    
" Get text in files with Rg
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

"~~~windows specific (Yucky!)~~~
if has("gui_win32")
    " Vim with all enhancements
    source $VIMRUNTIME/vimrc_example.vim

    " Use the internal diff if available.
    " Otherwise use the special 'diffexpr' for Windows.
    if &diffopt !~# 'internal'
        set diffexpr=MyDiff()
    endif
    function MyDiff()
        let opt = '-a --binary '
        if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
        if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
        let arg1 = v:fname_in
        if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
        let arg1 = substitute(arg1, '!', '\!', 'g')
        let arg2 = v:fname_new
        if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
        let arg2 = substitute(arg2, '!', '\!', 'g')
        let arg3 = v:fname_out
        if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
        let arg3 = substitute(arg3, '!', '\!', 'g')
        if $VIMRUNTIME =~ ' '
            if &sh =~ '\<cmd'
                if empty(&shellxquote)
                    let l:shxq_sav = ''
                    set shellxquote&
                endif
                let cmd = '"' . $VIMRUNTIME . '\diff"'
            else
                let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
            endif
        else
            let cmd = $VIMRUNTIME . '\diff'
        endif
        let cmd = substitute(cmd, '!', '\!', 'g')
        silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
        if exists('l:shxq_sav')
            let &shellxquote=l:shxq_sav
        endif
    endfunction

endif
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

"~~~gui specific~~~ 
if has("gui_running")
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll barDarkGrey
    set guioptions-=L  "remove left-hand scroll bar

    " system specific fonts
    if has("gui_win32") 
        set guifont=Consolas:h11:cANSI
        " resize font with control + arrows
        nnoremap <C-Up> :silent! let &guifont = substitute(&guifont, ':h\zs\d\+', '\=eval(submatch(0)+1)', '')<CR>
        nnoremap <C-Down> :silent! let &guifont = substitute(&guifont, ':h\zs\d\+', '\=eval(submatch(0)-1)', '')<CR>
    else
        set guifont=DroidSansMono\ 12
        " resize font with control + arrows
        nnoremap <C-Up> :silent! let &guifont = substitute(&guifont, ' \zs\d\+', '\=eval(submatch(0)+1)', '')<CR>        
        nnoremap <C-Down> :silent! let &guifont = substitute(&guifont, ' \zs\d\+', '\=eval(submatch(0)-1)', '')<CR>
    endif

    "~~~~~~~~~~~~~~~~~~

    " colorscheme 
    colorscheme gruvbox
    set background=dark
    let g:gruvbox_contrast_dark='hard' 

else
    colorscheme native  " 
endif
"~~~~~~~~~~~~~~~~~~~~
"
" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

set history=200		" keep 200 lines of command line history
set ruler		    " show the cursor position all the time
set showcmd		    " display incomplete commands
set wildmenu		" display completion matches in a status line

set ttimeout		" time out for key codes
set ttimeoutlen=100	" wait up to 100ms after Esc for special key

" Show @@@ in the last line if it is truncated.
set display=truncate

" Show a few lines of context around the cursor.  Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

" Do not recognize octal numbers for Ctrl-A and Ctrl-X, most users find it
" confusing.
set nrformats-=octal

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries.
if has('win32')
    set guioptions-=t
endif

" Don't use Ex mode, use Q for formatting.
" Revert with ":unmap Q".
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-U>".
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine.  By enabling it you
" can position the cursor, Visually select and scroll with the mouse.
" Only xterm can grab the mouse events when using the shift key, for other
" terminals use ":", select text and press Esc.
if has('mouse')
    if &term =~ 'xterm'
        set mouse=a
    else
        set mouse=nvi
    endif
endif

" Only do this part when Vim was compiled with the +eval feature.
if 1
    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    " Revert with ":filetype off".
    filetype plugin indent on

    " Put these in an autocmd group, so that you can revert them with:
    " ":augroup vimStartup | au! | augroup END"
    augroup vimStartup
        au!

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid, when inside an event handler
        " (happens when dropping a file on gvim) and for a commit message (it's
        " likely a different one than last time).
        autocmd BufReadPost *
                    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
                    \ |   exe "normal! g`\""
                    \ | endif

    augroup END

endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langremap')
    " Prevent that the langmap option applies to characters that result from a
    " mapping.  If set (default), this may break plugins (but it's backward
    " compatible).
    set nolangremap
endif

"~~~crl+s to save~~~
noremap  <silent><c-s> :<c-u>update<cr>
vnoremap <silent><c-s> <c-c>:update<cr>
inoremap <silent><c-s> <c-o>:update<cr>
"~~~~~~~~~~~~~~~~~~

" line numbers
set number

"~~~custom keybindings~~~
let mapleader = " " " set leader for custom bindings to space prevents namespace collisions
" make window commands a little simpler (ctrl + w sucks to press)
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>q :wincmd q<CR>
nnoremap <leader>Q :q!<CR>

" faster splitting
nnoremap <leader>H :wincmd v<bar> :wincmd h<CR>
nnoremap <leader>L :wincmd v<CR>  :wincmd l<CR>
nnoremap <leader>J :wincmd s<bar> :wincmd j<CR>
nnoremap <leader>K :wincmd s<CR>  :wincmd k<CR>

" file explorer
nnoremap <leader>e :Vexplore!<CR>
nnoremap <leader>E :Ex<CR>
nnoremap <leader>t :Texplore<CR>

" misc
nnoremap <leader><Bslash> :noh<CR>
nnoremap <tab> I<tab><esc>
nnoremap <s-tab> I<backspace><esc>
nnoremap <leader>= ggVG=''

" copy paste 
nnoremap <leader>p "0p

" quick toggle some settings
nnoremap <silent> <leader>w :call ToggleWrap()<CR>
function! ToggleWrap()
    if &l:wrap
        let &l:wrap = 0
    else
        let &l:wrap = 1
    endif
endfunction 

let &l:relativenumber = 1

nnoremap <silent> <leader>r :call ToggleRelative()<CR>
function! ToggleRelative()
    if &l:relativenumber
        let &l:relativenumber = 0
    else 
        let &l:relativenumber = 1 
    endif
endfunction

"~~~~~~~~~~~~~~~~~~~~~~~~

" SEARCH STUFF 
set incsearch
set hlsearch

" coding stuff
syntax on
set expandtab
set smartindent 
set nowrap
set smartcase
set ignorecase
set tabstop=4 softtabstop=4
set shiftwidth=4
set nobackup
set nowritebackup
set noswapfile
set noundofile

set encoding=UTF-8 " allow unicode symbols

" no replace mode
imap <Insert> <Nop>
inoremap <S-Insert> <Insert>

set backspace=indent,eol,start
set ruler
set suffixes+=.aux,.bbl,.blg,.brf,.cb,.dvi,.idx,.ilg,.ind,.inx,.jpg,.log,.out,.png,.toc
set suffixes-=.h
set suffixes-=.obj

" color adjustments 
" (for some reason this needs to be last in the config?)
" grey line numbers
highlight lineNr ctermfg=DarkGrey

" make highlights legible
if has("gui_running")
    " may use in the future
else    
    highlight Search ctermfg=Black
    highlight IncSearch ctermfg=Black
    highlight ErrorMsg ctermfg=Black
    highlight Error ctermfg=Black
    highlight MatchParen ctermfg=Cyan
    highlight MatchParen ctermbg=Black
endif
