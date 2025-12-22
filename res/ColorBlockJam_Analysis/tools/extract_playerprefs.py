import tarfile
import xml.etree.ElementTree as ET

tar_path = 'res/ColorBlockJam_Analysis/phone_cache/backup_extracted/backup.tar'

with tarfile.open(tar_path, 'r') as tar:
    # Extract playerprefs
    prefs_path = 'apps/com.GybeGames.ColorBlockJam/sp/com.GybeGames.ColorBlockJam.v2.playerprefs.xml'
    member = tar.getmember(prefs_path)
    f = tar.extractfile(member)
    content = f.read().decode('utf-8')
    
# Parse XML
root = ET.fromstring(content)

print("PlayerPrefs contents:")
print("="*60)

# Look for level-related entries
level_entries = []
for child in root:
    name = child.get('name', '')
    value = child.text or child.get('value', '')
    
    if 'level' in name.lower() or 'Level' in name:
        level_entries.append((name, value))
        print(f"\n{name}:")
        if len(str(value)) > 200:
            print(f"  Value ({len(str(value))} chars): {str(value)[:200]}...")
        else:
            print(f"  Value: {value}")

print(f"\n\nTotal level-related entries: {len(level_entries)}")

# Also look for any GUIDs
print("\n" + "="*60)
print("Looking for GUIDs in playerprefs...")
import re
guid_pattern = r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
guids = re.findall(guid_pattern, content)
print(f"Found {len(guids)} GUIDs")
for g in guids[:20]:
    print(f"  {g}")



