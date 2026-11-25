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
