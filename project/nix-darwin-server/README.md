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

## 適用後の確認 (手動)

`task apply` の適用後、各設定が反映されたことを次のコマンドで確認する。

| 確認対象 | コマンド | 期待値 |
|---|---|---|
| 電源設定 | `pmset -g` | `sleep 0` / `displaysleep 0` / `disksleep 0` / `autorestart 1` |
| アップデート設定 | `defaults read /Library/Preferences/com.apple.SoftwareUpdate` | `AutomaticCheckEnabled = 1` など。`AutomaticallyInstallMacOSUpdates = 0` |
| SSH | `systemsetup -getremotelogin` と別マシンからの `ssh <user>@<tailscale-ip>` | `Remote Login: On`、ログイン成功 |
| 画面共有 | `launchctl print system/com.apple.screensharing` と「画面共有」アプリからの接続 | ロード済み、接続成功 (初回は TCC 許可が必要) |
| Tailscale | `tailscale status` | Running (authkey 配置済みの場合) |
| ブラウザ | `brew list --cask` | `google-chrome` があり `arc` が無い |

## dotfiles の setup_server.sh との対応

dotfiles には pmset を直接叩く未配線のスクリプト (`script/entry_point/setup_server.sh`) があった。本プロジェクトではその意図を次の宣言的設定へ置き換えている。

| setup_server.sh の操作 | 本プロジェクトでの宣言 |
|---|---|
| `pmset sleep 0` / `displaysleep 0` / `disksleep 0` | `module/power.nix` の `power.sleep.* = "never"` |
| `pmset autorestart 1` | `module/power.nix` の `power.restartAfterPowerFailure = true` |
| `pmset womp 1` (Wake on LAN) | `module/power.nix` の `networking.wakeOnLan.enable = true` |
| `systemsetup -setremotelogin on` | `module/remote_access.nix` の `services.openssh.enable = true` |

## 受入基準との対応

親 Issue の受入基準と、それを満たす実装の対応は次のとおり。

| 受入基準 | 実装 |
|---|---|
| flake が build / validate を通過する | `task build` / `task validate` (CI 相当の検証はローカルで実行) |
| Tailscale 経由で SSH ログインできる | `module/host.nix` + `module/remote_access.nix` |
| リモートデスクトップとコンソールで接続できる | `module/remote_access.nix` + 初回の TCC 許可 (上記手順) |
| 自動スリープせず常時稼働する | `module/power.nix` |
| アップデートがサーバー向けポリシーで宣言管理されている | `module/software_update.nix` |
| Arc が無く Google Chrome がある | `flake.nix` の `homebrew.casks` |

## 構成

- `flake.nix` — `darwinConfigurations."homelab-server"` の定義。Homebrew casks は Google Chrome のみを導入する
- `home.nix` — home-manager 設定。シェル (bash / zsh / starship) と最小限の CLI ツールのみ
- `module/` — 機能別の nix-darwin モジュール
- `script/` — Taskfile から呼び出すエントリーポイントスクリプト
