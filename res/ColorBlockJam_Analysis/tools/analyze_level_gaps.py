"""
Analyze which levels are missing between game indices and actual level data.
"""
import json

# Load GUIDs order (game order)
with open('res/ColorBlockJam_Analysis/level_data/AllLevels_guids.json', 'r') as f:
    guids_data = json.load(f)
guids = guids_data['level_guids']

# Load parsed levels
with open('res/ColorBlockJam_Analysis/level_data/parsed_levels_complete.json', 'r') as f:
    parsed = json.load(f)

# Create GUID -> level mapping
guid_to_level = {level['guid']: level for level in parsed}

print(f"Total GUIDs in game order: {len(guids)}")
print(f"Total parsed levels: {len(parsed)}")
print(f"Levels with matching GUIDs: {len([g for g in guids if g in guid_to_level])}")

print("\n" + "="*60)
print("Game indices 1-50 and their level data:")
print("="*60)

for i in range(50):
    guid = guids[i] if i < len(guids) else "N/A"
    level = guid_to_level.get(guid)
    
    if level:
        name = level.get('name', 'Unknown')
        grid = level.get('gridSize', {})
        gx, gy = grid.get('x', '?'), grid.get('y', '?')
        status = f"{name} ({gx}x{gy})"
    else:
        status = f"MISSING - GUID: {guid[:20]}..."
    
    print(f"  Game Index {i+1:3d}: {status}")

print("\n" + "="*60)
print("Missing levels (GUIDs without parsed data):")
print("="*60)

missing_count = 0
for i, guid in enumerate(guids[:100]):
    if guid not in guid_to_level:
        missing_count += 1
        print(f"  Game Index {i+1}: {guid}")

print(f"\nTotal missing in first 100: {missing_count}")


