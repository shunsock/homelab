# RustFS 参考文献

`containers/object_storage/` (RustFS) を構築・運用するうえで根拠とした一次情報をここに集約する。仕様判断の出典が必要になったとき、まずこのファイルを起点にする。

## 公式ドキュメント

- [Installing RustFS with Docker](https://docs.rustfs.com/installation/docker/) — 単一ノード Docker 起動例の正典。`docker run` と `docker-compose` 双方の最小構成、必要な環境変数 (`RUSTFS_ACCESS_KEY` / `RUSTFS_SECRET_KEY`)、データディレクトリの渡し方 (`command: /data`) が記載されている。
- [RustFS Documentation トップ](https://docs.rustfs.com/) — その他の運用トピック (TLS, 分散構成など) の入口。

## 公式リポジトリ

- [rustfs/rustfs](https://github.com/rustfs/rustfs) — 本体リポジトリ。
- [docker-compose-simple.yml](https://github.com/rustfs/rustfs/blob/main/docker-compose-simple.yml) — 公式が提供する単一ノード compose の正本。permission-fixer helper service (uid `10001` でボリューム所有権を補正する) の実装例として参照する。
- [docker-compose.yml](https://github.com/rustfs/rustfs/blob/main/docker-compose.yml) — 4 ボリューム + observability まで含むフル構成。
- [Discussion #333: 環境変数一覧の要望](https://github.com/orgs/rustfs/discussions/333) — 公式が現状 README で網羅していない環境変数についての議論。新しい環境変数を使うときは Dockerfile / ソースコードを当たる必要があることが分かる。

## Docker Hub

- [rustfs/rustfs](https://hub.docker.com/r/rustfs/rustfs) — 配布イメージ。タグ運用方針 (`latest` ほか) はここで確認する。

## 採用判断の背景

- [docs/spec/containers/object_storage/README.md](../../spec/containers/object_storage/README.md) — MinIO がアーカイブされた経緯と RustFS 採用理由をスペック側に記載済み。
</content>
</invoke>