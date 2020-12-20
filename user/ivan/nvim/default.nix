{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      vim-gitgutter
      vim-fugitive
      
      # Color themes/syntax highlighting
      jellybeans-vim
      rust-vim
      vim-fish
      vim-nix
      vim-toml

      # Code/syntax completers/linters
      fzf-vim

      # Misc
      vim-commentary
      vim-easy-align
    ];

    extraConfig = builtins.readFile ./init.vim;
  };
}
