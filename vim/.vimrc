" ==================== Editor behavior ====================
set clipboard=unnamedplus
let &t_ut=''
set autochdir
set exrc
set secure
set number
set relativenumber
set cursorline
set noexpandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set list
set listchars=tab:\|\ ,trail:▫
set scrolloff=4
set ttimeoutlen=0
set notimeout
set viewoptions=cursor,folds,slash,unix
set wrap
set tw=0
set indentexpr=
set foldmethod=indent
set foldlevel=99
set foldenable
set formatoptions-=tc
set splitright
set splitbelow
set noshowmode
set ignorecase
set smartcase
set shortmess+=c
set lazyredraw
set visualbell
set updatetime=100
set virtualedit=block

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" ==================== Basic Mappings ====================
let mapleader=" "
noremap ; :
nnoremap Q :q<CR>
nnoremap S :w<CR>

nnoremap <LEADER>rc :e $HOME/.vimrc<CR>
augroup NVIMRC
  autocmd!
	autocmd BufWritePost *.nvimrc exec ":so %"
augroup END

" Search
noremap <LEADER><CR> :nohlsearch<CR>

" J/K keys for 5 times j/k for faster navigation
noremap <silent> J 5j
noremap <silent> K 5k

" H key: go to the start of the line
noremap <silent> H 0

" L key: go to the end of the line
noremap <silent> L $

" Faster in-line navigation
noremap W 5w
noremap B 5b

" ==================== Insert Mode Cursor Movement ====================
inoremap <C-a> <ESC>A
inoremap <C-I> <ESC>I
inoremap jk <ESC>
inoremap kj <ESC>

" ==================== Window management ====================
noremap <LEADER>h <C-w>h
noremap <LEADER>j <C-w>j
noremap <LEADER>k <C-w>k
noremap <LEADER>l <C-w>l

" Disable the default s key
noremap s <nop>

" split the screens to up down left right
noremap sk :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
noremap sj :set splitbelow<CR>:split<CR>
noremap sh :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
noremap sl :set splitright<CR>:vsplit<CR>

" ==================== Tab management ====================
" Create a new tab with tn
noremap tn :tabe<CR>
noremap tN :tab split<CR>

" Move around tabs with tn and ti
noremap th :tabp<CR>
noremap tl :tabn<CR>
