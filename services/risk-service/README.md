# risk-service (RSK)

## Responsibility

Academic and behavioral risk kept separate, cases and their explanation. The first delivery uses a rules engine, not machine learning.

It does not do: Notifying or intervening by itself.

## Module C position

- Code: RSK
- Level: 2
- Implementation order: 8
- Database: riesgo_db (db-rsk)

## Published topics

| Topic | Events |
| --- | --- |
| `mp.rsk.riesgo.v1` | CasoCreado, CasoRevisado, IntervencionRegistrada, CasoEscalado, CasoCerrado |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.grd.nota.v1` | Academic signal: official grades. |
| `mp.asg.entrega.v1` | Academic signal: late or missing submissions. |
| `mp.att.asistencia.v1` | Academic signal: attendance. |
| `mp.b.conducta.v1` | Behavioral signal, never mixed with academic risk. |
| `mp.aul.actividad.v1` | Aggregated classroom activity under the activity ACL. |

## Structure

```text
ec.edu.mentora.risk/
├── RiskApplication.java
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
./gradlew :services:risk-service:build
./gradlew :services:risk-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
