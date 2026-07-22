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
    "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson",
)    # United States Geological Survey
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://quake:quake@db:5432/quakes")
DATA_DIR = Path(os.getenv("DATA_DIR", "/data"))


def extract():
    """Download the last 24h of earthquakes from USGS (no API key needed!)."""
    print("[extract] downloading earthquakes from USGS ...")
    resp = requests.get(USGS_URL, timeout=30)
    resp.raise_for_status()
    data = resp.json()

    # Save the raw feed into our mounted /data folder so we can inspect it later.
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    stamp = dt.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    raw_path = DATA_DIR / f"usgs_raw_{stamp}.json"
    raw_path.write_text(json.dumps(data))

    print(f"[extract] got {len(data['features'])} quakes -> raw saved to {raw_path}")
    return data


def transform(data):
    """Pull out just the useful fields and drop anything without a magnitude."""
    rows = []
    for feature in data["features"]:
        props = feature["properties"]
        lon, lat, depth = feature["geometry"]["coordinates"]  # GeoJSON order!
        mag = props.get("mag")
        if mag is None:
            continue  # skip records with no magnitude
        rows.append({
            "id": feature["id"],
            "place": props.get("place"),
            "magnitude": mag,
            "depth_km": depth,
            "longitude": lon,
            "latitude": lat,
            "event_time": dt.datetime.utcfromtimestamp(props["time"] / 1000),
        })
    print(f"[transform] kept {len(rows)} quakes that have a magnitude")
    return rows


def get_connection(retries=10, delay=3):
    """Postgres can take a few seconds to wake up — so we retry politely."""
    for attempt in range(1, retries + 1):
        try:
            return psycopg2.connect(DATABASE_URL)
        except psycopg2.OperationalError:
            print(f"[load] db not ready ({attempt}/{retries}); waiting {delay}s ...")
            time.sleep(delay)
    raise RuntimeError("Could not connect to the database after several tries")


def load(rows):
    """Create the table if needed and upsert every quake into Postgres."""
    conn = get_connection()
    conn.autocommit = True
    cur = conn.cursor()

    cur.execute("""
        CREATE TABLE IF NOT EXISTS quakes (
            id         TEXT PRIMARY KEY,
            place      TEXT,
            magnitude  DOUBLE PRECISION,
            depth_km   DOUBLE PRECISION,
            longitude  DOUBLE PRECISION,
            latitude   DOUBLE PRECISION,
            event_time TIMESTAMP
        );
    """)

    for r in rows:
        cur.execute("""
            INSERT INTO quakes (id, place, magnitude, depth_km, longitude, latitude, event_time)
            VALUES (%(id)s, %(place)s, %(magnitude)s, %(depth_km)s,
                    %(longitude)s, %(latitude)s, %(event_time)s)
            ON CONFLICT (id) DO UPDATE SET
                magnitude = EXCLUDED.magnitude,
                place     = EXCLUDED.place;
        """, r)

    cur.execute("SELECT COUNT(*) FROM quakes;")
    total = cur.fetchone()[0]
    print(f"[load] database now holds {total} quakes")
    cur.close()
    conn.close()


def main():
    data = extract()
    rows = transform(data)
    load(rows)
    print("[done] ETL finished ✅")


if __name__ == "__main__":
    main()
