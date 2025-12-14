# Color Block Jam - Аналіз рівнів

## Опис проекту

Цей архів містить повний технічний аналіз гри **Color Block Jam** версії 1.31.16. Включає витягнуті дані всіх 1557 рівнів, детальну документацію формату даних та інструменти для парсингу.

## Структура архіву

```
ColorBlockJam_Analysis/
│
├── README.md                    ← Цей файл
│
├── reports/                     ← Звіти та документація
│   ├── MAIN_REPORT.md           - Загальний технічний звіт
│   └── LEVELS_DOCUMENTATION.md  - Детальна документація рівнів
│
├── level_data/                  ← Дані рівнів
│   ├── parsed_levels_complete.json  - Всі 1557 рівнів (JSON)
│   ├── level_index.json             - Індекс рівнів
│   └── AllLevels_guids.json         - GUID всіх рівнів
│
└── tools/                       ← Інструменти
    └── level_parser_final.py    - Python парсер бінарних файлів
```

## Опис файлів

### Звіти (reports/)

| Файл | Опис |
|------|------|
| `MAIN_REPORT.md` | Загальний технічний звіт про структуру гри, системи рівнів, класи даних та бінарний формат |
| `LEVELS_DOCUMENTATION.md` | Детальна документація по рівнях з інструкцією відтворення |

### Дані рівнів (level_data/)

| Файл | Розмір | Опис |
|------|--------|------|
| `parsed_levels_complete.json` | ~5.6 MB | JSON з усіма 1557 рівнями: блоки, двері, камера, сітка |
| `level_index.json` | ~275 KB | Індекс рівнів з базовою інформацією |
| `AllLevels_guids.json` | ~227 KB | Список GUID всіх рівнів |

### Інструменти (tools/)

| Файл | Опис |
|------|------|
| `level_parser_final.py` | Python скрипт для парсингу бінарних файлів рівнів |

## Швидкий старт

### Перегляд даних рівнів

```python
import json

# Завантажити всі рівні
with open('level_data/parsed_levels_complete.json', 'r') as f:
    levels = json.load(f)

# Переглянути перший рівень
print(json.dumps(levels[0], indent=2))

# Статистика
print(f"Всього рівнів: {len(levels)}")
print(f"З блоками: {sum(1 for l in levels if l['blocks'])}")
print(f"З дверима: {sum(1 for l in levels if l['doors'])}")
```

### Пошук рівня за назвою

```python
def find_level(levels, name):
    return next((l for l in levels if l['name'] == name), None)

level_1 = find_level(levels, "Level 1")
print(f"Grid: {level_1['gridSize']}")
print(f"Blocks: {len(level_1['blocks'])}")
```

### Використання парсера

```bash
# Парсинг одного файлу
python tools/level_parser_final.py Level_1.bin

# Парсинг всіх файлів (потрібно вказати шлях в скрипті)
python tools/level_parser_final.py
```

## Формат даних рівня

### Структура JSON

```json
{
  "file": "Level_1.bin",
  "name": "Level 1",
  "guid": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "gridSize": {"x": 4, "y": 5},
  "camera": {
    "position": {"x": 0.0, "y": -6.0, "z": -21.0},
    "rotation": {"x": 345.0, "y": 0.0, "z": 0.0},
    "fov": 60.0
  },
  "hiddenCoords": [],
  "blocks": [...],
  "doors": [...]
}
```

### Типи блоків

| ID | Назва | Форма |
|----|-------|-------|
| 0 | One | ■ |
| 1 | Two | ■■ |
| 2 | Three | ■■■ |
| 3 | L | L-блок |
| 4 | ReverseL | Зворотній L |
| 5 | ShortL | Короткий L |
| 6 | Plus | + блок |
| 7 | TwoSquare | 2×2 квадрат |
| 8 | ShortT | T-блок |
| 9 | Z | Z-блок |
| 10 | ReverseZ | Зворотній Z |
| 11 | U | U-блок |

## Статистика

- **Всього рівнів**: 1557
- **100% успіх парсингу**
- **Найпопулярніші розміри сітки**: 6×8 (254), 7×7 (241), 6×6 (176)
- **Більшість рівнів**: 1-2 блоки (84.6%)

## Ліцензія та використання

Дані отримані з гри Color Block Jam розробника GybeGames для дослідницьких та освітніх цілей. Всі права на гру належать правовласнику.

---

*Створено: Грудень 2024*
