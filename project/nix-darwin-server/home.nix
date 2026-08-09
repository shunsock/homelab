{
  config,
  pkgs,
  username,
  homeDirectory,
  lib,
  ...
}:

{
  imports = [
    ./module/bash.nix
    ./module/claude.nix
    ./module/skk.nix
    ./module/starship.nix
    ./module/wezterm.nix
    ./module/zsh.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkForce homeDirectory;
  home.stateVersion = "23.11";

  # フォント設定
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    claude-code
    dotnet-sdk_10
    gh
    git
    go-task
    hackgen-nf-font
    nixfmt
    tree
  ];

  # docker compose / docker buildx (v2 サブコマンド) の CLI プラグイン登録。
  # Homebrew の docker-compose / docker-buildx は単体バイナリを置くのみで
  # `docker compose` / `docker build` (buildx バックエンド) から認識されないため、
  # ~/.docker/cli-plugins/ に brew の opt パスを symlink する。
  # 手動で張ると Docker Desktop 削除時の zap で ~/.docker ごと消えるため、
  # home-manager 管理にして再現性を担保する (opt パスはバージョン非依存)。
  home.file.".docker/cli-plugins/docker-compose".source =
    config.lib.file.mkOutOfStoreSymlink "/opt/homebrew/opt/docker-compose/bin/docker-compose";
  home.file.".docker/cli-plugins/docker-buildx".source =
    config.lib.file.mkOutOfStoreSymlink "/opt/homebrew/opt/docker-buildx/bin/docker-buildx";
}
