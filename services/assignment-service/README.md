# assignment-service (ASG)

## Responsibility

Assignments, rubrics, submissions, lateness and the grade of each assignment. Lateness is decided by the server clock.

It does not do: The official grade of the period or its closing.

## Module C position

- Code: ASG
- Level: 1
- Implementation order: 4
- Database: tareas_db (db-asg)

## Published topics

| Topic | Events |
| --- | --- |
| `mp.asg.tarea.v1` | TareaPublicada |
| `mp.asg.entrega.v1` | EntregaRecibida, EntregaCalificada, EntregaDevuelta |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.aul.aula.v1` | Keeps the classroom and its members projected. |
| `mp.aul.unidad.v1` | Associates an assignment with a unit. |
| `mp.b.archivo.v1` | Receives the verdict of the file attached to a submission. |

## Structure

```text
ec.edu.mentora.assignment/
├── AssignmentApplication.java
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
./gradlew :services:assignment-service:build
./gradlew :services:assignment-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
