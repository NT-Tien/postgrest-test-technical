-- Create invoices table
CREATE TABLE invoices (
  id         SERIAL PRIMARY KEY,
  name       TEXT        NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Sample data around 2026-04-01
INSERT INTO invoices (name, created_at) VALUES
  ('Invoice 28/3', '2026-03-28 12:00:00+00'),
  ('Invoice 30/3', '2026-03-30 12:00:00+00'),
  ('Invoice 1/4',  '2026-04-01 12:00:00+00'),
  ('Invoice 2/4',  '2026-04-02 12:00:00+00'),
  ('Invoice 3/4',  '2026-04-03 12:00:00+00');
