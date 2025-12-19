#!/usr/bin/env python3
"""
Extract correct hardness and duration from Unity assets.
Uses Occurrence 2 of each GUID, which contains:
  - Offset +0: Duration as float (seconds)
  - Offset +4: Duration as float (duplicate)
  - Offset +8: Hardness as int (0=Normal, 1=Hard, 2=VeryHard)
"""
import os
import struct
import json

script_dir = os.path.dirname(os.path.abspath(__file__))
base_dir = os.path.dirname(script_dir)
data_path = os.path.join(base_dir, 'xapk_extracted/game_apk/assets/bin/Data')

HARDNESS_TYPES = {0: "Normal", 1: "Hard", 2: "VeryHard"}

def main():
    # Load level GUIDs
    guids_path = os.path.join(base_dir, "level_data/AllLevels_guids.json")
    with open(guids_path, 'r') as f:
        data_json = json.load(f)
    level_guids = data_json['level_guids']
    
    print(f"Total level GUIDs: {len(level_guids)}")
    
    # Read the combined asset file
    asset_file = os.path.join(data_path, "_combined_sharedassets2.assets")
    with open(asset_file, 'rb') as f:
        data = f.read()
    
    print(f"Asset file size: {len(data)} bytes")
    print("Extracting hardness and duration data...")
    
    # Collect raw data for each level first
    # The data before GUID[n] corresponds to level[n-1]
    raw_data_by_guid = {}
    
    for level_idx, guid in enumerate(level_guids):
        guid_bytes = guid.encode('utf-8')
        
        # Find all occurrences of this GUID
        occurrences = []
        pos = 0
        while len(occurrences) < 5:
            pos = data.find(guid_bytes, pos)
            if pos == -1:
                break
            occurrences.append(pos)
            pos += 1
        
        # We need Occurrence 2 (index 1)
        if len(occurrences) >= 2:
            pos = occurrences[1]  # Second occurrence (index 1)
            
            # Read data BEFORE the GUID
            # Pattern: [duration_float1][duration_float2][hardness_int][string_length][GUID]
            before_data = data[pos - 16:pos]
            if len(before_data) == 16:
                duration1 = struct.unpack('<f', before_data[0:4])[0]
                hardness = struct.unpack('<i', before_data[8:12])[0]
                string_len = struct.unpack('<i', before_data[12:16])[0]
                
                if string_len == 36 and 0 <= hardness <= 2:
                    raw_data_by_guid[guid] = {
                        "duration": int(duration1),
                        "hardness": hardness
                    }
    
    # Now map the data correctly: data before GUID[n+1] is for level[n]
    result = {}
    found_count = 0
    hard_levels = []
    very_hard_levels = []
    
    for level_idx, guid in enumerate(level_guids):
        # For level N, we need to find the data that was stored before the NEXT level's GUID
        next_level_idx = level_idx + 1
        
        if next_level_idx < len(level_guids):
            next_guid = level_guids[next_level_idx]
            if next_guid in raw_data_by_guid:
                raw = raw_data_by_guid[next_guid]
                hardness_type = HARDNESS_TYPES.get(raw["hardness"], "Unknown")
                
                result[guid] = {
                    "duration": raw["duration"],
                    "hardness": raw["hardness"],
                    "hardnessType": hardness_type
                }
                found_count += 1
                
                if raw["hardness"] == 1:
                    hard_levels.append(level_idx + 1)  # 1-based level number
                elif raw["hardness"] == 2:
                    very_hard_levels.append(level_idx + 1)
    
    print(f"\nSuccessfully extracted data for {found_count} levels")
    
    # Save results
    output_path = os.path.join(base_dir, "level_data/level_hardness.json")
    with open(output_path, 'w') as f:
        json.dump(result, f, indent=2)
    print(f"Saved to: {output_path}")
    
    # Print summary
    print(f"\n=== Summary ===")
    print(f"Total levels with data: {found_count}")
    print(f"Hard levels: {len(hard_levels)}")
    if hard_levels[:10]:
        print(f"  First Hard levels: {hard_levels[:10]}")
    print(f"VeryHard levels: {len(very_hard_levels)}")
    if very_hard_levels[:10]:
        print(f"  First VeryHard levels: {very_hard_levels[:10]}")
    
    # Show first 20 levels
    print("\n=== First 20 levels ===")
    for i, guid in enumerate(level_guids[:20], 1):
        if guid in result:
            info = result[guid]
            print(f"Level {i:2d}: Duration={info['duration']:3d}s, Hardness={info['hardnessType']}")
        else:
            print(f"Level {i:2d}: No data found")

if __name__ == "__main__":
    main()

