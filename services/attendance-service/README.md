# attendance-service (ATT)

## Responsibility

Attendance sessions, records, justifications and session closing. It records attendance; it does not compute thresholds or emit alerts.

It does not do: Thresholds, alerts or notifications.

## Module C position

- Code: ATT
- Level: 1
- Implementation order: 2
- Database: asistencia_db (db-att)

## Published topics

| Topic | Events |
| --- | --- |
| `mp.att.asistencia.v1` | SesionAbierta, AsistenciaRegistrada, SesionCerrada |
| `mp.att.justificacion.v1` | JustificacionSolicitada, JustificacionAprobada, JustificacionRechazada |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.aul.aula.v1` | Keeps the classroom and its members projected. |
| `mp.b.persona.v1` | Keeps the student data used in a session. |
| `mp.b.archivo.v1` | Receives the verdict of the evidence attached to a justification. |

## Structure

```text
ec.edu.mentora.attendance/
├── AttendanceApplication.java
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
./gradlew :services:attendance-service:build
./gradlew :services:attendance-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
