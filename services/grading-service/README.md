# grading-service (GRD)

## Responsibility

Official grades, averages, period closing and administrative corrections. It consumes assignment, quiz and attendance results.

It does not do: Grading assignments or quizzes; it receives their results as events.

## Module C position

- Code: GRD
- Level: 1
- Implementation order: 6
- Database: calificaciones_db (db-grd)

## Published topics

| Topic | Events |
| --- | --- |
| `mp.grd.nota.v1` | NotaPublicada, NotaCorregida |
| `mp.grd.periodo.v1` | PeriodoCerrado, PromedioCalculado |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.asg.entrega.v1` | Turns a graded submission into a component grade. |
| `mp.cue.intento.v1` | Turns a graded attempt into a component grade. |
| `mp.att.asistencia.v1` | Feeds the participation component when the institution enables it. |
| `mp.aul.aula.v1` | Keeps the classroom and its members projected. |

## Structure

```text
ec.edu.mentora.grading/
├── GradingApplication.java
├── ConfiguracionBeans.java
├── domain/                  entities, value objects, domain services and errors
├── application/             use cases
│   └── port/
│       ├── in/              input ports and commands
│       └── out/             output ports
├── infrastructure/          output adapters
│   └── outbox/              transactional outbox adapter
└── interfaces/              input adapters
    └── events/              event consumers
```

## Build

```bash
./gradlew :services:grading-service:build
./gradlew :services:grading-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
