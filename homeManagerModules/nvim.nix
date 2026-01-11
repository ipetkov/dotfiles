{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkMerge;
  inherit (pkgs) vimPlugins;
  cfgFzf = config.programs.fzf;
  cfgRust = config.dotfiles.rust;
  cfgTypescript = config.dotfiles.typescript;
in
{
  options.dotfiles.typescript.enable = lib.mkEnableOption "typescript";

  config = mkMerge [
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

        package = pkgs.neovim-unwrapped;

        extraPackages = [
          pkgs.bash-language-server
          pkgs.nil
          pkgs.nixfmt
          pkgs.shellcheck
          pkgs.shfmt
          pkgs.tree-sitter
        ] ++ lib.optional cfgTypescript.enable pkgs.nodePackages.typescript-language-server;

        plugins =
          with vimPlugins;
          [
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
            nvim-lspconfig # Collection of common configurations for the Nvim LSP client
            rustaceanvim # To enable more of the features of rust-analyzer, such as inlay hints and more!
            nvim-cmp # Completion framework
            cmp-buffer # completion source for buffer words
            cmp-nvim-lsp # completion source for builtin lsp
            cmp-path # completion source for paths
            cmp-vsnip # completion source for snippets
            vim-vsnip # snippet engine (required...)

            # Diagnostics
            dressing-nvim
            trouble-nvim
            fidget-nvim

            # Misc
            neoconf-nvim
            vim-easy-align
          ]
          ++ lib.optional cfgFzf.enable vimPlugins.fzf-vim;

        extraConfig =
          let
            file = builtins.readFile ../config/nvim/init.vim;
          in
          if cfgRust.enable then
            builtins.replaceStrings [ "@rustAnalyzer@" ] [ "${pkgs.rust-analyzer}" ] (
              builtins.readFile ../config/nvim/init.vim
            )
          else
            file;
      };
    })
  ];
}
