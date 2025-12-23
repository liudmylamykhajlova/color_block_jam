# Color Block Jam - Game Analysis

> **Version:** 1.0.0  
> **Date:** 2025-12-23  
> **Sources:** App Store, XAPK reverse-engineering, Game screenshots

---

## 1. General Information

### 1.1 App Store Data

| Parameter | Value |
|-----------|-------|
| Name | Color Block Jam |
| Publisher | **Rollic Games** |
| Developer | Gybe Games |
| Package ID | com.GybeGames.ColorBlockJam |
| Version | 1.31.16 |
| Engine | Unity (IL2CPP) |
| Category | Puzzle |
| Rating | 4.6 (107K reviews) |
| Age | 13+ |
| Size | 468.6 MB |
| Languages | English, Arabic |
| Platforms | iOS 15+, Android |

### 1.2 Content Statistics (from XAPK)

| Content | Count |
|---------|-------|
| Total Levels | 1557 |
| Levels with Ice | 370 |
| Levels with Inner Layers | 243 |
| Levels with Move Restrictions | 689 |

---

## 2. Visual Style

### 2.1 Color Palette (10 colors)

| ID | Name | HEX | RGB |
|----|------|-----|-----|
| 0 | Blue | #03a5ef | (3, 165, 239) |
| 1 | Dark Blue | #143cf6 | (20, 60, 246) |
| 2 | Green | #48aa1a | (72, 170, 26) |
| 3 | Pink | #b844c8 | (184, 68, 200) |
| 4 | Purple | #7343db | (115, 67, 219) |
| 5 | Yellow | #fbb32d | (251, 179, 45) |
| 6 | Dark Green | #09521d | (9, 82, 29) |
| 7 | Orange | #f2772b | (242, 119, 43) |
| 8 | Red | #b8202c | (184, 32, 44) |
| 9 | Cyan | #0facae | (15, 172, 174) |

### 2.2 Block Style
- LEGO-like design
- Circular stud in center of each cell
- Dark outline around block
- Subtle gradient/shadow for 3D effect

### 2.3 Board Frame
- Dark gray/black frame (NOT wooden)
- Subtle 3D effect
- Doors embedded as colored strips on edges

---

## 3. Block Types (12 shapes)

| ID | Name | Shape | Cells |
|----|------|-------|-------|
| 0 | One | `#` | 1 |
| 1 | Two | `##` | 2 |
| 2 | Three | `###` | 3 |
| 3 | L | L-shape | 4 |
| 4 | ReverseL | Mirrored L | 4 |
| 5 | ShortL | Short L (2+1) | 3 |
| 6 | Plus | Cross (+) | 5 |
| 7 | TwoSquare | 2x2 square | 4 |
| 8 | ShortT | T-shape (3+1) | 4 |
| 9 | Z | Z-shape | 4 |
| 10 | ReverseZ | S-shape | 4 |
| 11 | U | U-shape | 5 |

---

## 4. Game Mechanics

### 4.1 Basic Movement (DONE)
- Drag & drop blocks
- Move horizontally or vertically
- Collisions with other blocks
- Exit through matching color doors

### 4.2 Movement Direction Restriction (DONE)

| Type | Description | Visual |
|------|-------------|--------|
| Both | Move any direction | No arrows |
| Horizontal | Only left-right | White arrows |
| Vertical | Only up-down | White arrows |

**Binary:** offset +32 (flag1), offset +40 (flag2)

### 4.3 Frozen Blocks / Ice (DONE)
- Block covered with cyan ice overlay
- Number shows blocks to exit before unfreezing
- Each exited block decreases counter
- Unfreezes when iceCount = 0

**Binary:** offset +44 (isFrozen flag), offset +48 (iceCount)

### 4.4 Multi-layer Blocks (DONE)
- Two colors: outer (outline) + inner (fill)
- Touch outer color door = destroy outer layer
- Then exit through inner color door

**Binary:** offset +96 (hasInnerLayer), offset +100 (innerBlockType)

### 4.5 Blockers (NOT IMPLEMENTED)
```csharp
bool _isBlocker;
bool _isBlockerFixed;
int _blockerCounter;
```

### 4.6 Rainbow Blocks (NOT IMPLEMENTED)
```csharp
bool _isRainbow;
```
- Can enter any color door

### 4.7 Time Capsule (NOT IMPLEMENTED)
```csharp
bool _hasTimeCapsule;
int _timeCapsuleDuration;
```
- Adds time when block exits

### 4.8 Color Switcher (NOT IMPLEMENTED)
```csharp
bool _hasColorSwitcher;
int _colorSwitcherBlockType;
```

---

## 5. Level Elements (LevelElementType)

| ID | Name | Description | Status |
|----|------|-------------|--------|
| 0 | None | No element | - |
| 1 | Ice | Ice on block | DONE |
| 2 | Star | Bonus star | TODO |
| 3 | Key | Key item | TODO |
| 4 | Lock | Lock mechanism | TODO |
| 5 | TimerBomb | Timed bomb | TODO |
| 6 | Curtain | Curtain | TODO |
| 7 | Scissors | Scissors | TODO |
| 8 | Ropes | Ropes | TODO |
| 9 | HiddenColor | Hidden color | TODO |
| 10 | CountBomb | Count bomb | TODO |

---

## 6. Door Mechanics

### 6.1 Basic Doors (DONE)
- Position on frame (top/bottom/left/right)
- Color matching blocks
- Part count (1-5)

### 6.2 Star Door (NOT IMPLEMENTED)
```csharp
bool _hasStar;
```

### 6.3 Switch Door (NOT IMPLEMENTED)
```csharp
bool _isSwitchDoor;
```

### 6.4 Ice Door (NOT IMPLEMENTED)
```csharp
bool _hasIce;
int _iceCount;
```

---

## 7. Monetization

### 7.1 In-App Purchases (App Store USD)

| Product | Price |
|---------|-------|
| Coin Pack 1 | $1.99 |
| Fail Offer | $4.99 |
| Coin Pack 2 | $7.99 |
| Golden Ticket | $9.99 |
| No Ads Bundle | $11.99 |
| Coin Pack 3 | $14.99 |
| Medium Bundle | $19.99 |
| Coin Pack 4 | $29.99 |

### 7.2 In-Game Prices (UAH from screenshots)

| Coins | Price |
|-------|-------|
| 1,000 | 79.99 UAH |
| 5,000 | 284.99 UAH |
| 10,000 | 549.99 UAH |
| 25,000 | 1,099.99 UAH |
| 50,000 | 1,949.99 UAH |
| 100,000 | 3,649.99 UAH |

### 7.3 Remove Ads (284.99 UAH)
- Removes: Interstitial ads
- Removes: Bottom banner ads
- Keeps: Optional rewarded ads

### 7.4 Social Rewards
- Instagram Like: +100 coins
- Facebook Follow: +100 coins
- TikTok Follow: +100 coins

---

## 8. Game Systems

### 8.1 Lives System
| Parameter | Value |
|-----------|-------|
| Display | "Full 5" |
| Max Lives | 5 |
| Refill Time | ~30 min / life |
| Lose on | Level fail (time out) |

### 8.2 Timer System
| Difficulty | Time |
|------------|------|
| Easy | 60-90s |
| Medium | 45-60s |
| Hard | 30-45s |
| Expert | 20-30s |

### 8.3 Boosters (from screenshots)
| Icon | Name | Function |
|------|------|----------|
| Clock | Extra Time | +15 seconds |
| Hammer | Destroy | Remove one block |
| Drill | Unknown | TBD |
| Pause | Pause | Pause game |

---

## 9. Level Structure

### 9.1 Grid Sizes Distribution

| Size | Count |
|------|-------|
| 6x8 | 254 |
| 7x7 | 241 |
| 6x6 | 176 |
| 8x8 | 124 |
| 6x7 | 115 |
| 7x6 | 94 |
| 8x9 | 81 |
| Other | 472 |

### 9.2 Level Map (from screenshots)
- Vertical scrollable path
- Levels connected by rope
- Colors:
  - Green = Current/Available
  - Red + Skull = Hard
  - Purple + Skull = Boss
  - Lock = Locked

---

## 10. Binary Structure

### 10.1 Block (156 bytes)

| Offset | Size | Type | Field |
|--------|------|------|-------|
| 0x00 | 12 | Vector3 | position |
| 0x0C | 12 | Vector3 | rotation |
| 0x18 | 12 | Vector3 | scale |
| 0x24 | 4 | int32 | blockGroupType (shape) |
| 0x28 | 4 | int32 | blockType (color) |
| 0x20 | 4 | int32 | moveDir flag 1 |
| 0x28 | 4 | int32 | moveDir flag 2 |
| 0x2C | 4 | int32 | isFrozen |
| 0x30 | 4 | int32 | iceCount |
| 0x60 | 4 | int32 | hasInnerLayer |
| 0x64 | 4 | int32 | innerBlockType |

### 10.2 Door (40 bytes)

| Offset | Size | Type | Field |
|--------|------|------|-------|
| 0x00 | 12 | Vector3 | position |
| 0x0C | 12 | Vector3 | rotation |
| 0x18 | 4 | int32 | doorPartCount |
| 0x1C | 4 | int32 | blockType |
| 0x20 | 1 | bool | hasStar |
| 0x21 | 1 | bool | isSwitchDoor |
| 0x23 | 1 | bool | hasIce |
| 0x24 | 4 | int32 | iceCount |

---

## 11. Implementation Status

### Phase 1: Core (DONE)
- [x] Basic movement
- [x] Collisions
- [x] Door exit
- [x] Move direction restrictions
- [x] Frozen blocks (ice)
- [x] Multi-layer blocks
- [x] 27 levels
- [x] Timer system (countdown, per-level duration)
- [x] Lives system (5 max, 30 min refill)
- [x] Fail dialog

### Phase 2: Economy (NEXT)
- [ ] Coins system
- [ ] Boosters (time, hammer)

### Phase 3: Monetization
- [ ] Rewarded ads
- [ ] Interstitial ads
- [ ] No Ads IAP
- [ ] Coin packs IAP

### Phase 4: Advanced Mechanics
- [ ] Blockers
- [ ] Rainbow blocks
- [ ] Star collection
- [ ] Keys & Locks

### Phase 5: Meta
- [ ] Profile (avatar, name)
- [ ] Level map (vertical scroll)
- [ ] Daily rewards
- [ ] Social rewards

---

## 12. Comparison: Original vs Our Game

| Feature | Original | Our Game |
|---------|----------|----------|
| Levels | 1557 | 27 |
| Block shapes | 12 | 12 |
| Colors | 10 | 10 |
| Move restrictions | Yes | Yes |
| Frozen blocks | Yes | Yes |
| Multi-layer | Yes | Yes |
| Blockers | Yes | No |
| Rainbow | Yes | No |
| Timer | Yes | **Yes** |
| Lives | Yes | **Yes (5, 30m refill)** |
| Fail dialog | Yes | **Yes** |
| Coins | Yes | No |
| Shop | Yes | No |
| Ads | Yes | No |
| Profile | Yes | No |

---

*Document based on App Store analysis, XAPK reverse-engineering, and game screenshots*

