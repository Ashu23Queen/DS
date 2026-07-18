'''this is the etl script for the project
which will grab real time data - from url 
'''

# importing the dependencies
import os
import json
import time
import datetime as dt
from pathlib import Path

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

