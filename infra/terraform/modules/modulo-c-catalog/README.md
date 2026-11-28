# Module C catalogue

Single source of truth for the ten Module C services and the eleven Module C topics.

Each service entry defines its name, level, database, cache usage, S3 usage, PostgreSQL extensions and Kafka topics. Each topic entry defines partitions, replication factor, retention and cleanup policy.

The compositions and modules consume this catalogue so names and levels do not drift between the data, database, topic and Helm layers.

Sources: `CONTEXTO.md` sections 2.1, 4.4 and 4.5; `DOC-C-ARQ-05`; `DOC-C-ARQ-10`.
