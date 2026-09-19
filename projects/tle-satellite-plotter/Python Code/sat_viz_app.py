"""
sat_viz_app.py

Purpose:
- VisPy visualization app for satellite propagation results
- Renders textured Earth + lat/lon grid + satellite point cloud smoothly

Fixes:
- Uses a Mesh + TextureFilter (works with frozen Mesh objects)
- Auto-downsamples huge texture images to avoid PIL DecompressionBombWarning and GPU pain
- Keeps Earth rotation via GMST in an inertial scene
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from pathlib import Path
import math
import time
import traceback

import numpy as np

from vispy import app, scene, io
from vispy.visuals import transforms
from vispy.visuals.filters import TextureFilter
from vispy.gloo import Texture2D

from config import PROP_DT_SEC
from propagation import Sgp4Propagator


#Earth radius used to normalize km -> Earth radii
EARTH_RADIUS_KM = 6378.137

#Satellite marker sizing
SAT_MARKER_SIZE = 4.0

#How often to print status line (seconds)
PRINT_STATUS_EVERY_SEC = 10.0

# Resolve the texture from this module so the app works from any working directory.
EARTH_TEX_PATH = Path(__file__).resolve().parent / "assets" / "earth_4k.png"

#Max texture dimension=
MAX_TEX_DIM = 4096


#Function computes GMST angle [rad] from UTC datetime (good enough for visualization)
def gmst_angle_rad(dt_utc: datetime) -> float:
    #Ensure UTC
    if dt_utc.tzinfo is None:
        raise ValueError("Input datetime must be timezone-aware.")
    dt_utc = dt_utc.astimezone(timezone.utc)

    #Julian Date (simple)
    y = dt_utc.year
    m = dt_utc.month
    d = dt_utc.day
    hr = dt_utc.hour
    mn = dt_utc.minute
    sc = dt_utc.second + dt_utc.microsecond * 1e-6

    if m <= 2:
        y -= 1
        m += 12
    A = y // 100
    B = 2 - A + (A // 4)

    jd0 = int(365.25 * (y + 4716)) + int(30.6001 * (m + 1)) + d + B - 1524.5
    frac_day = (hr + mn / 60.0 + sc / 3600.0) / 24.0
    jd = jd0 + frac_day

    T = (jd - 2451545.0) / 36525.0
    gmst_deg = (
        280.46061837
        + 360.98564736629 * (jd - 2451545.0)
        + 0.000387933 * T * T
        - (T * T * T) / 38710000.0
    )
    gmst_deg = gmst_deg % 360.0
    return math.radians(gmst_deg)


#Function generates a UV sphere mesh (vertices, faces, texcoords)
def make_uv_sphere(radius: float = 1.0, n_lat: int = 90, n_lon: int = 180):
    #Latitude from -pi/2..pi/2, Longitude from 0..2pi
    lats = np.linspace(-0.5 * np.pi, 0.5 * np.pi, n_lat, dtype=np.float64)
    lons = np.linspace(0.0, 2.0 * np.pi, n_lon, dtype=np.float64)

    #Grid
    lon_grid, lat_grid = np.meshgrid(lons, lats)

    #Sphere coordinates
    x = radius * np.cos(lat_grid) * np.cos(lon_grid)
    y = radius * np.cos(lat_grid) * np.sin(lon_grid)
    z = radius * np.sin(lat_grid)

    #Vertices (N,3)
    vertices = np.column_stack([x.ravel(), y.ravel(), z.ravel()]).astype(np.float32)

    #Texture coordinates (u,v) in [0,1]
    u = (lon_grid / (2.0 * np.pi)).astype(np.float32)
    v = (1.0 - (lat_grid + 0.5 * np.pi) / np.pi).astype(np.float32)
    texcoords = np.column_stack([u.ravel(), v.ravel()]).astype(np.float32)

    #Faces
    faces = []
    for i in range(n_lat - 1):
        for j in range(n_lon - 1):
            i0 = i * n_lon + j
            i1 = i0 + 1
            i2 = i0 + n_lon
            i3 = i2 + 1
            faces.append([i0, i2, i1])
            faces.append([i1, i2, i3])

        #Wrap seam
        j = n_lon - 1
        i0 = i * n_lon + j
        i1 = i * n_lon + 0
        i2 = (i + 1) * n_lon + j
        i3 = (i + 1) * n_lon + 0
        faces.append([i0, i2, i1])
        faces.append([i1, i2, i3])

    faces = np.asarray(faces, dtype=np.uint32)
    return vertices, faces, texcoords


#Function builds a lat/lon grid as a single Line visual (with NaN breaks)
def build_latlon_grid(step_deg: float = 15.0, n_pts: int = 180) -> np.ndarray:
    def _append_segment(out_list, xyz):
        out_list.append(xyz)
        out_list.append(np.array([[np.nan, np.nan, np.nan]], dtype=np.float32))

    segs = []

    #Latitude lines
    lats = np.arange(-90.0 + step_deg, 90.0, step_deg)
    lons = np.linspace(0.0, 360.0, n_pts, endpoint=True)

    for lat in lats:
        lat_r = math.radians(lat)
        clat = math.cos(lat_r)
        slat = math.sin(lat_r)

        lon_r = np.radians(lons)
        x = clat * np.cos(lon_r)
        y = clat * np.sin(lon_r)
        z = np.full_like(x, slat)
        xyz = np.column_stack([x, y, z]).astype(np.float32)
        _append_segment(segs, xyz)

    #Longitude lines
    lons2 = np.arange(0.0, 360.0, step_deg)
    lats2 = np.linspace(-90.0, 90.0, n_pts, endpoint=True)

    for lon in lons2:
        lon_r = math.radians(lon)
        cl = math.cos(lon_r)
        sl = math.sin(lon_r)

        lat_r = np.radians(lats2)
        x = np.cos(lat_r) * cl
        y = np.cos(lat_r) * sl
        z = np.sin(lat_r)

        xyz = np.column_stack([x, y, z]).astype(np.float32)
        _append_segment(segs, xyz)

    return np.vstack(segs)


#Function loads Earth texture and downsamples if too large
def load_earth_texture(path: Path, max_dim: int = 4096) -> np.ndarray:
    if not path.exists():
        raise FileNotFoundError(f"Earth texture not found: {path.resolve()}")

    img = io.read_png(str(path))

    #Ensure uint8 image
    if img.dtype != np.uint8:
        img = img.astype(np.uint8)

    #Downsample if needed (nearest is fine; you can switch to a better resampler later)
    h, w = img.shape[0], img.shape[1]
    scale = max(h / max_dim, w / max_dim)

    if scale > 1.0:
        new_h = int(h / scale)
        new_w = int(w / scale)

        #Simple stride-based downsample (fast, avoids extra deps)
        #This is good enough for a first pass and prevents huge memory usage.
        step_y = max(1, h // new_h)
        step_x = max(1, w // new_w)
        img = img[::step_y, ::step_x]

        print(f"Downsampled Earth texture: {w}x{h} -> {img.shape[1]}x{img.shape[0]}")

    return img


class SatVizApp:
    def __init__(self, propagator: Sgp4Propagator, sat_names: list[str], start_utc: datetime):
        #Store propagation tools and metadata
        self.propagator = propagator
        self.sat_names = sat_names
        self.n = len(sat_names)

        #Initialize simulation time
        self.sim_time = start_utc

        #Step counter
        self.step = 0

        #Timing for status prints
        self._last_status_wall = time.perf_counter()

        #Auto-fit camera once
        self._camera_fitted = False

        #Preallocate buffers
        self.r_earth_radii_full = np.zeros((self.n, 3), dtype=np.float32)

        #Build scene
        self._build_scene()

        #Timer
        self.timer = app.Timer(interval=PROP_DT_SEC, connect=self.on_timer, start=True)

    def _build_scene(self):
        #Create canvas
        self.canvas = scene.SceneCanvas(
            keys="interactive",
            size=(1200, 800),
            bgcolor="black",
            show=True,
            title="Live Satellite Visualization (TEME inertial frame)",
        )

        #View
        self.view = self.canvas.central_widget.add_view()
        self.view.camera = scene.cameras.TurntableCamera(
            fov=45,
            distance=8.0,
            elevation=20,
            azimuth=30
        )

        #Earth rotation transform (shared by Earth + grid)
        self.earth_xform = transforms.MatrixTransform()

        #Build textured Earth mesh
        verts, faces, uvs = make_uv_sphere(radius=1.0, n_lat=90, n_lon=180)
        self.earth = scene.visuals.Mesh(
            vertices=verts,
            faces=faces,
            parent=self.view.scene,
            shading=None
        )
        self.earth.transform = self.earth_xform

        #Load + downsample texture (prevents decompression bomb + GPU thrash)
        tex_img = load_earth_texture(EARTH_TEX_PATH, max_dim=MAX_TEX_DIM)

        #Attach texture via TextureFilter (works with frozen Mesh)
        tf = TextureFilter(tex_img, uvs)
        self.earth.attach(tf)

        #Lat/lon grid overlay
        grid_xyz = build_latlon_grid(step_deg=15.0, n_pts=180)
        self.latlon = scene.visuals.Line(
            pos=grid_xyz,
            color=(0.85, 0.85, 0.85, 0.25),
            width=1.0,
            method="gl",
            parent=self.view.scene
        )
        self.latlon.transform = self.earth_xform

        #Sat markers
        self.sat_markers = scene.visuals.Markers(parent=self.view.scene)

        #Initialize with a dummy point so data is always valid
        init_pts = np.array([[2.0, 0.0, 0.0]], dtype=np.float32)
        self.sat_markers.set_data(init_pts, size=SAT_MARKER_SIZE, face_color=(1, 1, 1, 1), edge_color=None)

        #Text display (HUD)
        self.hud = scene.visuals.Text(
            text="Initializing...",
            color="white",
            font_size=12,
            pos=(10, 10),
            anchor_x="left",
            anchor_y="bottom",
            parent=self.canvas.scene
        )

    def on_timer(self, event):
        try:
            #Propagate all sats to current sim time
            res = self.propagator.propagate_datetime(self.sim_time)

            #Extract errors
            err = np.asarray(res.err)
            if err.ndim == 2 and err.shape[1] == 1:
                err = err[:, 0]
            if err.ndim == 2:
                err = np.diag(err)

            #Positions
            r_km = np.asarray(res.r_km)
            if r_km.ndim == 3 and r_km.shape[1] == 1:
                r_km = r_km[:, 0, :]

            #Validity mask
            finite_mask = np.isfinite(r_km).all(axis=1)
            good_mask = (err == 0) & finite_mask
            n_ok = int(good_mask.sum())
            n_bad = self.n - n_ok

            #Normalize and filter for plotting
            self.r_earth_radii_full[:] = (r_km / EARTH_RADIUS_KM).astype(np.float32)

            if n_ok > 0:
                pts = self.r_earth_radii_full[good_mask]
            else:
                pts = np.array([[2.0, 0.0, 0.0]], dtype=np.float32)

            #Update satellite point cloud
            self.sat_markers.set_data(pts, size=SAT_MARKER_SIZE, face_color=(1, 1, 1, 1), edge_color=None)

            #Rotate Earth to real-world orientation under inertial satellites (GMST about +Z)
            theta = gmst_angle_rad(self.sim_time)
            self.earth_xform.reset()
            self.earth_xform.rotate(np.degrees(theta), (0, 0, 1))

            #Auto-fit camera once
            if (not self._camera_fitted) and (n_ok > 0):
                radii = np.linalg.norm(pts, axis=1)
                r_max = float(np.nanmax(radii))
                r_max = max(r_max, 2.0)
                self.view.camera.distance = r_max * 2.2
                self._camera_fitted = True

            #HUD
            self.hud.text = (
                f"UTC: {self.sim_time.isoformat(timespec='seconds')}  |  "
                f"total={self.n} ok={n_ok} bad={n_bad} | dt={PROP_DT_SEC}s"
            )

            #Periodic status print
            wall_now = time.perf_counter()
            if wall_now - self._last_status_wall > PRINT_STATUS_EVERY_SEC:
                self._last_status_wall = wall_now
                if n_ok > 0:
                    idx0 = int(np.flatnonzero(good_mask)[0])
                    print(f"[{self.sim_time.isoformat()}] ok={n_ok} bad={n_bad} example={self.sat_names[idx0]}")
                else:
                    print(f"[{self.sim_time.isoformat()}] ok=0 bad={n_bad}")

            #Advance simulation time
            self.sim_time = self.sim_time + timedelta(seconds=PROP_DT_SEC)
            self.step += 1

        except Exception:
            print("\n--- Exception in SatVizApp.on_timer ---")
            traceback.print_exc()
            print("--- End exception ---\n")
            self.timer.stop()
