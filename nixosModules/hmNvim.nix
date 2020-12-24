{ pkgs, inputs, ... }:
{
  # Ensure we pull in fzf for our fzf plugin below
  imports = [ ./hmFzf.nix ];

  nixpkgs.overlays = [ inputs.neovim-nightly-overlay.overlay ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;

    package = pkgs.neovim-nightly;

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
      nvim-lspconfig # Collection of common configurations for the Nvim LSP client
      lsp_extensions-nvim # Extensions to built-in LSP, for example, providing type inlay hints
      completion-nvim #" Autocompletion framework for built-in LSP

      # Code/syntax completers/linters
      fzf-vim

      # Misc
      vim-commentary
      vim-easy-align
    ];

    extraConfig = builtins.readFile ../config/nvim/init.vim;
  };
}
