# Creating a new service

The list of services and their modules is in the [services index](README.md).

`services/sample-service` is an **optional starting point**, not an obligation: each team decides how it builds its services. This guide explains how to start from it.

What does apply to every folder under `services/`, however you create it:

- **Rule H4:** a service depends only on `libs/*`, never on another service. Gradle enforces it.
- **The `mentora.servicio` plugin** gives Java 21, Spring Boot and the quality tools described in the [root README](../README.md#build-conventions). Applying it is what makes the build the same in every service.
- **This repository is public:** no secrets, AWS account IDs or real data.

## What the template includes and what it does not

| Included | Not included |
| --- | --- |
| Hexagonal layout and ArchUnit rules | Shared institution context (`tenant_id` per request): `libs/platform` is empty |
| Health checks and `dev`, `qa` and `prod` profiles | Authentication and authorization: the sample routes are open |
| OpenAPI first, with generated interfaces | Transactional outbox, event publishing and Avro code generation |
| Flyway, two database roles and row-level security | Observability setup (OpenTelemetry) and common error codes |
| Unit, component and integration tests | Contract tests against the OpenAPI |
| Docker Compose with PostgreSQL and Kafka | A `.proto` example for gRPC, and a CI pipeline that runs the tests |

Also keep in mind:

- The sample keeps its data **in memory**. The table, its security policy and their tests exist, but no repository uses them yet. If your service stores data of institutions, your repository has to set the institution in every transaction (see [Database migrations](../README.md#database-migrations)).
- The packages `infrastructure.outbox` and `interfaces.events` are empty placeholders.
- It has not been tested against RDS or Aurora.

## Start from the sample

You need JDK 21. Run the commands in **Git Bash** (or any Unix shell) from the root of the repository.

### 1. Copy and rename

`SVC` is the short name of your service: lowercase letters only, because it is also a Java package. The example uses `catalog`.

```bash
SVC=catalog
DEST=services/$SVC-service

cp -r services/sample-service $DEST
rm -rf $DEST/build

# Move the packages: ec.edu.mentora.sample -> ec.edu.mentora.<svc>
for set in main test integrationTest; do
  mv $DEST/src/$set/java/ec/edu/mentora/sample $DEST/src/$set/java/ec/edu/mentora/$SVC
done

# Update the package, the service name and the contract path inside the files
grep -rIl -e 'ec\.edu\.mentora\.sample' -e 'sample-service' $DEST |
  xargs sed -i -e "s/ec\.edu\.mentora\.sample/ec.edu.mentora.$SVC/g" -e "s/sample-service/$SVC-service/g"

# Its own local database (see step 3)
sed -i "s/\${POSTGRES_DB:mentora}/$SVC/" $DEST/src/main/resources/application-dev.yml

# Its own API contract
cp libs/contracts/openapi/sample-service.yaml libs/contracts/openapi/$SVC-service.yaml
```

There is no need to edit `settings.gradle.kts`: a folder with a `build.gradle.kts` is included automatically.

### 2. Check that it works

```bash
./gradlew :services:$SVC-service:spotlessApply :services:$SVC-service:build
./gradlew :services:$SVC-service:integrationTest     # needs Docker
```

Do this **before changing anything else**: if it passes, any later failure comes from your changes.

### 3. Create its local database

Each service owns its database. Two services must not share one: each has its own migrations and Flyway would find the history of the other. `compose.yml` creates only the database of the sample, so create yours once, with the containers running:

```bash
docker compose up -d
docker exec mentora-postgres psql -U mentora -d mentora -c "CREATE DATABASE $SVC"
docker exec mentora-postgres psql -U mentora -d $SVC \
  -c "GRANT USAGE, CREATE ON SCHEMA public TO svc_migrator" -c "GRANT USAGE ON SCHEMA public TO svc_app"
```

If you changed `POSTGRES_USER` in `.env`, use that user instead of `mentora`. The roles come from `infra/local/postgres/01-roles.sql`; if `svc_app` does not exist, see [Database migrations](../README.md#database-migrations). `docker compose down -v` deletes your database too, so you have to create it again.

Then start the service and open `http://localhost:8080/actuator/health` (add `--server.port=8081` inside `--args` if the port is taken):

```bash
./gradlew :services:$SVC-service:bootRun --args="--spring.profiles.active=dev"
```

### 4. Replace the example with your service

Change it little by little and build after each step.

| What | Where |
| --- | --- |
| Class names `SampleApplication` and `Muestra*`, and their tests | `src/*/java/ec/edu/mentora/<svc>/` |
| API contract (title, routes, schemas) | `libs/contracts/openapi/<svc>-service.yaml`; the build regenerates the interfaces |
| Domain, use cases, ports, adapters and the bean wiring | The four layers and `ConfiguracionBeans` |
| Example table | `src/main/resources/db/migration/`. In a new service, replace `V1`; after it has run in a shared environment, only add new versions. `MigracionesIT` expects version `1` |
| Isolation test | `AislamientoRlsIT` uses the table `muestra`: adapt it to your tables |
| Kafka | If you do not use it, remove `ContenedoresConfig`, its `@Import`, the Kafka test in `InfraestructuraLocalIT` and the Kafka dependency. If you do, move the dependency to `implementation` |
| Database | If you do not need one, remove the JDBC and Flyway dependencies, the `datasource` and `flyway` settings, `db` from the readiness group, the exclusions in `src/test/resources/config/application.yml`, the migrations and their tests |
| README of the service | Rewrite the copied one: purpose and owner, how to run it, variables without secrets, contracts and tests (DOC-ARQ-09 section 8.1) |

The event schema in `libs/contracts/avro` is not copied. Add yours when your service publishes events, following the [contracts README](../libs/contracts/README.md).

## Start from scratch

You can also create the folders yourself. The minimum is a `build.gradle.kts` with `plugins { id("mentora.servicio") }`. To keep the architecture checked, follow the [service layout](../README.md#service-layout-and-architecture-tests) and add `ArquitecturaHexagonalTest`: **a service without that test is not verified.**

## Tests

| Type | What it checks | Where | Class name | Example in the sample |
| --- | --- | --- | --- | --- |
| Unit | Domain and use cases, without Spring or a database | `src/test` | `*Test` | `MuestraTest`, `CasosDeUsoTest` |
| Component | The service wiring through HTTP, without a database | `src/test` | `*Test` | `MuestraApiTest`, `SaludApiTest`, `PerfilesTest` |
| Architecture | Layer rules | `src/test` | `ArquitecturaHexagonalTest` | the same |
| Integration | Real PostgreSQL and Kafka with Testcontainers | `src/integrationTest` | `*IT` | `MigracionesIT`, `AislamientoRlsIT`, `InfraestructuraLocalIT` |

```bash
./gradlew :services:<svc>-service:test                              # unit, component and architecture
./gradlew :services:<svc>-service:test --tests '*MuestraTest'       # one class
./gradlew :services:<svc>-service:integrationTest                   # integration, needs Docker
./gradlew build                                                     # everything that does not need Docker
```

- Tests use JUnit 5 and AssertJ; Mockito comes with them if you need test doubles.
- `src/test/resources/config/application.yml` starts the component tests **without a database**. When your use cases need a repository there, give the test a double of the output port.
- Integration tests use `@PruebaDeIntegracion`, which starts the whole service with the restricted database role.
- JaCoCo reports are written to `build/reports/jacoco/` after the tests.
- Checkstyle also checks the tests, including a limit of 7 collaborating classes per class.

## Common problems

| Problem | What to do |
| --- | --- |
| `PKIX path building failed` when downloading on Windows | Your network or antivirus uses its own certificate. Add `systemProp.javax.net.ssl.trustStoreType=WINDOWS-ROOT` to **your** `~/.gradle/gradle.properties`, never to the file of the repository |
| The editor does not find `...interfaces.rest...` | Those classes are generated by the build. Build once, then run "Java: Clean Java Language Server Workspace" in VS Code |
| `UnsupportedClassVersionError` with `java -jar` | Your `java` is older than 21. `./gradlew bootRun` always uses JDK 21 |
| `password authentication failed for user "svc_app"` | The local database was created before the roles. Recreate it with `docker compose down -v` (deletes local data) |
