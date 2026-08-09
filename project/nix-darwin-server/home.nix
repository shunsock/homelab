{
  pkgs,
  username,
  homeDirectory,
  lib,
  ...
}:

{
  imports = [
    ./module/bash.nix
    ./module/starship.nix
    ./module/zsh.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkForce homeDirectory;
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    gh
    git
    go-task
    nixfmt
    tree
  ];
}
