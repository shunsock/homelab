# containers/orchestrator/

Dagster のカスタム Docker イメージとユーザーコード。

## ディレクトリ構成

```
orchestrator/
├── Dockerfile
├── dagster.yaml             # インスタンス設定 (ストレージバックエンド等)
├── workspace.yaml           # code location 定義
├── pyproject.toml           # Python 依存定義
├── uv.lock                  # ロックファイル
└── app/                     # ユーザーコード (asset, job, resource)
```

### ユーザーコードのディレクトリ名

`app/` という名前を採用する。短い `code/` のような名前は **避ける**。

理由: Python の `pdb` などの標準モジュールは内部で `import code` (stdlib の対話インタプリタ) を行う。`/app` を `WORKDIR` に持つコンテナでユーザーコードを `code/` という名前にすると、import 解決で `/app/code/` が stdlib の `code` を上書きしてしまい、Dagster の import チェーンが循環参照で破綻する (実装時に検証済み)。`app/` は stdlib および主要ライブラリと衝突せず、`-m app` で起動コマンドにもそのまま利用できる。

### Linux ユーザー名との衝突回避

ディレクトリ名 `app/` は WORKDIR `/app` と並ぶため、コンテナ内の Linux ユーザー名まで `app` にすると 1 語が 3 つの異なる対象 (WORKDIR / Linux ユーザー / Python モジュール) を指すことになりレビュー時の認知負荷が高い。Linux ユーザー名は **`app-user`** とし、Python モジュール名 `app` と分離する。

## Docker イメージ

### ベースイメージ

`ghcr.io/astral-sh/uv:python3.12-trixie-slim`

### ビルド方針

- マルチステージビルドを採用する。ビルドステージで依存をインストールし、ランタイムステージにコピーする。
- 非 root ユーザー (`app-user`) で実行する。
- 依存管理は `pyproject.toml` + `uv.lock` で宣言的に行う。

### サービス構成

1つの Docker イメージから command 切り替えで3つのサービスを起動する。

| サービス | command | ポート |
|---------|---------|-------|
| dagster-webserver | `dagster-webserver -h 0.0.0.0 -p 13000` | 13000 (ホスト公開) |
| dagster-daemon | `dagster-daemon run` | なし |
| dagster-code-location | `dagster code-server start -h 0.0.0.0 -p 4000 -m app` | 4000 (コンテナ内のみ) |

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

## ユーザーコード (app/)

Dagster の asset, job, resource 定義を配置する。Milestone 1 ではスケルトンのみ作成し、Milestone 2 以降で arXiv 収集パイプラインや Claude Code バッチなどを追加する。

## 担当するワークロード (将来)

| Milestone | ワークロード |
|-----------|------------|
| 2 | arXiv 論文収集 (メタデータ → PostgreSQL, PDF → RustFS) |
| 3 | Claude Code バッチ (GitHub Issue の自動処理) |
| 4 | dbt によるデータ変換 |
