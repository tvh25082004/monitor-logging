-- PostgreSQL Audit Configuration
-- Enable pg_stat_statements for slow query tracking

-- 1. Enable pg_stat_statements extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- 2. Configure logging
-- Add these to postgresql.conf:
-- log_destination = 'stderr'
-- logging_collector = on
-- log_directory = 'audit-logs/postgres'
-- log_filename = 'postgresql-%Y-%m-%d.log'
-- log_rotation_age = 1d
-- log_rotation_size = 10MB
-- log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
-- log_statement = 'mod' -- log DDL and DML statements
-- log_min_duration_statement = 2000 -- log queries taking more than 2 seconds
-- log_connections = on
-- log_disconnections = on
-- log_hostname = on

-- 3. Enable audit trigger (optional)
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, new_data, timestamp, user_name)
        VALUES (TG_TABLE_NAME, 'INSERT', row_to_json(NEW), NOW(), current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, old_data, new_data, timestamp, user_name)
        VALUES (TG_TABLE_NAME, 'UPDATE', row_to_json(OLD), row_to_json(NEW), NOW(), current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, old_data, timestamp, user_name)
        VALUES (TG_TABLE_NAME, 'DELETE', row_to_json(OLD), NOW(), current_user);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Create audit log table
CREATE TABLE IF NOT EXISTS audit_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    user_name TEXT NOT NULL
);

-- 5. Example: Apply audit trigger to a table
-- CREATE TRIGGER audit_trigger
-- AFTER INSERT OR UPDATE OR DELETE ON your_table_name
-- FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

