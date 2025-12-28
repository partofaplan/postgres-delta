# Postgres HA Helm Chart

Highly available PostgreSQL 16 powered by Patroni and the Spilo image. The chart provisions a primary with streaming replicas, automatic failover, and a post-upgrade hook that applies configuration changes via the Patroni API so PostgreSQL reloads without restarts.

## Features
- Patroni-managed primary/replica topology with streaming replication and automatic failover
- Read/write (`-primary`) and read-only (`-replica`) Services plus a headless service for stable DNS
- Dynamic configuration updates: change `patroni.postgresql.parameters` and run `helm upgrade` to apply via Patroni without downtime
- PodDisruptionBudget and soft anti-affinity to keep quorum during maintenance
- RBAC + dedicated ServiceAccount; REST API secured with basic auth

## Quick start
```bash
# create a namespace (if needed)
kubectl create namespace db || true

# install
helm install perkinzk-db ./postgres-ha --namespace db
```

Key endpoints after install (with release name `perkinzk-db`):
- Primary (read/write): `perkinzk-db-postgres-ha-primary:5432`
- Replicas (read-only): `perkinzk-db-postgres-ha-replica:5432`
- Patroni API: port `8008` on each pod or via the services above

To connect locally:
```bash
kubectl -n db port-forward svc/perkinzk-db-postgres-ha-primary 5432:5432
psql "postgresql://postgres:PerkinzkSecure42@127.0.0.1:5432/postgres"
```

Update these via `values.yaml` before installing in a real cluster.

## Zero-downtime config updates
1. Edit `values.yaml` (or a custom values file) and change `patroni.postgresql.parameters` or `patroni.synchronousMode`.
2. Run `helm upgrade <release> ./postgres-ha -f <your-values>.yaml`.
3. The `post-install,post-upgrade` job `(<release>-postgres-ha-apply-config)` patches the Patroni API with the rendered config map and triggers a PostgreSQL reload—no pod restarts required.

## Operational notes
- Default `replicaCount` is 3; keep it ≥3 for reliable leader election and failover.
- Services expose port `5432` for Postgres and `8008` for the Patroni API. Health checks also use the API.
- Storage defaults to `10Gi` `ReadWriteOnce` PVCs; set `storage.storageClassName` to target a specific class.

## Validation
- `helm lint ./postgres-ha` (already run locally)
