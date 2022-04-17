{ pkgs, lib, config, inputs, ... }:
let
  inherit (lib) mkIf mkMerge mkEnableOption;
  cfg = config.programs.neovim;
in
{
  # Ensure we pull in fzf for our fzf plugin below
  imports = [ ./fzf.nix ];

  options = {
    programs.neovim.useNightly = lib.mkEnableOption {
      description = "use neovim-nightly build";
    };
  };

  config = mkMerge [
    (mkIf cfg.useNightly {
      nixpkgs.overlays = [ inputs.neovim-nightly-overlay.overlay ];
      programs.neovim.package = pkgs.neovim-nightly;
    })

    ({
      home.sessionVariables = {
        EDITOR = "vim";
      };

      programs.neovim = {
        enable = true;
        vimAlias = true;
        vimdiffAlias = true;

        withPython3 = false;
        withRuby = false;

        extraPackages = with pkgs; [
          rnix-lsp
          nodePackages.typescript-language-server
        ];

        plugins = with pkgs.vimPlugins; [
          # Git
          vim-gitgutter
          vim-fugitive

          # Color themes/syntax highlighting
          jellybeans-vim
          rust-vim # Also makes things work like formatting and cargo integration

          # LSP plugins
          nvim-lspconfig  # Collection of common configurations for the Nvim LSP client
          rust-tools-nvim # To enable more of the features of rust-analyzer, such as inlay hints and more!
          nvim-cmp        # Completion framework
          cmp-buffer      # completion source for buffer words
          cmp-nvim-lsp    # completion source for builtin lsp
          cmp-path        # completion source for paths
          cmp-vsnip       # completion source for snippets
          vim-vsnip       # snippet engine (required...)

          # Code/syntax completers/linters
          fzf-vim
          dressing-nvim
          fidget-nvim

          # Misc
          vim-commentary
          vim-easy-align

          (nvim-treesitter.withPlugins (plugins: with pkgs.tree-sitter-grammars; [
            tree-sitter-bash
            tree-sitter-c
            tree-sitter-comment
            tree-sitter-cpp
            tree-sitter-css
            tree-sitter-dockerfile
            tree-sitter-dot
            tree-sitter-fish
            tree-sitter-go
            tree-sitter-gomod
            tree-sitter-html
            tree-sitter-http
            tree-sitter-java
            tree-sitter-javascript
            tree-sitter-jsdoc
            tree-sitter-json
            tree-sitter-json5
            tree-sitter-kotlin
            tree-sitter-lua
            tree-sitter-make
            tree-sitter-markdown
            tree-sitter-nix
            tree-sitter-python
            tree-sitter-regex
            tree-sitter-rust
            tree-sitter-scss
            tree-sitter-swift
            tree-sitter-toml
            tree-sitter-typescript
            tree-sitter-vim
            tree-sitter-yaml
          ]))
        ];

        extraConfig = builtins.readFile ../config/nvim/init.vim;
      };
    })
  ];
}
