{ pkgs, ... }:
{
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [ vim-lastplace vim-nix ]; 
          opt = [ nerdtree ];
        };
        customRC = builtins.readFile /home/zygot/.config/nvim/init.vim;
      };
    }
  )];
}
