# containers/dagster/

Dagster のカスタム Docker イメージとユーザーコード。

## ディレクトリ構成

```
dagster/
├── Dockerfile
├── dagster.yaml          # インスタンス設定 (ストレージバックエンド等)
├── workspace.yaml        # code location 定義
├── pyproject.toml        # Python 依存定義
├── uv.lock               # ロックファイル
└── code/                 # ユーザーコード (asset, job, resource)
```

## Docker イメージ

### ベースイメージ

`ghcr.io/astral-sh/uv:python3.12-trixie-slim`

### ビルド方針

- マルチステージビルドを採用する。ビルドステージで依存をインストールし、ランタイムステージにコピーする。
- 非 root ユーザー (app) で実行する。
- 依存管理は `pyproject.toml` + `uv.lock` で宣言的に行う。

### サービス構成

1つの Docker イメージから command 切り替えで3つのサービスを起動する。

| サービス | command | ポート |
|---------|---------|-------|
| dagster-webserver | `dagster-webserver -h 0.0.0.0 -p 13000` | 13000 (ホスト公開) |
| dagster-daemon | `dagster-daemon run` | なし |
| dagster-code-location | `dagster code-server start -h 0.0.0.0 -p 4000` | 4000 (コンテナ内のみ) |

## dagster.yaml

PostgreSQL をストレージバックエンドとして使用する。接続情報は環境変数から注入する。

```yaml
storage:
  postgres:
    postgres_db:
      hostname: postgres
      username:
        env: POSTGRES_USER
      password:
        env: POSTGRES_PASSWORD
      db_name:
        env: POSTGRES_DB
      params:
        options: "-c search_path=dagster"
```

## workspace.yaml

code location サーバーへの gRPC 接続を定義する。

```yaml
load_from:
  - grpc_server:
      host: dagster-code-location
      port: 4000
      location_name: "homelab"
```

## ユーザーコード (code/)

Dagster の asset, job, resource 定義を配置する。Milestone 1 ではスケルトンのみ作成し、Milestone 2 以降で arXiv 収集パイプラインや Claude Code バッチなどを追加する。

## 担当するワークロード (将来)

| Milestone | ワークロード |
|-----------|------------|
| 2 | arXiv 論文収集 (メタデータ → PostgreSQL, PDF → RustFS) |
| 3 | Claude Code バッチ (GitHub Issue の自動処理) |
| 4 | dbt によるデータ変換 |
