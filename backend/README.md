# Dayflow backend

A lightweight demo REST API using Python's standard library and SQLite. No package installation is required.

## Start it

```powershell
cd backend
python server.py
```

The API starts at `http://127.0.0.1:8000` and creates `dayflow.db` automatically on first run.

## Main endpoints

- `POST /auth/login`
- `GET /employees`
- `GET /attendance?employee_id=2`
- `POST /attendance/check-in`
- `POST /attendance/check-out`
- `GET /leaves`
- `POST /leaves`
- `PATCH /leaves/{id}`
- `GET /payroll`
- `GET /notifications?employee_id=2`

All requests and responses use JSON. This is a local demo backend; authentication tokens are illustrative only.
