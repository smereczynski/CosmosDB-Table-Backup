# Cosmos DB Table Backup

Application-level backups for an Azure Cosmos DB Table API account, isolated in a dedicated Azure subscription. The service discovers all tables on every run, excludes the exact table name `cards`, streams entities into typed encrypted objects, and commits an encrypted manifest last.

## Security model

- Managed identity only; no account keys, SAS tokens, or client secrets.
- Private Link for Cosmos Table, Blob, Key Vault, and ACR.
- No VNet peering or dependency on production networking.
- Per-run AES-256-GCM data encryption; the DEK is wrapped by an HSM-backed Key Vault RSA key using RSA-OAEP-256.
- Backup identity can wrap but cannot unwrap keys.
- Blob public and shared-key access are disabled; backups are immutable for seven days and lifecycle-eligible after 14 days.
- The encrypted manifest is the only successful-run marker.

## Repository

- `src/cosmos_table_backup/` — Python 3.14 backup job.
- `tests/` — unit and format-contract tests.
- `infra/` — Bicep/AVM deployment stacks.
- `scripts/` — read-only preflight and operational validation helpers.
- `.github/workflows/` — validation and OIDC deployment workflows.
- `docs/` — backup format, operations, security, and deployment guidance.

## Local development

```bash
uv sync --frozen --all-extras
uv run ruff format --check .
uv run ruff check .
uv run mypy src
uv run pytest
```

The runtime configuration is environment-based. See `docs/operations.md` and `src/cosmos_table_backup/config.py` for the authoritative settings.

## Infrastructure validation

```bash
az bicep restore --file infra/main.bicep
az bicep build --file infra/main.bicep
./scripts/preflight.sh
```

Deployments use separate GitHub environments and federated identities for infrastructure, source integration, and immutable image release. See [Deployment and CI/CD](docs/deployment.md) for the OIDC bootstrap, required variables, promotion, rollback, and production-fork procedure. Never grant a runtime identity deployment permissions.

## Scope

Phase 1 implements daily backups. Phase 2 adds guarded restore tooling and a dormant-by-default monthly validation job targeting a separate private, keyless Cosmos Table account. Backup and restore schedules remain disabled until their respective acceptance gates pass.

## Code Review
