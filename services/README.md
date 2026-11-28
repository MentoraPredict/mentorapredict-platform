# Services

Entry point of the microservices of MentoraPredict: what each of the **29 services** does, which module it belongs to and what makes it different. Each service lives in `services/<name>-service/`.

**Current state:** [`sample-service`](sample-service/README.md) is the example of the optional [service template](CREATING-A-SERVICE.md), and [`identity-service`](identity-service/README.md) has an initial executable foundation. The remaining services are described here before they are built.

This page is a summary. The sources are the platform catalog (DOC-ARQ-04) and the service cards of each module (DOC-A-ARQ-04, DOC-B-ARQ-04 and DOC-C-ARQ-04) in Confluence. If they differ from this page, check them and update it.

## Modules

| Module | Services | REST facade |
| --- | --- | --- |
| [A. Platform and external services](#module-a-platform-and-external-services) | 12 | `tenant-service` |
| [B. People, enrollment and support](#module-b-people-enrollment-and-support) | 7 | `people-service` |
| [C. Classroom, grades and risk](#module-c-classroom-grades-and-risk) | 10 | `classroom-service` |

The platform catalog (DOC-ARQ-04 section 4.1) defines one REST facade per module: it is the only one exposed to clients, it translates to gRPC for the other services of its module and it holds no business rules about them. Services of different modules do not call each other synchronously: they use events and keep local copies of what they need.

**Level** is the criticality: **0**, nobody can sign in without it; **1**, the daily work of an institution depends on it; **2**, support work that can degrade first.

## Module A: platform and external services

| Service | Code | Level | What it does | Particularities |
| --- | --- | --- | --- | --- |
| `identity-service` | IDN | 0 | Who the user is, how they sign in and what they can do in an institution | Orchestrates identity: each institution configures its sign-in methods. Keycloak issues the tokens and keeps credentials and sessions |
| `tenant-service` | TEN | 1 | The institution as a customer: plan, contracted modules, parameters and lifecycle | **REST facade of module A.** Source of truth of the state of an institution; orchestrates onboarding and offboarding |
| `audit-service` | AUD | 2 | Evidence of who accessed or changed personal data, and when | Append-only store; keeps records for at least 5 years |
| `integration-service` | ITG | 2 | The boundary with external systems: government systems, payment gateways, email, WhatsApp, push and calendars | No connection with banks. Connector credentials live in the secrets manager |
| `billing-service` | BIL | 2 | Fees that families pay to private institutions: charges, payments, reconciliation and receipts | Optional module; peaks at the start of the month |
| `regulation-service` | REG | 2 | Current education rules and their effect on the system: watches official sources, keeps versions and analyses the impact with AI | Platform service **without `tenant_id`** (global tables); no data of students, families or teachers |
| `file-service` | FIL | 2 | Files: safe storage, short-lived signed links, inspection and antivirus, and OCR of scanned PDFs | Shared by the three modules; uploads are treated as hostile; file bytes do not go through the services |
| `directory-service` | DIR | 1 | Bridge to Active Directory over LDAPS, one connector per institution | Stores no credentials and no copy of the directory; a failing directory only affects its institution |
| `documentation-service` | DCM | 2 | Dynamic features of the documentation and manuals site: editable content, comments and search | The platform works without it; no student data |
| `technical-service` | TEC | 2 | Technical baccalaureate: professional profiles, training modules, area projects, practices and competencies | Base of the two specialties below |
| `agro-service` | AGR | 2 | Agricultural specialty: production projects, crop and breeding cycles and field records | Specializes `technical-service`; they coordinate through events |
| `industrial-service` | IND | 2 | Industrial specialty (mechanics and electricity): workshops, workshop practices and safety | Specializes `technical-service`; safety incidents of minors may contain health data |

## Module B: people, enrollment and support

| Service | Code | Level | What it does | Particularities |
| --- | --- | --- | --- | --- |
| `people-service` | PEO | 1 | Students, teachers, guardians and staff, the links between them and data consent | **REST facade of module B.** Source of truth of personal data of minors; field-level encryption for sensitive attributes |
| `academic-service` | ACA | 1 | How an institution is organised each year: periods, grades, groups, subjects, teaching assignments, timetables and study plan | Owns the academic calendar and the capacity of each group; read-heavy |
| `enrollment-service` | ENR | 1 | Admission, place assignment, enrollment, transfers and the admission file | Orchestrates enrollment and produces the official list of each group; seasonal peak |
| `messaging-service` | MSG | 2 | Announcements, messages between teachers and families, notifications and the real-time channel | Decides what to notify from domain events; holds open real-time connections |
| `welfare-service` | WEL | 2 | Follow-up by the student counselling department (DECE): cases, interventions, referrals and appointments | The most sensitive data (health, family, protection); isolating keys matters more than scaling |
| `coexistence-service` | CNV | 2 | School coexistence and conduct: code of conduct, offences, disciplinary process and measures | Field-level encryption of facts and statements; performance services cannot read conduct data |
| `document-service` | DOC | 2 | Official documents: report cards, certificates and final tables in PDF, in batches | Versioned templates and immutable versions; files uploaded by users belong to `file-service` |

## Module C: classroom, grades and risk

Each service of this module owns its logical database. According to its cards, services integrate through events.

| Service | Code | Level | What it does | Particularities |
| --- | --- | --- | --- | --- |
| `classroom-service` | AUL | 1 | Classrooms, classroom enrollment, units, announcements and activity | **REST facade of module C.** Does not handle content, assignments, grades or attendance; read peak at the start of class |
| `content-service` | CNT | 1 | Learning content, its versions and files, and quarantine | Does not publish assignments or grade them |
| `assignment-service` | ASG | 1 | Assignments, rubrics, submissions, lateness and the grade of each assignment | Not the official grade of the period; peak in the last hour before a deadline |
| `quiz-service` | CUE | 1 | Quizzes, question banks, attempts, answers and automatic grading | The question bank must not leak |
| `grading-service` | GRD | 1 | Official grades, averages, period closing and administrative corrections | Takes assignment and quiz results from their events; highest load at period closing |
| `attendance-service` | ATT | 1 | Attendance sessions, records and justifications | Does not compute thresholds or send alerts; mass registration in the first hour |
| `attendance-compliance-service` | ATC | 2 | Attendance compliance, versioned thresholds and alerts | Fed by events; an alert should arrive within 5 minutes |
| `analytics-service` | ANL | 2 | Analytical views, dashboards and aggregated queries | Never writes to transactional databases; it is not the source of truth |
| `reporting-service` | RPT | 2 | Reports, report cards, exports and signatures | Does not compute grades |
| `risk-service` | RSK | 2 | Dropout and risk detection, cases and their explanation | Keeps academic and conduct risk **separate**; it does not notify or intervene by itself. DOC-INF-03 runs it in **Python** (see `ml/`) |

## Rules for every service

- **Rule H4:** a service depends only on `libs/*`, never on another service. Gradle and ArchUnit enforce it.
- Contracts between services and with clients live in [`libs/contracts`](../libs/contracts/README.md) and are written before the code.
- Each service owns its data: no service reads the database of another.
- Data of an institution is isolated by `tenant_id`; `regulation-service` is the documented exception, and `documentation-service` is also a platform service with its own storage.
- Java services use the `mentora.servicio` plugin (see [build conventions](../README.md#build-conventions)).
- Every service has a `README.md` with its purpose and owner, how to run it, its variables without secrets, its contracts and its tests (DOC-ARQ-09 section 8.1).
- **This repository is public:** no secrets, AWS account IDs or real data.

## How to start a service

Each team decides how to build its services. The [template guide](CREATING-A-SERVICE.md) explains how to start from `sample-service`, what it includes and what it does not.
