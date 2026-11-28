# Module C data module

Creates the shared QA data layer for Module C:

- RDS PostgreSQL 16 instance with `manage_master_user_password`, TLS-only connections and a 7-day backup window.
- Data subnet group and security groups for PostgreSQL and Valkey.
- ElastiCache Valkey replication group with at-rest and in-transit encryption.
- Shared KMS key, Valkey secret and SSM parameters for endpoints.
- Per-service database names and topic lists are supplied by the catalogue module.

The module does not create databases, roles or topics. Those are handled by the `modulo-c-databases` and `modulo-c-topics` modules.

The RDS instance is shared in QA to control cost. Production uses one instance per service, following `DOC-C-ARQ-10` and `CONTEXTO.md` section 4.4.
