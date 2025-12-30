**Match3 \- NEW \- Программа Playcus Brute-Force v 0.0.2**

Brute-Force представляет собой отдельное веб\-приложение, в которое заложена функция синхронизации файлов уровней с PROD и DEV версиями игры.

**ВАЖНО.** Программу Brute-Force, ее архитектуру, модульность и т.п., необходимо максимально делать универсальной, чтобы можно было использовать в других проектах, например другое матч-3 или Слоты. Основные составляющие программы: Главное Окно, где задаются параметры Эмуляции, а также Статистика.

Главное для программы Brute-Force всегда иметь последнюю DEV и PROD версию игрового движка (гейм-логики), на котором будет производиться эмуляция. Например, если в игре изменилась логика выбора цели для спецэлемента “светлячок”, или время его активации (“полета”), то это неприменно влияет на все игровые параметры, и легко может изменить сложность уровня, например показатель LOSE\_RATE, сделав его критически неверным для всего баланса уровня/локации/игры.

| Brute-Force \- Main Screen |
| :---: |

1) Вверху приложения указывается текущая версия программы Brute-Force. В приложении Brute-Force или где\-либо в отдельном файле левел-дизайнеру необходимо иметь доступ к файлу “Change Log”, чтобы видеть изменения, которые имеются в текущей версии.  
2) **Load Level** \- Первый селектор отвечает за номер уровня. Именование уровня происходит следующим образом: (карта, локация, уровень). Например 1.2.15. Далее селектором можно выбрать, откуда загрузить уровень, с DEV ветки, или PRODUCTION. Правее находится статус-бар, в котором могуть быть следующие сообщения:

| Ситуация | Текст |
| ----- | ----- |
| Файл успешно загружен (возможно сделать какой-либо “checker” файла уровня на наличие ошибок), но как правило проверки просто на то, что он загружен, и не было сбоев интернета, или что файл не поврежден \- достаточно. Last edit \- здесь определяется разница между датой, записанной в файле уровня (записывается локальная дата комьютера), и текущей датой. Это дает возможность левел-дизайнеру удостоверится, что он работает с последней версией файла и ничего не закешировалось. | File “level\_(number).lvl” successfully loaded\! Last edit: 30 sec ago |
| Такое сообщение может появиться, если прервался интернет, или файл поврежден, или какая-либо другая ошибка. | ERROR\! File “level\_(number).lvl” not loaded\! |

3) **Use Game Engine** \- селектором можно выбрать, какой игровой движок использовать, DEV или PROD версию. Правее указывается версия игрового движка, а также последнее время изменения (т.к. левел-дизайнер может быть не в курсе изменений версии движка, и должен иметь представление насколько он устарел, чтобы исключить возможность того, что он по какой-либо причине перестал “подтягиваться” в Brute-Force.  
4) кнопка **Reload Level** \- перезагружает файл уровня, и если появилась более свежая версия файла \- загружает ее. **Variant** \- выбор [варианта](https://docs.google.com/a/playcus.com/document/d/1MIOS9xZskPt4FtVQJXZ9tuTcZGWOL-thhOB29viq48U/edit#bookmark=id.gorzxixpleyi) для уровня.  
5) Play level in Normal Mode \- запускается уровень в обычном режиме. Валюты игры при этом можно все поставить в значение “999”. Необходимо для того, чтобы гейм-дизайнер мог тестировать уровень не выходя из программы Brute-Force. В уровне, при нажатии на кнопку Выхода, левел-дизайнер попадает обратно в Brute-Force.  
6) **Max number of retries on level** \- Когда эмулятор играет в уровень, данное указанное количество должно при наступлении указанного значения остановить попытки пройти уровень, и перейти к следующей Эмуляции. При наступлении данного события на любом этапе эмуляции, Эмуляция приостанавливается, и добавляется кнопка на Главное Окно под кнопкой “Start Emulation…” инфо-панель становится красной, и в логе пишется: WARNING\!\!\! Max number of retries (number) reached on Emulation \#(number). Кнопка называется “Continue Anyway” \- после нажатия на которой Эмуляция продолжается на текущей Эмуляции, до момента, пока не пройдет уровень.  
7) Кнопка **Stop** всегда активна, и в любой момент останавливает процесс Эмуляции. После этого доступна статистика Эмуляции, включая последний завершенный retry.  
8) Инфо-панель \- здесь логгируются все операции \- загрузка файла, старт эмуляции, пауза, номер текущей попытки и номер эмуляции пишутся как: “Current Emulation number 34, retry 12”. Также указывается время от старта Эмуляции и используемый Алгоритм ходов.  
9) Кнопка **View Brute-Force Stat…** открывает окно со [статистикой](#bookmark=id.j1nx13751y8p) Brute-Force’a (или выводит статистику ниже Приложения).  
10) Кнопка **View Retry by ID** \- запускает уровень, подобно Play level in Normaд Mode, только у левел-дизайнера будут точно такие же ленты, с точно таких же позиций, точно такие же подсказки на каждом ходу (подсказки, куда летели “рыбки”, что взрывали спец.комбинации, и тд при Эмуляции должны писаться отдельно во внутреннюю статистику, чтобы можно было поиграть в любую эмуляция/попытку, пока левел-дизайнер не закрыл программу Brute-Force). В итоге данные статистики Brute-Force’a должны 1:1 совпасть с тем, как сыграет левел-дизайнер, в случае конечно, если левел-дизайнер не сделал что-то не по подсказке. Если в уровне присутствует где\-либо логика рандома (спец.генератор, который может работать не по лентам, например), это также записывается в файл Эмуляции, чтобы воспроизвести при надобности игру на уровне. Это все необходимо для того, чтобы проверить Brute-Force или игровой движок на наличие несовпадений, иначе смысл Brute-Force’a теряется совсем, если не проверить его работу. Каждой Эмуляции/реплею присваивается ID по нарастанию, и при просмотре статистики выводится этот номер, чтобы его можно было найти, и ввести правее кнопки View Retry by ID.  
11) **Save Brute-Force stat to level file…** \- добавляет в файл уровня Summary информацию о параметрах брут форса.  
12) Кнопка **Settings** или по подобию Главного окна, или ниже Приложения выводит таблицу с [настройками](#bookmark=kix.yzkbszbn0wjv).

Во время процесса Эмуляции, все кнопки и селекторы становятся неактивными (серыми), кноме кнопки Stop, и наоборот. Соответственно кнопки Reload Level и Play level in Normal Mode неактивны, если не выбран/не загружен уровень. Start Emulation неактивна до момента, пока не загружен уровень и не указаны параметры Эмуляции. View Brute-Force Stat, View Retry by ID, Save Brute-Force stat to level file, активны только после того, как закончился процесс Эмуляции.

| Brute-Force \- View Stat |
| :---: |

На странице статистики Эмуляции должна быть кнопка “Save Stat to html” (или pdf, или любой другой формат, удобный для просмотра) или кнопка открытия статистики в новой вкладке. Таким образом, чтобы левел-дизайнер имел возможность быстро подредактировать параметры уровня, перезапустить Эмуляцию, и сравнить данные.

**Параметры уровня:**

| Номер уровня: | 1.3.15 (45) |
| :---- | :---- |
| Количество полей: | 2 |
| Цель уровня:  | собрать 8 “медведей” |
| “So close” событие: | собрал 6 “медведей” |
| Количество ходов: | 35 |
| Количество цветов: | 5 (blue, orange, yellow, green, red) |
| Random Seed: | yes |
| Plan Score 1: | 10000 |
| Plan Score 2: | 20000 |
| Plan Score 3: | 30000 |

**Параметры эмуляции:**

| Количество произведенных эмуляций | 1000 |
| :---- | :---- |
| Макс. количество попыток на уровне: | 200 |
| Алгоритм ходов: | hints |

**Lose Rate (количество потраченных жизней):**  
![][image1]

| Показатель | Параметр | Комментарий (для ТЗ) |
| ----- | ----- | ----- |
| Min. | 1 |  |
| Max. | 22 |  |
| Avg before Percenile: |  |  |
| Avg after Percenile: | 10 |  |
| Median before Percenile: | 11 |  |
| Median after Percenile: | 15 |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0): | 44% |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0) (7th Percentile): | 27% |  |
| Adjust Percentile: | 7% (Refresh) | это настраиваемое поле (вводимое значение-цифра от 0 до 15), которое по умолчанию имеет значение 7, и может быть изменено, и по нажатию на кнопку “Refresh”, которая находится правее \- происходит пересчет Коэффициента вариации с Процентилями (строка выше). |

Расчёт медианы в бруте: по каждому юзеру считается сумма лузов, сортируется результат и если кол-во юзеров четное \-  то берется avg двух центральных значений, нечетное \- то берется центральное значение. Учитываются все игроки/боты \- кто прошел и кто не прошел уровень.

**% выполнения уровня (исключая выигрышные):**  
![][image1]

| Показатель | Параметр | Комментарий (для ТЗ) |
| ----- | ----- | ----- |
| Min. | 10 | минимальное кол-во для одного игрока |
| Max. | 99 | максимальное кол-во для одного игрока |
| Avg. | 50 | среднее кол-во для одного игрока |
| Median | 80 | медианное кол-во для одного игрока |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0): | 33% |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0) (7th Percentile): | 27% |  |

**FUUU-Factor:**  
![][image1]

| Показатель | Параметр | Комментарий (для ТЗ) |
| ----- | ----- | ----- |
| FUUU-Factor: | **10** (144 (попыток всего / 14 “почти”) \= 10\) | “почти” \- событие “почти прошел” Если значение 10 и более \- подсвечивать поле красным. |
| Min. | 1 | минимальное значение FUUU для одного игрока |
| Max. | 22 | максимальное значение FUUU для одного игрока |
| Avg. | 10 | среднее значение FUUU для одного игрока (сначала считаем среднее для каждого игрока, а потом среднее по средним) |
| Median | 11 | медианное значение FUUU для одного игрока |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0): | 33% |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0) (7th Percentile): | 27% |  |
| Количество попыток всех игроков |  | Количество попыток всех игроков, которые они сделали до того как пройти уровень |
| Количество событий “Так близко”  во всех попытках |  | Количество событий “Так близко”  во всех попытках, которые они сделали до того как пройти уровень |
| % выполнения уровня |  | % выполнения уровня для события “Так близко” |
| Мин. значение |  | Мин. значение для события “Так близко” |

**Scores:**  
![][image1]

| Показатель | Параметр | Комментарий |
| ----- | ----- | ----- |
| Score min. | 9000 |  |
| Score max. | 22000 |  |
| Score avg. | 15000 |  |
| Score median | 14000 |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0): | 33% |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0) (7th Percentile): | 27% |  |
| Score 1 star: | 145 times (33%) (10000 points) | Минимальное значение Эмуляции. Таким образом, все игроки, которые пройдут уровень, в любом случае будут иметь хотябы 1 звезду. |
| Score 2 star: | 145 times (33%) (14000 points) | Должно быть медианное значение |
| Score 3 star: | 145 times (33%) (25000 points) | Минимальное значение очков из набранных наилучших результатов 25% игроков. Таким образом, шанс получить 3 звезды у игрока 1 из 4 побед, что означает, что необходимо выиграть в уровне до 4х раз, чтобы получить 3 звезды. |

**Moves:**  
![][image1]

| Min. | 10 |
| :---- | :---- |
| Max. | 55 |
| Avg. | 20 |
| Median | 21 |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0): | 33% |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0) (7th Percentile): | 27% |

**Possible Events:**

Если были возможны комбинации “спец.символ \+ спец.символ” \- то счетчик прибавляется и к одному и к другому спец.символу.

| Median \# of “fish” / retry | 4 |
| :---- | :---- |
| Median \# of 4 in a row / retry | 3 |
| Median \# of T bomb / retry | 5 |
| Median \# of L bomb / retry | 4 |
| Median \# of color bomb / retry | 3 |
| Median \# of coloring bomb / retry | 0 |

**Activated Events:**

| Median \# of “fish” / retry | 4 |
| :---- | :---- |
| Median \# of 4 in a row / retry | 3 |
| Median \# of T bomb / retry | 5 |
| Median \# of L bomb / retry | 4 |
| Median \# of color bomb / retry | 3 |
| Median \# of coloring bomb / retry | 0 |

**Cascades:**  
![][image1]

| Показатель | Параметр | Комментарий (для ТЗ) |
| ----- | ----- | ----- |
| Min. | 1 |  |
| Max. | 22 |  |
| Avg. | 10 |  |
| Median | 11 |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0): | 33% |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0) (7th Percentile): | 27% |  |

**Shuffle:**  
![][image1]

| Показатель | Параметр | Комментарий (для ТЗ) |
| ----- | ----- | ----- |
| Min. | 1 |  |
| Max. | 22 |  |
| Avg. | 10 |  |
| Median | 11 |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0): | 33% |  |
| [Coefficient of Variation](https://docs.google.com/a/playcus.com/spreadsheets/d/1SMKmmAdNCjtXBxkP_2D3i7iKERR9ltWMWLevF5bmR8g/edit#gid=0) (7th Percentile): | 27% |  |

**Shuffle\_error:**

| Показатель | Параметр | Комментарий (для ТЗ) |
| ----- | ----- | ----- |
| Number | 12 (0,01)% per 1000 retries | ситуации, когда невозможен Shuffle символов так, чтобы не появился возможный какой-либо ход. Количество попыток показывается за все время эмуляции, и соответственно процент от этих попыток. |

**Эмуляции:** (Данная таблица не открывается/загружается автоматически), а слово “Эмуляции” является ссылкой или кнопкой, при нажатии на которую загрузится таблица. То есть эти данные, если они будут усложнясь/удлиннять процесс открытия статистики не нужны в первую очередь.

| Эмуляции |  |  |  |  |  |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **\# Emulation** | **Result** | **Lose Rate (потрачено жизней)** | **FUUU-Factor** | **% медиана выполнения цели** | **Avg. Shuffle** |
| 1 | win | 5 | 3 | 50% | 3% |
| 2 | win | 4 | 20 |  | 4% |
| 3 | lose | 200 (max limit\!) | 23 |  | 4% |
| 4 |  |  |  |  |  |
| 5 |  |  |  |  |  |
| 6 |  |  |  |  |  |
| 7 |  |  |  |  |  |
| ... |  |  |  |  |  |
| 200 |  |  |  |  |  |

**Попытки:** (Данная таблица не открывается/загружается автоматически), а слово “Попытки” является ссылкой или кнопкой, при нажатии на которую загрузится таблица. То есть эти данные, если они будут усложнясь/удлиннять процесс открытия статистики не нужны в первую очередь.

| Retries |  |  |  |  |  |  |  |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **\# Retry** | **Result** | **Number of moves** | **% выполнения цели** | **Shuffle number** | **Shuffle Error** | **Score** | **Star** |
| 1 | lose | 5 | 3 | 3% | n/a | n/a | n/a |
| 2 | lose | 4 | 10 | 4% | n/a | 13000 | 1 |
| 3 | lose | 200 (max limit\!) | 23 | 4% | 2 | n/a | n/a |
| 4 | win | 39 | 77 | 42% | n/a |  |  |
| 5 |  |  |  |  |  |  |  |
| 6 |  |  |  |  |  |  |  |
| 7 |  |  |  |  |  |  |  |
| ... |  |  |  |  |  |  |  |
| 200 |  |  |  |  |  |  |  |

| Brute-Force \- Settings |
| :---: |

**Alerts:** (Данные диапазоны будут реагировать на показатели статистики, и если значение параметра выходит за рамки допустимого значения, весь текст или ячейки таблицы отображаются красным. Если в пределах допустимого значения \- зеленым.

| Допустимое значение | Обратить внимание\! |
| :---: | :---: |

| Parameter | Min | Max |
| ----- | :---: | :---: |
| **Lose Rate** Coefficient of Variation (w 7th Percentile): | 33% | 1000% |
| **FUUU-Factor** Coefficient of Variation (w 7th Percentile): | 33% | 100% |
| **Scores** Coefficient of Variation (w 7th Percentile): | 33% | 100% |
| **Moves** Coefficient of Variation (w 7th Percentile): | 33% | 100% |
| **Shuffle\_error:** | 0% | 1% |

[image1]: <data:image/png;base64,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>