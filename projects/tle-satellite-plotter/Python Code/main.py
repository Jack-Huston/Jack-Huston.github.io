"""
main.py

Purpose:
- Fetch active satellite TLEs from CelesTrak (cached)
- Parse into Satrec objects
- Propagate in an inertial frame (TEME) using SatrecArray
- Visualize smoothly in 3D using VisPy (GPU-accelerated points + Earth sphere)
"""

from datetime import datetime, timezone

#VisPy imports (GPU accelerated)
from vispy import app

from config import CELESTRAK_URL, CACHE_FILE, CACHE_TTL_SEC, MAX_SATELLITES, PROP_DT_SEC
from data_source import fetch_celestrak
from elements import parse_celestrak_tle
from propagation import Sgp4Propagator
from sat_viz_app import SatVizApp


def main():
    #Fetch TLE data from Celestrak with caching
    tle_data = fetch_celestrak(CELESTRAK_URL, CACHE_FILE, CACHE_TTL_SEC)
    print("TLE data fetched successfully.")

    #Parse TLE payload into Satellite objects
    satellites = parse_celestrak_tle(tle_data, max_sats=MAX_SATELLITES)
    print(f"Parsed {len(satellites)} satellites.")

    #Build vectorized propagator (SatrecArray)
    satrecs = [s.satrec for s in satellites]
    sat_names = [s.name for s in satellites]
    propagator = Sgp4Propagator(satrecs)

    #Print current UTC time and propagation time step
    start_utc = datetime.now(timezone.utc)
    print(f"Current UTC time: {start_utc.isoformat()}")
    print(f"Propagation time step: {PROP_DT_SEC} seconds")

    #Start visualization app (VisPy event loop drives updates)
    _ = SatVizApp(propagator=propagator, sat_names=sat_names, start_utc=start_utc)
    app.run()


if __name__ == "__main__":
    main()
