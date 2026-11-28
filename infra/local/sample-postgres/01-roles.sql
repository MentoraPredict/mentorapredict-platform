-- Database roles for LOCAL DEVELOPMENT AND TESTS ONLY (DOC-ARQ-06 section 5.2).
-- The passwords are development values, not secrets. In QA and production the roles are created by
-- the platform and their passwords come from the secrets manager.
--
-- compose.yml and the integration tests run this once, when the database is created. It is not a
-- Flyway migration because creating roles needs an administrator.

-- Runs the migrations and owns the tables. Never used by the running service.
CREATE ROLE svc_migrator LOGIN PASSWORD 'svc_migrator' NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS;

-- Used by the running service. It owns nothing and cannot skip row-level security.
CREATE ROLE svc_app LOGIN PASSWORD 'svc_app' NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS;

GRANT USAGE, CREATE ON SCHEMA public TO svc_migrator;
GRANT USAGE ON SCHEMA public TO svc_app;
-- Table privileges are granted by each migration, table by table.
