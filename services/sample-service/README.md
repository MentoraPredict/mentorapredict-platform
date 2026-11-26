# sample-service

Example of the service template, without business logic. It is an optional starting point for new services: see [Creating a new service](../CREATING-A-SERVICE.md), which also lists what the template does not include.

## What it shows

- The hexagonal layout (`domain`, `application`, `infrastructure`, `interfaces`) with ArchUnit rules.
- A controller that implements the interface generated from the OpenAPI contract.
- A migration with `tenant_id` and row-level security, run by a different database role than the service.
- Health checks and per-environment configuration.

The samples are kept **in memory**: no repository uses the database table yet.

## Run it

With Docker running, from the root of the repository:

```bash
docker compose up -d
./gradlew :services:sample-service:bootRun --args="--spring.profiles.active=dev"
```

```bash
curl -X PUT http://localhost:8080/v1/muestras/m-1 -H 'Content-Type: application/json' -d '{"nombre":"Primera"}'
curl http://localhost:8080/v1/muestras/m-1
curl http://localhost:8080/actuator/health
```

## Configuration

| Variable | Meaning | Default with the `dev` profile |
| --- | --- | --- |
| `SPRING_PROFILES_ACTIVE` | `dev`, `qa` or `prod` | none |
| `DB_URL` | PostgreSQL connection of the service | local database of `compose.yml` |
| `DB_USER`, `DB_PASSWORD` | Role of the service | local development values |
| `DB_MIGRATION_USER`, `DB_MIGRATION_PASSWORD` | Role of Flyway | local development values |
| `DB_MIGRATION_URL` | Optional direct connection for Flyway | `DB_URL` |

`qa` and `prod` have no defaults. Never commit real values.

## Contracts

- API: [`sample-service.yaml`](../../libs/contracts/openapi/sample-service.yaml).
- Example event, not published by the service: [`mp.smp.muestra.v1.avdl`](../../libs/contracts/avro/mp.smp.muestra.v1.avdl).

## Tests

```bash
./gradlew :services:sample-service:build              # no Docker needed
./gradlew :services:sample-service:integrationTest    # needs Docker
```
