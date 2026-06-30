# Building ETL APIs with FastAPI

A complete hands-on session covering FastAPI from basics to production patterns,
demonstrated through a real SQLite-backed ETL pipeline.

---

## What You Will Learn

- Why FastAPI is well suited for ETL workloads
- Python type hints and Pydantic data validation
- Designing REST endpoints for extract, transform, and load stages
- Path parameters, query parameters, headers, and cookies
- Middleware, CORS, background tasks, and dependency injection
- OAuth2 + JWT authentication to protect ETL routes
- Asynchronous processing for non-blocking I/O
- Production project structure and design patterns
- A complete end-to-end ETL API backed by SQLite

---

## Prerequisites

Before starting the session, make sure you have the following installed:

| Requirement | Version | How to check |
|---|---|---|
| Python | 3.11 or higher | `python --version` |
| uv | Latest | `uv --version` |

If you do not have `uv` installed, see the next section.

---

## Installing uv

`uv` is a fast Python package manager that replaces `pip` and `venv`.
It handles package installation, virtual environments, and running scripts
in a single tool.

**Mac and Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**Verify the installation:**
```bash
uv --version
```

You should see output like `uv 0.5.x`. If you see `command not found`,
restart your terminal and try again (the installer adds `uv` to your PATH,
which takes effect on the next terminal session).

---

## Creating the Project

### Step 1: Initialise the project

```bash
uv init fastapi-etl-session
cd fastapi-etl-session
```

`uv init` creates a minimal project scaffold. Here is what gets created:

```
fastapi-etl-session/
├── pyproject.toml    <- Project metadata and dependency list (like package.json in Node)
├── README.md         <- Auto-generated placeholder (replace with this file)
└── hello.py          <- Sample file (you can delete this)
```

**What is `pyproject.toml`?**

This file is the source of truth for your project. It stores:
- The project name and version
- The Python version requirement
- The list of installed packages

When someone else clones your project, they run `uv sync` and get the exact
same packages — no `requirements.txt` needed.

### Step 2: Create the virtual environment

```bash
uv venv
```

This creates a `.venv` folder inside your project. A virtual environment is
an isolated Python installation — packages you install here do not affect
your global Python or other projects.

```
fastapi-etl-session/
├── .venv/            <- Virtual environment (do not edit manually)
├── pyproject.toml
└── ...
```

### Step 3: Activate the virtual environment

You must activate the virtual environment before running Python files or
using `python` directly. Activating makes `.venv/bin/python` your default
Python interpreter.

**Mac / Linux:**
```bash
source .venv/bin/activate
```

**Windows (Command Prompt):**
```cmd
.venv\Scripts\activate.bat
```

**Windows (PowerShell):**
```powershell
.venv\Scripts\Activate.ps1
```

**How to confirm the virtual environment is active:**

Your terminal prompt will show the environment name in brackets:
```
(fastapi-etl-session) shridhar@mac fastapi-etl-session %
```

You can also run:
```bash
which python       # Mac/Linux — should point to .venv/bin/python
python --version   # Should show the Python version from pyproject.toml
```

**To deactivate** (when you are done):
```bash
deactivate
```

---

## Installing Dependencies

Install all required packages with a single command:

```bash
uv add fastapi uvicorn pydantic httpx python-multipart python-jose passlib sqlalchemy aiosqlite
```

`uv add` installs the package AND records it in `pyproject.toml` automatically.
You do not need to maintain a separate `requirements.txt`.

**What each package does:**

| Package | Role in this session |
|---|---|
| `fastapi` | The web framework — defines routes, validation, dependency injection |
| `uvicorn` | ASGI server that runs your FastAPI application |
| `pydantic` | Data validation using Python type hints — powers FastAPI's request parsing |
| `httpx` | HTTP client — used in test cells and for async external API calls |
| `python-multipart` | Required for FastAPI to handle file uploads (`UploadFile`) |
| `python-jose` | JWT token creation and verification (install with `[cryptography]` extra) |
| `passlib` | Password hashing utilities — used in authentication examples |
| `sqlalchemy` | SQL toolkit and ORM — maps Python classes to database tables |
| `aiosqlite` | Async SQLite driver for SQLAlchemy when using `async` routes |

**Install `python-jose` with the cryptography extra:**
```bash
uv add "python-jose[cryptography]"
```

**Verify everything is installed:**
```bash
uv pip list
```

---

## Running the Notebook

The notebook is the main learning resource. Run it with:

```bash
uv run jupyter notebook
```

This installs `jupyter` temporarily (if not already installed) and opens the
notebook interface in your browser. Open `FastAPI_ETL_Session.ipynb`.

If you prefer JupyterLab:
```bash
uv run jupyter lab
```

---

## Running Individual `.py` Files

Each section produces one or more `.py` files. To run them:

### General command

```bash
uvicorn filename:app --reload
```

Replace `filename` with the name of the file **without the `.py` extension**.

**Example:**
```bash
uvicorn 01_hello_fastapi:app --reload
```

### What the flags mean

| Flag | Meaning |
|---|---|
| `filename:app` | `filename.py` file, `app` variable (the FastAPI instance) |
| `--reload` | Auto-restart the server when you save code changes |
| `--host 0.0.0.0` | Make the server accessible on all network interfaces (default: 127.0.0.1) |
| `--port 8001` | Run on a different port if 8000 is already in use |

### Stop the server

Press `Ctrl + C` in the terminal where uvicorn is running.

---

## Using Swagger UI

FastAPI generates interactive API documentation automatically. No extra code needed.

Once your server is running, open:

```
http://127.0.0.1:8000/docs
```

**What you can do in Swagger UI:**
1. See all available endpoints grouped by tag
2. Click any endpoint to expand it
3. Click "Try it out"
4. Edit the example request body
5. Click "Execute" to send the real HTTP request
6. See the response code, headers, and JSON body

There is also a read-only reference at:
```
http://127.0.0.1:8000/redoc
```

---

## Recommended Project Folder Structure

For a production ETL API, organise your files like this:

```
fastapi-etl-session/
│
├── main.py                      <- App entry point — registers all routers
├── database.py                  <- SQLAlchemy engine, session factory, Base
├── pyproject.toml               <- uv project file with all dependencies
├── .venv/                       <- Virtual environment (do not commit to git)
│
├── routers/                     <- One file per ETL stage
│   ├── __init__.py
│   ├── extract.py               <- Routes: POST /extract, GET /extract/{id}
│   ├── transform.py             <- Routes: POST /transform
│   └── load.py                  <- Routes: POST /load, GET /load/status
│
├── schemas/                     <- Pydantic request and response models
│   ├── __init__.py
│   ├── extract.py               <- ExtractRequest, ExtractResponse
│   ├── transform.py             <- TransformRequest, TransformResponse
│   └── load.py                  <- LoadRequest, LoadResponse
│
├── models/                      <- SQLAlchemy ORM models (database tables)
│   ├── __init__.py
│   └── etl.py                   <- RawRecord, TransformedRecord, LoadLog
│
├── services/                    <- Business logic (no FastAPI imports)
│   ├── __init__.py
│   ├── extract_service.py       <- def run_extract(source, db) -> dict
│   ├── transform_service.py     <- def run_transform(job_id, ops, db) -> dict
│   └── load_service.py          <- def run_load(job_id, dest, db) -> dict
│
└── core/                        <- Shared utilities
    ├── __init__.py
    ├── config.py                <- Settings from environment variables
    ├── auth.py                  <- JWT creation, verification, dependencies
    └── dependencies.py          <- get_db(), get_current_user(), get_config()
```

---

## Section-to-File Reference

| Section | File | Concept |
|---|---|---|
| 0 | `00_requirements_check.py` | Package verification |
| 1 | `01_hello_fastapi.py` | Minimal FastAPI app |
| 1 | `01_etl_skeleton.py` | ETL route stubs |
| 2 | `02_type_hints.py` | Python type annotations |
| 2 | `02_pydantic_basics.py` | Pydantic request/response models |
| 2 | `02_swagger_demo.py` | Auto-generated Swagger UI |
| 3 | `03_path_params.py` | Path parameters with type coercion |
| 3 | `03_query_params.py` | Query parameters, filtering, pagination |
| 4 | `04_headers.py` | Custom request and response headers |
| 4 | `04_cookies.py` | Setting and reading cookies |
| 5 | `05_database.py` | SQLite + SQLAlchemy ORM setup |
| 5 | `05_etl_endpoints.py` | Full ETL endpoints backed by SQLite |
| 6 | `06_nested_models.py` | Deeply nested Pydantic models |
| 6 | `06_custom_validators.py` | `@field_validator`, `@model_validator` |
| 7 | `07_cors.py` | CORS middleware configuration |
| 7 | `07_custom_middleware.py` | Request logging audit middleware |
| 8 | `08_background_tasks.py` | Async ETL triggers with `BackgroundTasks` |
| 9 | `09_dependency_injection.py` | `Depends()`, chained dependencies |
| 10 | `10_authentication.py` | OAuth2 password flow, JWT, role checks |
| 11 | `11_async_fastapi.py` | `async def`, `asyncio.gather`, `httpx.AsyncClient` |
| 12 | `12_modular_routes.py` | `APIRouter`, global exception handlers |
| 13 | `13_full_etl_app.py` | Capstone — all concepts combined |

---

## Common Errors and Fixes

### 1. `ModuleNotFoundError: No module named 'fastapi'`

**Cause:** The virtual environment is not activated, or packages were not installed.

**Fix:**
```bash
source .venv/bin/activate     # Mac/Linux
uv add fastapi uvicorn pydantic
```

---

### 2. `uvicorn: command not found`

**Cause:** uvicorn is not on your PATH, or the venv is not active.

**Fix:**
```bash
source .venv/bin/activate
uvicorn --version    # Should work now
```

Or run it via uv:
```bash
uv run uvicorn 01_hello_fastapi:app --reload
```

---

### 3. `Address already in use` on port 8000

**Cause:** Another process (or a previous uvicorn run) is already using port 8000.

**Fix — use a different port:**
```bash
uvicorn 01_hello_fastapi:app --reload --port 8001
```

**Fix — kill the process on port 8000:**
```bash
# Mac/Linux
lsof -ti:8000 | xargs kill -9

# Windows
netstat -ano | findstr :8000
taskkill /PID <pid_number> /F
```

---

### 4. `422 Unprocessable Entity` when testing endpoints

**Cause:** The request body does not match the Pydantic model (missing field, wrong type).

**Fix:** Check the `detail` array in the response — it lists every validation error with
the field name and reason. Fix your request payload to match the schema shown in Swagger UI.

---

### 5. `ImportError: cannot import name 'jwt' from 'jose'`

**Cause:** `python-jose` was installed without the cryptography extra.

**Fix:**
```bash
uv add "python-jose[cryptography]"
```

---

### 6. SQLite database not created / `OperationalError: no such table`

**Cause:** `create_tables()` was not called before starting the server.

**Fix:** In `05_etl_endpoints.py` and `13_full_etl_app.py`, the `if __name__ == "__main__":`
block calls `create_tables()` before starting uvicorn. Always run the file directly
(`python 05_etl_endpoints.py`) rather than importing it, or call `create_tables()` manually:

```python
from database_05 import create_tables
create_tables()
```

---

## Next Steps After This Session

- **Add PostgreSQL:** swap `sqlite:///./etl_pipeline.db` for `postgresql://user:pass@host/db`
  and install `psycopg2-binary`
- **Add Celery:** replace `BackgroundTasks` with Celery tasks for retry logic and monitoring
- **Add Docker:** containerise the app with a `Dockerfile` and `docker-compose.yml`
- **Add tests:** write `pytest` tests using FastAPI's `TestClient`
- **Add monitoring:** integrate Prometheus with `prometheus-fastapi-instrumentator`

---

## References

- FastAPI documentation: https://fastapi.tiangolo.com
- Pydantic documentation: https://docs.pydantic.dev
- SQLAlchemy documentation: https://docs.sqlalchemy.org
- uvicorn documentation: https://www.uvicorn.org
- uv documentation: https://docs.astral.sh/uv
- python-jose documentation: https://python-jose.readthedocs.io
