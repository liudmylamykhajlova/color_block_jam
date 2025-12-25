# Color Block Jam - Game Design Document

> **Version:** 3.2.0  
> **Date:** 2025-12-24  
> **Based on:** Original game screenshots (10 screens analyzed)

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
| **Movement Direction** | Some blocks can only move horizontally or vertically (white arrows ↔ ↕) |
| **Frozen Blocks** | Blocks covered in ice with number (e.g. "4") showing blocks to exit before unfreeze |
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
| Dialog border | Light blue outline | Rounded corners |
| Primary buttons | Green gradient | #7ED321 (Play, Retry, Buy) |
| Secondary buttons | Blue gradient | Settings items |
| Orange header | Orange | "Bundles" section |
| Close buttons | Red circle | White X inside |
| Main background | Purple/Blue gradient | Level map, menus |
| Game background | Light gray/blue | During gameplay |
| Toggle ON | Green pill | With "On" label |
| Toggle OFF | Gray pill | No label |

### 3.3 Game Board (from screenshots)

| Element | Description |
|---------|-------------|
| **Board frame** | Dark gray/black, NOT wooden, 3D rounded edges |
| **Board interior** | Dark gray grid with subtle lines |
| **Doors** | Colored strips on frame edges with white direction arrows |
| **Blocks** | 3D LEGO style with round studs (4 per cell), shadow underneath |

### 3.4 Block Shapes (12 types)

| ID | Name | Cells |
|----|------|-------|
| 0 | One | 1 |
| 1 | Two | 2 |
| 2 | Three | 3 |
| 3 | L | 4 |
| 4 | ReverseL | 4 |
| 5 | ShortL | 3 |
| 6 | Plus | 5 |
| 7 | TwoSquare | 4 |
| 8 | ShortT | 4 |
| 9 | Z | 4 |
| 10 | ReverseZ | 4 |
| 11 | U | 5 |

---

## 4. Screens (from screenshots)

### 4.1 Splash Screen
- Blue gradient background
- 3D LEGO blocks floating/falling animation
- "Color Block Jam" logo with neon glow circle effect
- Progress bar at bottom with percentage (e.g. "5%")
- Rollic logo in corner

### 4.2 Level Map Screen

**Top HUD:**
| Element | Position | Description |
|---------|----------|-------------|
| Avatar | Top-left | Clickable profile picture in blue frame |
| Lives | Left of center | Green "+" button + "Full" text + red heart "5" |
| Coins | Right of center | Green "+" button + "1.48k" + coin icon |
| Settings | Top-right | Yellow gear icon |

**Map Content:**
- Vertical scrollable path
- Dark rope/line connecting level nodes
- Level node states:
  - **Green** = Available/Current (rounded square)
  - **Red + Skull badge** = Hard level
  - **Purple + Skull badge** = Boss/Special level
  - **Gold lock icon** = Locked level
- Gold coin badge between some levels (rewards)
- Current level has "Level N" green label below

**Right Side:**
- "ADS" button (red crossed circle) - opens Remove Ads

**Bottom Navigation Bar:**
| Slot | Icon | Label |
|------|------|-------|
| 1 | Chest with coins | "Shop" |
| 2 | 3D LEGO blocks | "Home" |
| 3 | Lock icon | "Lvl 50" |

### 4.3 Level Start Dialog
- "LEVEL N" title in blue banner
- Red X close button (top-right)

**Milestone Section:**
- Chest icon (3D treasure)
- "Unlock Level 70" text
- Progress bar "0/3" with lock icon

**Boosters Section:**
- "Select Boosters:" label
- 2 booster slots:
  | Slot | Icon | Badge |
  |------|------|-------|
  | 1 | Hourglass | Red circle "2" |
  | 2 | Rocket | Red circle "2" |

- "Play" button (large green)

### 4.4 Game Screen

**Top HUD:**
| Element | Position | Description |
|---------|----------|-------------|
| Level badge | Left | Blue oval "Level" + large number |
| Timer | Center | Yellow clock icon + "Time" + "02:50" |
| Restart | Right of timer | Yellow circular arrow button |
| Coins | Right | Green coin + "1.48k" + green "+" |

**Game Board:**
- Dark gray frame with 3D edges
- Colored doors on edges with white arrows
- LEGO blocks with studs
- Movement arrows on restricted blocks (white ↔ or ↕)
- Ice overlay with number on frozen blocks

**Bottom HUD (5 Boosters):**
| Slot | Icon | Badge | Function |
|------|------|-------|----------|
| 1 | Snowflake ❄️ | "1" | Freeze time |
| 2 | Rocket 🚀 | "1" | Destroy one unit |
| 3 | Hammer 🔨 | "1" | Destroy entire block |
| 4 | Vacuum 🧹 | "1" | Vacuum all same color |
| 5 | Pause ⏸️ | - | Pause game |

### 4.5 Fail Dialog
- "Level N" title in blue banner
- Red X close button (top-right)
- **Broken heart icon** (3D, cracked, red) with "-1" overlay
- "You will lose 1 life!" text
- "Retry" button (large green)

### 4.6 Settings Dialog
- "SETTINGS" title in blue banner with white stroke
- Red X close button

**Toggles (top to bottom):**
| Icon | Setting | Default |
|------|---------|---------|
| Phone with vibration | Vibration | OFF (gray) |
| Speaker with waves | Sound | ON (green) |
| Music note | Music | ON (green) |

**Buttons (blue rounded):**
1. "Legal Terms"
2. "Restore Purchases"
3. "Support" (with checkmark icon)
4. "Language"

**Social Links (bottom):**
| Platform | Icon | Reward |
|----------|------|--------|
| Instagram | IG logo | "Like +100" coins |
| Facebook | F logo | "Follow +100" coins |
| TikTok | TT logo | "Follow +100" coins |

### 4.7 Profile Dialog
- "Profile" title in blue banner
- Red X close button

**Player Card (cream/beige background):**
- Avatar image (square, blue border)
- "Player8659" name
- Blue pencil edit button

**Tabs:**
- "Avatar" | "Frame" (blue buttons)

**Avatar Grid:**
- 3 columns x 4 rows = 12 avatars
- Green checkmark + green border on selected
- Various cartoon character portraits

### 4.8 Shop

**Two Views:**
1. **Dialog** (overlay on game/map)
2. **Full Screen** (from bottom nav)

**Structure:**
- "Shop" title (full screen) or "Coins" header (dialog)
- Coins display top-right

**Coins Section (yellow/gold border):**
| Coins | Image | Price (UAH) |
|-------|-------|-------------|
| 1 000 | Small pile | 79,99 |
| 5 000 | Medium pile | 284,99 |
| 10 000 | Large pile | 549,99 |
| 25 000 | Bigger pile | 1 099,99 |
| 50 000 | Huge pile | 1 949,99 |
| 100 000 | Chest + pile | 3 649,99 |

**Bundles Section (orange header):**
- "No Ads" card:
  - Crossed ADS icon (red circle)
  - "Remove interstitial & banner ads"
  - "284,99 UAH" green button

### 4.9 Remove Ads Dialog
- "REMOVE ADS" title (white, large)
- Red X close button
- Large crossed "ADS" icon (3D, red prohibition sign)

**Bullet Points:**
| Icon | Text |
|------|------|
| TV screen | "Remove obligatory ads" |
| Phone with line | "Remove bottom banner ads" |
| Play button | "Keep optional ads for rewards" |

- "Level 29" label (shows current level)
- "284,99 UAH" button (large green)

---

## 5. Economy

### 5.1 Lives
- **Display:** Green "+" + "Full" + Heart icon + "5"
- **Maximum:** 5 lives
- **Lost on:** Level fail (time out)
- **Restore:** Wait 30 min / Watch ad / Buy

### 5.2 Coins
- **Display:** "1.48k" format + coin icon + green "+" button
- **Earn:** Complete levels, watch ads, social follows, daily rewards
- **Spend:** Boosters, extra time, hints

### 5.3 Timer
- **Display:** Clock icon + "Time" + "MM:SS"
- **Visual:** Yellow when normal, changes color when low
- **Varies:** By level difficulty (typically 2:30-3:00)

### 5.4 Milestones (NEW)
- "Unlock Level 70" type progression
- Progress bar (0/3)
- Rewards: Chest with items
- Triggers at specific level thresholds

---

## 6. Boosters

### 6.1 In-Game Boosters (Bottom HUD)

| Icon | Name | Quantity | Function |
|------|------|----------|----------|
| ❄️ Snowflake | Freeze Time | 1 | Freezes the game timer for 5 seconds. Player can still move blocks. |
| 🚀 Rocket | Destroy Unit | 1 | Removes one cell from any block. Shows target crosshairs on all block cells. |
| 🔨 Hammer | Destroy Block | 1 | Destroys an entire block instantly. |
| 🧹 Vacuum | Vacuum Color | 1 | Vacuums (removes) all blocks of the same color as the tapped block. |
| ⏸️ Pause | Pause | - | Pauses the game |

### 6.2 Pre-Game Boosters (Level Start)

| Icon | Name | Quantity | Function |
|------|------|----------|----------|
| ⏳ Hourglass | More Time | 2 | Start level with extra time |
| 🚀 Rocket | Destroy Unit | 2 | Same as in-game Rocket booster |
| 🔨 Hammer | Destroy Block | 2 | Same as in-game Hammer booster |

### 6.3 Booster Visual Effects

#### Freeze Time (❄️)
- **Duration:** 5 seconds (`AppConstants.freezeBoosterDuration`)
- **Overlay:** Full-screen blue tint with radial gradient
- **Snowflakes:** 25 animated snowflakes falling and swaying
- **Frost:** White gradient effects in all 4 corners
- **Border:** Blue glowing border (8px width)
- **Indicator:** Pulsing badge below timer with ❄️ icon and countdown (5, 4, 3, 2, 1)
- **Timer display:** Shows "FROZEN" text instead of time

#### Rocket (🚀)
- **Tooltip:** Blue gradient banner at top with:
  - 🚀 icon in purple square with gold rocket
  - "ROCKET" title badge
  - "Tap and destroy one unit of a block!" instruction
  - ❌ close button (red circle)
- **Targets:** Red circles with white crosshair on each block cell
- **Animation:** Rocket flies from booster button to tapped cell with rotation
- **Explosion:** Orange/yellow radial explosion animation
- **Tap behavior:**
  - Tap on block cell → rocket flies, explosion, removes that cell
  - Tap on empty cell → cancels rocket mode
  - Tap outside board → cancels rocket mode
  - Tap close button → cancels rocket mode

#### Hammer (🔨)
- **Tooltip:** Blue gradient banner at top with:
  - 🔨 icon in green square with orange hammer
  - "HAMMER" title badge
  - "Tap any block to destroy it!" instruction
  - ❌ close button (red circle)
- **Animation:** Strike animation at tapped block:
  1. Hammer appears above block
  2. Raises up slightly (wind-up)
  3. Strikes down fast with rotation
  4. Fades on impact
- **Explosion:** Large orange/yellow radial explosion with 8 flying particles
- **Tap behavior:**
  - Tap on any block → hammer strike, big explosion, destroys entire block
  - Tap on empty cell → cancels hammer mode
  - Tap outside board → cancels hammer mode
  - Tap close button → cancels hammer mode

#### Vacuum (🧹)
- **Tooltip:** Blue gradient banner at top with:
  - 🧹 icon in blue square with yellow vacuum
  - "VACUUM" title badge
  - "Tap and vacuum blocks with the same color!" instruction
  - ❌ close button (red circle)
- **Animation:** Shrink-to-zero animation:
  - All blocks of the selected color shrink simultaneously
  - Blocks fade out while shrinking
  - Slight rotation effect during shrink
  - Glow effect around shrinking blocks
- **Tap behavior:**
  - Tap on any block → all blocks of same color shrink and disappear
  - Tap on empty cell → cancels vacuum mode
  - Tap outside board → cancels vacuum mode
  - Tap close button → cancels vacuum mode

### 6.4 Booster State Management

All boosters are cancelled automatically when:
- Game is paused
- App goes to background
- Level is won or failed
- Timer runs out
- Level is restarted

Booster is consumed only when actually used (not on activation).

---

## 7. Monetization

### 7.1 Ads
- **Interstitial:** Between levels (removed with No Ads)
- **Rewarded:** Extra time, extra life, 2x coins (kept with No Ads)
- **Banner:** Bottom of screen (removed with No Ads)

### 7.2 In-App Purchases (UAH Prices)

| Product | Price |
|---------|-------|
| 1,000 coins | 79.99 |
| 5,000 coins | 284.99 |
| 10,000 coins | 549.99 |
| 25,000 coins | 1,099.99 |
| 50,000 coins | 1,949.99 |
| 100,000 coins | 3,649.99 |
| No Ads | 284.99 |

### 7.3 Social Rewards
- Instagram Like: +100 coins
- Facebook Follow: +100 coins
- TikTok Follow: +100 coins

---

## 8. Audio

### 8.1 Settings (from screenshots)
- **Sound Effects:** ON/OFF toggle (speaker icon)
- **Music:** ON/OFF toggle (note icon)
- **Vibration:** ON/OFF toggle (phone icon)

### 8.2 Sound Effects (expected)
- Block pickup
- Block drop/place
- Block exit through door
- Level complete fanfare
- Level fail sound
- Button tap
- Timer warning (low time)
- Ice break
- Booster use

---

## 9. Implementation Status

### ✅ Done (Phase 1 - MVP)
- [x] Core gameplay (drag & drop)
- [x] 27 levels from original game
- [x] Movement direction restrictions
- [x] Frozen blocks (ice mechanic)
- [x] Multi-layer blocks
- [x] Level visualizer (debug)
- [x] Timer system (countdown, color changes)
- [x] Lives system (5 max, 30 min refill)
- [x] Fail dialog (broken heart, retry)
- [x] Settings (Sound, Music, Vibration toggles)
- [x] Basic level select grid

### ✅ Done (Phase 2 - Core Features)
- [x] Coins display in HUD
- [x] Bottom boosters bar (5 slots)
- [x] Win dialog with stars, coins earned
- [x] Level start dialog with boosters
- [x] Freeze booster (freezes timer 5s)
- [x] Rocket booster (destroys one cell)
- [x] Pause functionality

### ✅ Done (Phase 3 - Screens)
- [x] Splash screen (animated blocks, logo, progress)
- [x] Level map (vertical scroll, rope path)
- [x] Level nodes (green/red/purple, lock/star badges)
- [x] Map HUD (avatar, lives, coins, settings)
- [x] Shop screen (6 coin packs, bundles)
- [x] Remove Ads dialog

### ✅ Done (Phase 4 - Polish)
- [x] Profile screen (avatar grid, name edit, tabs)
- [x] Settings extras (Legal, Support, Language)
- [x] Social links (Instagram, Facebook +100 coins)

### 🔷 Future (Phase 5 - Monetization)
- [ ] Ads integration (AdMob/AppLovin)
- [ ] IAP integration (RevenueCat)
- [ ] Real audio files
- [ ] Push notifications
- [ ] Analytics (Firebase)

---

## Change History

| Version | Date | Changes |
|---------|------|---------|
| 3.2.0 | 2025-12-24 | Updated implementation status: Phase 1-4 complete |
| 3.1.0 | 2025-12-24 | Updated from 10 new screenshots: detailed HUD specs, Level Map elements, Settings icons, Shop views, Remove Ads bullets, Milestone system |
| 3.0.0 | 2025-12-23 | Complete rewrite based on screenshots only |
| 2.1.0 | 2025-12-23 | Previous version |
| 1.0.0 | 2025-12-17 | Initial version |
