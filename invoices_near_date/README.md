# PostgREST — Invoices Near Date

Demo sử dụng **PostgREST** để expose PostgreSQL function thành REST API, không cần viết backend code.

## Stack

- **PostgreSQL 16** — database
- **PostgREST v12** — tự động generate REST API từ DB schema

## Cấu trúc

```
.
├── docker-compose.yml   # PostgreSQL + PostgREST
└── init.sql             # Schema, data mẫu, function
```

## Schema

```sql
CREATE TABLE invoices (
  id         SERIAL PRIMARY KEY,
  name       TEXT        NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Function

```sql
CREATE FUNCTION invoices_near_date(target_date timestamptz)
RETURNS TABLE (id INT, name TEXT, created_at TIMESTAMPTZ, date_diff FLOAT8)
```

Logic tính `date_diff`:
- `created_at - target_date` → ra interval (`-2 days`, `+1 day`...)
- `EXTRACT(EPOCH FROM ...)` → đổi ra giây
- `ABS(...)` → bỏ dấu âm, sort tăng dần

## Khởi động

```bash
docker compose up -d
```

PostgREST chạy tại `http://localhost:3000`, PostgreSQL tại port `5432`.

## API

### Lấy tất cả invoices

```bash
GET /invoices
```

```bash
curl http://localhost:3000/invoices
```

### Tìm invoices gần một ngày nhất định

```bash
POST /rpc/invoices_near_date
```

```bash
curl -X POST http://localhost:3000/rpc/invoices_near_date \
  -H "Content-Type: application/json" \
  -d '{"target_date": "2026-04-01T00:00:00Z"}'
```

Kết quả với `target_date = 2026-04-01`:

```json
[
  { "id": 3, "name": "Invoice 1/4",  "created_at": "2026-04-01T12:00:00+00:00", "date_diff": 0      },
  { "id": 4, "name": "Invoice 2/4",  "created_at": "2026-04-02T12:00:00+00:00", "date_diff": 86400  },
  { "id": 2, "name": "Invoice 30/3", "created_at": "2026-03-30T12:00:00+00:00", "date_diff": 172800 },
  { "id": 5, "name": "Invoice 3/4",  "created_at": "2026-04-03T12:00:00+00:00", "date_diff": 172800 },
  { "id": 1, "name": "Invoice 28/3", "created_at": "2026-03-28T12:00:00+00:00", "date_diff": 345600 }
]
```

> `date_diff` là số giây chênh lệch so với `target_date`.

## Tắt

```bash
docker compose down
```

Xóa cả data:

```bash
docker compose down -v
```
