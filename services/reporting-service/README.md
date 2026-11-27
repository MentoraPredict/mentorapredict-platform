# reporting-service (RPT)

## Responsibility

Reports, report cards, exports and signatures. Report cards are generated only for closed periods.

It does not do: Computing grades.

## Module C position

- Code: RPT
- Level: 2
- Implementation order: 9
- Database: reportes_db (db-rpt)

## Published topics

| Topic | Events |
| --- | --- |
| `mp.rpt.reporte.v1` | ReporteSolicitado, ReporteGenerado, ReporteFallido |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.grd.periodo.v1` | Knows when a period is closed and can be reported. |
| `mp.grd.nota.v1` | Reads the official grades of the report card. |
| `mp.att.asistencia.v1` | Reads the attendance summary of the report card. |
| `mp.rsk.riesgo.v1` | Reads the risk cases included in the report. |

## Structure

```text
ec.edu.mentora.reporting/
├── ReportingApplication.java
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
./gradlew :services:reporting-service:build
./gradlew :services:reporting-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
