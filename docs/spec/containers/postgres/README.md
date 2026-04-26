# containers/postgres/

PostgreSQL 17 のサービス定義と初期化スクリプト。

## ディレクトリ構成

```
postgres/
└── init/
    └── 001_create_schemas.sql
```

## イメージ

`postgres:17` (公式イメージをそのまま使用)

## ネットワーク

ホストへのポート公開はしない。コンテナネットワーク内で Dagster からのみアクセスする。

デバッグ時は `docker compose exec postgres psql` で接続する。将来的にデータを外部で参照したい場合は Dagster 経由で BigQuery 等にスナップショットを送る。

## データベース設計

1つの PostgreSQL インスタンス内でスキーマを分離する。

| スキーマ | 用途 | 作成タイミング |
|---------|------|--------------|
| dagster | Dagster メタデータ (run, event log, schedule) | Milestone 1 |
| (追加スキーマ) | アプリケーションデータ | 将来の Milestone で決定 |

複数インスタンスは立てない。スキーマ分離で論理的に分ける。

## 初期化

`containers/postgres/init/` に SQL ファイルを配置し、Docker の `docker-entrypoint-initdb.d` マウントで自動実行する。

```sql
-- 001_create_schemas.sql
CREATE SCHEMA IF NOT EXISTS dagster;
```

## 永続化

named volume `postgres_data` を `/var/lib/postgresql/data` にマウントする。
