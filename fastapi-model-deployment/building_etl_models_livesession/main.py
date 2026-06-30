
from fastapi import FastAPI  # FastAPI class -- your application instance lives here
import uvicorn               # ASGI server that serves your FastAPI app

# Create the FastAPI application instance
# title and description appear in Swagger UI at /docs
app = FastAPI(
    title="FastAPI ETL Session",
    description="Learning FastAPI through ETL-focused examples",
    version="1.0.0",
)

# @app.get defines a GET endpoint at the path "/"
# The function name (root) is just a Python function -- FastAPI calls it on each request
@app.get("/")
def root():
    # Whatever you return here is automatically serialised to JSON
    return {"message": "FastAPI ETL Session is running", "status": "ok"}

# Health check endpoint -- standard practice in production APIs
# Used by load balancers and monitoring tools to verify the service is alive
@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "fastapi-etl"}



# -- EXTRACT stage --------------------------------------------------------------
# Extract = pull raw data from a source system (file, API, database, stream)
@app.post("/extract")
def extract():
    # Stub -- full implementation in Section 5
    return {"stage": "extract", "status": "stub -- not yet implemented"}

# -- TRANSFORM stage ------------------------------------------------------------
# Transform = clean, reshape, enrich the extracted data
@app.post("/transform")
def transform():
    return {"stage": "transform", "status": "stub -- not yet implemented"}

# -- LOAD stage -----------------------------------------------------------------
# Load = write the transformed data to a destination (database, warehouse, file)
@app.post("/load")
def load():
    return {"stage": "load", "status": "stub -- not yet implemented"}

# -- PIPELINE trigger -----------------------------------------------------------
# Orchestration endpoint -- runs all three stages in sequence
@app.post("/pipeline/run")
def run_pipeline():
    return {"pipeline": "extract -> transform -> load", "status": "stub"}
