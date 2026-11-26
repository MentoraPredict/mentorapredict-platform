-- Example table of the template, with row-level security per institution (rule H7, DOC-ARQ-06
-- sections 5.1 and 5.2). Never edit a migration that was already applied: add a new one.

CREATE TABLE muestra (
    tenant_id      uuid        NOT NULL,
    id             text        NOT NULL,
    nombre         text        NOT NULL CHECK (btrim(nombre) <> ''),
    registrada_en  timestamptz NOT NULL,
    -- The key includes tenant_id: two institutions may use the same id, and a foreign key to this
    -- table can never point to a row of another institution.
    PRIMARY KEY (tenant_id, id)
);

ALTER TABLE muestra ENABLE ROW LEVEL SECURITY;
-- FORCE also applies the policy to the owner of the table.
ALTER TABLE muestra FORCE ROW LEVEL SECURITY;

-- The service sets the institution in every transaction: set_config('app.tenant_id', ?, true).
-- Without it no row is visible or writable. NULLIF is needed because, on a connection that already
-- used the setting, PostgreSQL returns '' instead of NULL after the transaction ends.
CREATE POLICY aislamiento_tenant ON muestra
    USING      (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid)
    WITH CHECK (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

-- Least privilege for the running service.
GRANT SELECT, INSERT, UPDATE, DELETE ON muestra TO svc_app;
