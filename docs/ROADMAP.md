# Color Block Jam - Roadmap

> **Версія:** 1.7.0  
> **Дата оновлення:** 2025-12-24  
> **Статус:** Активна розробка

---

## 📊 Загальний Прогрес

```
Phase 0: Foundation     ████████████████████ 100%
Phase 1: Polish & UX    ████████████████████ 100%
Phase 1.5: Core Systems ████████████████████ 100%
Phase 2: Core Features  ████████████████████ 100%
Phase 3: Screens        ████████████████████ 100%
Phase 4: Polish         ████████████████████ 100%
Phase 5: Deployment     ░░░░░░░░░░░░░░░░░░░░   0%
Phase 6: Monetization   ░░░░░░░░░░░░░░░░░░░░   0%
Phase 7: Content        ░░░░░░░░░░░░░░░░░░░░   0%
────────────────────────────────────────────────
Total MVP Progress:     ███████████████████░  95%
```

---

## 🏁 Phase 0: Foundation (COMPLETED ✅)

> **Тривалість:** ~2 тижні  
> **Статус:** ✅ Завершено

### Sprint 0.1: Analysis & Parsing
| Завдання | Статус |
|----------|--------|
| Аналіз Unity asset bundles | ✅ |
| Парсер рівнів (Python) | ✅ |
| Level visualizer (HTML) | ✅ |
| Документація правил рендерингу | ✅ |
| Експорт 27 рівнів у JSON | ✅ |
| Верифікація рівнів 1-27 | ✅ |
| Парсинг moveDirection (обмеження руху блоків) | ✅ |
| Реалізація moveDirection в грі (блокування руху + стрілки) | ✅ |
| Парсинг innerBlockType (внутрішній шар блоків) | ✅ |
| Реалізація inner layer в грі (візуальне відображення) | ✅ |
| Парсинг iceCount (заморожені блоки) | ✅ |
| Реалізація iceCount в грі (візуалізація + механіка) | ✅ |

### Sprint 0.2: Core Game
| Завдання | Статус |
|----------|--------|
| Flutter project setup | ✅ |
| Game models (Block, Door, Level) | ✅ |
| Level loader | ✅ |
| Game board renderer (CustomPainter) | ✅ |
| Block shapes & rotations | ✅ |

### Sprint 0.3: Game Mechanics
| Завдання | Статус |
|----------|--------|
| Drag & drop movement | ✅ |
| Collision detection | ✅ |
| Door exit detection | ✅ |
| Auto-exit animation | ✅ |
| Win detection | ✅ |

### Sprint 0.4: UI Screens
| Завдання | Статус |
|----------|--------|
| Menu screen | ✅ |
| Level select screen | ✅ |
| Game screen UI | ✅ |
| Win dialog | ✅ |
| Storage service | ✅ |

---

## ✨ Phase 1: Polish & UX (COMPLETED ✅)

> **Тривалість:** ~3 години  
> **Статус:** ✅ Завершено  
> **Дата:** 2025-12-17

### Sprint 1.1: Audio & Haptics
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Audio service | ✅ | Централізований сервіс |
| Haptic feedback | ✅ | Light/Medium/Heavy/Success |
| Button sounds | ✅ | Всі кнопки |
| Game sounds | ✅ | Pickup, drop, exit, win |

### Sprint 1.2: Settings
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Settings screen | ✅ | Повний UI |
| Sound toggle | ✅ | On/Off з persist |
| Haptic toggle | ✅ | On/Off з persist |
| Reset progress | ✅ | З підтвердженням |

### Sprint 1.3: Visual Effects
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Selection glow | ✅ | Blur effect на блоці |
| Win confetti | ✅ | Анімовані частинки |
| Star animation | ✅ | Elastic appear |
| Trophy animation | ✅ | Scale animation |

---

## ⏱️ Phase 1.5: Core Systems (COMPLETED ✅)

> **Тривалість:** ~1 година  
> **Статус:** ✅ Завершено  
> **Дата:** 2025-12-23

### Sprint 1.5.1: Timer & Lives
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Timer countdown | ✅ | MM:SS format, per-level duration |
| Timer color change | ✅ | Gold -> Orange (30s) -> Red (10s) |
| Lives system | ✅ | 5 max, 30 min refill |
| Lose life on fail | ✅ | Timer expires = -1 life |
| Fail dialog | ✅ | Broken heart, Retry button |
| Lives display in HUD | ✅ | Heart icon + count |

---

## 🎯 Phase 2: Core Features (COMPLETED ✅)

> **Тривалість:** ~2 години  
> **Статус:** ✅ Завершено  
> **Дата:** 2025-12-24

### Sprint 2.1: HUD & Dialogs
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Coins display in HUD | ✅ | CoinsWidget з "+" button |
| Bottom boosters bar | ✅ | 5 slots (time, hammer, drill, buy, pause) |
| Win dialog | ✅ | Stars, coins earned, Next/Replay |
| Level start dialog | ✅ | Boosters selection, milestone |
| Extra time booster | ✅ | +30 seconds |
| Pause functionality | ✅ | Pause button |

---

## 🖼️ Phase 3: Screens (COMPLETED ✅)

> **Тривалість:** ~2 години  
> **Статус:** ✅ Завершено  
> **Дата:** 2025-12-24

### Sprint 3.1: Splash & Map
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Splash screen | ✅ | Animated blocks, logo, progress |
| Level map | ✅ | Vertical scroll, rope path |
| Level nodes | ✅ | Green/Red/Purple, lock/star badges |
| Map HUD | ✅ | Avatar, lives, coins, settings |

### Sprint 3.2: Shop & Ads
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Shop screen | ✅ | 6 coin packs, bundles section |
| Remove Ads dialog | ✅ | 3 bullet points, price button |

---

## ✨ Phase 4: Polish (COMPLETED ✅)

> **Тривалість:** ~2 години  
> **Статус:** ✅ Завершено  
> **Дата:** 2025-12-24

### Sprint 4.1: Profile & Settings
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Profile screen | ✅ | Avatar grid, name edit, tabs |
| Settings extras | ✅ | Legal, Support, Language |
| Social links | ✅ | Instagram, Facebook +100 coins |

### Sprint 4.2: Code Quality
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Unit tests | ✅ | WinDialog, Settings, Shop, etc. |
| Test helpers | ✅ | TestHelpers class, extensions |
| AppColors cleanup | ✅ | Centralized constants |
| Timer memory leak fix | ✅ | Proper dispose in WinDialog |

---

## 🚀 Phase 5: Deployment (PENDING)

> **Тривалість:** ~2 години  
> **Статус:** ⏳ Очікує  
> **Пріоритет:** High

### Sprint 5.1: Branding
| Завдання | Статус | Деталі |
|----------|--------|--------|
| App icon | ⏳ | 1024x1024 + adaptive |
| Native splash screen | ⏳ | Native splash |
| App name | ⏳ | Display name |
| Package name | ⏳ | com.playcus.colorblockjam |

### Sprint 5.2: Build
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Android release build | ⏳ | APK + AAB |
| iOS release build | ⏳ | IPA |
| Performance testing | ⏳ | Low-end devices |
| Bug fixes | ⏳ | Критичні баги |

### Sprint 5.3: Store Preparation
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Screenshots | ⏳ | 5-8 screenshots |
| Store description | ⏳ | EN, UK |
| Privacy policy | ⏳ | URL |
| Age rating | ⏳ | PEGI 3 / Everyone |

---

## 💰 Phase 6: Monetization (PLANNED)

> **Тривалість:** ~4 години  
> **Статус:** 📅 Заплановано  
> **Пріоритет:** After release

### Sprint 6.1: AdMob
| Завдання | Статус | Деталі |
|----------|--------|--------|
| AdMob account | 📅 | Create app |
| google_mobile_ads | 📅 | flutter add |
| Interstitial ads | 📅 | After every 3 levels |
| Rewarded ads | 📅 | For hints |
| Ad consent (GDPR) | 📅 | UMP SDK |

### Sprint 6.2: IAP
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Remove Ads IAP | 📅 | ~$2.99 |
| Coin Packs IAP | 📅 | 6 tiers |
| Restore purchases | 📅 | Required |

---

## 🎮 Phase 7: Content Expansion (PLANNED)

> **Тривалість:** Ongoing  
> **Статус:** 📅 Заплановано  
> **Пріоритет:** After launch

### Sprint 7.1: More Levels
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Levels 1-18 | ✅ | Верифіковано |
| Levels 19-27 | 🔄 | Експортовано, потрібна верифікація |
| Levels 28-50 | 📅 | Parse & test |
| Level packs | 📅 | Themed groups |

### Sprint 7.2: Features
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Hint system | 📅 | Show next move |
| Undo button | 📅 | One step back |
| Move counter | 📅 | Track moves |
| Timer | 📅 | Optional |
| Star system | 📅 | 1-3 stars based on moves |

### Sprint 7.3: Social
| Завдання | Статус | Деталі |
|----------|--------|--------|
| Achievements | 📅 | Google Play / Game Center |
| Leaderboards | 📅 | Time-based |
| Share | 📅 | Share progress |

---

## 🐛 Known Issues & Tech Debt

| Issue | Priority | Status |
|-------|----------|--------|
| Test on low-end devices | High | ⏳ |
| Unit tests | Medium | ✅ |
| Widget tests | Medium | ✅ |
| Integration tests | Medium | ⏳ |
| Code documentation | Low | ⏳ |

---

## 📅 Timeline

```
December 2025
├── Week 1-2: Phase 0 (Foundation) ✅
├── Week 2: Phase 1 (Polish) ✅
└── Week 3: Phase 2-3 (Onboarding + Deploy)

January 2026
├── Week 1: Store submission
├── Week 2: Phase 4 (Analytics)
└── Week 3-4: Phase 5 (Monetization)

February 2026+
└── Phase 6 (Content) - ongoing
```

---

## 🎯 MVP Definition

**MVP = Phase 0 + Phase 1 + Phase 1.5 + Phase 2 + Phase 3 + Phase 4 + Phase 5**

| Критерій | Статус |
|----------|--------|
| 18 verified playable levels | ✅ |
| 27 total levels exported | ✅ |
| Core mechanics working | ✅ |
| Save progress | ✅ |
| Sound & haptics | ✅ |
| Settings screen | ✅ |
| Visual polish | ✅ |
| Timer system | ✅ |
| Lives system | ✅ |
| Fail dialog | ✅ |
| Win dialog | ✅ |
| Level start dialog | ✅ |
| Coins & Boosters | ✅ |
| Level map | ✅ |
| Shop screen | ✅ |
| Profile screen | ✅ |
| Unit tests | ✅ |
| Level visualizer with verification | ✅ |
| App icon & branding | ⏳ |
| Release build | ⏳ |

**Estimated MVP completion: 95%**

---

## Історія Змін

| Версія | Дата | Зміни |
|--------|------|-------|
| 1.7.0 | 2025-12-24 | Phase 2-4 complete: Core Features, Screens, Polish, Unit tests |
| 1.6.0 | 2025-12-23 | Phase 1.5 + QA fixes: Timer background pause, input validation, lives persistence |
| 1.5.0 | 2025-12-23 | Додано iceCount - заморожені блоки (візуалізація + механіка розморозки) |
| 1.4.0 | 2025-12-21 | Механіка багатошарових блоків: руйнування зовнішнього шару |
| 1.3.0 | 2025-12-21 | Додано innerBlockType - багатошарові блоки |
| 1.2.0 | 2025-12-21 | Додано moveDirection - обмеження напрямку руху |
| 1.1.2 | 2025-12-18 | Верифіковано 21 рівень, універсальний алгоритм ReverseL |
| 1.1.1 | 2025-12-18 | Виправлено Level 16 (двері), Level 19 (ShortL, двері) |
| 1.1.0 | 2025-12-18 | Верифікація 18 рівнів, експорт 27 рівнів |
| 1.0.0 | 2025-12-17 | Початкова версія документа |

