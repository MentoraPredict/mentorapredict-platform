# Module C databases module

Creates one database, one migration role and one runtime role per Module C service.

The runtime role is deliberately not the database owner, so row-level security applies to the application. The migration role owns the database and the tables created by migrations, so it keeps full access through ownership without the `BYPASSRLS` attribute. Default privileges grant the runtime role `SELECT`, `INSERT`, `UPDATE` and `DELETE` on tables and `USAGE, SELECT, UPDATE` on sequences created later by migrations.

The module reads the runtime and migration passwords from Secrets Manager. It never receives a password in a variable.

Run it from a network path that can reach the private RDS endpoint. The provider is configured in the `81-modulo-c-databases` composition with `sslmode = require`.
