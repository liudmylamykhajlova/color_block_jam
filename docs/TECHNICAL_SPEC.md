# Color Block Jam - Технічна Специфікація (ТЗ)

> **Версія:** 1.4.0  
> **Дата оновлення:** 2025-12-21  
> **Статус:** В розробці

---

## 1. Загальний Опис

### 1.1 Назва проекту
**Color Block Jam** - мобільна головоломка на основі переміщення кольорових блоків.

### 1.2 Платформи
| Платформа | Статус | Мін. версія |
|-----------|--------|-------------|
| Android | ✅ Підтримується | API 21 (Android 5.0) |
| iOS | ✅ Підтримується | iOS 12.0 |
| Web | 🔄 Експериментально | Сучасні браузери |
| Windows | 🔄 Для розробки | Windows 10+ |

### 1.3 Технологічний стек
| Компонент | Технологія | Версія |
|-----------|------------|--------|
| Framework | Flutter | 3.x |
| Мова | Dart | 3.x |
| State Management | setState (StatefulWidget) | - |
| Локальне сховище | shared_preferences | 2.2.x |
| Рендеринг | CustomPainter | - |

---

## 2. Архітектура

### 2.1 Структура проекту
```
lib/
├── main.dart                      # Entry point
├── core/                          # Ядро застосунку
│   ├── constants/
│   │   ├── colors.dart           # Палітра кольорів блоків
│   │   └── block_shapes.dart     # Визначення форм блоків
│   ├── models/
│   │   └── game_models.dart      # GameBlock, GameDoor, GameLevel, Point
│   ├── services/
│   │   ├── storage_service.dart  # Збереження прогресу
│   │   └── audio_service.dart    # Звуки та вібрація
│   └── widgets/
│       └── confetti_widget.dart  # Візуальні ефекти
├── data/
│   └── services/
│       └── level_loader.dart     # Завантаження рівнів з JSON
└── features/                      # Екрани
    ├── menu/
    │   └── menu_screen.dart
    ├── level_select/
    │   └── level_select_screen.dart
    ├── game/
    │   └── game_screen.dart      # Основний ігровий екран
    └── settings/
        └── settings_screen.dart

assets/
└── levels/
    └── levels_27.json            # Дані 27 рівнів (18 верифікованих)

res/
└── ColorBlockJam_Analysis/       # Інструменти парсингу
    ├── tools/
    │   ├── parse_from_unity.py   # Парсер Unity assets
    │   └── export_game_levels.py # Експорт у game JSON
    ├── level_visualizer.html     # Візуалізатор з системою верифікації
    ├── level_data/
    │   ├── parsed_levels_complete.json  # Всі розпарсені рівні
    │   └── AllLevels_guids.json  # Порядок рівнів у грі
    └── reports/
        └── RENDERING_RULES.md    # Правила рендерингу
```

### 2.2 Потік даних
```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│ levels.json │────▶│ LevelLoader  │────▶│  GameLevel  │
└─────────────┘     └──────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Canvas    │◀────│ BoardPainter │◀────│ GameScreen  │
└─────────────┘     └──────────────┘     └─────────────┘
                                               │
                                               ▼
                    ┌──────────────┐     ┌─────────────┐
                    │StorageService│◀────│   Win/Loss  │
                    └──────────────┘     └─────────────┘
```

---

## 3. Моделі Даних

### 3.1 GameLevel
```dart
class GameLevel {
  final int id;
  final String name;
  final int gridWidth;
  final int gridHeight;
  final List<GameBlock> blocks;
  final List<GameDoor> doors;
  final List<Point> hiddenCells;
}
```

### 3.2 GameBlock
```dart
enum MoveDirection {
  horizontal,  // 0 - тільки горизонтально (←→)
  vertical,    // 1 - тільки вертикально (↑↓)
  both,        // 2 - в обидва напрямки
}

class GameBlock {
  final int blockType;        // Колір (0-9)
  final int blockGroupType;   // Форма (0-11)
  int gridRow;                // Позиція Y
  int gridCol;                // Позиція X
  final int rotationZ;        // Поворот (0-3)
  final MoveDirection moveDirection;  // Обмеження напрямку руху
  final int innerBlockType;   // Внутрішній шар (-1 = немає, 0-9 = колір)
  
  List<Point> get cells;      // Обчислені клітинки
  bool get hasInnerLayer;     // Чи є внутрішній шар
}
```

### 3.3 GameDoor
```dart
class GameDoor {
  final int blockType;        // Колір
  final int partCount;        // Розмір (1-4)
  final String edge;          // top/bottom/left/right
  final int startRow;
  final int startCol;
}
```

### 3.4 Типи блоків (blockGroupType)
| ID | Назва | Форма |
|----|-------|-------|
| 0 | Single | ▪ |
| 1 | Double | ▪▪ |
| 2 | Triple | ▪▪▪ |
| 3 | Quad | ▪▪▪▪ |
| 4 | ShortL | ▪▪ ▪ |
| 5 | ShortT | ▪▪▪ ▪ |
| 6 | Square | ▪▪ ▪▪ |
| 7 | L | ▪▪▪ ▪ |
| 8 | ReverseL | ▪▪▪ ▪ (mirror) |
| 9 | T | ▪▪▪ ▪ |
| 10 | S | ▪▪ ▪▪ (zigzag) |
| 11 | Z | ▪▪ ▪▪ (reverse zigzag) |

---

## 4. Ключові Алгоритми

### 4.1 Collision Detection
```dart
bool _canMove(GameBlock block, int deltaRow, int deltaCol, GameLevel level) {
  // 0. Перевірити обмеження напрямку руху (moveDirection)
  //    - horizontal: блокувати вертикальний рух (deltaRow != 0)
  //    - vertical: блокувати горизонтальний рух (deltaCol != 0)
  // 1. Обчислити нові позиції клітинок
  // 2. Перевірити межі поля
  // 3. Перевірити двері (дозволити вихід за межі якщо є двері)
  // 4. Перевірити колізії з іншими блоками
  // 5. Перевірити hidden cells
}
```

### 4.2 Door Exit Detection
```dart
void _checkDoorExit(GameLevel level) {
  // 1. Підрахувати клітинки блоку за межами поля
  // 2. Якщо >= 50% клітинок за межами:
  //    - Запустити анімацію виходу
  //    - Видалити блок
  // 3. Якщо всі блоки вийшли -> перемога
}
```

### 4.2.1 Багатошарові блоки (Multi-layer Blocks)
Блоки з `innerBlockType >= 0` мають два шари кольору: зовнішній (`blockType`) та внутрішній (`innerBlockType`).

**Візуалізація:**
- Зовнішній шар відображається як товста обводка блоку
- Внутрішній шар заповнює середину блоку та LEGO-стади

**Механіка виходу:**
```dart
void _checkLayerDestruction(GameBlock block, GameLevel level) {
  // 1. Якщо блок торкається дверей з кольором ЗОВНІШНЬОГО шару:
  //    - Руйнується зовнішній шар (outerLayerDestroyed = true)
  //    - Блок залишається на полі з кольором ВНУТРІШНЬОГО шару
  //    - Блок НЕ заходить в двері
  // 2. Після руйнування зовнішнього шару:
  //    - Блок може вийти тільки через двері ВНУТРІШНЬОГО кольору
  //    - При виході через правильні двері - блок видаляється повністю
}
```

**Властивості GameBlock для багатошарових блоків:**
- `innerBlockType`: колір внутрішнього шару (-1 = немає)
- `outerLayerDestroyed`: чи зруйновано зовнішній шар
- `activeBlockType`: повертає поточний активний колір (зовнішній або внутрішній)
- `hasInnerLayer`: чи є активний внутрішній шар

### 4.3 Block Shape Rotation
```dart
List<List<int>> rotateShape(List<List<int>> shape, int rotZ) {
  // rotZ: 0 = 0°, 1 = 90°, 2 = 180°, 3 = 270°
  // Застосувати матрицю повороту до кожної клітинки
}
```

---

## 5. Сервіси

### 5.1 StorageService
| Метод | Опис |
|-------|------|
| `init()` | Ініціалізація SharedPreferences |
| `getCompletedLevels()` | Отримати завершені рівні |
| `markLevelCompleted(id)` | Позначити рівень завершеним |
| `getSoundEnabled()` | Статус звуку |
| `getHapticEnabled()` | Статус вібрації |
| `resetProgress()` | Скинути прогрес |

### 5.2 AudioService
| Метод | Опис |
|-------|------|
| `lightTap()` | Легка вібрація (кнопки) |
| `mediumTap()` | Середня вібрація (pickup) |
| `heavyTap()` | Сильна вібрація (drop) |
| `success()` | Вібрація перемоги |
| `playPickup()` | Звук підняття блоку |
| `playDrop()` | Звук опускання блоку |
| `playWin()` | Звук перемоги |

---

## 6. Інтеграції

### 6.1 Поточні
- **SharedPreferences** - локальне збереження

### 6.2 Заплановані
- [ ] Firebase Analytics
- [ ] Firebase Crashlytics
- [ ] AdMob (rewarded ads)
- [ ] In-App Purchases

---

## 7. Вимоги до Продуктивності

| Метрика | Ціль |
|---------|------|
| Startup time | < 2s |
| Frame rate | 60 FPS |
| Memory usage | < 100 MB |
| APK size | < 20 MB |
| Battery drain | Мінімальний |

---

## 8. Тестування

### 8.1 Unit Tests
- [ ] GameBlock.cells calculation
- [ ] Collision detection
- [ ] Door matching

### 8.2 Widget Tests
- [ ] Menu navigation
- [ ] Level selection
- [ ] Win dialog

### 8.3 Integration Tests
- [ ] Complete level flow
- [ ] Progress saving

---

## Історія Змін

| Версія | Дата | Зміни |
|--------|------|-------|
| 1.4.0 | 2025-12-21 | Механіка багатошарових блоків: руйнування шарів при торканні дверей |
| 1.3.0 | 2025-12-21 | Додано innerBlockType - багатошарові блоки |
| 1.2.0 | 2025-12-21 | Додано MoveDirection - обмеження напрямку руху блоків |
| 1.1.2 | 2025-12-18 | Верифіковано 21 рівень, універсальний алгоритм ReverseL |
| 1.1.1 | 2025-12-18 | Виправлено Level 16 (двері), Level 19 (ShortL, двері) |
| 1.1.0 | 2025-12-18 | Оновлено структуру проекту, 27 рівнів (18 верифікованих) |
| 1.0.0 | 2025-12-17 | Початкова версія документа |

