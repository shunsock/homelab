# containers/object_storage/

S3 互換 Object Storage。論文 PDF などのバイナリデータを格納する。

## 選定理由

当初 MinIO を検討していたが、2026-04-25 にリポジトリがアーカイブされたため RustFS を採用した。

- S3 100% 互換
- Apache License 2.0
- MinIO からのバイナリ置き換え移行が可能
- Docker イメージが公式で提供されている

## イメージ

`rustfs/rustfs` (公式イメージ)

## ポート

| ポート | ホスト | コンテナ | 用途 |
|-------|-------|---------|------|
| 19000 | 19000 | 9000 | S3 互換 API エンドポイント |
| 19001 | 19001 | 9001 | Web コンソール |

## 認証情報

環境変数で注入する。`.env` に以下を設定する。

| 環境変数 | 説明 |
|---------|------|
| RUSTFS_ROOT_USER | 管理者ユーザー名 |
| RUSTFS_ROOT_PASSWORD | 管理者パスワード |

## 永続化

named volume `rustfs_data` を `/data` にマウントする。

## 用途 (将来)

| Milestone | 用途 |
|-----------|------|
| 2 | arXiv 論文 PDF の格納 |
