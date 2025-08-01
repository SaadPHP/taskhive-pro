-- Enable UUID Extension (needed for Prisma)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    status VARCHAR(20) CHECK (status IN ('pending', 'in_progress', 'completed')) DEFAULT 'pending',
    due_date DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS task_log (
    id SERIAL PRIMARY KEY,
    task_id UUID,
    action TEXT,
    triggered_at TIMESTAMPTZ DEFAULT now()
);

-- Trigger Function
CREATE OR REPLACE FUNCTION log_task_insert() RETURNS trigger AS $$
BEGIN
  INSERT INTO task_log(task_id, action) VALUES (NEW.id, 'CREATED');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger Setup
DROP TRIGGER IF EXISTS trg_log_task_creation ON tasks;

CREATE TRIGGER trg_log_task_creation
AFTER INSERT ON tasks
FOR EACH ROW EXECUTE FUNCTION log_task_insert();
