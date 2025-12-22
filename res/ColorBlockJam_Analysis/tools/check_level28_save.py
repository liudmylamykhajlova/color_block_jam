import re
import json

# Load the missing level GUIDs
missing_guids = [
    "3a21dc2a-95ed-42b1-aa96-24af7ffae92a",  # Game Index 28
    "648d6ef2-8c27-4583-8fca-4e03d8e16557",  # Game Index 29
    "7bf81a57-669f-4969-a86f-44e1c99a4c72",  # Game Index 30
    "ad8c6c0e-f2cf-41b9-b6e8-fcf8008c481e",  # Game Index 31
]

# Check Save.dat for these GUIDs
with open('res/ColorBlockJam_Analysis/phone_cache/Save_after28.dat', 'rb') as f:
    data = f.read()

text = data.decode('utf-8', errors='ignore')

print("Checking Save.dat for level 28-31 GUIDs...")
for guid in missing_guids:
    if guid in text:
        print(f"  FOUND: {guid}")
        # Find context
        idx = text.find(guid)
        context = text[max(0, idx-50):idx+50+len(guid)]
        print(f"    Context: ...{context}...")
    else:
        print(f"  NOT FOUND: {guid}")

# Also search for any GUIDs in the save file
print("\n" + "="*60)
print("All GUIDs found in Save.dat:")
all_guids = re.findall(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', text)
for guid in all_guids[:30]:
    print(f"  {guid}")

print(f"\nTotal GUIDs found: {len(all_guids)}")

# Check if Remote Config has changed
print("\n" + "="*60)
print("Comparing Remote Config files...")

with open('res/ColorBlockJam_Analysis/phone_cache/ELEPHANT_REMOTE_CONFIG_DATA', 'rb') as f:
    old_rc = f.read()

with open('res/ColorBlockJam_Analysis/phone_cache/ELEPHANT_REMOTE_CONFIG_DATA_after28', 'rb') as f:
    new_rc = f.read()

if old_rc == new_rc:
    print("Remote Config unchanged")
else:
    print(f"Remote Config CHANGED! Old: {len(old_rc)}, New: {len(new_rc)}")



