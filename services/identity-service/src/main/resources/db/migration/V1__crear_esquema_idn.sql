-- The application role may use the schema but cannot create objects in it.
-- Domain tables and their RLS policies are added by the relevant IDN stories.
CREATE SCHEMA IF NOT EXISTS idn;
GRANT USAGE ON SCHEMA idn TO idn_app;
