# Color Block Jam - Повний технічний звіт

## Загальна інформація

| Параметр | Значення |
|----------|----------|
| Назва гри | Color Block Jam |
| Версія | 1.31.16 |
| Package ID | com.GybeGames.ColorBlockJam |
| Розробник | GybeGames |
| Движок | Unity (IL2CPP) |
| Архітектура | ARM64-v8a |

---

## 1. Структура проекту

### 1.1 Основні компоненти

Гра побудована на движку Unity з використанням IL2CPP для компіляції C# коду в нативний код. Основні системи:

- **LevelSystem** - управління рівнями
- **BlockGroupSystem** - система блоків
- **DoorSystem** - система дверей/воріт
- **CameraSystem** - управління камерою
- **SaveSystem** - збереження прогресу

### 1.2 Ігрові ресурси

```
assets/
├── bin/Data/
│   ├── globalgamemanagers     # Налаштування Unity
│   ├── level0                 # Основні ресурси
│   ├── level1                 # Сцена гри
│   ├── sharedassets0.assets   # Спільні ресурси
│   └── sharedassets1.assets   # Дані рівнів (1557 рівнів)
├── lib/arm64-v8a/
│   └── libil2cpp.so          # Скомпільований код гри
```

---

## 2. Система рівнів

### 2.1 Загальна статистика

| Метрика | Значення |
|---------|----------|
| Всього рівнів | 1557 |
| Успішно розпарсено | 1557 (100%) |
| Рівнів з блоками | 1557 (100%) |
| Рівнів з дверима | 1531 (98.3%) |
| Рівнів в альбомах | 162 (18 альбомів × 9 рівнів) |

### 2.2 Розподіл розмірів сітки

| Розмір сітки | Кількість рівнів |
|--------------|------------------|
| 6×8 | 254 |
| 7×7 | 241 |
| 6×6 | 176 |
| 8×8 | 124 |
| 6×7 | 115 |
| 7×6 | 94 |
| 8×9 | 81 |
| 7×8 | 74 |
| 9×9 | 51 |
| 7×10 | 45 |
| Інші | 302 |

### 2.3 Розподіл кількості блоків

| Кількість блоків | Рівнів |
|------------------|--------|
| 1 | 287 |
| 2 | 1031 |
| 3 | 112 |
| 4-7 | 63 |
| 8-11 | 45 |
| 12+ | 19 |

---

## 3. Ігрові об'єкти

### 3.1 Типи блоків (BlockGroupType)

| ID | Назва | Опис |
|----|-------|------|
| 0 | One | Одинарний блок (1×1) |
| 1 | Two | Двійковий блок (1×2) |
| 2 | Three | Потрійний блок (1×3) |
| 3 | L | L-подібний блок |
| 4 | ReverseL | Зворотній L-блок |
| 5 | ShortL | Короткий L-блок |
| 6 | Plus | Хрестоподібний блок |
| 7 | TwoSquare | Квадратний 2×2 блок |
| 8 | ShortT | T-подібний блок |
| 9 | Z | Z-подібний блок |
| 10 | ReverseZ | Зворотній Z-блок |
| 11 | U | U-подібний блок |

### 3.2 Типи елементів рівня (LevelElementType)

| ID | Назва | Функція |
|----|-------|---------|
| 0 | None | Без елемента |
| 1 | Ice | Лід (потребує розбиття) |
| 2 | Star | Зірка (бонусний об'єкт) |
| 3 | Key | Ключ |
| 4 | Lock | Замок |
| 5 | TimerBomb | Бомба з таймером |
| 6 | Curtain | Завіса |
| 7 | Scissors | Ножиці |
| 8 | Ropes | Мотузки |
| 9 | HiddenColor | Прихований колір |
| 10 | CountBomb | Лічильник бомби |

### 3.3 Кольори блоків (BlockType)

Блоки мають числовий ідентифікатор кольору (0-10+), який визначає:
- Колір візуального відображення
- Відповідність дверям того ж кольору
- Правила з'єднання блоків

---

## 4. Класи та структури даних

### 4.1 Ієрархія класів рівнів

```
ScriptableObject
└── BaseLevel (ILevel)
    └── LevelData
        └── LevelDataPureClass (серіалізовані дані)
```

### 4.2 LevelData - основний клас рівня

```csharp
public class LevelData : BaseLevel
{
    string id;                              // Унікальний GUID
    LevelDataPureClass _levelDataPureClass; // Всі дані рівня
}
```

### 4.3 LevelDataPureClass - дані рівня

```csharp
public class LevelDataPureClass
{
    Vector2Int _gridSize;                   // Розмір сітки (X × Y)
    List<Vector2Int> _hidedGridCoords;      // Приховані клітинки
    List<GridColorData> _gridColorDatas;    // Кольори сітки
    LevelCameraData _levelCameraData;       // Дані камери
    LevelDoorsData _levelDoorsData;         // Двері
    LevelBlockadesData _levelBlockadesData; // Блокади
    LevelBlockGroupsData _levelBlockGroupsData; // Блоки
    List<LevelJoinLockDatas> _levelJoinLockDatasList;
    LevelCratesData _levelCratesData;       // Ящики
}
```

### 4.4 LevelBlockGroupData - дані блоку

```csharp
public class LevelBlockGroupData
{
    Vector3 _position;           // Позиція в світі
    Vector3 _rotation;           // Ротація (0°, 90°, 180°, 270°)
    Vector3 _scale;              // Масштаб
    int _blockGroupType;         // Тип форми (enum)
    int _blockType;              // Колір
    bool _isOneWayMovementActive;
    int _oneWayMovementCounter;
    int _wayDirection;
    bool _isBlocker;             // Чи є блокером
    bool _isBlockerFixed;
    int _blockerCounter;
    bool _isRainbow;             // Веселковий блок
    bool _hasTimeCapsule;
    int _timeCapsuleDuration;
    bool _hasColorSwitcher;
    int _colorSwitcherBlockType;
    LevelElementData _blockGroupLevelElementData;
}
```

### 4.5 LevelDoorData - дані дверей

```csharp
public struct LevelDoorData
{
    Vector3 _position;     // Позиція
    Vector3 _rotation;     // Ротація
    int _doorPartCount;    // Кількість частин
    int _blockType;        // Колір
    bool _hasStar;         // Чи є зірка
    bool _isSwitchDoor;    // Перемикач
    bool _hasIce;          // Чи покрито льодом
    int _iceCount;         // Кількість шарів льоду
}
```

---

## 5. Бінарний формат файлів рівнів

### 5.1 Загальна структура (*.bin)

```
Offset  | Size  | Тип          | Опис
--------|-------|--------------|------------------
0x00    | 0x1C  | bytes        | Заголовок (padding)
0x1C    | 4     | int32        | Довжина назви
0x20    | var   | string       | Назва рівня
align4  | 4     | int32        | Довжина GUID (36)
+4      | 36    | string       | GUID
align4  | 4     | int32        | Grid Size X
+4      | 4     | int32        | Grid Size Y
+8      | 4     | int32        | Hidden coords count
+12     | n×8   | Vector2Int[] | Hidden coordinates
...     | 4     | int32        | Grid color count
...     | n×8   | Vector2Int[] | Grid colors
...     | 12    | Vector3      | Camera position
...     | 12    | Vector3      | Camera rotation
...     | 4     | float        | Camera FOV
...     | 4     | int32        | Door count
...     | n×40  | Door[]       | Door data
...     | 4     | int32        | Block count
...     | n×44  | Block[]      | Block data
```

### 5.2 Структура блоку (44 байти)

```
Offset | Size | Тип     | Опис
-------|------|---------|------------------
0x00   | 12   | Vector3 | Position (x, y, z)
0x0C   | 12   | Vector3 | Rotation (x, y, z)
0x18   | 12   | Vector3 | Scale (x, y, z)
0x24   | 4    | int32   | BlockGroupType
0x28   | 4    | int32   | BlockType (color)
```

### 5.3 Структура дверей (40 байт)

```
Offset | Size | Тип     | Опис
-------|------|---------|------------------
0x00   | 12   | Vector3 | Position
0x0C   | 12   | Vector3 | Rotation
0x18   | 4    | int32   | Door part count
0x1C   | 4    | int32   | BlockType (color)
0x20   | 1    | bool    | Has star
0x21   | 1    | bool    | Is switch door
0x22   | 1    | padding |
0x23   | 1    | bool    | Has ice
0x24   | 4    | int32   | Ice count
```

---

## 6. Взаємозв'язки компонентів

### 6.1 Завантаження рівня

```
1. LevelLoader.LoadLevel(ILevel)
   ↓
2. LevelSpawnManager.Spawn(LevelData)
   ↓
3. Створення BlockGroup об'єктів
   ↓
4. Створення Door об'єктів
   ↓
5. Налаштування камери
```

### 6.2 Механіка гри

```
Блок (BlockGroup)          Двері (Door)
     │                          │
     │ blockType (колір)        │ blockType (колір)
     │                          │
     └──────────┬───────────────┘
                │
                ▼
         MATCHING SYSTEM
         (блок входить в двері
          того ж кольору)
```

### 6.3 Система альбомів

```
AllLevels (ScriptableObject)
├── Album 1 (stage1)
│   ├── Level 1-1 (album1)
│   ├── Level 1-2 (album2)
│   └── ... (9 рівнів)
├── Album 2 (stage2)
│   └── ... (9 рівнів)
└── Album 18 (stage18)
    └── ... (9 рівнів)

Всього: 18 альбомів × 9 = 162 рівні в альбомах
+ 1395 додаткових рівнів
= 1557 рівнів
```

---

## 7. Можливість відтворення рівнів

### 7.1 Що можна відтворити (100%)

- **Геометрію рівня** - розмір сітки, приховані клітинки
- **Позиції блоків** - точні координати X, Y, Z
- **Ротації блоків** - кути 0°, 90°, 180°, 270°
- **Типи блоків** - форма (One, Two, L, тощо)
- **Кольори** - відповідність блоків і дверей
- **Позиції дверей** - координати та орієнтація
- **Налаштування камери** - позиція, ротація, FOV

### 7.2 Приклад відтворення Level 1

```json
{
  "name": "Level 1",
  "gridSize": {"x": 4, "y": 5},
  "camera": {
    "position": {"x": 0.0, "y": -6.0, "z": -21.0},
    "rotation": {"x": 345.0, "y": 0.0, "z": 0.0},
    "fov": 60.0
  },
  "blocks": [
    {
      "position": {"x": -4.56, "y": 5.52, "z": 0.0},
      "rotation": {"x": 270.0, "y": 0.0, "z": 0.0},
      "blockGroupTypeName": "One",
      "blockType": 0
    },
    {
      "position": {"x": -3.0, "y": 5.54, "z": 1.5},
      "rotation": {"x": 270.0, "y": 0.0, "z": 0.0},
      "blockGroupTypeName": "Two",
      "blockType": 0
    }
    // ... ще 6 блоків
  ],
  "doors": [
    {
      "position": {"x": -1.0, "y": -6.0, "z": 0.0},
      "doorPartCount": 3,
      "blockType": 3
    }
  ]
}
```

---

## 8. Файли та ресурси

### 8.1 Витягнуті файли

| Файл | Опис | Розмір |
|------|------|--------|
| parsed_levels_complete.json | Всі 1557 рівнів | 5.6 MB |
| level_index.json | Індекс рівнів | 275 KB |
| AllLevels_guids.json | GUID всіх рівнів | 227 KB |
| levels_raw/*.bin | Бінарні файли | 1557 файлів |

### 8.2 Інструменти

| Файл | Призначення |
|------|-------------|
| level_parser_final.py | Python парсер бінарних файлів |

---

## 9. Висновки

### 9.1 Досягнуті результати

1. **Повний аналіз** структури гри Color Block Jam
2. **Витягнуто 1557 рівнів** у форматі JSON
3. **Розшифровано бінарний формат** файлів рівнів
4. **100% успіх** парсингу всіх рівнів
5. **Створено інструменти** для подальшої роботи

### 9.2 Практичне застосування

Отримані дані дозволяють:
- Відтворити всі рівні в іншому движку
- Аналізувати складність рівнів
- Створювати нові рівні за шаблоном
- Вивчати геймдизайн гри

---

*Звіт створено: Грудень 2024*
