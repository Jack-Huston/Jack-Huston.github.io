# TLE-Plotter — Setup + Run Instructions

This project:
- Downloads the latest **active satellite** TLEs from CelesTrak (cached locally)
- Parses them into SGP4 `Satrec` objects
- Propagates all satellites in an **inertial TEME frame** using `SatrecArray`
- Visualizes satellites as a GPU-accelerated point cloud around a textured Earth using **VisPy**

---

## Folder layout

Expected structure:

```
TLE-Plotter/
  assets/
    earth_4k.png
  .cache/
    (created automatically)
  config.py
  data_source.py
  elements.py
  propagation.py
  sat_viz_app.py
  main.py
```

---

## Requirements

### Python
- Recommended: **Python 3.10–3.12**

### Python packages
Install these packages into a clean environment:
- `numpy`
- `requests`
- `sgp4`
- `vispy`
- **A Qt backend for VisPy**: `PyQt6` (recommended) or `PySide6`
- Optional but recommended for robust image loading: `pillow` (and/or `imageio`)

## Run the app

From the project root:

```powershell
python main.py
```

You should see console output like:
- “Fetching fresh TLE data…” or “Using cached TLE data.”
- “Parsed N satellites.”
- Then a VisPy window opens.

---

## Configure behavior

Edit `config.py`:

- `CELESTRAK_URL`: data source (default is ACTIVE satellites, TLE format)
- `CACHE_TTL_SEC`: cache duration (seconds)
- `MAX_SATELLITES`: limit count for performance testing (`None` = all)
- `PROP_DT_SEC`: propagation time step (seconds)

Suggested values:
- Start with `MAX_SATELLITES = 2000` while iterating
- Use `PROP_DT_SEC = 0.05` to `0.25` for smooth updates

---

## Notes
- The scene is **inertial** (satellites propagated in TEME), with Earth rotation handled visually.
- This is meant for **visualization**, not precision orbit determination.

