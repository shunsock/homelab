{
  description = "Flake for macOS homelab server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";

      username = "shunsock";
      homeDirectory = "/Users/${username}";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      # HACK: 引数なしの `nix fmt` に対する nixfmt の stdin 待ちを避ける。
      # 対象配下の .nix を列挙して nixfmt へ渡すラッパーを formatter とする。
      formatter.${system} = pkgs.writeShellApplication {
        name = "nixfmt-tree";
        runtimeInputs = [
          pkgs.nixfmt
          pkgs.findutils
        ];
        text = ''
          if [ "$#" -eq 0 ]; then
            set -- .
          fi
          find "$@" -type f -name '*.nix' -print0 | xargs -0 -r nixfmt
        '';
      };

      darwinConfigurations."homelab-server" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          {
            system.stateVersion = 4;
            system.primaryUser = username;
            nixpkgs.config.allowUnfree = true;
            ids.gids.nixbld = 350;

            # CONSTRAINT: experimental-features は恒久設定しなくてはならない。
            # REASON: apply 後にフラグ指定なしで nix コマンドを使うため。
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          }

          ./module/host.nix
          ./module/power.nix
          ./module/software_update.nix

          {
            homebrew = {
              enable = true;
              onActivation = {
                # CONSTRAINT: casks の cleanup は zap でなくてはならない。
                # REASON: brew 導入物を Nix で一元管理し、関連ファイルまで消すため。
                cleanup = "zap";
                autoUpdate = true;
                upgrade = false;
                # CONSTRAINT: --force-cleanup を明示しなくてはならない。
                # REASON: Homebrew 5.1 以降、破壊的な cleanup は明示承認を要求するため。
                extraFlags = [ "--force-cleanup" ];
              };
              casks = [
                "google-chrome"
              ];
            };
          }

          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit username;
                inherit homeDirectory;
              };

              users.${username} = import ./home.nix;

              backupFileExtension = "hm-backup";
            };
          }
        ];
      };
    };
}
