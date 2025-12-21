# Бекап чату: Дослідження рівнів 28-31

**Дата:** 19 грудня 2025

---

## Правила роботи з верифікацією рівнів

### Процес верифікації
1. Користувач каже що саме треба змінити в рівні
2. Я змінюю алгоритм парсингу, **але враховую щоб верифіковані рівні не змінились**
3. Треба знайти рішення яке не зламає вже готове
4. Якщо зміни впливають на верифіковані рівні - **нічого не міняю, а питаю користувача**

### Після зміни парсера обов'язково:
1. Перепарсити рівні (`python res/ColorBlockJam_Analysis/tools/parse_from_unity.py`)
2. Оновити візуалізатор (`level_visualizer.html`)
3. Оновити гру (`python res/ColorBlockJam_Analysis/tools/export_game_levels.py`)
4. Запустити верифікацію (`python res/ColorBlockJam_Analysis/tools/verify_levels.py`)
5. Оновити документацію (ТЗ, ГД, roadmap)
6. Зробити коміт та пуш через `/git` агент

### Важливо про парсер
- **Ніяких заморожених рівнів** - тільки живий парсинг
- Після змін в парсері - пробігати по всім рівням і перевіряти зміни
- Якщо є зміни в верифікованих рівнях - **відкатуємо зміни в парсері і шукаємо інший шлях**

### Інструмент верифікації
```bash
# Зберегти snapshot верифікованих рівнів
python res/ColorBlockJam_Analysis/tools/verify_levels.py --save

# Перевірити чи не зламались верифіковані рівні
python res/ColorBlockJam_Analysis/tools/verify_levels.py
```

### Поточний статус
- **27 рівнів верифіковано** (станом на 19.12.2025)
- Snapshot зберігається в `res/ColorBlockJam_Analysis/level_data/verified_levels_snapshot.json`

---

## Проблема

Рівні з Game Index 28-31 відсутні в локальних файлах APK. Вони мають GUID-и, але самі дані рівнів (блоки, двері) не знайдені в `_combined_sharedassets2.assets`.

### Відсутні рівні (GUID):
- **Game Index 28:** `3a21dc2a-95ed-42b1-aa96-24af7ffae92a`
- **Game Index 29:** `648d6ef2-8c27-4583-8fca-4e03d8e16557`
- **Game Index 30:** `7bf81a57-669f-4969-a86f-44e1c99a4c72`
- **Game Index 31:** `ad8c6c0e-f2cf-41b9-b6e8-fcf8008c481e`

## Що ми виявили

### 1. Рівні завантажуються з сервера
- Firebase Storage bucket: `color-block-jam.firebasestorage.app`
- Знайдено класи: `NewLevelDataWithAdditionals`, `_newAddedLevelsWithAdditionals`
- Remote Config містить метадані (duration, hardness), але НЕ самі дані рівнів

### 2. Витягнуті файли з телефону
Папка: `res/ColorBlockJam_Analysis/phone_cache/`

| Файл | Опис |
|------|------|
| `ELEPHANT_REMOTE_CONFIG_DATA` | Remote Config (571KB) - метадані рівнів |
| `CACHED_OPEN_RESPONSE` | Кешована відповідь сервера (685KB) |
| `Save.dat` | Save файл гри |
| `Save_after28.dat` | Save після проходження 28 рівня |
| `game_backup.ab` | ADB backup гри (60MB) |
| `backup_extracted/` | Розпакований backup |

### 3. Що містить Remote Config
```
all_level_data_with_additionals - 167715 chars (тільки GUID, duration, hardness)
latest_new_level_data_with_additionals - 5281 chars (нові рівні)
loop_level_data_with_additionals - 60125 chars (loop рівні)
level_indexes - порядок рівнів
level_durations - тривалість рівнів
```

### 4. Backup НЕ містить даних рівнів
Unity Addressables кешує дані в `/data/data/com.GybeGames.ColorBlockJam/` (потрібен root) або взагалі не кешує (завантажує кожен раз).

## Створені інструменти

| Скрипт | Призначення |
|--------|-------------|
| `tools/analyze_level_gaps.py` | Аналіз прогалин в рівнях |
| `tools/analyze_remote_config.py` | Аналіз Remote Config |
| `tools/analyze_cached_response.py` | Аналіз кешованої відповіді |
| `tools/analyze_save.py` | Аналіз Save.dat |
| `tools/check_level28_save.py` | Перевірка GUID 28 рівня в Save |
| `tools/extract_backup.py` | Розпакування ADB backup |
| `tools/extract_playerprefs.py` | Витягування PlayerPrefs |
| `tools/search_remote.py` | Пошук remote patterns |
| `tools/search_api.py` | Пошук API endpoints |
| `tools/find_firebase_url.py` | Пошук Firebase URLs |
| `tools/check_firebase_storage.py` | Перевірка Firebase Storage |

## Варіанти отримання даних рівнів

### 1. Charles Proxy (рекомендовано)
- Встановити Charles на ПК
- Налаштувати телефон через proxy
- Встановити SSL сертифікат Charles на телефон
- Зайти на рівень 29+ і побачити що завантажується
- **Безпечно**, не змінює телефон

### 2. Root телефон
- Отримати root доступ (Magisk)
- Доступ до `/data/data/com.GybeGames.ColorBlockJam/`
- **Ризиковано** - втрата гарантії, можливість "зацеглити" телефон

### 3. Оновлена версія APK
- Можливо в новішій версії ці рівні вже є локально

## Статус верифікації рівнів

- ✅ Рівні 1-27: Верифіковані
- ❌ Рівні 28-31: Відсутні в APK (завантажуються з сервера)
- ⏳ Рівень 32+: Не перевірялись

## Команди ADB для подальшої роботи

```bash
# Перевірка підключення
adb devices

# Список файлів гри (зовнішнє сховище)
adb shell "ls -la /sdcard/Android/data/com.GybeGames.ColorBlockJam/"

# Витягти файл
adb pull "/sdcard/Android/data/com.GybeGames.ColorBlockJam/files/Save.dat" ./

# Backup гри
adb backup -f game_backup.ab -noapk com.GybeGames.ColorBlockJam

# З root доступом - внутрішнє сховище
adb shell su -c "ls -la /data/data/com.GybeGames.ColorBlockJam/"
```

## Примітки

- GUID 28 рівня (`3a21dc2a-95ed-42b1-aa96-24af7ffae92a`) з'явився в Save.dat після проходження рівня
- Внутрішня назва 28 рівня: `Level mix Derin 19`
- Firebase Storage захищений - без автентифікації не можна отримати файли

