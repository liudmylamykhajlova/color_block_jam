"""
Check Firebase Storage for available level files.
Firebase Storage bucket: color-block-jam.firebasestorage.app
"""
import urllib.request
import urllib.error
import json
import ssl

# Disable SSL verification for testing
ssl._create_default_https_context = ssl._create_unverified_context

# Firebase Storage URLs to try
bucket = "color-block-jam"

def try_url(url, desc=""):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as resp:
            content = resp.read().decode('utf-8', errors='ignore')
            print(f"  SUCCESS: {desc or url}")
            print(f"  Status: {resp.status}")
            try:
                data = json.loads(content)
                print(f"  JSON: {json.dumps(data, indent=2)[:500]}")
            except:
                print(f"  Content: {content[:500]}")
            return True
    except urllib.error.HTTPError as e:
        print(f"  HTTP Error {e.code}: {desc or url}")
        return False
    except Exception as e:
        print(f"  Error: {desc or url} - {e}")
        return False

print("Attempting to access Firebase Storage...")
print("="*60)

# Try to list files in bucket
urls_to_try = [
    (f"https://firebasestorage.googleapis.com/v0/b/{bucket}.appspot.com/o", "List bucket (appspot)"),
    (f"https://firebasestorage.googleapis.com/v0/b/{bucket}.firebasestorage.app/o", "List bucket (firebasestorage.app)"),
]

for url, desc in urls_to_try:
    try_url(url, desc)
    print()

# Try specific level file paths
print("="*60)
print("Trying specific level file paths...")

file_paths = [
    "levels/level28.json",
    "levels/Level28.json", 
    "Level28",
    "level28",
    "newLevels/28",
    "data/levels/28",
]

for path in file_paths:
    encoded_path = urllib.parse.quote(path, safe='')
    url = f"https://firebasestorage.googleapis.com/v0/b/{bucket}.appspot.com/o/{encoded_path}?alt=media"
    try_url(url, f"Download {path}")
