-- Local development and Testcontainers only. Never reuse these passwords elsewhere.
CREATE ROLE idn_migrator LOGIN PASSWORD 'idn_migrator' NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS;
CREATE ROLE idn_app LOGIN PASSWORD 'idn_app' NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS;
GRANT CREATE ON DATABASE identity TO idn_migrator;
GRANT USAGE, CREATE ON SCHEMA public TO idn_migrator;
GRANT USAGE ON SCHEMA public TO idn_app;
