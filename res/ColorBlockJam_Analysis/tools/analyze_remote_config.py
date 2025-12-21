import json
import os

# Analyze ELEPHANT_REMOTE_CONFIG_DATA
config_path = 'res/ColorBlockJam_Analysis/phone_cache/ELEPHANT_REMOTE_CONFIG_DATA'

with open(config_path, 'r', encoding='utf-8', errors='ignore') as f:
    data = json.load(f)

inner_data = data.get('data', {})
keys = inner_data.get('keys', [])
values = inner_data.get('values', [])

print(f"Keys count: {len(keys)}")
print(f"Values count: {len(values)}")

print("\nAll keys:")
for i, key in enumerate(keys):
    print(f"  {i}: {key}")

# Find level-related keys
print("\n" + "="*60)
print("Level-related keys and values:")
print("="*60)

for i, key in enumerate(keys):
    if 'level' in key.lower() or 'Level' in key:
        value = values[i] if i < len(values) else None
        print(f"\n{key}:")
        if isinstance(value, str):
            if len(value) > 500:
                print(f"  Value ({len(value)} chars): {value[:500]}...")
            else:
                print(f"  Value: {value}")
        else:
            print(f"  Value: {value}")

# Check for new_levels specifically
print("\n" + "="*60)
print("Looking for 'new' related keys:")
print("="*60)

for i, key in enumerate(keys):
    if 'new' in key.lower():
        value = values[i] if i < len(values) else None
        print(f"\n{key}:")
        value_str = str(value)
        if len(value_str) > 1000:
            print(f"  Value ({len(value_str)} chars): {value_str[:1000]}...")
        else:
            print(f"  Value: {value_str}")
