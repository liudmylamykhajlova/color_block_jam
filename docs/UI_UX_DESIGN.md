# Color Block Jam - UI/UX Design Document

> **Version:** 2.0.0  
> **Date:** 2025-12-23  
> **Based on:** Original game screenshots analysis

---

## 1. Design System

### 1.1 Color Palette

| Name | HEX | Usage |
|------|-----|-------|
| Sky Blue | #4DA6FF | Dialog backgrounds, buttons |
| Deep Blue | #1A1A4E | Main background |
| Bright Green | #7ED321 | Primary buttons (Play, Retry) |
| Red | #E74C3C | Close buttons, warnings |
| Yellow/Gold | #F5A623 | Coins, highlights |
| Purple | #9B59B6 | Special levels, bundles |
| Orange | #F39C12 | Bundles section |
| White | #FFFFFF | Text, icons |

### 1.2 Typography
- **Titles:** Bold, white, drop shadow
- **Numbers:** Extra bold (coins, levels)
- **Body:** Regular white
- **Style:** Cartoon/playful font

### 1.3 UI Components Style
- **Dialogs:** Rounded corners (~20px), blue gradient, white border
- **Buttons:** Rounded, gradient fill, slight 3D effect
- **Cards:** Rounded corners, inner shadow
- **Close button:** Red circle with white X

---

## 2. Screen Specifications

### 2.1 Splash Screen

```
+----------------------------------+
|                                  |
|     [Floating 3D LEGO blocks]    |
|                                  |
|           Color                  |
|           Block                  |
|            Jam                   |
|        [Neon glow effect]        |
|                                  |
|     [Floating 3D LEGO blocks]    |
|                                  |
|        [====----] 5%             |
|                                  |
+----------------------------------+
```

**Elements:**
- 3D LEGO blocks floating/rotating in background
- Logo with neon blue glow ring
- Progress bar at bottom with percentage

---

### 2.2 Level Select (Map Screen)

```
+----------------------------------+
| [Avatar] Full[5] [1.48k+] [Gear] |
|                                  |
|           [Skull]                |
|            [31]  <- Purple/locked|
|             |                    |
|           [Skull]         [ADS]  |
|            [30]  <- Red/locked   |
|             |                    |
|            [29]  <- Green/current|
|             |                    |
|      [===Level 29===]            |
|                                  |
+----------------------------------+
| [Shop]    [Home]    [Lvl50]     |
|  coins    blocks     lock       |
+----------------------------------+
```

**Top Bar:**
- Avatar (tappable -> Profile)
- Lives: "Full" + heart icon + "5"
- Coins: "1.48k" + green plus button
- Settings gear

**Level Map:**
- Vertical scrollable path
- Levels connected by rope/line
- Level states:
  - Green = Available/Current
  - Red + Skull = Hard/Locked
  - Purple + Skull = Boss level
  - Lock icon = Locked
- Current level highlighted with button

**Side Elements:**
- "ADS" crossed button (Remove Ads promo)

**Bottom Navigation:**
| Tab | Icon | State |
|-----|------|-------|
| Shop | Coins in basket | Available |
| Home | 3D LEGO blocks | Current |
| Lvl 50 | Lock icon | Locked milestone |

---

### 2.3 Level Start Dialog

```
+----------------------------------+
|        LEVEL 29           [X]   |
|  +----------------------------+  |
|  |                            |  |
|  |     Unlock Level 70        |  |
|  |    [Box] [===] 0/3 [Lock]  |  |
|  |                            |  |
|  |     Select Boosters:       |  |
|  |     [Clock]    [Rocket]    |  |
|  |       (2)        (2)       |  |
|  |                            |  |
|  |     [====PLAY====]         |  |
|  |                            |  |
|  +----------------------------+  |
+----------------------------------+
```

**Header:**
- "LEVEL N" in dark banner
- Red close button (X)

**Content:**
- Unlock progress: "Unlock Level 70" with 0/3 progress
- Booster selection: 2 slots with quantity badges
- Play button (large, green)

---

### 2.4 Game Screen

```
+----------------------------------+
|[Lvl]    [Time]        [1.48k+]  |
| 29     02:50  [Restart]          |
|                                  |
|  +----------------------------+  |
|  |[G]                    [B]  |  |  <- Doors on edges
|  |  [YY]  [GG] [BB]      [O]  |  |
|  |  [YY]  [  ] [BB]      [O]  |  |
|  |        [PP] [Ice4]         |  |
|  |  [RR]  [PP] [Ice4]    [C]  |  |
|  |  [RR]       [OO]      [C]  |  |
|  |[P]                    [R]  |  |
|  +----------------------------+  |
|              [G]                 |
|                                  |
+----------------------------------+
|  [1]   [1]   [1]   [+]   [||]   |
| clock hammer drill  buy  pause  |
+----------------------------------+
```

**Top HUD:**
| Position | Element | Style |
|----------|---------|-------|
| Left | Level number | Blue circle, white text |
| Center | Timer | Clock icon + "Time 02:50" |
| Center-right | Restart | Circular arrow button |
| Right | Coins | Gold coin + "1.48k" + plus |

**Game Board:**
- Dark gray background
- Wooden/dark frame
- Colored doors on edges with direction arrows
- LEGO-style blocks with studs
- Ice overlay on frozen blocks with number
- Direction arrows (white) on restricted blocks

**Bottom Boosters:**
| Slot | Icon | Badge | Function |
|------|------|-------|----------|
| 1 | Clock | "1" | Add time |
| 2 | Hammer | "1" | Destroy block |
| 3 | Drill | "1" | Unknown |
| 4 | Plus | "+" | Buy boosters |
| 5 | Pause | - | Pause menu |

---

### 2.5 Fail Dialog

```
+----------------------------------+
|        Level 29           [X]   |
|  +----------------------------+  |
|  |                            |  |
|  |         [Heart]            |  |
|  |           -1               |  |
|  |                            |  |
|  |   You will lose 1 life!    |  |
|  |                            |  |
|  |      [===Retry===]         |  |
|  |                            |  |
|  +----------------------------+  |
+----------------------------------+
```

**Elements:**
- Title: "Level N" in dark banner
- Close button (X) - red circle
- Broken heart icon with "-1"
- Warning text
- Retry button (green)

---

### 2.6 Shop Screen

```
+----------------------------------+
|       Shop             [1.48k]  |
|                                  |
|  +======= Coins =======+        |
|  |                      |       |
|  | [1000]  [5000]  [10000]     |
|  | 79.99  284.99   549.99      |
|  |                      |       |
|  | [25000] [50000] [100000]    |
|  | 1099.99 1949.99 3649.99     |
|  |                      |       |
|  +======= Bundles ======+       |
|  |                      |       |
|  | [ADS] Remove inter-  |       |
|  |       stitial &      |       |
|  |       banner ads     |       |
|  | No Ads      284.99   |       |
|  +----------------------+       |
|                                  |
+----------------------------------+
| [Shop]    [Home]    [Lvl50]     |
+----------------------------------+
```

**Sections:**
1. **Coins** (yellow header)
   - 6 coin packs in 2x3 grid
   - Each shows: amount, coin pile image, price

2. **Bundles** (orange header)
   - No Ads bundle with description
   - Green price button

---

### 2.7 Remove Ads Dialog

```
+----------------------------------+
|                           [X]   |
|       REMOVE ADS                |
|                                  |
|         [ADS]                   |
|         (crossed)               |
|                                  |
|  [TV] Remove obligatory ads     |
|                                  |
|  [Phone] Remove bottom banner   |
|          ads                    |
|                                  |
|  [Play] Keep optional ads for   |
|         rewards                 |
|                                  |
|       Level 29                  |
|      [=284,99 UAH=]             |
|                                  |
+----------------------------------+
```

**Content:**
- Large crossed ADS icon
- Checklist of what's included
- Current level indicator
- Price button (green)

---

### 2.8 Settings Screen

```
+----------------------------------+
|       SETTINGS            [X]   |
|  +----------------------------+  |
|  |                            |  |
|  |  [Phone]        [===O]     |  |  <- Vibration OFF
|  |                            |  |
|  |  [Speaker]      [O===]     |  |  <- Sound ON
|  |                            |  |
|  |  [Music]        [O===]     |  |  <- Music ON
|  |                            |  |
|  |  [====Legal Terms====]     |  |
|  |                            |  |
|  |  [===Restore Purchases==]  |  |
|  |                            |  |
|  |  [Checkmark Support]       |  |
|  |                            |  |
|  |  [====Language====]        |  |
|  |                            |  |
|  |  [IG +100] [FB +100]       |  |
|  |       [TT +100]            |  |
|  +----------------------------+  |
+----------------------------------+
```

**Toggle Switches:**
- Green = ON (right position)
- Gray = OFF (left position)

**Buttons:**
- Legal Terms
- Restore Purchases
- Support (with green checkmark)
- Language

**Social Rewards:**
- Instagram: +100 coins
- Facebook: +100 coins
- TikTok: +100 coins

---

### 2.9 Profile Screen

```
+----------------------------------+
|       Profile             [X]   |
|  +----------------------------+  |
|  |  +------+                  |  |
|  |  |Avatar|  Player8659 [E]  |  |
|  |  +------+                  |  |
|  |                            |  |
|  |  [Avatar]      [Frame]     |  |  <- Tabs
|  |                            |  |
|  |  [A1] [A2] [A3]           |  |
|  |  [A4] [A5] [A6] <-checked |  |
|  |  [A7] [A8] [A9]           |  |
|  |  [A10][A11][A12]          |  |
|  |                            |  |
|  +----------------------------+  |
+----------------------------------+
```

**Header:**
- Current avatar display
- Player name with edit button (pencil)

**Tabs:**
- Avatar (selected)
- Frame

**Grid:**
- 3x4 avatar selection grid
- Green checkmark on selected
- Green border on selected

---

## 3. Animations

### 3.1 Splash Screen
- 3D blocks floating and rotating
- Logo fade in with glow effect
- Progress bar filling

### 3.2 Game Interactions
- Block pickup: Slight scale up + shadow
- Block move: Smooth follow finger
- Block drop: Bounce effect
- Block exit: Scale down + particles

### 3.3 Dialogs
- Slide up from bottom
- Fade in background dim
- Buttons: Press state (scale down)

### 3.4 Level Map
- Smooth vertical scroll
- Current level pulsing
- Level complete: Star burst

---

## 4. Component Specifications

### 4.1 Primary Button (Play, Retry)
```
- Background: Green gradient (#7ED321 -> #5CB812)
- Border: 2px dark green
- Border radius: 12px
- Text: White, bold, uppercase
- Shadow: 0 4px dark green
- Height: 56px
- Press: Scale to 95%
```

### 4.2 Dialog Box
```
- Background: Blue gradient (#4DA6FF -> #2E86DE)
- Border: 3px white
- Border radius: 20px
- Shadow: 0 8px rgba(0,0,0,0.3)
- Padding: 20px
```

### 4.3 Close Button
```
- Background: Red gradient (#E74C3C)
- Shape: Circle, 40x40px
- Icon: White X
- Position: Top-right corner
- Offset: -10px from edge
```

### 4.4 Toggle Switch
```
- Track: 50x28px, rounded
- Thumb: 24x24px circle
- ON: Green track, thumb right
- OFF: Gray track, thumb left
```

---

## 5. Implementation Notes

### 5.1 Required Assets
- 12+ avatar images
- 10 block colors
- Booster icons (clock, hammer, drill, pause)
- Social icons (Instagram, Facebook, TikTok)
- Coin pile images (6 sizes)
- 3D LEGO blocks for splash/background

### 5.2 Flutter Packages
```yaml
dependencies:
  flutter_animate: ^4.x    # Animations
  audioplayers: ^5.x       # Sound
  shared_preferences: ^2.x # Storage
  in_app_purchase: ^3.x    # IAP
  google_mobile_ads: ^3.x  # Ads
```

### 5.3 Screen Priority
1. Game Screen (done)
2. Level Select Map
3. Fail Dialog
4. Shop Screen
5. Settings
6. Profile
7. Remove Ads Dialog

---

## Change History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2025-12-23 | Complete rewrite based on screenshots |
| 1.0.0 | 2025-12-23 | Initial version |
