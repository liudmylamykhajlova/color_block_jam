import os
import re

metadata_path = r'res\ColorBlockJam_Analysis\xapk_extracted\game_apk\assets\bin\Data\Managed\Metadata\global-metadata.dat'

with open(metadata_path, 'rb') as f:
    data = f.read()

# Search for more specific patterns
patterns = [
    b'RemoteConfig',
    b'AllLevels',
    b'LevelData',
    b'LevelManager',
    b'LevelController',
    b'GetLevel',
    b'LoadLevel',
    b'FetchLevel',
]

print("Searching for level-related class/method names...")
for pattern in patterns:
    indices = []
    start = 0
    while True:
        idx = data.find(pattern, start)
        if idx == -1:
            break
        indices.append(idx)
        start = idx + 1
    
    if indices:
        print(f"\n'{pattern.decode()}' found {len(indices)} times")
        # Show context for first few occurrences
        for idx in indices[:3]:
            # Try to extract surrounding readable text
            start = max(0, idx - 50)
            end = min(len(data), idx + len(pattern) + 100)
            chunk = data[start:end]
            # Find all readable strings in chunk
            strings = re.findall(rb'[A-Za-z_][A-Za-z0-9_<>\.]{3,60}', chunk)
            context = ' | '.join(s.decode('utf-8', errors='ignore') for s in strings[:10])
            print(f"  @ {idx}: {context}")

# Search for JSON keys that might be level config
print("\n" + "="*50)
print("Searching for level configuration keys...")
json_patterns = [
    b'"levels"',
    b'"levelData"',
    b'"level_',
    b'"allLevels"',
    b'"remoteLevels"',
]

for pattern in json_patterns:
    if pattern in data:
        idx = data.find(pattern)
        context = data[max(0, idx-30):idx+80]
        readable = ''.join(chr(b) if 32 <= b < 127 else '.' for b in context)
        print(f"Found {pattern.decode()}: ...{readable}...")



