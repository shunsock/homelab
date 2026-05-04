# syntax=docker/dockerfile:1

# Builder: install dependencies into /app/.venv using uv against the locked
# pyproject.toml + uv.lock. Kept separate from the runtime stage so the final
# image does not carry the uv binary or build tooling.
FROM ghcr.io/astral-sh/uv:python3.12-trixie-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Runtime: same Debian (trixie) + Python (3.12) base as the uv builder image
# so the venv from the builder stage is binary-compatible.
FROM python:3.12-slim-trixie AS runtime

# Linux user is `app-user` (not `app`) to keep it distinct from WORKDIR `/app`
# and the Python module `app/` — see docs/spec/containers/orchestrator/.
# Fixed uid/gid 1000 to match the typical host user, which keeps any future
# bind mounts of app/ readable from the host without permission gymnastics.
RUN groupadd --system --gid 1000 app-user \
 && useradd --system --uid 1000 --gid app-user --create-home app-user

# /app is created by WORKDIR as root-owned by default. Chown it to app-user
# so dagster (running as DAGSTER_HOME=/app) can write its telemetry/log dirs.
WORKDIR /app
RUN chown app-user:app-user /app

COPY --from=builder --chown=app-user:app-user /app/.venv /app/.venv
COPY --chown=app-user:app-user app ./app

# PYTHONPATH=/app makes `dagster code-server start -m app` resolve the user
# code regardless of where the dagster CLI is invoked from.
ENV PATH="/app/.venv/bin:${PATH}" \
    PYTHONPATH=/app \
    PYTHONUNBUFFERED=1

USER app-user
