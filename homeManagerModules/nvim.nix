{ pkgs, ... }:
{
  # Ensure we pull in fzf for our fzf plugin below
  imports = [ ./fzf.nix ];

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
    ];

    plugins = with pkgs.vimPlugins; [
      # Git
      vim-gitgutter
      vim-fugitive
      
      # Color themes/syntax highlighting
      jellybeans-vim
      rust-vim
      vim-fish
      vim-nix
      vim-toml

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

      # Misc
      vim-commentary
      vim-easy-align
    ];

    extraConfig = builtins.readFile ../config/nvim/init.vim;
  };
}
