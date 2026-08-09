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

## リモートアクセス

`module/remote_access.nix` が SSH (Remote Login) と画面共有 (Screen Sharing) を有効化する。SSH は `services.openssh.enable`、画面共有は launchctl を用いた activationScript で宣言している。

### 画面共有の初回セットアップ (手動、コンソール作業)

画面共有の実接続には TCC (Transparency, Consent, and Control) の許可が必要で、これは CLI や Nix からは付与できない。初回のみ、物理コンソール (ディスプレイとキーボードを直接接続) で次を行うこと。

1. システム設定 > プライバシーとセキュリティ > 画面収録 を開き、必要な権限を許可する
2. リモートから macOS 標準の「画面共有」アプリで Tailscale IP へ接続し、接続できることを確認する

### コンソールアクセスの前提

コンソールアクセスは物理的なディスプレイ・キーボード接続そのものであり、Nix 宣言の対象外である。macOS は初期状態でローカルコンソールログインを許可しているため追加設定は不要だが、初回セットアップ (上記 TCC 許可と `task init` / `task apply`) にはコンソール作業が必要になる。

## 構成

- `flake.nix` — `darwinConfigurations."homelab-server"` の定義。Homebrew casks は Google Chrome のみを導入する
- `home.nix` — home-manager 設定。シェル (bash / zsh / starship) と最小限の CLI ツールのみ
- `module/` — 機能別の nix-darwin モジュール
- `script/` — Taskfile から呼び出すエントリーポイントスクリプト
