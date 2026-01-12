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
set spell                                 " enable spell checking always, treesitter should only mark comments as eligible
set spelloptions=noplainbuffer,camel      " check whenever syntax is on and treat camel cased words as separate words
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

highlight clear SignColumn " NB: enforce this *after* color scheme

let mapleader="\<Space>"
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>t :tabe<CR>
nnoremap <leader>s :vert Git<CR>
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
nnoremap <leader>xx <cmd>Trouble diagnostics toggle<cr>
nnoremap <leader>xw <cmd>Trouble diagnostics focus=true<cr>
nnoremap gR <cmd>Trouble lsp focus=true<cr>

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

  " Turn on spell checking and auto wrap text
  autocmd Filetype markdown setlocal spell textwidth=80 formatoptions+=t
  autocmd Filetype gitcommit setlocal spell textwidth=72 formatoptions+=t
  autocmd Filetype jj setlocal spell textwidth=72 formatoptions+=t
  autocmd Filetype jjdescription setlocal spell textwidth=72 formatoptions+=t

  " Show diagnostic popup on cursor hold
  autocmd CursorHold * lua vim.diagnostic.open_float({focusable = false})
augroup END

" https://sharksforarms.dev/posts/neovim-rust/
lua<<EOF

-- NB: we prepend here so our own installations take priority
-- over the grammars which might be bundled from the nixpkgs definition
local ts_parsers = vim.fn.stdpath("cache") .. "/ts-parsers"
vim.opt.runtimepath:prepend(ts_parsers)

local treesitter = require('nvim-treesitter')
treesitter.setup {
  install_dir = ts_parsers,
}
treesitter.install {
  "bash",
  "comment",
  "diff",
  "fish",
  "gitattributes",
  "gitcommit",
  "git_config",
  "gitignore",
  "git_rebase",
  "jq",
  "json",
  "lua",
  "make",
  "markdown",
  "mermaid",
  "nix",
  "regex",
  "rust",
  "ssh_config",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    "bash",
    "diff",
    "fish",
    "gitattributes",
    "gitcommit",
    "gitconfig",
    "gitignore",
    "gitrebase",
    "jq",
    "json",
    "lua",
    "make",
    "markdown",
    "mermaid",
    "nix",
    "rust",
    "sshconfig",
    "toml",
    "vim",
    "yaml",
  },
  callback = function() vim.treesitter.start() end,
})

local neoconf = require("neoconf")
neoconf.setup({
  -- name of the local settings files
  local_settings = ".neoconf.json",
  -- name of the global settings file in your Neovim config directory
  global_settings = "neoconf.json",
  -- import existing settings from other plugins
  import = {
    vscode = true, -- local .vscode/settings.json
    coc = false, -- global/local coc-settings.json
    nlsp = false, -- global/local nlsp-settings.nvim json settings
  },
  -- send new configuration to lsp clients when changing json settings
  live_reload = true,
  -- set the filetype to jsonc for settings files, so you can use comments
  -- make sure you have the jsonc treesitter parser installed!
  filetype_jsonc = true,
  plugins = {
    -- configures lsp clients with settings in the following order:
    -- - lua settings passed in lspconfig setup
    -- - global json settings
    -- - local json settings
    lspconfig = {
      enabled = true,
    },
    -- configures jsonls to get completion in .nvim.settings.json files
    jsonls = {
      enabled = false,
      -- only show completion in json settings for configured lsp servers
      configured_servers_only = true,
    },
    -- configures lua_ls to get completion of lspconfig server settings
    lua_ls = {
      -- by default, lua_ls annotations are only enabled in your neovim config directory
      enabled_for_neovim_config = true,
      -- explicitely enable adding annotations. Mostly relevant to put in your local .nvim.settings.json file
      enabled = false,
    },
  },
})

vim.g.rustaceanvim = {
    tools = {
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server-configurations.md
    server = {
        cmd = { '@rustAnalyzer@/bin/rust-analyzer' },
        default_settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
                cargo = {
                    allFeatures = true,
                    targetDir = true,
                },
                -- enable clippy on save
                check = {
                    allTargets = true,
                    command = "clippy",
                },
                diagnostics = {
                  disabled = {"inactive-code"}
                },
                procMacro = {
                    enable = true,
                },
                flags = {
                  exit_timeout = 100,
                },
                -- Make rustaceanvim effectively work with neoconf for the fields we care about
                files = {
                  exclude = ((((neoconf.get("vscode", {}) or {})["rust-analyzer"] or {}).files or {}).excludeDirs or {}),
                },
            }
        }
    },
}

vim.lsp.enable('ast_grep')
vim.lsp.enable('bashls')

vim.lsp.config('nil_ls', {
  settings = {
    ["nil"] = {
      formatting = {
        command = { "nixfmt" },
      },
    },
  },
})

vim.lsp.enable('ts_ls')

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
  progress = {
    display = {
      progress_icon = {"moon"},
    },
  }
})

require('trouble').setup({
  auto_close = true,
  modes = {
    diagnostics = {
      auto_open = true,
    },
  },
})

require('kanagawa').setup({
    undercurl = true,           -- enable undercurls
    commentStyle = { italic = false },
    functionStyle = {},
    keywordStyle = { italic = false },
    statementStyle = { bold = false },
    typeStyle = {},
    variablebuiltinStyle = { italic = false },
    specialReturn = true,       -- special highlight for the return keyword
    specialException = true,    -- special highlight for exception handling keywords
    transparent = false,        -- do not set background color
    dimInactive = false,        -- dim inactive window `:h hl-NormalNC`
    globalStatus = false,       -- adjust window separators highlight for laststatus=3
    terminalColors = true,      -- define vim.g.terminal_color_{0,17}
    colors = {},
    overrides = function(colors)
      return {
      }
    end,
    theme = "default"           -- Load "default" theme or the experimental "light" theme
})
-- setup must be called before loading
vim.cmd("colorscheme kanagawa")

vim.lsp.inlay_hint.enable(true)
EOF
