# MentoraPredict

MentoraPredict is a school management platform for Ecuadorian schools (basic and high school education) built around a virtual classroom. It connects what happens in class with grades, attendance, family communication and student welfare, and uses those signals to warn teachers and counselors about students at risk of dropping out, before it happens.

This repository, **mentorapredict-services**, holds the server side of the platform: the microservices, the shared contracts, the risk inference code and the infrastructure as code. The client applications live in [`mentorapredict-clients`](https://github.com/MentoraPredict/mentorapredict-clients).

> MentoraPredict is an academic project of the Universidad Central del Ecuador (Distributed Programming course). It is not launched as a commercial product.

## Overview

MentoraPredict puts the daily work of teachers and students in one place. Teachers publish materials, assignments and quizzes; students hand in work and read feedback; families follow progress; and the institution closes academic periods, issues official report cards and follows the rules of the Ministry of Education by configuration.

The platform is modular: each institution activates only the modules it needs (enrollment, grading, attendance, communication, student welfare, early warning, analytics, tuition, coexistence, technical high school, and more). The virtual classroom is the core, and everything else connects to it.

## Problem Statement

In Ecuadorian schools, dropout and low performance are rarely sudden. They are a process whose signals already exist inside the institution, but scattered: accumulated absences, falling grades, behavior changes, late tuition payments and family context known by the counseling team. When someone puts these signals together, the student has usually stopped attending.

School management is fragmented:

- Grades live in spreadsheets or notebooks, and report cards are built by hand.
- Attendance is found late, so the regulatory absence threshold is crossed without warning.
- Families are contacted through personal messaging groups, with no traceability and with exposure of minors' data.
- Counseling files are kept on paper, without systematic follow-up or alerts.
- Assignments and materials are spread across messaging groups, email and external classrooms, and none of that reaches grades, families or alerts.
- Regulation changes are noticed late, and handling minors' data without controls is costly under the Ecuadorian data protection law (LOPDP).

## System Objective

Digitalize the full academic cycle of an institution and use its data to detect academic risk early. In short:

1. Digitalize enrollment, grading, attendance and official documents in each institution.
2. Apply the rules of the Ministry of Education by configuration, so report cards are never issued with an outdated calculation rule.
3. Detect risk of dropout or low performance early enough to intervene, with explainable alerts that a person reviews.
4. Protect the data of minors: access is controlled by role and every access to personal data is audited.
5. Work for institutions with limited connectivity: essential operations can be completed offline.
6. Make the virtual classroom the daily workplace, with its results connected to grades, notices and early warning.
7. Keep the product up to date with regulation, always with a human decision.

## Architecture Overview

The server side is a set of **29 microservices** (Java 21 and Spring Boot) organized as a Gradle multiproject monorepo. The services are split into three work modules (A, B and C) that are developed separately and integrate only through events and asynchronous commands.

- **Service design:** hexagonal structure (`domain`, `application`, `infrastructure`, `interfaces`), verified with ArchUnit. A service depends only on `libs/*`, never on another service.
- **Communication:** each module exposes one REST facade (`tenant-service`, `people-service` and `classroom-service`) and talks to its own services with gRPC. Between modules there are no synchronous calls: only Kafka, RabbitMQ and MQTT messages.
- **Contracts:** OpenAPI, Avro and gRPC definitions live in `libs/contracts`. The clients generate their types from the same files.
- **Data:** PostgreSQL with multi-tenancy by institution (row level security). Each database cluster serves services of a single module.
- **Identity:** Keycloak (OIDC and OAuth 2) with optional federation to each institution's identity system or Active Directory.
- **Delivery:** Terraform for infrastructure, Kubernetes (EKS) for runtime and Argo CD for GitOps. Observability uses OpenTelemetry, with the module as a label on every metric, log and trace.
- **Machine learning:** the risk inference service and the data analysis code are written in Python and live in `ml/`.

## Core Platform Capabilities

| Capability | What it does |
| --- | --- |
| Virtual classroom (core) | Classrooms per subject, section and period; units and content; assignments with feedback; quizzes; announcements; activity signals for early warning |
| Institutional core | Institutions, users and roles, people and guardians, academic structure, schedules and audit trail |
| Enrollment | Admission, quotas and enrollment |
| Grading and promotion | Grades, averages, period closing, report cards, certificates and promotion rules |
| Attendance | Per-class records, justifications and absence thresholds |
| Early warning | Academic and behavioral risk, kept separate, with alerts that explain their reasons and are reviewed by a person |
| Communication | Notices, scheduled summons to guardians with confirmation, reminders and contact preferences |
| Student welfare | Counseling cases, automatic referrals and confidential follow-up |
| Coexistence | Behavior code of each institution, due process, sanctions and educative measures, kept apart from academic performance |
| Analytics and reports | Dashboards, official reports and exports |
| Tuition and finance | Charges, late payments and reconciliation with payment gateways |
| Integrations and identity | Ministry of Education and tax integrations, messaging providers, federated login and Active Directory |
| Regulation watch | Internal tool that follows regulation changes and proposes adjustments for a person to decide |
| Technical high school | Project-based learning, training modules, practices and competency assessment for technical specialties |

## Vision

A school where the information that already exists stops being scattered. Teachers work in a classroom that feeds grades, notices and alerts by itself. Families know what happens, when it happens. Counselors receive the right signals, with the reasons behind them, while there is still time to help. And the institution complies with the rules by default, protecting the data of minors.

The prediction supports people, it never replaces them: every alert is explainable and reviewed by a person before any action is taken.

---

# Repository

## Structure

```text
mentorapredict-services/
├── settings.gradle.kts        includes every subproject
├── gradle/libs.versions.toml  single version catalog
├── build-logic/               Gradle convention plugins (mentora.calidad, mentora.servicio, mentora.biblioteca)
├── config/checkstyle/         shared Checkstyle rules
├── libs/
│   ├── contracts/             OpenAPI, Avro and gRPC (contracts between services)
│   ├── arch-rules/            ArchUnit rules of the hexagonal architecture (H1, H2, H3, H8, H10)
│   └── platform/              multi-tenancy, outbox, observability and errors
├── services/<svc>-service/    one Gradle subproject per service (29)
├── ml/                        risk inference and data analysis (Python)
├── extensions/keycloak-spi/   Keycloak extensions
├── infra/                     Terraform (QA and production)
└── gitops/                    manifests read by Argo CD
```

Rules:

- A service can only depend on `libs/*`, never on another service.
- Every folder under `services/` or `libs/` that has a `build.gradle.kts` becomes a Gradle subproject automatically; there is no need to edit `settings.gradle.kts`.
- Do not commit secrets, AWS account IDs or real data: **this repository is public**. Secrets live in AWS Secrets Manager.

### Service layout and architecture tests

Every service uses the same hexagonal layout under `ec.edu.mentora.<svc>`. `services/sample-service` is a working example of it: you can copy it to start a service, but you do not have to. You can also create the folders by hand or in your IDE, as long as the layout below is respected:

```text
ec.edu.mentora.<svc>/
├── Application, config     Spring entry point and composition of beans (the only place that knows adapters and use cases)
├── domain/                 entities, value objects, domain services, domain events and errors (no framework)
├── application/            use cases
│   └── port/
│       ├── in/             input ports: use case interfaces and their commands
│       └── out/            output ports: what the service needs from the outside
├── infrastructure/         output adapters: repositories, Kafka, HTTP clients, cache
│   └── outbox/             transactional outbox and its relay
└── interfaces/             input adapters: REST controllers, request and response objects, error translation
    └── events/             event consumers
```

A request goes `interfaces` (controller) → `application.port.in` (use case) → `domain`, and the use case reaches the outside through `application.port.out`, implemented in `infrastructure`. The domain and the use cases carry no Spring annotations; they are wired in the composition root.

Every package has a `package-info.java` with `@NullMarked`, so NullAway checks it. Nothing else may live under the root package: `util` or `common` packages are rejected.

The rules of DOC-CAL-08 section 3 are ArchUnit tests that live in `libs/arch-rules` and run with `./gradlew build`. A violation fails the build.

| Rule | What it forbids |
| --- | --- |
| H1 | `domain` importing other layers or any framework: Spring, Jakarta (persistence, validation, annotations), Jackson, Hibernate, jOOQ, cloud SDKs or Kafka |
| H2 | `application` importing `infrastructure` or `interfaces` |
| H3 | `infrastructure` and `interfaces` importing each other |
| H8 | cycles between the layers |
| H10 | `domain` reading the clock or random sources directly (`Instant.now()`, `UUID.randomUUID()`, `Math.random()`, `System.currentTimeMillis()` and similar); inject a `Clock` or an identifier source instead |
| Layout | any package under the service root other than the four layers |

H4 is checked by Gradle (see the convention plugins) and H5 to H7 and H9 are not covered by these tests yet.

The rules only check a service that includes the test below: a service that does not add it is not verified. Add it to every new service, whether you started from `sample-service` or not:

```kotlin
// services/<svc>-service/build.gradle.kts
dependencies {
    testImplementation(project(":libs:arch-rules"))
}
```

```java
@AnalyzeClasses(
    packages = "ec.edu.mentora.<svc>",
    importOptions = ImportOption.DoNotIncludeTests.class)
class ArquitecturaHexagonalTest {
  @ArchTest static final ArchTests hexagonal = ArchTests.in(HexagonalRules.class);
}
```

`libs/arch-rules` has its own tests with deliberately broken fixtures, so each rule is proven to fail when it should.

## Requirements

| Tool | Used for |
| --- | --- |
| Git | Cloning and working with branches |
| JDK 21 | Building and running the services (set `JAVA_HOME` to it) |
| Gradle | Comes with the wrapper (`./gradlew`); no installation needed |
| Docker | Local environment with Docker Compose (development only) |
| Python 3.12 or later and `uv` | `ml/` only |

## Getting started

```bash
git clone https://github.com/MentoraPredict/mentorapredict-services.git
cd mentorapredict-services
git checkout dev
```

Check the setup with `./gradlew build`. Work branches start from `dev`. Before opening your first pull request, read the [contributing guide](CONTRIBUTING.md).

## Local environment

`compose.yml` starts the infrastructure a service needs on your machine: PostgreSQL 17 and Kafka (single node, KRaft). You need Docker running. The group is named `mentora-local` and its containers `mentora-postgres` and `mentora-kafka`, so you do not need `-p` or any other option: `docker compose up -d` is enough.

```bash
docker compose up -d                          # PostgreSQL on localhost:5432 and Kafka on localhost:9092
./gradlew :services:sample-service:bootRun --args="--spring.profiles.active=dev"
docker compose down                           # stop them (add -v to delete the data too)
```

`sample-service` needs the database to start, so run it with the `dev` profile (see below). The values in `compose.yml` are for local development only and are not secrets (administrator, password and database are all `mentora`; the roles of the service are in [Database migrations](#database-migrations)). To change a port or a value, copy `.env.example` to `.env`; `.env` is ignored by git. Never commit real passwords: **this repository is public**.

### Integration tests with Testcontainers

Unit and component tests run with `./gradlew build` and do not need Docker. Tests that need a real database or broker live in `src/integrationTest` of the service and run with:

```bash
./gradlew integrationTest
```

[Testcontainers](https://testcontainers.com) starts a throwaway PostgreSQL and Kafka from the test itself, on random ports, and removes them when it finishes. There is nothing to configure and they do not clash with the containers of `compose.yml`: Kafka uses `@ServiceConnection`, and PostgreSQL gets the same roles as `compose.yml`, so the tests run with the restricted role of the service. The `mentora.servicio` plugin sets up the `integrationTest` source set and the Testcontainers dependencies; `services/sample-service` shows how to use them (`PruebaDeIntegracion`, `PostgresPorRoles`, `ContenedoresConfig` and the `*IT` classes). They are not part of `./gradlew build` on purpose, so a clone with only JDK 21 still builds. The CI pipeline will need to run `integrationTest` too (the G1 gate is a separate task).

## Configuration and health checks

`services/sample-service` shows how every service is configured. `src/main/resources/application.yml` holds what is common to all environments (including Java 21 virtual threads), and `application-dev.yml`, `application-qa.yml` and `application-prod.yml` add or replace values for each one. Choose the environment with the Spring profile, either with the `SPRING_PROFILES_ACTIVE` variable or like this:

```bash
./gradlew :services:sample-service:bootRun --args="--spring.profiles.active=dev"
```

No profile is active by default. **This repository is public**: never write passwords, tokens or AWS account IDs in these files; sensitive values come from environment variables, such as `${DB_PASSWORD}`.

[Spring Boot Actuator](https://docs.spring.io/spring-boot/reference/actuator/) provides the health checks (DOC-INF-03 section 5.4). They are routes for the platform, not part of the business API, so they have no `/v1` prefix:

| Route | Question it answers |
| --- | --- |
| `/actuator/health` | Is the service healthy? |
| `/actuator/health/liveness` | Is the process still working? It never checks the database or other services |
| `/actuator/health/readiness` | Can it receive traffic? Add here the dependencies the service cannot work without |

Only `health` and `info` are exposed over HTTP, and health shows no details. Keep it that way: other Actuator endpoints, such as `env` or `heapdump`, can reveal secrets or data.

## Database migrations

[Flyway](https://documentation.red-gate.com/flyway) applies the pending migrations when the service starts. It works the same on the local PostgreSQL and on RDS or Aurora PostgreSQL (not yet tested against them).

**Convention**

- Scripts live in `src/main/resources/db/migration` and are named `V<n>__descripcion.sql` (two underscores, `n` is the next number). A badly named script stops the startup.
- **Never edit a migration that was already applied** anywhere: add a new one. Flyway compares checksums and stops if one changed.
- During a deployment the old and the new version of the service run at the same time, so use **expand/contract**: first add what is new (compatible with the old code), then move the data and the code, and remove the old part in a later release. Never rename or drop a column in one step.
- There is no automatic undo: a problem is fixed with a new migration. Try it in QA first. `flyway clean` is disabled.
- The outbox table arrives with MPC-116.

**Every table with data of an institution** (rule H7, DOC-ARQ-06 section 5) has `tenant_id uuid NOT NULL`, includes it in its primary and foreign keys, enables **and forces** row-level security with a policy, and grants privileges to `svc_app`. Copy `V1__crear_tabla_muestra.sql`. `MigracionesIT` fails if a table is missing this protection. The service sets the institution in each transaction with `set_config('app.tenant_id', ?, true)`; without it no row is visible. The shared institution context arrives with MPC-391.

**Two database roles**

| Role | Used by | Can |
| --- | --- | --- |
| `svc_migrator` | Flyway only | Create and change tables |
| `svc_app` | The running service | Read and write rows; it cannot skip row-level security |

Never run the service as a superuser or as a role with `BYPASSRLS`: row-level security would not protect anything.

| Variable | Meaning |
| --- | --- |
| `DB_URL`, `DB_USER`, `DB_PASSWORD` | Connection of the service |
| `DB_MIGRATION_USER`, `DB_MIGRATION_PASSWORD` | Connection of Flyway |
| `DB_MIGRATION_URL` | Optional, `DB_URL` by default. Point it directly at the writer instance when the service goes through PgBouncer |

The `dev` profile has defaults that match `compose.yml`; `qa` and `prod` have none. Locally, the roles are created by `infra/local/postgres/01-roles.sql` only when the database is new. **If you started the database before these roles existed**, recreate it once with `docker compose down -v` (this deletes your local data).

`./gradlew build` still works without Docker: those tests start the service without a database (`src/test/resources/config/application.yml`). The migrations and the isolation between institutions are tested by `./gradlew integrationTest`.

## Build conventions

Every service and library gets its build setup from a convention plugin in `build-logic/`, so a `build.gradle.kts` only says which kind of project it is:

```kotlin
// services/grading-service/build.gradle.kts
plugins {
    id("mentora.servicio")
}
```

| Plugin | Use it in | What it adds |
| --- | --- | --- |
| `mentora.servicio` | `services/<svc>-service` | `mentora.calidad`, the Spring Boot plugin and BOM (executable jar), `spring-boot-starter-test`, ArchUnit and the Testcontainers BOM |
| `mentora.biblioteca` | `libs/*` | `mentora.calidad` and `java-library` (no Spring Boot executable, no business logic: rule H5), JUnit 5, AssertJ and ArchUnit |
| `mentora.calidad` | applied by the two above; do not use it directly | The shared Java and quality setup described below |

All versions come from `gradle/libs.versions.toml`; do not write a version in a `build.gradle.kts`.

### Quality tools

`mentora.calidad` runs these on every `./gradlew build`; any failure stops the build:

| Tool | What it checks |
| --- | --- |
| Java 21 toolchain | Compiles with JDK 21 whatever JDK runs Gradle |
| `javac` with `-Xlint:all -Werror` | Every compiler warning is an error |
| Error Prone and NullAway | Common bugs; null safety in packages marked `@NullMarked` (JSpecify) |
| Spotless (google-java-format) | Code format. Fix it with `./gradlew spotlessApply` |
| Checkstyle | Style rules in `config/checkstyle/checkstyle.xml`, with zero warnings allowed |
| SpotBugs | Bug patterns in the compiled code |
| JUnit 5 and JaCoCo | Tests run on the JUnit platform; JaCoCo writes XML and HTML reports after them |

### Rule H4: services never depend on services

A project can depend only on `libs/*`. If a build file declares `project(":services:...")` (and it is not the project itself), Gradle stops while configuring the build with a message that starts with `Rule H4 violated` and names both projects. There is no flag to skip the check: move the shared code to a library under `libs/` instead.

### JDK 21

Install JDK 21 before building. The Java 21 toolchain finds it on its own (Gradle looks in the usual install folders and in `JAVA_HOME`), so Gradle itself can run on a newer JDK. If no JDK 21 is found, the build fails with a message that lists the toolchains it looked for.

## Service ownership

Every service belongs to a module (A, B or C).

| Module | Services |
| --- | --- |
| **A. Platform and external services** (12) | `identity`, `tenant`, `audit`, `integration`, `billing`, `regulation`, `file`, `directory`, `documentation`, `technical`, `agro`, `industrial` |
| **B. People, enrollment and support** (7) | `people`, `academic`, `enrollment`, `messaging`, `welfare`, `coexistence`, `document` |
| **C. Classroom, grades and risk** (10) | `classroom`, `content`, `assignment`, `quiz`, `grading`, `attendance`, `attendance-compliance`, `analytics`, `reporting`, `risk` |

Every name has the `-service` suffix (for example `services/grading-service/`). Module A also maintains the shared parts: `infra/`, `gitops/`, `build-logic/` and `libs/`.

## Branches and approval

- Permanent branches: `dev` (development), `qa` and `main` (production).
- Nobody pushes directly to them: everything goes through a pull request.
- In `dev` and `qa`, each person reviews and merges their own PR.
- The `qa` to `main` step is approved by the course instructor.
