# containers/

Docker Compose で管理するコンテナ群の定義。

## ディレクトリ構成

```
containers/
├── compose.yaml          # 全サービスのオーケストレーション (1ファイル)
├── .env                  # 認証情報 (git 管理外)
├── .env.example          # 認証情報テンプレート (git 管理対象)
├── orchestrator/         # Dagster (webserver, daemon, code location)
├── relational_database/  # PostgreSQL
└── object_storage/       # RustFS (S3 互換 Object Storage)
```

## compose.yaml の方針

- 1ファイルで全サービスを管理する。サービス数が増えて見通しが悪くなるまで分割しない。
- 全サービスに `restart: unless-stopped` を設定し、Docker 起動時に自動復帰させる。
- 認証情報は `env_file` で `.env` から注入する。

## ポート割り当て

| サービス | ホスト公開ポート | 用途 |
|---------|----------------|------|
| dagster-webserver | 13000 | Dagster Web UI |
| dagster-daemon | なし | バックグラウンドスケジューラ |
| dagster-code-location | なし | gRPC code location サーバー |
| postgres | なし | コンテナネットワーク内のみ |
| rustfs (API) | 19000 | S3 互換エンドポイント |
| rustfs (コンソール) | 19001 | RustFS Web UI |

ホストへのポート公開は Web UI と外部アクセスが必要なサービスのみに限定する。PostgreSQL や code location サーバーはコンテナネットワーク内で完結する。

## データ永続化

named volume を使用する。

| ボリューム | 用途 |
|-----------|------|
| postgres_data | PostgreSQL データ |
| rustfs_data | RustFS オブジェクトデータ |

## 認証情報

`containers/.env.example` をテンプレートとしてコミットし、実際の `.env` は git 管理外とする。

```env
POSTGRES_USER=homelab
POSTGRES_PASSWORD=changeme
POSTGRES_DB=homelab

RUSTFS_ACCESS_KEY=homelab
RUSTFS_SECRET_KEY=changeme123
```
