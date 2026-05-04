# containers/object_storage/

S3 互換 Object Storage。論文 PDF などのバイナリデータを格納する。

## 選定理由

当初 MinIO を検討していたが、2026-04-25 にリポジトリがアーカイブされたため RustFS を採用した。

- S3 100% 互換
- Apache License 2.0
- MinIO からのバイナリ置き換え移行が可能
- Docker イメージが公式で提供されている

## イメージ

`rustfs/rustfs:latest` (公式イメージ)

## ポート

| ポート | ホスト | コンテナ | 用途 |
|-------|-------|---------|------|
| 19000 | 19000 | 9000 | S3 互換 API エンドポイント |
| 19001 | 19001 | 9001 | Web コンソール |

## 起動コマンド

データディレクトリのパスのみを引数として渡す。MinIO の `server ... --console-address ...` 形式とは異なり、コンソールアドレスやアクセスキーなどはすべて環境変数で設定する。

```yaml
command: /data
```

## 認証情報

環境変数で注入する。`.env` に以下を設定する。

| 環境変数 | 説明 |
|---------|------|
| RUSTFS_ACCESS_KEY | S3 互換アクセスキー (管理者) |
| RUSTFS_SECRET_KEY | S3 互換シークレットキー (管理者) |

公式の既定値は `rustfsadmin` / `rustfsadmin` だが、本番値は必ず差し替える。

## 永続化

named volume `rustfs_data` を `/data` にマウントする。

## 既知の制約

- コンテナは uid `10001` で動作する。named volume を使う場合 Docker が自動的に root 所有でボリュームを作成するため、書き込み権限エラーが発生する可能性がある。発生した場合は permission-fixer の helper service ([公式 simple compose](../../../reference/rustfs/README.md) 参照) を追加する。

## 参考文献

- [docs/reference/rustfs/README.md](../../../reference/rustfs/README.md)

## 用途 (将来)

| Milestone | 用途 |
|-----------|------|
| 2 | arXiv 論文 PDF の格納 |
