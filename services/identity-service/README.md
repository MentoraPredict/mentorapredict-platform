# identity-service

The module A identity service will orchestrate institutional access methods,
roles and identity policies. Keycloak is responsible for authentication and
issuing tokens. This initial foundation exposes only operational health endpoints;
it does not implement login, authorization, domain persistence or Keycloak integration.

## Run locally

Requirements: JDK 21 and a running Docker Desktop. From the repository root:

```powershell
docker compose up -d identity-postgres
.\gradlew.bat :services:identity-service:bootRun --args="--spring.profiles.active=dev"
```

In another terminal, check `http://localhost:8080/actuator/health` and the
`/actuator/health/liveness` and `/actuator/health/readiness` probes. The base
requires PostgreSQL but not a broker. The local database uses a separate volume
from the existing development PostgreSQL and from Keycloak. Its host port is
`5433` by default; set `IDENTITY_DB_PORT` in `.env` to change it.

Flyway connects as `idn_migrator` and prepares the `idn` schema; the application
connects as `idn_app` and cannot create schema objects or bypass row security.
No business tables are created yet. The local passwords are only for development.
QA and production must supply `DB_URL`, `DB_USER`, `DB_PASSWORD`,
`DB_MIGRATION_USER` and `DB_MIGRATION_PASSWORD` through their environment;
`DB_MIGRATION_URL` is optional. Do not commit real credentials.
The migration grants access to the PostgreSQL role `idn_app`, which must exist
before Flyway runs. The migration role must be allowed to create the `idn`
schema. Database and role provisioning outside local development is separate.

## Build and run with Docker Compose

From the repository root, with Docker running:

```powershell
docker compose up -d --build identity-service
Invoke-RestMethod http://localhost:8081/actuator/health
docker compose logs identity-service
docker compose stop identity-service
```

The service is exposed on port `8081` by default; set `IDENTITY_PORT` in the
local `.env` file to use another host port. Compose waits for the dedicated
PostgreSQL container; Kafka is not required. The Dockerfile builds from the repository root because the Gradle
wrapper, convention plugins and shared libraries live there. It runs the
application as a non-root user.

## Tests and contracts

```powershell
.\gradlew.bat :services:identity-service:build
.\gradlew.bat :services:identity-service:integrationTest
```

The shared identity contracts are indexed in [libs/contracts](../../libs/contracts/README.md).
They are not implemented by this foundation. Federated login, identity policies,
Keycloak and deployment to AWS are covered by separate tasks.

## Local Swagger UI

With the `dev` profile, open `http://localhost:8081/swagger-ui.html` when using
Compose, or `http://localhost:8080/swagger-ui.html` when running Gradle locally.
The generated OpenAPI document is available at `/v3/api-docs` and currently
describes operational Actuator routes only; the service has no business API yet.
The UI and generated documents are disabled by default, including QA and prod.
The module A public REST contract belongs to the `tenant-service` facade; this
local operational documentation is not that public contract.
