# DND Design System — плагин Figma

Плагин собирает в Figma дизайн-систему проекта **из Dart-токенов**: переменные,
текстовые стили и компоненты, названные ровно так же, как виджеты в
`lib/widgets/`.

Вторая страница — **Flutter Kit**: 40 блоков Material 3 с именами классов
Flutter (`FilledButton`, `Card`, `NavigationBar`, `TextField`, `Scaffold`…).
Собираются из тех же токенов, поэтому акцент, радиусы и отступы совпадают с
приложением.

Обе страницы работают **библиотекой**: при запуске открывается каталог с
живыми превью, фильтром по категориям и поиском. Клик вставляет инстанс на
макет.

Экраны плагин **не генерирует**. Макеты собираются инстансами на странице
«Макеты», а Dart-код по макету пишется отдельно — по ссылке на фрейм.

```
Dart-токены  →  design_system.json  →  плагин  →  Figma
Figma-фрейм  →  REST (figma_read.mjs)  →  спека  →  Dart
```

## 1. Обновить токены

Источник правды — `lib/theme/`. Меняешь цвет, отступ, радиус или стиль текста —
пересобираешь JSON:

```powershell
cd D:\KorandDev\DND_APP
flutter test tool/export_design_system_test.dart
```

Файл `figma_ds/design_system.json` перезаписывается. Проверить, что плагин его
переварит, можно без Figma:

```powershell
node figma_ds/mock/run.mjs
```

Второй сценарий — сборка Figma без Variables API (старая версия или
ограничения плана). Плагин обязан выжить на сырых цветах:

```powershell
node figma_ds/mock/run.mjs --no-variables
```

Ожидаемый вывод:

```
Компоненты (6):
  RollButton           320×56  детей 1
  DiceChip/Default     hug×40  детей 1
  DiceChip/Selected    hug×40  детей 1
  CountStepper         320×56  детей 3
  SurfaceCard          320×hug  детей 2
  DiceShape            200×200  детей 1
Переменные: 29 (DND / Tokens)
Текстовые стили: 10
Kit (40): Buttons 8, Selection 4, Chips 3, Inputs 4, Surfaces 5, Navigation 5, Dialogs 4, Progress 2, Data 1, Blocks 4
Библиотека: 46 карточек, групп 11, превью 46
Вставка: «EmptyState» → «Макеты», выделено 1
OK: контракт плагина соблюдён
```

## 2. Импортировать плагин (один раз)

1. Открой **Figma desktop** (в браузере локальные плагины не грузятся).
2. Меню → **Plugins → Development → Import plugin from manifest…**
3. Выбери `D:\KorandDev\DND_APP\figma_ds\manifest.json`.
4. В списке появится **DND Design System**.

`networkAccess` в манифесте нет: плагин не ходит в сеть. JSON читается с диска
через `<input type="file">`.

## 3. Библиотека компонентов

При запуске плагин открывается **на вкладке «Библиотека»** — это каталог всех
блоков: 6 виджетов проекта и 40 блоков Material 3.

| Элемент | Что делает |
|---|---|
| Превью | реальный `exportAsync` PNG из Figma, ширина 320 |
| Имя | имя компонента = имя Dart-виджета (`FilledButton`, `Card`, `RollButton`) |
| Подпись | путь к Dart-файлу (`lib/...`) или сигнатура конструктора |
| Размер | категория и `W×H` компонента |
| Фильтр | чипы по категориям: Buttons, Inputs, Navigation, Blocks… |
| Поиск | по имени, категории, описанию и сигнатуре |
| Обновить | перечитать список со страниц ДС и kit |

Клик по карточке вставляет **инстанс** в центр вьюпорта, выделяет его и зумит.
Если текущая страница — `DND Design System` или `Flutter Kit`, плагин сначала
переводит на `Макеты`: пересборка очищает служебные страницы.

Список отдаётся сразу, превью догоняют потоком. Экспорт 46 компонентов занимает
секунды, держать UI пустым это время нельзя. Превью кешируются в
`figma.clientStorage`, поэтому второй запуск показывает карточки с картинками
мгновенно; после пересборки id меняются и кеш сам протухает.

Список читается со страниц, а не из JSON. Добавил компонент в экспортёр,
пересобрал — карточка появилась сама.

## 3.1. Flutter Kit: 40 блоков Material 3

Почему свой, а не официальный Material 3 Design Kit от Google: **Plugin API не
умеет тянуть чужой файл**. Нет метода «скопируй компоненты из community-файла»;
`importComponentByKeyAsync` работает только с уже опубликованной библиотекой и
требует `componentKey`, а перечислить компоненты чужой библиотеки API не даёт.

Поэтому kit собирается по спецификации M3 из наших токенов. Это наша
реализация Material, а не файл Google — зато она офлайн, без ключей, без
лицензионных вопросов и с привязкой к переменным `DND / Tokens`.

| Категория | Компоненты |
|---|---|
| Buttons | `FilledButton`, `FilledButton / tonal`, `ElevatedButton`, `OutlinedButton`, `TextButton`, `IconButton`, `FloatingActionButton`, `SegmentedButton` |
| Selection | `Checkbox`, `Radio`, `Switch`, `Slider` |
| Chips | `Chip`, `FilterChip`, `ChoiceChip` |
| Inputs | `TextField`, `TextField / filled`, `SearchBar`, `DropdownMenu` |
| Surfaces | `Card`, `ListTile`, `Divider`, `Badge`, `Tooltip` |
| Navigation | `AppBar`, `NavigationBar`, `NavigationRail`, `TabBar`, `Drawer` |
| Dialogs | `AlertDialog`, `BottomSheet`, `SnackBar`, `MaterialBanner` |
| Progress | `LinearProgressIndicator`, `CircularProgressIndicator` |
| Data | `DataTable` |
| Blocks | `Scaffold`, `ListView`, `Form`, `EmptyState` |

Блоки собраны **инстансами** своих же компонентов, а не копиями узлов. Правишь
`AppBar` — меняется `Scaffold`. Имена блоков — не классы Flutter (`Scaffold`
класс, а `EmptyState` — наша композиция), поэтому для них сигнатура в подписи
честно показывает, из чего собирать.

Иконки — плейсхолдеры с безопасными глифами Inter. Шрифт `MaterialIcons` в
Figma может отсутствовать, а врать векторной формой хуже, чем показать
заглушку.

## 4. Собрать

1. Plugins → Development → **DND Design System**.
2. Вкладка **Сборка** → выбери `figma_ds/design_system.json`.
3. Нажми **Собрать в Figma**.

После сборки плагин сам возвращается на «Библиотеку» и обновляет превью.

Что появится:

| Объект | Имя | Откуда |
|---|---|---|
| Страница | `DND Design System` | плагин |
| Коллекция переменных | `DND / Tokens` | `AppColors`, `AppSpacing`, `AppRadii` |
| Текстовые стили | `AppTypography/displayHero` … | `AppTypography` |
| Компоненты | `RollButton`, `DiceChip/Default`, `DiceChip/Selected`, `CountStepper`, `SurfaceCard`, `DiceShape` | `lib/widgets/`, `lib/theme/app_theme.dart` |
| Страница | `Flutter Kit` | 40 блоков Material 3 из `tool/material_kit.dart` |
| Страница | `Макеты` | пустой артборд 360×800 |

## 5. Правила, которые нельзя нарушать

- **Страницы `DND Design System` и `Flutter Kit` принадлежат плагину.** Каждая
  сборка их очищает. Свои макеты туда не кладём.
- **Макеты — только на странице `Макеты`.** Плагин её не трогает.
- **Компоненты не переименовывать.** Имя компонента — это имя Dart-виджета.
  Переименовал `RollButton` в `Кнопка броска` — обратный путь сломался.
- **Не отвязывать заливки от переменных.** Смена `color/accent` в коллекции
  должна менять все инстансы.
- **`DiceShape` — placeholder.** Настоящая форма рисуется `DicePainter` в
  Dart. В Figma пунктирная рамка 200×200 честно говорит об этом.
- **Kit правится в `tool/material_kit.dart`, не в Figma.** Ручная правка
  компонента на странице kit исчезнет при следующей сборке.

## 6. Обратный путь: фрейм → Dart

Нужен personal access token Figma со скоупом **`file_content:read`**:

1. Figma → Settings → Security → Personal access tokens → Create new token.
2. Сохрани его **вне проекта**:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.figma" | Out-Null
Set-Content -NoNewline "$env:USERPROFILE\.figma\token" "figd_твой_токен"
```

Дальше ссылка на фрейм читается так:

```powershell
node C:\Users\macsi\.agents\skills\figma-ultimate-agent\scripts\figma_read.mjs "https://www.figma.com/design/<fileKey>/...?node-id=12-34"
```

Скрипт выдаёт структуру: `layout=col spacing=12 pad=16`, тексты, размеры,
инстансы с именами компонентов. По этому дереву пишется Dart: `layout=col` →
`Column`, `spacing=12` → `AppSpacing.sm`, `INSTANCE 'RollButton'` →
`RollButton(onPressed: ...)`.

Токен бесплатный, работает на free-плане. В репозиторий он не попадает.

## 7. Ограничения

- **Variables API** — best-effort. Если план или сборка Figma не даёт создать
  переменные, плагин пишет предупреждение и продолжает на сырых цветах.
  Компоненты при этом собираются.
- **Inter** должен быть доступен в Figma (он есть по умолчанию). Если нет —
  плагин падает на `Regular` и пишет об этом в лог.
- **Kit — реализация M3, а не файл Google.** Компоненты нарисованы по
  спецификации Material 3 из наших токенов. Расхождение с официальным kit
  возможно; источник правды для кода — Flutter, а не Figma.
- **Иконки в kit — плейсхолдеры.** Настоящих `MaterialIcons` в Figma может не
  быть. Для макетов этого достаточно, для пиксель-перфекта — нет.
- **Пиксели не проверяются.** Плагин выставляет числа из Dart-токенов; глазами
  результат смотрит человек. Mock-харнесс проверяет контракт API, а не красоту.
- **Пересборка не мигрирует старые инстансы.** Если удалить компонент и создать
  заново с тем же именем, старые инстансы станут «detached». Поэтому плагин
  пересоздаёт страницу целиком: макеты держим отдельно.
- **Превью снимается экспортом.** На 6 компонентах это доли секунды; на сотне
  библиотека будет открываться заметно дольше. Кеша нет — превью всегда
  актуальное.

## 8. Если что-то сломалось

Лог плагина — в его окне: зелёное `Готово`, жёлтые `!` предупреждения, красное
`Ошибка`. Для отладки без Figma:

```powershell
node figma_ds/mock/run.mjs
```

Харнесс поднимает заглушку Plugin API и падает с кодом 1, если плагин нарушил
контракт: не создал страницу, потерял компонент, не привязал заливку к
переменной, перепутал ось auto-layout.
