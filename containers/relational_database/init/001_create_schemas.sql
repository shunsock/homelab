-- Dagster's run / event-log / schedule storage lives here.
-- Referenced by docs/spec/containers/orchestrator/ via dagster.yaml's
-- `params.options: -c search_path=dagster`.
CREATE SCHEMA IF NOT EXISTS dagster;
