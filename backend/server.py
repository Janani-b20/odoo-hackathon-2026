"""Dayflow demo API - standard-library Python backend with SQLite storage."""

import json
import sqlite3
from datetime import datetime
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse


ROOT = Path(__file__).resolve().parent
DB_PATH = ROOT / "dayflow.db"


def connection():
    db = sqlite3.connect(DB_PATH)
    db.row_factory = sqlite3.Row
    return db


def seed_database():
    db = connection()

    db.executescript(
        """
        CREATE TABLE IF NOT EXISTS employees (
            id INTEGER PRIMARY KEY,
            employee_id TEXT UNIQUE,
            name TEXT,
            email TEXT UNIQUE,
            role TEXT,
            department TEXT,
            designation TEXT,
            phone TEXT,
            address TEXT,
            base_salary INTEGER
        );

        CREATE TABLE IF NOT EXISTS attendance (
            id INTEGER PRIMARY KEY,
            employee_id INTEGER,
            date TEXT,
            check_in TEXT,
            check_out TEXT,
            status TEXT
        );

        CREATE TABLE IF NOT EXISTS leaves (
            id INTEGER PRIMARY KEY,
            employee_id INTEGER,
            leave_type TEXT,
            start_date TEXT,
            end_date TEXT,
            remarks TEXT,
            status TEXT DEFAULT 'Pending',
            admin_comment TEXT
        );

        CREATE TABLE IF NOT EXISTS notifications (
            id INTEGER PRIMARY KEY,
            employee_id INTEGER,
            title TEXT,
            message TEXT,
            created_at TEXT,
            is_read INTEGER DEFAULT 0
        );
        """
    )

    if not db.execute("SELECT 1 FROM employees LIMIT 1").fetchone():
        db.executemany(
            """
            INSERT INTO employees
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    1,
                    "DF-1001",
                    "Aarav Sharma",
                    "aarav@dayflow.com",
                    "admin",
                    "Human Resources",
                    "HR Manager",
                    "+91 98765 11111",
                    "Bengaluru, Karnataka",
                    120000,
                ),
                (
                    2,
                    "DF-1024",
                    "Neha Kapoor",
                    "neha@dayflow.com",
                    "employee",
                    "Product",
                    "Product Designer",
                    "+91 98765 43210",
                    "Bengaluru, Karnataka",
                    85000,
                ),
                (
                    3,
                    "DF-1031",
                    "Arjun Mehta",
                    "arjun@dayflow.com",
                    "employee",
                    "Engineering",
                    "Software Engineer",
                    "+91 98765 43211",
                    "Bengaluru, Karnataka",
                    92000,
                ),
                (
                    4,
                    "DF-1042",
                    "Sanya Verma",
                    "sanya@dayflow.com",
                    "employee",
                    "Marketing",
                    "Marketing Manager",
                    "+91 98765 43212",
                    "Mumbai, Maharashtra",
                    78000,
                ),
            ],
        )

        db.executemany(
            """
            INSERT INTO leaves
            (
                employee_id,
                leave_type,
                start_date,
                end_date,
                remarks,
                status
            )
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    2,
                    "Paid leave",
                    "2026-08-25",
                    "2026-08-27",
                    "Family travel",
                    "Pending",
                ),
                (
                    3,
                    "Sick leave",
                    "2026-08-22",
                    "2026-08-23",
                    "Medical rest",
                    "Pending",
                ),
                (
                    4,
                    "Unpaid leave",
                    "2026-09-02",
                    "2026-09-02",
                    "Personal work",
                    "Approved",
                ),
            ],
        )

        db.execute(
            """
            INSERT INTO notifications
            (
                employee_id,
                title,
                message,
                created_at
            )
            VALUES (?, ?, ?, ?)
            """,
            (
                2,
                "Welcome to Dayflow",
                "Your employee profile is ready.",
                datetime.now().isoformat(),
            ),
        )

    db.commit()
    db.close()


def rows(cursor):
    return [dict(row) for row in cursor.fetchall()]


class ApiHandler(BaseHTTPRequestHandler):

    def log_message(self, fmt, *args):
        print(f"[{self.log_date_time_string()}] {fmt % args}")

    def _send(self, status, data):
        payload = json.dumps(data, default=str).encode()

        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header(
            "Access-Control-Allow-Methods",
            "GET, POST, PATCH, OPTIONS",
        )
        self.end_headers()

        self.wfile.write(payload)

    def _body(self):
        size = int(self.headers.get("Content-Length", 0))

        try:
            return json.loads(self.rfile.read(size) or b"{}")
        except json.JSONDecodeError:
            self._send(
                HTTPStatus.BAD_REQUEST,
                {"error": "Body must be valid JSON"},
            )
            return {}

    def do_OPTIONS(self):
        self._send(HTTPStatus.NO_CONTENT, {})

    def do_GET(self):
        parsed = urlparse(self.path)
        query = parse_qs(parsed.query)

        db = connection()

        try:

            if parsed.path == "/health":

                self._send(
                    HTTPStatus.OK,
                    {
                        "status": "ok",
                        "service": "dayflow-api",
                    },
                )

            elif parsed.path == "/employees":

                self._send(
                    HTTPStatus.OK,
                    rows(
                        db.execute(
                            """
                            SELECT
                                id,
                                employee_id,
                                name,
                                email,
                                role,
                                department,
                                designation,
                                phone,
                                address,
                                base_salary
                            FROM employees
                            ORDER BY id
                            """
                        )
                    ),
                )

            elif parsed.path.startswith("/employees/"):

                employee = db.execute(
                    "SELECT * FROM employees WHERE id = ?",
                    (parsed.path.rsplit("/", 1)[1],),
                ).fetchone()

                self._send(
                    HTTPStatus.OK if employee else HTTPStatus.NOT_FOUND,
                    dict(employee)
                    if employee
                    else {"error": "Employee not found"},
                )

            elif parsed.path == "/attendance":

                employee_id = query.get("employee_id", [None])[0]

                sql = """
                    SELECT
                        attendance.*,
                        employees.name
                    FROM attendance
                    JOIN employees
                        ON employees.id = attendance.employee_id
                """

                params = ()

                if employee_id:
                    sql += " WHERE attendance.employee_id = ?"
                    params = (employee_id,)

                sql += " ORDER BY attendance.date DESC, attendance.id DESC"

                self._send(
                    HTTPStatus.OK,
                    rows(db.execute(sql, params)),
                )

            elif parsed.path == "/leaves":

                employee_id = query.get("employee_id", [None])[0]

                sql = """
                    SELECT
                        leaves.*,
                        employees.name
                    FROM leaves
                    JOIN employees
                        ON employees.id = leaves.employee_id
                """

                params = ()

                if employee_id:
                    sql += " WHERE leaves.employee_id = ?"
                    params = (employee_id,)

                sql += " ORDER BY leaves.id DESC"

                self._send(
                    HTTPStatus.OK,
                    rows(db.execute(sql, params)),
                )

            elif parsed.path == "/payroll":

                self._send(
                    HTTPStatus.OK,
                    rows(
                        db.execute(
                            """
                            SELECT
                                id,
                                employee_id,
                                name,
                                department,
                                base_salary,
                                ROUND(base_salary * 0.05) AS deductions,
                                ROUND(base_salary * 0.95) AS net_pay
                            FROM employees
                            ORDER BY id
                            """
                        )
                    ),
                )

            elif parsed.path == "/notifications":

                employee_id = query.get("employee_id", ["2"])[0]

                self._send(
                    HTTPStatus.OK,
                    rows(
                        db.execute(
                            """
                            SELECT *
                            FROM notifications
                            WHERE employee_id = ?
                            ORDER BY id DESC
                            """,
                            (employee_id,),
                        )
                    ),
                )

            else:

                self._send(
                    HTTPStatus.NOT_FOUND,
                    {"error": "Route not found"},
                )

        finally:
            db.close()

    def do_POST(self):

        path = urlparse(self.path).path
        body = self._body()

        db = connection()

        try:

            # LOGIN
            if path == "/auth/login":

                employee = db.execute(
                    """
                    SELECT *
                    FROM employees
                    WHERE lower(email) = lower(?)
                    """,
                    (body.get("email", ""),),
                ).fetchone()

                if not employee:

                    self._send(
                        HTTPStatus.UNAUTHORIZED,
                        {"error": "Invalid email or password"},
                    )

                else:

                    self._send(
                        HTTPStatus.OK,
                        {
                            "token": f"demo-token-{employee['id']}",
                            "user": dict(employee),
                        },
                    )

            # CHECK IN
            elif path == "/attendance/check-in":

                employee_id = body.get("employee_id")

                if not employee_id:

                    self._send(
                        HTTPStatus.BAD_REQUEST,
                        {"error": "employee_id is required"},
                    )
                    return

                now = datetime.now()

                today = now.date().isoformat()

                check_in_time = now.strftime("%I:%M %p")

                existing = db.execute(
                    """
                    SELECT
                        id,
                        check_in,
                        check_out
                    FROM attendance
                    WHERE employee_id = ?
                    AND date = ?
                    ORDER BY id DESC
                    LIMIT 1
                    """,
                    (employee_id, today),
                ).fetchone()

                if existing:

                    if existing["check_in"] and not existing["check_out"]:

                        self._send(
                            HTTPStatus.CONFLICT,
                            {
                                "error": "Employee is already checked in",
                                "time": existing["check_in"],
                            },
                        )

                    else:

                        self._send(
                            HTTPStatus.CONFLICT,
                            {
                                "error": "Attendance already recorded for today"
                            },
                        )

                    return

                db.execute(
                    """
                    INSERT INTO attendance
                    (
                        employee_id,
                        date,
                        check_in,
                        status
                    )
                    VALUES (?, ?, ?, 'Present')
                    """,
                    (
                        employee_id,
                        today,
                        check_in_time,
                    ),
                )

                db.commit()

                self._send(
                    HTTPStatus.CREATED,
                    {
                        "message": "Checked in",
                        "time": check_in_time,
                    },
                )

            # CHECK OUT
            elif path == "/attendance/check-out":

                employee_id = body.get("employee_id")

                if not employee_id:

                    self._send(
                        HTTPStatus.BAD_REQUEST,
                        {"error": "employee_id is required"},
                    )
                    return

                now = datetime.now()

                today = now.date().isoformat()

                check_out_time = now.strftime("%I:%M %p")

                result = db.execute(
                    """
                    UPDATE attendance
                    SET check_out = ?
                    WHERE id = (
                        SELECT id
                        FROM attendance
                        WHERE employee_id = ?
                        AND date = ?
                        AND check_out IS NULL
                        ORDER BY id DESC
                        LIMIT 1
                    )
                    """,
                    (
                        check_out_time,
                        employee_id,
                        today,
                    ),
                )

                db.commit()

                if result.rowcount:

                    self._send(
                        HTTPStatus.OK,
                        {
                            "message": "Checked out",
                            "time": check_out_time,
                        },
                    )

                else:

                    self._send(
                        HTTPStatus.NOT_FOUND,
                        {
                            "error": "No open check-in found for today"
                        },
                    )

            # APPLY LEAVE
            elif path == "/leaves":

                required = [
                    "employee_id",
                    "leave_type",
                    "start_date",
                    "end_date",
                ]

                if any(not body.get(field) for field in required):

                    self._send(
                        HTTPStatus.BAD_REQUEST,
                        {
                            "error": (
                                "employee_id, leave_type, "
                                "start_date and end_date are required"
                            )
                        },
                    )

                else:

                    cursor = db.execute(
                        """
                        INSERT INTO leaves
                        (
                            employee_id,
                            leave_type,
                            start_date,
                            end_date,
                            remarks
                        )
                        VALUES (?, ?, ?, ?, ?)
                        """,
                        (
                            body["employee_id"],
                            body["leave_type"],
                            body["start_date"],
                            body["end_date"],
                            body.get("remarks", ""),
                        ),
                    )

                    db.commit()

                    self._send(
                        HTTPStatus.CREATED,
                        {
                            "id": cursor.lastrowid,
                            "status": "Pending",
                        },
                    )

            else:

                self._send(
                    HTTPStatus.NOT_FOUND,
                    {"error": "Route not found"},
                )

        finally:
            db.close()

    def do_PATCH(self):

        path = urlparse(self.path).path
        body = self._body()

        if not path.startswith("/leaves/"):

            self._send(
                HTTPStatus.NOT_FOUND,
                {"error": "Route not found"},
            )

            return

        status = body.get("status")

        if status not in {"Approved", "Rejected"}:

            self._send(
                HTTPStatus.BAD_REQUEST,
                {
                    "error": "status must be Approved or Rejected"
                },
            )

            return

        db = connection()

        try:

            result = db.execute(
                """
                UPDATE leaves
                SET
                    status = ?,
                    admin_comment = ?
                WHERE id = ?
                """,
                (
                    status,
                    body.get("admin_comment", ""),
                    path.rsplit("/", 1)[1],
                ),
            )

            db.commit()

            if result.rowcount:

                self._send(
                    HTTPStatus.OK,
                    {"status": status},
                )

            else:

                self._send(
                    HTTPStatus.NOT_FOUND,
                    {"error": "Leave request not found"},
                )

        finally:
            db.close()


if __name__ == "__main__":

    seed_database()

    print(
        "Dayflow API running at "
        "http://127.0.0.1:8000"
    )

    ThreadingHTTPServer(
        ("127.0.0.1", 8000),
        ApiHandler,
    ).serve_forever()