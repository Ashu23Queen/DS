# Building ETL APIs with FastAPI

A complete hands-on session covering FastAPI from basics to production patterns,
demonstrated through a real SQLite-backed ETL pipeline.

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
 
   
