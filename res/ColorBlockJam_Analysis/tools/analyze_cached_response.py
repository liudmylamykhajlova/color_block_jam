import json
import os

# Analyze CACHED_OPEN_RESPONSE
config_path = 'res/ColorBlockJam_Analysis/phone_cache/CACHED_OPEN_RESPONSE'

with open(config_path, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Try to parse as JSON
try:
    data = json.loads(content)
    print("JSON parsed successfully!")
    print(f"Type: {type(data)}")
    
    if isinstance(data, dict):
        print(f"\nTop-level keys: {list(data.keys())}")
        
        for key, value in data.items():
            value_str = str(value)
            if len(value_str) > 200:
                print(f"\n{key}: [{len(value_str)} chars]")
                # Try to see if it's nested JSON
                if isinstance(value, str):
                    try:
                        inner = json.loads(value)
                        print(f"  Inner type: {type(inner)}")
                        if isinstance(inner, dict):
                            print(f"  Inner keys: {list(inner.keys())[:10]}")
                        elif isinstance(inner, list):
                            print(f"  List length: {len(inner)}")
                    except:
                        print(f"  Raw: {value[:200]}...")
                elif isinstance(value, dict):
                    print(f"  Dict keys: {list(value.keys())[:10]}")
                elif isinstance(value, list):
                    print(f"  List length: {len(value)}")
                    if len(value) > 0:
                        print(f"  First item type: {type(value[0])}")
            else:
                print(f"\n{key}: {value_str}")
                
except Exception as e:
    print(f"Not valid JSON: {e}")
    print(f"First 1000 chars: {content[:1000]}")


