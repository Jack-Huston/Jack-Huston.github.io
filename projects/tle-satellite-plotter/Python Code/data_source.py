import time
from pathlib import Path
import requests

#Function checks to ensure that the cached TLE data is still valid based on the TTL setting
def _is_cache_fresh(cache_file: Path, ttl_sec: int) -> bool:
    #Check if cache file exists (ifi it doesn't, it's not fresh)
    if not cache_file.exists():
        return False
    
    #Calculate age of cache file and compare to TTL allowable age
    cache_age = time.time() - cache_file.stat().st_mtime
    return cache_age < ttl_sec

#Function to fetch TLE data from Celestrak with caching mechanism
def fetch_celestrak(url: str, cache_file: Path, ttl_sec: int, force: bool = False) -> str:
    
    # Return cached data if valid and not forced to refresh
    if not force and _is_cache_fresh(cache_file, ttl_sec):
        #Print message indicating cache hit
        print("Using cached TLE data.")
        
        #Read and return cached data
        return cache_file.read_text(encoding = "utf-8")
    
    #Print message indicating cache miss
    print("Fetching fresh TLE data from Celestrak.")
    
    # Otherwise, fetch fresh data from the URL
    response = requests.get(url, timeout = 30)
    response.raise_for_status()
    
    # Save the fresh data to cache
    text = response.text
    cache_file.write_text(text, encoding = "utf-8")
    
    # Return the fetched data
    return text

