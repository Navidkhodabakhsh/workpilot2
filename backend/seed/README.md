`demo_org_dump.sql` is a full `pg_dump` (schema + data) of a demo organization
seeded by `../scripts/seed_demo_org.py` — passwords are real bcrypt hashes
produced by `app.core.security.hash_password`, the same function the app
uses at signup, so every login below was verified end-to-end against a real
`POST /api/v1/auth/login` call before this dump was made.

`docker-compose.yml` mounts this file into the `postgres` service's
`/docker-entrypoint-initdb.d/`, so it auto-loads **only on a brand-new
(empty) `postgres_data` volume** -- if you've run the stack before without
it, run `docker compose down -v` first, then `docker compose up` again.

This only seeds the local `docker compose` Postgres. It has no effect on a
separately hosted database (e.g. Render's managed Postgres) -- for that,
run `python scripts/seed_demo_org.py` against it directly (with
`DATABASE_URL` pointing at it), or sign up through the app's own `/signup`
page.

Password for every seeded account: `Test@1234`

| نقش | شماره موبایل |
|---|---|
| مدیر سازمان (org_admin) | 09100000001 |
| مدیر پروژهٔ مهندسی و فنی | 09111000000 |
| کارمند ۱ تا ۶ - مهندسی و فنی | 09111000011 تا 09111000016 |
| مدیر پروژهٔ حسابداری و مالی | 09121000100 |
| کارمند ۱ تا ۶ - حسابداری و مالی | 09121000111 تا 09121000116 |
| مدیر پروژهٔ منابع انسانی | 09131000200 |
| کارمند ۱ تا ۶ - منابع انسانی | 09131000211 تا 09131000216 |

To regenerate after changing `seed_demo_org.py` or the schema:

```bash
cd backend
export DATABASE_URL=postgresql+psycopg2://workpilot:workpilot@localhost:5432/workpilot
export REDIS_URL=redis://localhost:6379/0
export SECRET_KEY=local-seed-secret
alembic upgrade head
PYTHONPATH=. python scripts/seed_demo_org.py
PGPASSWORD=workpilot pg_dump -h localhost -U workpilot -d workpilot --no-owner --no-privileges \
  | grep -v '^\\restrict\|^\\unrestrict' > seed/demo_org_dump.sql
```
