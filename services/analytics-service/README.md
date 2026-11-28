# analytics-service (ANL)

## Responsibility

Analytical projections, dashboards and aggregated queries. It never writes to a transactional database.

It does not do: Being the source of truth or writing to the databases of other services.

## Module C position

- Code: ANL
- Level: 2
- Implementation order: 10
- Database: analitica_db (db-anl) and OpenSearch

## Published topics

| Topic | Events |
| --- | --- |
| `mp.anl.tablero.v1` | TableroActualizado, MetricaRecalculada |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.aul.aula.v1` | Classroom events. |
| `mp.aul.unidad.v1` | Unit events. |
| `mp.aul.anuncio.v1` | Announcement events. |
| `mp.aul.actividad.v1` | Aggregated classroom activity. |
| `mp.cnt.contenido.v1` | Content events. |
| `mp.asg.tarea.v1` | Assignment events. |
| `mp.asg.entrega.v1` | Submission events. |
| `mp.cue.cuestionario.v1` | Quiz events. |
| `mp.cue.intento.v1` | Attempt events. |
| `mp.grd.nota.v1` | Official grade events. |
| `mp.grd.periodo.v1` | Period closing events. |
| `mp.att.asistencia.v1` | Attendance events. |
| `mp.att.justificacion.v1` | Justification events. |
| `mp.atc.cumplimiento.v1` | Compliance and alert events. |
| `mp.rsk.riesgo.v1` | Risk case events. |
| `mp.rpt.reporte.v1` | Report events. |

## Structure

```text
ec.edu.mentora.analytics/
├── AnalyticsApplication.java
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
./gradlew :services:analytics-service:build
./gradlew :services:analytics-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
