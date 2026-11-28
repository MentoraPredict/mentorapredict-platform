# identity-service

The module A identity service will orchestrate institutional access methods,
roles and identity policies. Keycloak is responsible for authentication and
issuing tokens. This initial foundation exposes only operational health endpoints;
it does not implement login, authorization, persistence or Keycloak integration.

## Run locally

Requirements: JDK 21. From the repository root:

```powershell
.\gradlew.bat :services:identity-service:bootRun --args="--spring.profiles.active=dev"
```

In another terminal, check `http://localhost:8080/actuator/health` and the
`/actuator/health/liveness` and `/actuator/health/readiness` probes. The base
does not require a database or broker. The `dev`, `qa` and `prod` profiles set
logging levels; do not commit secrets when adding future integrations.

## Build and run with Docker Compose

From the repository root, with Docker running:

```powershell
docker compose up -d --build identity-service
Invoke-RestMethod http://localhost:8081/actuator/health
docker compose logs identity-service
docker compose stop identity-service
```

The service is exposed on port `8081` by default; set `IDENTITY_PORT` in the
local `.env` file to use another host port. It does not yet depend on PostgreSQL
or Kafka. The Dockerfile builds from the repository root because the Gradle
wrapper, convention plugins and shared libraries live there. It runs the
application as a non-root user.

## Tests and contracts

```powershell
.\gradlew.bat :services:identity-service:build
```

The shared identity contracts are indexed in [libs/contracts](../../libs/contracts/README.md).
They are not implemented by this foundation. Federated login, identity policies,
Keycloak and deployment to AWS are covered by separate tasks.
