"""
propagation.py

Purpose:
- Convert datetime -> (jd, fr)
- Batch propagate many Satrec objects using SatrecArray
- Uses a SINGLE time sample (length-1 arrays) to avoid NxN broadcasting
- Returns r_km and v_km_s arrays of shape (N, 3) plus err shape (N,)
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import List, Tuple

import numpy as np
from sgp4.api import Satrec, SatrecArray, jday


@dataclass
class PropResult:
    #TEME position [km] and velocity [km/s], shape: (N, 3)
    r_km: np.ndarray
    v_km_s: np.ndarray
    err: np.ndarray


#Function converts a timezone-aware datetime to Julian Date and fractional day
def datetime_to_jd_fr(dt: datetime) -> Tuple[float, float]:
    #Ensure datetime is timezone-aware
    if dt.tzinfo is None:
        raise ValueError("Input datetime must be timezone-aware (use timezone.utc).")

    #Convert to UTC
    dt_utc = dt.astimezone(timezone.utc)

    #Compute Julian day + fractional day
    jd, fr = jday(
        dt_utc.year,
        dt_utc.month,
        dt_utc.day,
        dt_utc.hour,
        dt_utc.minute,
        dt_utc.second + dt_utc.microsecond * 1e-6
    )
    return float(jd), float(fr)


class Sgp4Propagator:
    #Initialize propagator with a list of Satrec objects
    def __init__(self, satrecs: List[Satrec]):
        #Check inputs
        if not satrecs:
            raise ValueError("At least one Satrec is required to initialize the propagator.")

        #Store satellite count
        self.n = len(satrecs)

        #Create SatrecArray for batch propagation
        self.arr = SatrecArray(satrecs)

        #Preallocate LENGTH-1 time arrays (required by this sgp4 wrapper)
        #Important: length-1 avoids NxN broadcasting while still satisfying .astype() expectations
        self._jd1 = np.empty(1, dtype=np.float64)
        self._fr1 = np.empty(1, dtype=np.float64)

    #Propagate all satellites to a single (jd, fr) time
    def propagate(self, jd: float, fr: float) -> PropResult:
        #Fill the single time sample
        self._jd1[0] = jd
        self._fr1[0] = fr

        #Call sgp4 with (T=1) arrays
        err, r, v = self.arr.sgp4(self._jd1, self._fr1)

        #Convert to numpy
        err = np.asarray(err, dtype=np.int32)
        r = np.asarray(r, dtype=np.float64)
        v = np.asarray(v, dtype=np.float64)

        #Expected shapes from SatrecArray when T=1:
        # err: (N, 1)
        # r:   (N, 1, 3)
        # v:   (N, 1, 3)
        #Squeeze the time dimension
        if err.ndim == 2 and err.shape[1] == 1:
            err = err[:, 0]
        if r.ndim == 3 and r.shape[1] == 1:
            r = r[:, 0, :]
        if v.ndim == 3 and v.shape[1] == 1:
            v = v[:, 0, :]

        #Final sanity checks
        if err.shape != (self.n,):
            raise ValueError(f"Unexpected err shape {err.shape}; expected ({self.n},)")
        if r.shape != (self.n, 3):
            raise ValueError(f"Unexpected r shape {r.shape}; expected ({self.n}, 3)")
        if v.shape != (self.n, 3):
            raise ValueError(f"Unexpected v shape {v.shape}; expected ({self.n}, 3)")

        return PropResult(r_km=r, v_km_s=v, err=err)

    #Propagate all satellites to a timezone-aware datetime
    def propagate_datetime(self, dt: datetime) -> PropResult:
        jd, fr = datetime_to_jd_fr(dt)
        return self.propagate(jd, fr)
