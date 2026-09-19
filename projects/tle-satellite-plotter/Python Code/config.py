from pathlib import Path

# Define the JSON url path
CELESTRAK_URL = "https://celestrak.org/NORAD/elements/gp.php?GROUP=active&FORMAT=TLE"

# Ensure cache directory exists
CACHE_DIR = Path(".cache")
CACHE_DIR.mkdir(exist_ok=True)
CACHE_FILE = CACHE_DIR / "celestrak_active.txt"

# Set Cache expiration time in seconds
CACHE_TTL_SEC = 3600  # 1 hour

# Optional Maximum number of satellites to process
MAX_SATELLITES = None  # Set to an integer value to limit, or None for no limit

# Propagation time step in seconds
PROP_DT_SEC = 0.033 # 0.25 seconds