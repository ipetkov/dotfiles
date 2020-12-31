syntax on                                 " enable syntax processing
set backspace=indent,eol,start            " get around backspace defaults, behave as expected in other apps
set completeopt=menuone,noinsert,noselect " Set completeopt to have a better completion experience
set ignorecase                            " when smartcase and ignore case are both on, search will be case
set incsearch                             " start search while typing
set laststatus=2                          " always display the statusline
set lazyredraw                            " redraw only when needed, get speedup from not redrawing during macros
set sessionoptions-=options               " Don't save options, see if this fixes problems with session restoration
set shortmess                             " Avoid showing extra messages when using completion
set showcmd                               " show the (currently pending) command at bottom right
set smartcase                             " sensitive if pattern contains uppercase letter, and insensitive otherwise
set statusline=%f\ %l:%c\ %m              " show: <filename> <line>:<col> <pending changes>
set undofile                              " save undo history persistently to disk
set updatetime=500                        " how long before triggering CursorHold/swap write
set wildmenu                              " visual autocomplete for command menu
set wildignore+=*/.git/*,*/.hg/*,*/.svn/* " Ignore version control directories

" Default tab settings
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Even though alacritty sets $COLORINFO = 'truecolor' neovim doesn't
" seem to turn on gui colors, so we do it manually here
if $TERM == 'alacritty'
  set termguicolors
endif

color jellybeans

highlight clear SignColumn " NB: enforce this *after* color scheme

" Borrow the search hilight from the darkblue theme
highlight Search guifg=#ffffff guibg=#2050d0 ctermfg=white ctermbg=darkblue

" "Correct" the GitGutterDelete color since jellybeans sets
" a really dark (almost black) color for it
highlight GitGutterDelete ctermfg=12 guifg=#ff2222

let mapleader="\<Space>"
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>t :tabe<CR>
nnoremap <leader>s :Gstatus<CR>
nnoremap <leader>n :GitGutterNextHunk<CR>
nnoremap <leader>p :GitGutterPrevHunk<CR>
nnoremap <leader>h :set hlsearch!<CR>
nnoremap <leader>rc :vsplit $MYVIMRC<CR>
nnoremap <Leader>l :lclose<CR>

" Make <Esc> work in terminal mode
tnoremap <Esc> <C-\><C-n>

" Ctrl-p with fzf
nnoremap <C-p> :Files<Cr>

" Keep accidentally hitting K (to move up) during visual selection
" after hitting V (for visual line) without letting go of <SHIFT>
" which results in trying to run `man` on the word under the cursor
" nnoremap K <NOP>
vnoremap K <NOP>

" Put searches in the center of the screen
nnoremap n nzz
nnoremap N Nzz

" Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
vmap <Enter> <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <silent> g] <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>

nnoremap <silent> <leader>] <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
" nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
" nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
" nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
" nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
" nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>

" Trigger completion with <Tab>
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ completion#trigger_completion()

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~ '\s'
endfunction

" Treat :W as :w for when typos happen
command! W w

augroup auto_cmds
  autocmd!
  " Crontabs must usually be edited in place
  autocmd BufEnter crontab* setlocal backupcopy=yes

  autocmd Filetype help wincmd H
  autocmd Filetype * setlocal formatoptions-=ro
  autocmd BufRead,BufNewFile *.md set filetype=markdown syntax=markdown

  " Show diagnostic popup on cursor hold
  autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()
  " Enable type inlay hints
  autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
    \ lua require'lsp_extensions'.inlay_hints{ prefix = '» ', highlight = "Comment" }
augroup END

" Configure LSP
" https://github.com/neovim/nvim-lspconfig#rust-analyzer
lua <<EOF

local lspconfig = require'lspconfig'

-- function to attach completion and diagnostics
-- when setting up lsp
local on_attach = function(client)
    require'completion'.on_attach(client)
end

-- Enable rust_analyzer
lspconfig.rust_analyzer.setup({ on_attach=on_attach })


vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
      prefix = '»',
    },
    update_in_insert = false,
  }
)
EOF
