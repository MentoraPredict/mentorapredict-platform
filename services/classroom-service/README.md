# classroom-service (AUL)

## Responsibility

Classrooms, classroom enrollment, units, announcements and activity. It is the aggregate root of the module.

It does not do: Content, assignments, grades, attendance or reports.

## Module C position

- Code: AUL
- Level: 1
- Implementation order: 1
- Database: aula_db (db-aul)
- Role: REST facade of Module C

## Published topics

| Topic | Events |
| --- | --- |
| `mp.aul.aula.v1` | AulaCreada, EstudianteMatriculado, EstudianteRetirado, AulaCerrada |
| `mp.aul.unidad.v1` | UnidadPublicada |
| `mp.aul.anuncio.v1` | AnuncioPublicado |
| `mp.aul.actividad.v1` | ActividadRegistrada |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.b.persona.v1` | Keeps the local copy of the members of each classroom. |
| `mp.b.matricula.v1` | Adds and removes students from a classroom. |
| `mp.a.periodo.v1` | Opens and closes the classroom with the academic period. |

## Structure

```text
ec.edu.mentora.classroom/
├── ClassroomApplication.java
├── ConfiguracionBeans.java
├── domain/                  entities, value objects, domain services and errors
├── application/             use cases
│   └── port/
│       ├── in/              input ports and commands
│       └── out/             output ports
├── infrastructure/          output adapters
│   └── outbox/              transactional outbox adapter
└── interfaces/              input adapters
    ├── events/              event consumers
    └── rest/                REST controllers of the module facade
```

## Build

```bash
./gradlew :services:classroom-service:build
./gradlew :services:classroom-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
