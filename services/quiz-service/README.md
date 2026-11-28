# quiz-service (CUE)

## Responsibility

Quizzes, question banks, attempts, answers and automatic grading. Question keys never leave the service before the attempt closes.

It does not do: Assignments or the official grade of the period.

## Module C position

- Code: CUE
- Level: 1
- Implementation order: 5
- Database: cuestionarios_db (db-cue)

## Published topics

| Topic | Events |
| --- | --- |
| `mp.cue.cuestionario.v1` | CuestionarioPublicado |
| `mp.cue.intento.v1` | IntentoIniciado, IntentoEnviado, IntentoCalificado |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.aul.aula.v1` | Keeps the classroom and its members projected. |
| `mp.aul.unidad.v1` | Associates a quiz with a unit. |

## Structure

```text
ec.edu.mentora.quiz/
├── QuizApplication.java
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
./gradlew :services:quiz-service:build
./gradlew :services:quiz-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
