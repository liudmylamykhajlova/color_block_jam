import os
import re

# Search for API endpoints, URLs in game data
search_patterns = [
    rb'https?://[^\s\x00"\'<>]+',  # URLs
    rb'firebasestorage\.googleapis\.com',
    rb'firebaseio\.com', 
    rb'googleapis\.com',
    rb'level.*download',
    rb'download.*level',
    rb'remote.*level',
    rb'fetch.*level',
    rb'LevelService',
    rb'LevelManager',
    rb'RemoteConfig',
]

base_path = r'res\ColorBlockJam_Analysis\xapk_extracted\game_apk'

# Search in lib folder too
search_paths = [
    os.path.join(base_path, 'assets', 'bin', 'Data'),
    os.path.join(base_path, 'lib'),
]

found_urls = set()

for search_path in search_paths:
    if not os.path.exists(search_path):
        continue
        
    for root, dirs, files in os.walk(search_path):
        for fname in files:
            fpath = os.path.join(root, fname)
            try:
                with open(fpath, 'rb') as f:
                    data = f.read()
                    
                # Search for URLs
                urls = re.findall(rb'https?://[a-zA-Z0-9\-\._~:/?#\[\]@!$&\'()*+,;=%]+', data)
                for url in urls:
                    url_str = url.decode('utf-8', errors='ignore')
                    if len(url_str) > 15 and 'level' in url_str.lower():
                        found_urls.add((fname, url_str))
                        
                # Search for Firebase URLs specifically
                for pattern in [rb'firebasestorage', rb'firebaseio', rb'firebase']:
                    if pattern in data.lower():
                        idx = data.lower().find(pattern)
                        context = data[max(0, idx-50):idx+150]
                        print(f"\n{fname}: Found Firebase reference")
                        # Extract readable strings around it
                        strings = re.findall(rb'[a-zA-Z0-9\-\._/]{10,}', context)
                        for s in strings:
                            print(f"  {s.decode('utf-8', errors='ignore')}")
                        
            except Exception as e:
                pass

print("\n" + "="*50)
print("URLs containing 'level':")
for fname, url in sorted(found_urls):
    print(f"  {fname}: {url}")

# Also search in global-metadata.dat for strings
metadata_path = os.path.join(base_path, 'assets', 'bin', 'Data', 'Managed', 'Metadata', 'global-metadata.dat')
if os.path.exists(metadata_path):
    print("\n" + "="*50)
    print("Searching global-metadata.dat for level-related strings...")
    with open(metadata_path, 'rb') as f:
        data = f.read()
    
    # Extract all readable strings
    strings = re.findall(rb'[A-Za-z_][A-Za-z0-9_]{5,50}', data)
    level_strings = [s.decode('utf-8', errors='ignore') for s in strings 
                     if b'level' in s.lower() or b'remote' in s.lower() or b'download' in s.lower()]
    
    unique_strings = sorted(set(level_strings))[:100]
    print(f"Found {len(unique_strings)} unique level/remote/download related strings:")
    for s in unique_strings:
        print(f"  {s}")


