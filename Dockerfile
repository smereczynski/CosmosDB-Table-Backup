# uv 0.12.19
FROM ghcr.io/astral-sh/uv@sha256:04d046b13e60d6bcec73cbc5e1cad25d680dea90c8573340950a0ac2d1aef424 AS uv

# Python 3.14.7 slim-bookworm
FROM python@sha256:46837ed3105db0029b6d656816185c6258e3b39690532fb782428e0a5fd76182 AS build
COPY --from=uv /uv /usr/local/bin/uv
ENV UV_PROJECT_ENVIRONMENT=/app/.venv
WORKDIR /build
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project --no-build

# Python 3.14.7 slim-bookworm
FROM python@sha256:46837ed3105db0029b6d656816185c6258e3b39690532fb782428e0a5fd76182
ENV PATH=/app/.venv/bin:$PATH \
    PYTHONPATH=/app/src \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
RUN install -d -o backup -g backup /app
COPY --from=build /app/.venv /app/.venv
COPY --chown=backup:backup src /app/src
WORKDIR /app
USER backup
CMD ["python", "-m", "cosmos_table_backup.cli"]
