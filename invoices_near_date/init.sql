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

-- Role for PostgREST (anonymous access)
CREATE ROLE web_anon NOLOGIN;
GRANT USAGE ON SCHEMA public TO web_anon;
GRANT SELECT ON invoices TO web_anon;

-- Function: return invoices ordered by proximity to target_date
CREATE OR REPLACE FUNCTION invoices_near_date(target_date timestamptz)
RETURNS TABLE (
  id         INT,
  name       TEXT,
  created_at TIMESTAMPTZ,
  date_diff  FLOAT8
) AS $$
  SELECT
    id,
    name,
    created_at,
    ABS(EXTRACT(EPOCH FROM (created_at - target_date))) AS date_diff
  FROM invoices
  ORDER BY date_diff;
$$ LANGUAGE sql STABLE;

GRANT EXECUTE ON FUNCTION invoices_near_date(timestamptz) TO web_anon;
