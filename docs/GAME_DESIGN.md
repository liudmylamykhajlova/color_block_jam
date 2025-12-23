# Color Block Jam - Game Design Document

> **Version:** 3.0.0  
> **Date:** 2025-12-23  
> **Based on:** Original game screenshots

---

## 1. Game Concept

### 1.1 Elevator Pitch
Drag colorful LEGO-like blocks and guide them through matching color doors.

### 1.2 Genre
- **Primary:** Puzzle
- **Subgenre:** Sliding Block
- **Style:** Casual

### 1.3 Target Audience
- **Age:** 13+
- **Gender:** Universal
- **Sessions:** 2-5 minutes

### 1.4 Reference
- Color Block Jam by Rollic/Gybe Games

---

## 2. Core Gameplay

### 2.1 Goal
Move ALL blocks out of the board through doors of matching color.

### 2.2 Rules
1. Blocks move horizontally OR vertically
2. Blocks cannot pass through each other
3. Blocks can only exit through doors of their color
4. Level complete when all blocks exit
5. Level fail when timer runs out

### 2.3 Mechanics (Implemented)

| Mechanic | Description |
|----------|-------------|
| **Movement Direction** | Some blocks can only move horizontally or vertically (white arrows) |
| **Frozen Blocks** | Blocks covered in ice, number shows how many blocks must exit to unfreeze |
| **Multi-layer Blocks** | Two colors - outer layer destroys on matching door, inner layer exits after |

---

## 3. Visual Design (from screenshots)

### 3.1 Color Palette (10 block colors)

| ID | Color | HEX |
|----|-------|-----|
| 0 | Blue | #03a5ef |
| 1 | Dark Blue | #143cf6 |
| 2 | Green | #48aa1a |
| 3 | Pink | #b844c8 |
| 4 | Purple | #7343db |
| 5 | Yellow | #fbb32d |
| 6 | Dark Green | #09521d |
| 7 | Orange | #f2772b |
| 8 | Red | #b8202c |
| 9 | Cyan | #0facae |

### 3.2 UI Colors (from screenshots)

| Element | Color | Description |
|---------|-------|-------------|
| Dialog background | Sky blue gradient | #4DA6FF to #2E86DE |
| Primary buttons | Green | #7ED321 (Play, Retry) |
| Close buttons | Red circle | White X inside |
| Main background | Purple/Blue gradient | Level select, menus |
| Game background | Light gray/blue | During gameplay |

### 3.3 Game Board (from screenshots)

| Element | Description |
|---------|-------------|
| **Board frame** | Dark gray/black, NOT wooden |
| **Board interior** | Dark gray grid |
| **Doors** | Colored strips on frame edges with direction arrows |
| **Blocks** | 3D LEGO style with round studs on each cell |

### 3.4 Block Shapes (12 types)

| ID | Name | Cells |
|----|------|-------|
| 0 | One | 1 |
| 1 | Two | 2 |
| 2 | Three | 3 |
| 3 | L | 4 |
| 4 | ReverseL | 4 |
| 5 | ShortL | 3 |
| 6 | ReverseShortL | 3 |
| 7 | TwoSquare | 4 |
| 8 | ShortT | 4 |
| 9 | Plus | 5 |
| 10 | Z | 4 |
| 11 | ReverseZ | 4 |

---

## 4. Screens (from screenshots)

### 4.1 Splash Screen
- 3D LEGO blocks floating in background
- "Color Block Jam" logo with neon glow
- Progress bar with percentage

### 4.2 Level Select (Map)
- Vertical scrollable path
- Levels connected by rope/line
- Level states:
  - Green = Available
  - Red + Skull = Hard
  - Purple + Skull = Boss/Special
  - Lock = Locked
- Bottom navigation: Shop | Home | Lvl 50

### 4.3 Level Start Dialog
- "LEVEL N" title
- "Unlock Level 70" progress (0/3)
- Booster selection (2 slots with quantity)
- "Play" button (green)

### 4.4 Game Screen

**Top HUD:**
- Level number (blue circle)
- Timer ("Time 02:50")
- Restart button
- Coins display ("1.48k")

**Bottom HUD (5 boosters):**
| Slot | Icon | Badge |
|------|------|-------|
| 1 | Clock | "1" |
| 2 | Hammer | "1" |
| 3 | Drill | "1" |
| 4 | Plus | "+" |
| 5 | Pause | - |

### 4.5 Fail Dialog
- "Level N" title
- Broken heart with "-1"
- "You will lose 1 life!"
- "Retry" button (green)
- Close button (X)

### 4.6 Settings
- Vibration toggle (default: OFF)
- Sound toggle (default: ON)
- Music toggle (default: ON)
- Legal Terms button
- Restore Purchases button
- Support button
- Language button
- Social: Instagram, Facebook, TikTok (+100 coins each)

### 4.7 Profile
- Avatar display with name ("Player8659")
- Edit name button (pencil)
- Tabs: Avatar | Frame
- 3x4 grid of avatar options
- Green checkmark on selected

### 4.8 Shop

**Coins section (from screenshots - UAH prices):**
| Coins | Price |
|-------|-------|
| 1,000 | 79.99 |
| 5,000 | 284.99 |
| 10,000 | 549.99 |
| 25,000 | 1,099.99 |
| 50,000 | 1,949.99 |
| 100,000 | 3,649.99 |

**Bundles section:**
- No Ads: 284.99 UAH

### 4.9 Remove Ads Dialog
- Large crossed "ADS" icon
- Removes: Interstitial ads, banner ads
- Keeps: Optional rewarded ads
- Price button (green)

---

## 5. Economy

### 5.1 Lives
- Display: "Full 5" with heart icon
- Maximum: 5 lives
- Lost on: Level fail (time out)
- Restore: Wait / Watch ad / Buy

### 5.2 Coins
- Display: "1.48k" format with plus button
- Earn: Complete levels, watch ads, daily rewards
- Spend: Boosters, hints, extra time

### 5.3 Timer
- Display: "Time MM:SS"
- Varies by level difficulty
- Can add time with boosters/ads

---

## 6. Boosters (from screenshots)

| Icon | Name | Function |
|------|------|----------|
| Clock | Extra Time | Add seconds to timer |
| Hammer | Destroy | Remove one block |
| Drill | Unknown | TBD |
| Plus | Buy More | Opens shop |
| Pause | Pause | Pause game |

Pre-game boosters (Level Start):
- Hourglass: Start with more time
- Rocket: Unknown effect

---

## 7. Monetization

### 7.1 Ads
- **Interstitial:** Between levels
- **Rewarded:** Extra time, extra life, 2x coins
- **Banner:** Bottom of screen (removed with No Ads)

### 7.2 In-App Purchases
- Coin packs (6 tiers)
- No Ads bundle
- Bundles (coins + boosters)

### 7.3 Social Rewards
- Instagram: +100 coins
- Facebook: +100 coins
- TikTok: +100 coins

---

## 8. Audio

### 8.1 Settings (from screenshots)
- Sound Effects: ON/OFF toggle
- Music: ON/OFF toggle
- Vibration: ON/OFF toggle

### 8.2 Sound Effects (expected)
- Block pickup
- Block drop
- Block exit
- Level complete
- Level fail
- Button tap

---

## 9. Implementation Status

### Done
- [x] Core gameplay
- [x] 27 levels
- [x] Movement direction restrictions
- [x] Frozen blocks (ice)
- [x] Multi-layer blocks
- [x] Level visualizer
- [x] Timer system (countdown, color changes)
- [x] Lives system (5 max, 30 min refill)
- [x] Fail dialog (broken heart, retry)

### Next (Phase 2)
- [ ] Boosters (clock, hammer)
- [ ] Win dialog improvements
- [ ] Coins system

### Future
- [ ] Shop
- [ ] Coins system
- [ ] Ads integration
- [ ] Profile/Avatar
- [ ] Level map (vertical scroll)

---

## Change History

| Version | Date | Changes |
|---------|------|---------|
| 3.0.0 | 2025-12-23 | Complete rewrite based on screenshots only |
| 2.1.0 | 2025-12-23 | Previous version |
| 1.0.0 | 2025-12-17 | Initial version |
