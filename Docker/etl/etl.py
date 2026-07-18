'''this is the etl script for the project
which will grab real time data - from url 
'''

# importing the dependencies
import os
import json
import time # import time: Provides time-related functions. it’s often used to add delays (time.sleep())

import datetime as dt
from pathlib import Path

# Third-Party Libraries (External)
import requests
import psycopg2
'''
Third-Party Libraries (External)
import requests: The standard library for making HTTP requests in Python. 
It allows your script to talk to the internet—downloading web pages, 
sending data, or fetching information from external APIs.

import psycopg2: The most popular PostgreSQL database adapter for Python. 
It allows your script to connect to a PostgreSQL database, run SQL queries, insert data, and manage transactions.
''' 

# --- Config (all read from environment variables so the container is flexible) ---
USGS_URL = os.getenv(
    "USGS_URL",
    "#",
)
DATABASE_URL = os.getenv("DATABASE_URL", "#")
DATA_DIR = Path(os.getenv("DATA_DIR", "#"))





