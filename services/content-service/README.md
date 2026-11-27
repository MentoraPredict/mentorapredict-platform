# content-service (CNT)

## Responsibility

Learning content, its versions, files and quarantine. Files are stored in S3 and only references are kept.

It does not do: Publishing assignments, grading or moving file bytes.

## Module C position

- Code: CNT
- Level: 1
- Implementation order: 3
- Database: contenido_db (db-cnt)

## Published topics

| Topic | Events |
| --- | --- |
| `mp.cnt.contenido.v1` | ContenidoPublicado, ContenidoVersionado, ContenidoEnCuarentena |

## Consumed topics

| Topic | Purpose |
| --- | --- |
| `mp.aul.unidad.v1` | Associates content with the unit that owns it. |
| `mp.b.archivo.v1` | Publishes content only after the antivirus verdict is clean. |

## Structure

```text
ec.edu.mentora.content/
├── ContentApplication.java
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
./gradlew :services:content-service:build
./gradlew :services:content-service:test
```

## Contracts

API and event contracts live in `libs/contracts` and are added when the service is implemented. The service never publishes directly to Kafka: it writes to the transactional outbox in the same transaction as the business change.

## Owner

Module C team.
