import os
import datetime as dt
import pandas as pd

import requests
import psycopg2
import psycopg2.extras
from fastapi import FastAPI

DATABASE_URL = os.getenv("DATABASE_URL")  # present => DB mode; absent => live mode
USGS_URL = os.getenv(
    "USGS_URL",
    "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson",
)
# United States Geological Survey

app = FastAPI(title="Quake Tracker API 🌍")
 

def from_database(limit):
    query = """
        SELECT id, place, magnitude, depth_km, longitude, latitude, event_time 
        FROM quakes 
        ORDER BY magnitude DESC 
        LIMIT %s;
    """
    df = pd.read_sql_query(query, DATABASE_URL, params=(limit,))
    return df.to_dict(orient="records")


def from_live(limit):
    data = requests.get(USGS_URL, timeout=30).json()
    rows = []
    for f in data["features"]:
        p = f["properties"]
        lon, lat, depth = f["geometry"]["coordinates"]
        if p.get("mag") is None:
            continue
        rows.append({
            "id": f["id"],
            "place": p.get("place"),
            "magnitude": p["mag"],
            "depth_km": depth,
            "longitude": lon,
            "latitude": lat,
            "event_time": dt.datetime.utcfromtimestamp(p["time"] / 1000).isoformat(),
        })
    rows.sort(key=lambda r: r["magnitude"], reverse=True)
    return rows[:limit]
 

@app.get("/")
def home():
    return {
        "message": "Welcome to Quake Tracker 🌍",
        "data_source": "database" if DATABASE_URL else "live USGS feed",
        "try": ["/quakes", "/quakes/biggest", "/stats", "/docs"],
    }


@app.get("/quakes")
def quakes(limit: int = 10):
    """The strongest `limit` earthquakes from the last 24 hours."""
    return {"count": limit, "quakes": get_quakes(limit)}


@app.get("/quakes/biggest")
def biggest():
    """The single biggest earthquake right now."""
    top = get_quakes(1)
    return top[0] if top else {"message": "no data yet"}


@app.get("/stats")
def stats():
    """Quick numbers: how many, the max, and the average magnitude."""
    rows = get_quakes(1000)
    if not rows:
        return {"message": "no data yet"}
    mags = [r["magnitude"] for r in rows]
    return {
        "total_quakes": len(rows),
        "max_magnitude": max(mags),
        "avg_magnitude": round(sum(mags) / len(mags), 2),
    }
