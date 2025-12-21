import os
import re

# Search in all binary files for Firebase Storage URLs
base_path = r'res\ColorBlockJam_Analysis\xapk_extracted\game_apk'

print("Searching for Firebase Storage URLs and level download patterns...")

all_files = []
for root, dirs, files in os.walk(base_path):
    for f in files:
        all_files.append(os.path.join(root, f))

# Patterns to search
patterns = [
    rb'firebasestorage\.googleapis\.com/[^\x00\s]+',
    rb'color-block-jam\.firebasestorage\.app[^\x00\s]*',
    rb'https://[^\x00\s"\']*level[^\x00\s"\']*',
    rb'gs://[^\x00\s]+',  # Firebase Storage URLs
]

for fpath in all_files:
    try:
        with open(fpath, 'rb') as f:
            data = f.read()
        
        for pattern in patterns:
            matches = re.findall(pattern, data, re.IGNORECASE)
            for match in matches:
                try:
                    url = match.decode('utf-8', errors='ignore')
                    print(f"\n{os.path.basename(fpath)}: {url}")
                except:
                    pass
                    
    except:
        pass

# Also search for RemoteConfig keys
print("\n" + "="*60)
print("Searching for RemoteConfig parameter names...")

metadata_path = os.path.join(base_path, 'assets', 'bin', 'Data', 'Managed', 'Metadata', 'global-metadata.dat')
with open(metadata_path, 'rb') as f:
    data = f.read()

# Look for strings that might be RemoteConfig keys (typically snake_case or camelCase)
# Focus on level-related ones
rc_patterns = [
    rb'new_levels',
    rb'remote_levels', 
    rb'level_pool',
    rb'levels_config',
    rb'additional_levels',
    rb'bonus_levels',
]

for pattern in rc_patterns:
    if pattern in data.lower():
        idx = data.lower().find(pattern)
        context = data[max(0,idx-20):idx+50]
        readable = ''.join(chr(b) if 32 <= b < 127 else '.' for b in context)
        print(f"Found: {readable}")

# Search for specific level count or index values
print("\n" + "="*60)
print("Searching for level count constants...")

# Look for HIGHEST_LEVEL_NUM or similar
level_count_patterns = [
    rb'HIGHEST_LEVEL',
    rb'MAX_LEVEL',
    rb'LEVEL_COUNT',
    rb'TOTAL_LEVELS',
]

for pattern in level_count_patterns:
    indices = [m.start() for m in re.finditer(pattern, data, re.IGNORECASE)]
    for idx in indices[:3]:
        context = data[max(0,idx-30):idx+80]
        strings = re.findall(rb'[A-Za-z_][A-Za-z0-9_]{3,40}', context)
        print(f"Found {pattern.decode()}: {[s.decode() for s in strings]}")


