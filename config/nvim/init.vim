filetype plugin indent on

syntax on                                 " enable syntax processing
set backspace=indent,eol,start            " get around backspace defaults, behave as expected in other apps
set completeopt=menuone,noinsert,noselect " Set completeopt to have a better completion experience
set ignorecase                            " when smartcase and ignore case are both on, search will be case
set incsearch                             " start search while typing
set laststatus=2                          " always display the statusline
set lazyredraw                            " redraw only when needed, get speedup from not redrawing during macros
set sessionoptions-=options               " Don't save options, see if this fixes problems with session restoration
set shortmess+=c                          " Avoid showing extra messages when using completion
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

set textwidth=100

" Spell settings
execute 'set spellfile=' . stdpath("config") . '/spell.utf8.add'

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
highlight GitGutterDelete ctermfg=9 guifg=#ff2222

let mapleader="\<Space>"
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>t :tabe<CR>
nnoremap <leader>s :Git<CR>
nnoremap <leader>n :GitGutterNextHunk<CR>
nnoremap <leader>p :GitGutterPrevHunk<CR>
nnoremap <leader>h :set hlsearch!<CR>
nnoremap <leader>rc :vsplit $MYVIMRC<CR>
nnoremap <Leader>l :lclose<CR>

" Bring back (old) Y -> yy behavior
" old habits die hard...
nnoremap Y yy

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
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>

nnoremap <silent> <leader>] <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gn    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <a-cr> <cmd>lua vim.lsp.buf.code_action()<CR>

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~ '\s'
endfunction

" Treat :W as :w for when typos happen
command! W w

augroup auto_cmds
  autocmd!
  " NB: hooks run in the order they were defined
  " NB: need to split the option changes like this or else it doesn't seem to work correctly
  autocmd Filetype * setlocal formatoptions-=t formatoptions-=r formatoptions-=o

  " Crontabs must usually be edited in place
  autocmd BufEnter crontab* setlocal backupcopy=yes

  autocmd Filetype help wincmd H
  autocmd BufRead,BufNewFile *.md set filetype=markdown syntax=markdown

  " Turn on spell checking and auto wrap text
  autocmd Filetype markdown setlocal spell textwidth=80
  autocmd Filetype gitcommit setlocal spell textwidth=72 formatoptions+=t

  " Show diagnostic popup on cursor hold
  autocmd CursorHold * lua vim.diagnostic.open_float({focusable = false})
augroup END

" https://sharksforarms.dev/posts/neovim-rust/
lua<<EOF
-- Configure LSP through rust-tools.nvim plugin.
-- rust-tools will configure and enable certain LSP features for us.
-- See https://github.com/simrat39/rust-tools.nvim#configuration
local rust_tools = require'rust-tools'
rust_tools.setup({
    tools = {
        autoSetHints = true,
        hover_with_actions = true,
        inlay_hints = {
            show_parameter_hints = true,
            other_hints_prefix = "» ",
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = {
        settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
                -- enable clippy on save
                checkOnSave = {
                    command = "clippy"
                },
                diagnostics = {
                  disabled = {"inactive-code"}
                },
            }
        }
    },
})

-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  -- Installed sources
  sources = {
    --{ name = 'buffer' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'vsnip' },
  },
})
EOF
