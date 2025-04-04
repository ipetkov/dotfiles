{ pkgs, lib, ... }:
let
  inherit (lib) mkMerge;
in
{
  # Ensure we pull in fzf for our fzf plugin below
  imports = [ ./fzf.nix ];

  config = mkMerge [
    ({
      home.sessionVariables = {
        EDITOR = "vim";
      };

      # NB: do the install inside of a nixshell with a C compiler so
      # we can build the yaml parser
      home.activation.tsgrammars = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run nix shell ${pkgs.gcc} --command fish -c 'nvim --headless +TSUpdateSync +q'
      '';

      programs.neovim = {
        enable = true;
        vimAlias = true;
        vimdiffAlias = true;

        withPython3 = false;
        withRuby = false;

        package = pkgs.neovim-unwrapped;

        extraPackages = with pkgs; [
          nodePackages.typescript-language-server
          nil
          nixpkgs-fmt
          tree-sitter
        ];

        plugins = with pkgs.vimPlugins; [
          # Git
          vim-gitgutter
          vim-fugitive

          # Color themes/syntax highlighting
          kanagawa-nvim
          rust-vim # Also makes things work like formatting and cargo integration
          # NB: let treesitter manage its own grammars, there's something about the
          # ones in nixpkgs makes it break from time to time. Internally it uses a
          # lockfile for the grammars so this is still fully reproducible
          nvim-treesitter
          hmts-nvim # better language highlighting inside home-manager configs

          # LSP plugins
          nvim-lspconfig  # Collection of common configurations for the Nvim LSP client
          rustaceanvim   # To enable more of the features of rust-analyzer, such as inlay hints and more!
          nvim-cmp        # Completion framework
          cmp-buffer      # completion source for buffer words
          cmp-nvim-lsp    # completion source for builtin lsp
          cmp-path        # completion source for paths
          cmp-vsnip       # completion source for snippets
          vim-vsnip       # snippet engine (required...)

          # Diagnostics
          dressing-nvim
          trouble-nvim
          fidget-nvim

          # Misc
          fzf-vim
          neoconf-nvim
          vim-easy-align
        ];

        extraConfig = builtins.replaceStrings
          [ "@rustAnalyzer@" ]
          [ "${pkgs.rust-analyzer}" ]
          (builtins.readFile ../config/nvim/init.vim);
      };
    })
  ];
}
