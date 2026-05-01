# containers/relational_database/

PostgreSQL 18 のサービス定義と初期化スクリプト。

## ディレクトリ構成

```
relational_database/
└── init/
    └── 001_create_schemas.sql
```

## イメージ

`postgres:18` (公式イメージをそのまま使用)

## ネットワーク

ホストには well-known port (5432) ではなく `15432` で公開する。コンテナネットワーク内では Dagster から `postgres:5432` でアクセスする。

ホストポートを well-known からずらす理由:

- ボットによる無差別スキャンの一次フィルタになる (5432 を狙う典型的なペイロードが当たらない)
- 同一ホストで PostgreSQL を別途動かすことになっても衝突しない

デバッグ時はホストから `psql -h localhost -p 15432` または `docker compose exec postgres psql` で接続する。将来的にデータを外部で参照したい場合は Dagster 経由で BigQuery 等にスナップショットを送る。

## データベース設計

1つの PostgreSQL インスタンス内でスキーマを分離する。

| スキーマ | 用途 | 作成タイミング |
|---------|------|--------------|
| dagster | Dagster メタデータ (run, event log, schedule) | Milestone 1 |
| (追加スキーマ) | アプリケーションデータ | 将来の Milestone で決定 |

複数インスタンスは立てない。スキーマ分離で論理的に分ける。

## 初期化

`containers/relational_database/init/` に SQL ファイルを配置し、Docker の `docker-entrypoint-initdb.d` マウントで自動実行する。

```sql
-- 001_create_schemas.sql
CREATE SCHEMA IF NOT EXISTS dagster;
```

## 永続化

named volume `postgres_data` を `/var/lib/postgresql/data` にマウントする。
