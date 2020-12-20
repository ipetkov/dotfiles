{ pkgs, inputs, ... }:
{
  nixpkgs = {
    overlays = [ inputs.neovim-nightly-overlay.overlay ];
    config = {
      binaryCaches = ["https://mjlbach.cachix.org"];
      binaryCachePublicKeys = ["mjlbach.cachix.org-1:dR0V90mvaPbXuYria5mXvnDtFibKYqYc2gtl9MWSkqI="];
    };
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;

    package = pkgs.neovim-nightly;

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
