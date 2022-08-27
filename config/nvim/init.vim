filetype plugin indent on

syntax on                                 " enable syntax processing
set backspace=indent,eol,start            " get around backspace defaults, behave as expected in other apps
set completeopt=menuone,noinsert,noselect " Set completeopt to have a better completion experience
set ignorecase                            " when smartcase and ignore case are both on, search will be case
set incsearch                             " start search while typing
set laststatus=2                          " always display the statusline
set lazyredraw                            " redraw only when needed, get speedup from not redrawing during macros
set mouse=""                              " Set the old mouse behavior I'm used to
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
nnoremap <Leader>l :lclose<CR>:cclose<CR>

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

nnoremap <silent> <leader>q <cmd>lua vim.diagnostic.setqflist()<CR>
nnoremap <silent> <leader>f <cmd>lua vim.lsp.buf.format()<CR>

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

" Trouble keybinds
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>Trouble workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>Trouble document_diagnostics<cr>
nnoremap <leader>xq <cmd>Trouble quickfix<cr>
nnoremap <leader>xl <cmd>Trouble loclist<cr>
nnoremap gR <cmd>Trouble lsp_references<cr>

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~ '\s'
endfunction

" Treat :W as :w for when typos happen
command! W w
command! Wa wa

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
  autocmd Filetype markdown setlocal spell textwidth=80 formatoptions+=t
  autocmd Filetype gitcommit setlocal spell textwidth=72 formatoptions+=t

  " Show diagnostic popup on cursor hold
  autocmd CursorHold * lua vim.diagnostic.open_float({focusable = false})
augroup END

" https://sharksforarms.dev/posts/neovim-rust/
lua<<EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = {},

  -- List of parsers to ignore installing (for "all")
  ignore_install = "all",

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = {},

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- Configure LSP through rust-tools.nvim plugin.
-- rust-tools will configure and enable certain LSP features for us.
-- See https://github.com/simrat39/rust-tools.nvim#configuration
local rust_tools = require'rust-tools'
rust_tools.setup({
    tools = {
        autoSetHints = true,
        inlay_hints = {
            show_parameter_hints = true,
            other_hints_prefix = "» ",
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = {
        before_init = function(initialize_params, config)
          -- Override clippy to run in its own directory to avoid clobbering caches
          local target_dir = config.root_dir .. "/target/ide-clippy";
          table.insert(config.settings["rust-analyzer"].checkOnSave.extraArgs, "--target-dir=" .. target_dir);
        end,
        settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
                cargo = {
                    allFeatures = true,
                },
                -- enable clippy on save
                checkOnSave = {
                    allTargets = true,
                    command = "clippy",
                    extraArgs = {},
                },
                diagnostics = {
                  disabled = {"inactive-code"}
                },
            }
        }
    },
})

local lspconfig = require'lspconfig'
lspconfig.rnix.setup({
})

lspconfig.tsserver.setup({
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

require('dressing').setup({
  input = {
    enabled = true,
  },
  select = {
    enabled = true,
  },
})

require('fidget').setup({
  text = {
    spinner = "moon",
  }
})

require('trouble').setup({
    position = "bottom", -- position of the list can be: bottom, top, left, right
    height = 10, -- height of the trouble list when position is top or bottom
    width = 50, -- width of the list when position is left or right
    icons = false, -- use devicons for filenames
    mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = "v", -- icon used for open folds
    fold_closed = ">", -- icon used for closed folds
    group = true, -- group results by file
    padding = true, -- add an extra new line on top of the list
    action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q", -- close the list
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r", -- manually refresh
        jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" }, -- open buffer in new split
        open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
        open_tab = { "<c-t>" }, -- open buffer in new tab
        jump_close = {"o"}, -- jump to the diagnostic and close the list
        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
        toggle_preview = "P", -- toggle auto_preview
        hover = "K", -- opens a small popup with the full multiline message
        preview = "p", -- preview the diagnostic location
        close_folds = {"zM", "zm"}, -- close all folds
        open_folds = {"zR", "zr"}, -- open all folds
        toggle_fold = {"zA", "za"}, -- toggle fold of current file
        previous = "k", -- preview item
        next = "j" -- next item
    },
    indent_lines = false, -- add an indent guide below the fold icons
    auto_open = true, -- automatically open the list when you have diagnostics
    auto_close = true, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    auto_jump = {"lsp_definitions"}, -- for the given modes, automatically jump if there is only a single result
    signs = {
        -- icons / text used for a diagnostic
        error = "error",
        warning = "warn",
        hint = "hint",
        information = "info"
    },
    use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
})
EOF
