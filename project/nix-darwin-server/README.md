# nix-darwin-server

macOS (Apple Silicon) を自宅サーバーとして常時稼働させるための nix-darwin 構成。`shunsock/dotfiles` の `nix-darwin/` をベースに、サーバー用途へ調整している。

## 前提条件

- 対象マシンは Apple Silicon の macOS であること
- Nix がインストール済みであること (`task init` は nix-darwin の導入のみを行う)
- Tailscale の authkey を `/etc/tailscale/authkey` へ手動で配置すること (発行は Tailscale 管理画面から行う)

## 使い方

| コマンド | 説明 |
|---|---|
| `task init` | Homebrew と nix-darwin を導入する (初回のみ) |
| `task apply` | 構成をビルドして適用する (sudo が必要) |
| `task build` | 適用せずビルドのみ行う |
| `task validate` | build と `nix flake check` をまとめて実行する |
| `task format` | Nix ファイルを整形する |
| `task update` | flake の依存を更新する |
| `task gc` | 30 日より古い Nix store 世代を削除する |

`task apply` は `darwin-rebuild switch` を含むため sudo を要求する。CI や Claude などの非対話環境からは実行できないので、コンソールまたは SSH セッションから手動で実行すること。

## 構成

- `flake.nix` — `darwinConfigurations."homelab-server"` の定義。Homebrew casks は Google Chrome のみを導入する
- `home.nix` — home-manager 設定。シェル (bash / zsh / starship) と最小限の CLI ツールのみ
- `module/` — 機能別の nix-darwin モジュール
- `script/` — Taskfile から呼び出すエントリーポイントスクリプト
