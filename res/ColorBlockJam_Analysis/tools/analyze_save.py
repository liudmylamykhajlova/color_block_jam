import re

with open('res/ColorBlockJam_Analysis/phone_cache/Save.dat', 'rb') as f:
    data = f.read()
    
print(f'File size: {len(data)} bytes')
print(f'First 200 bytes (hex): {data[:200].hex()}')
print()

# Check if it's JSON
try:
    import json
    text = data.decode('utf-8', errors='ignore')
    parsed = json.loads(text)
    print("Save.dat is valid JSON!")
    print(f"Type: {type(parsed)}")
    if isinstance(parsed, dict):
        print(f"Keys: {list(parsed.keys())[:20]}")
except:
    print("Not valid JSON, analyzing as binary...")
    
print()
print('Looking for readable strings...')

# Find readable strings
strings = re.findall(rb'[a-zA-Z0-9_\-]{5,50}', data)
print(f'Found {len(strings)} strings')
print('Sample strings:')
for s in strings[:50]:
    decoded = s.decode('utf-8', errors='ignore')
    print(f'  {decoded}')
    
# Look for level-related data
print()
print('Level-related strings:')
for s in strings:
    decoded = s.decode('utf-8', errors='ignore').lower()
    if 'level' in decoded or 'guid' in decoded:
        print(f'  {s.decode("utf-8", errors="ignore")}')



