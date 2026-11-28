# Module C databases

This composition creates the ten Module C databases on the shared QA PostgreSQL instance produced by `80-modulo-c`.

It reads the `80-modulo-c` state from S3, obtains the RDS-managed master secret, and creates:

- One database per service, owned by `svc_<code>_owner`.
- One migration role and one runtime role per service.
- `CONNECT` and `TEMPORARY` on the database for the runtime role.
- `USAGE` on the `public` schema for the runtime role and `USAGE, CREATE` for the owner role.
- Default table and sequence privileges so the runtime role can read and write tables created by the migrations.
- The `pgcrypto` extension in every database.

The runtime role does not own the database, so row-level security is enforced for the application. Migrations run with the owner role, which owns the tables and therefore keeps full access without the `BYPASSRLS` attribute. The RDS master user cannot grant `BYPASSRLS`, so the design relies on table ownership instead of that attribute.

## Apply

The composition must run where it can reach the private RDS endpoint.

```bash
cp backend.hcl.example backend.hcl
cp qa.tfvars.example qa.tfvars
terraform init -backend-config=backend.hcl
terraform plan -var-file=qa.tfvars -out=81-modulo-c-databases.tfplan
terraform apply 81-modulo-c-databases.tfplan
```

`qa.tfvars` needs the state bucket and, optionally, a different state key or region. The PostgreSQL provider uses `sslmode = require` and the RDS-managed master secret; no password is stored in the composition.
