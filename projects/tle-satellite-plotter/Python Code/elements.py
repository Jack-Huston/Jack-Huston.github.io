from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Optional

from sgp4.api import Satrec

@dataclass(frozen=True) # Class is immutable after initialization
class Satellite:
    name: str
    satrec: Satrec
    tle1: str
    tle2: str

# Loaded TLE data is cleaned to remove blank lines and trailing spaces from Celesetrak
def _clean_tle_lines(payload: str) -> List[str]:
    # Strip whitespace-only lines and keep the rest
    return [ln.strip("\r\n") for ln in payload.splitlines() if ln.strip()]

# Helper functions to identify TLE line types
def _is_line1(line: str) -> bool:
    return len(line) > 0 and line[0] == "1"

def _is_line2(line: str) -> bool:
    return len(line) > 0 and line[0] == "2"


# Parse CelesTrak TLE text (name + line1 + line2) into Satellite objects.
# Inputs:
#   payload: str - Raw TLE text data from Celestrak
#   max_sats: Optional[int] - Maximum number of satellites to parse (None for no limit)
# Outputs:
#   List[Satellite] - List of parsed Satellite objects
def parse_celestrak_tle(payload: str, max_sats: Optional[int] = None) -> List[Satellite]:

    # Clean and split the TLE data into a list
    lines = _clean_tle_lines(payload)

    # Initialize empty satellite list and set initial index
    satellites: List[Satellite] = []
    i = 0

    # Iterate through lines in blocks of 3 (name, line1, line2)
    while i < len(lines):
        # Read the name line
        name = lines[i].strip()
        if i + 2 >= len(lines):
            break
        
        # Read line1 and line2
        l1 = lines[i + 1]
        l2 = lines[i + 2]

        # If we aren't aligned, look ahead for a valid 1/2 pair to reset positioning
        if not (_is_line1(l1) and _is_line2(l2)):
            # Try to find the next "1 ..." then "2 ..." pair
            j = i
            found = False
            
            # Look ahead for valid line1/line2 pair
            while j + 1 < len(lines):
                # Check for valid line1/line2
                if _is_line1(lines[j]) and _is_line2(lines[j + 1]):
                    # The name should be the non-1/2 line immediately before line1 (if present)
                    name = lines[j - 1].strip() if j - 1 >= 0 and not (_is_line1(lines[j - 1]) or _is_line2(lines[j - 1])) else "UNKNOWN"
                    l1 = lines[j]
                    l2 = lines[j + 1]
                    i = j - 1  # so the increment at end lands correctly
                    found = True
                    break
                j += 1

            if not found:
                break
        
        # Try to parse the TLE lines into a Satrec object
        try:
            satrec = Satrec.twoline2rv(l1, l2)
            satellites.append(Satellite(name=name, satrec=satrec, tle1=l1, tle2=l2))

        except Exception as e:
            pass  # Skip malformed TLE entries

        # Check if we've reached the maximum number of satellites to parse
        if max_sats is not None and len(satellites) >= max_sats:
            break

        # Move to next 3-line block
        i += 3

    # If no satellites were parsed, raise an error
    if not satellites:
        raise ValueError(
            "Parsed 0 satellites. This usually means the input isn't name/line1/line2 triples "
            "or lines were not cleanly separated. Inspect the first ~20 cleaned lines."
        )

    return satellites