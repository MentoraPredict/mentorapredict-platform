# attendance-compliance-service (ATC)

## Responsibility

Attendance compliance, versioned thresholds and alerts. It calculates and alerts; it does not record attendance.

It does not do: Recording attendance or approving justifications.

## Module C position

- Code: ATC
- Level: 2
- Implementation order: 7
- Database: cumplimiento_db (db-atc)

## Published topics

| Topic | Events |
| --- | --- |
| `mp.atc.cumplimiento.v1` | CumplimientoActualizado, AlertaEmitida, AlertaResuelta |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.att.asistencia.v1` | Calculates compliance from the recorded attendance. |
| `mp.att.justificacion.v1` | Excludes justified absences from the threshold. |
| `mp.aul.aula.v1` | Keeps the classroom and its members projected. |

## Structure

```text
ec.edu.mentora.attendancecompliance/
├── AttendanceComplianceApplication.java
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
./gradlew :services:attendance-compliance-service:build
./gradlew :services:attendance-compliance-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
