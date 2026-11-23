/// Material-блоки Flutter для Figma-плагина.
///
/// Что это: локальная реализация Material 3 с именами классов Flutter.
/// Не копия файла Google — Plugin API не умеет тянуть чужой файл, — а сборка
/// по спецификации M3 из наших токенов. Имя компонента = имя класса в Dart,
/// поэтому обратный путь «макет → код» работает без таблиц соответствия.
///
/// Правила:
/// - ни одного числа «из головы»: отступы `AppSpacing`, радиусы `AppRadii`;
/// - цвета — имена токенов (`accent`, `surface1`, `divider`), не hex;
/// - `dart` — сигнатура конструктора, её показывает библиотека плагина;
/// - блоки (Scaffold, ListView, Form, EmptyState) собираются инстансами уже
///   созданных компонентов, а не копированием узлов.
library;

import 'package:dice_roller/theme/app_spacing.dart';

import 'kit_spec.dart';

/// Вся библиотека: страница + группы + компоненты.
Map<String, Object?> materialKit() {
  return <String, Object?>{
    'page': 'Flutter Kit',
    'groups': <Map<String, Object?>>[
      _group('Buttons', _buttons()),
      _group('Selection', _selection()),
      _group('Chips', _chips()),
      _group('Inputs', _inputs()),
      _group('Surfaces', _surfaces()),
      _group('Navigation', _navigation()),
      _group('Dialogs', _dialogs()),
      _group('Progress', _progress()),
      _group('Data', _data()),
      _group('Blocks', _blocks()),
    ],
  };
}

Map<String, Object?> _group(String name, List<Map<String, Object?>> items) {
  return <String, Object?>{'name': name, 'items': items};
}

/// Компонент = имя + описание + сигнатура + геометрия.
Map<String, Object?> _c(
  String name,
  String description,
  String dart,
  Map<String, Object?> spec,
) {
  return <String, Object?>{
    'name': name,
    'description': description,
    'dart': dart,
    ...spec,
  };
}

/// Кнопка-текст внутри кнопки: общий хвост для всех вариантов.
Map<String, Object?> _label(String text, String style, String color) {
  return textNode('Label', text, style, color);
}

// --- Buttons -----------------------------------------------------------------

List<Map<String, Object?>> _buttons() {
  return <Map<String, Object?>>[
    _c(
      'FilledButton',
      'Основное действие. Accent-заливка, pill, высота 40.',
      'FilledButton({required VoidCallback? onPressed, required Widget child})',
      componentSpec(
        height: AppSpacing.xxxl,
        hugWidth: true,
        fill: 'accent',
        radius: 'pill',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.xl),
        children: <Map<String, Object?>>[
          _label('Кнопка', 'labelLarge', 'onAccent'),
        ],
      ),
    ),
    _c(
      'FilledButton / tonal',
      'Второстепенное действие. AccentSoft вместо accent.',
      'FilledButton.tonal({required VoidCallback? onPressed, required Widget child})',
      componentSpec(
        height: AppSpacing.xxxl,
        hugWidth: true,
        fill: 'accentSoft',
        radius: 'pill',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.xl),
        children: <Map<String, Object?>>[
          _label('Кнопка', 'labelLarge', 'accent'),
        ],
      ),
    ),
    _c(
      'ElevatedButton',
      'Кнопка с приподнятой поверхностью. Тень не используем — стиль плоский.',
      'ElevatedButton({required VoidCallback? onPressed, required Widget child})',
      componentSpec(
        height: AppSpacing.xxxl,
        hugWidth: true,
        fill: 'surface3',
        radius: 'pill',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.xl),
        children: <Map<String, Object?>>[
          _label('Кнопка', 'labelLarge', 'accent'),
        ],
      ),
    ),
    _c(
      'OutlinedButton',
      'Кнопка-контур. Обводка border, заливки нет.',
      'OutlinedButton({required VoidCallback? onPressed, required Widget child})',
      componentSpec(
        height: AppSpacing.xxxl,
        hugWidth: true,
        stroke: 'border',
        strokeWidth: 0.5,
        radius: 'pill',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.xl),
        children: <Map<String, Object?>>[
          _label('Кнопка', 'labelLarge', 'accent'),
        ],
      ),
    ),
    _c(
      'TextButton',
      'Текстовая кнопка. Без рамки и заливки.',
      'TextButton({required VoidCallback? onPressed, required Widget child})',
      componentSpec(
        height: AppSpacing.xxxl,
        hugWidth: true,
        radius: 'pill',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          _label('Кнопка', 'labelLarge', 'accent'),
        ],
      ),
    ),
    _c(
      'IconButton',
      'Квадратная кнопка 40×40 с иконкой.',
      'IconButton({required VoidCallback? onPressed, required Widget icon})',
      componentSpec(
        width: AppSpacing.xxxl,
        height: AppSpacing.xxxl,
        radius: 'pill',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        children: <Map<String, Object?>>[
          iconNode('Icon', glyph: '+', color: 'textPrimary'),
        ],
      ),
    ),
    _c(
      'FloatingActionButton',
      'Плавающая кнопка 56×56, radius md.',
      'FloatingActionButton({required VoidCallback? onPressed, required Widget child})',
      componentSpec(
        width: AppSpacing.massive - AppSpacing.xs,
        height: AppSpacing.massive - AppSpacing.xs,
        fill: 'accent',
        radius: 'md',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        children: <Map<String, Object?>>[
          textNode('Icon', '+', 'titleLarge', 'onAccent'),
        ],
      ),
    ),
    _c(
      'SegmentedButton',
      'Переключатель из трёх сегментов в общей рамке.',
      'SegmentedButton<T>({required List<ButtonSegment<T>> segments, required Set<T> selected})',
      componentSpec(
        width: 320,
        height: AppSpacing.xxxl,
        stroke: 'border',
        strokeWidth: 0.5,
        radius: 'pill',
        layout: row(primary: 'MIN', counter: 'CENTER'),
        children: <Map<String, Object?>>[
          _segment('Day', 'День', selected: true),
          _segment('Week', 'Неделя'),
          _segment('Month', 'Месяц'),
        ],
      ),
    ),
  ];
}

Map<String, Object?> _segment(
  String name,
  String text, {
  bool selected = false,
}) {
  return box(
    name,
    fillWidth: true,
    height: AppSpacing.xxxl,
    fill: selected ? 'accentSoft' : null,
    layout: row(primary: 'CENTER', counter: 'CENTER'),
    children: <Map<String, Object?>>[
      _label(text, 'labelLarge', selected ? 'accent' : 'textSecondary'),
    ],
  );
}

// --- Selection ---------------------------------------------------------------

List<Map<String, Object?>> _selection() {
  return <Map<String, Object?>>[
    _c(
      'Checkbox',
      'Флажок 22×22 с галочкой.',
      'Checkbox({required bool? value, required ValueChanged<bool?>? onChanged})',
      componentSpec(
        width: AppSpacing.xl - 2,
        height: AppSpacing.xl - 2,
        fill: 'accent',
        radius: 'sm',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        children: <Map<String, Object?>>[
          textNode('Glyph', '✓', 'labelSmall', 'onAccent'),
        ],
      ),
    ),
    _c(
      'Radio',
      'Переключатель 20×20: кольцо accent и точка внутри.',
      'Radio<T>({required T value, required T? groupValue, required ValueChanged<T?>? onChanged})',
      componentSpec(
        width: AppSpacing.xl - 4,
        height: AppSpacing.xl - 4,
        stroke: 'accent',
        strokeWidth: 2,
        radius: 'pill',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        children: <Map<String, Object?>>[
          box(
            'Dot',
            width: AppSpacing.xs,
            height: AppSpacing.xs,
            fill: 'accent',
            radius: 'pill',
          ),
        ],
      ),
    ),
    _c(
      'Switch',
      'Тумблер 52×32, включён.',
      'Switch({required bool value, required ValueChanged<bool>? onChanged})',
      componentSpec(
        width: AppSpacing.massive - AppSpacing.sm,
        height: AppSpacing.xxl,
        fill: 'accent',
        radius: 'pill',
        layout: row(primary: 'MAX', counter: 'CENTER'),
        padding: padding(all: AppSpacing.xxs),
        children: <Map<String, Object?>>[
          box(
            'Thumb',
            width: AppSpacing.xl,
            height: AppSpacing.xl,
            fill: 'onAccent',
            radius: 'pill',
          ),
        ],
      ),
    ),
    _c(
      'Slider',
      'Ползунок: трек 4 px и бегунок 20×20 на 40 %.',
      'Slider({required double value, required ValueChanged<double>? onChanged})',
      componentSpec(
        width: 320,
        height: AppSpacing.xxxl,
        layout: row(primary: 'MIN', counter: 'CENTER'),
        children: <Map<String, Object?>>[
          box(
            'Track',
            fillWidth: true,
            height: AppSpacing.xxs,
            fill: 'surface3',
            radius: 'pill',
          ),
          box(
            'Thumb',
            width: AppSpacing.xl - 4,
            height: AppSpacing.xl - 4,
            fill: 'accent',
            radius: 'pill',
          ),
        ],
      ),
    ),
  ];
}

// --- Chips -------------------------------------------------------------------

List<Map<String, Object?>> _chips() {
  return <Map<String, Object?>>[
    _c(
      'Chip',
      'Чип-метка. Контур divider, высота 32.',
      'Chip({required Widget label})',
      componentSpec(
        height: AppSpacing.xxl,
        hugWidth: true,
        stroke: 'divider',
        strokeWidth: 0.5,
        radius: 'sm',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          _label('Метка', 'labelSmall', 'textSecondary'),
        ],
      ),
    ),
    _c(
      'FilterChip',
      'Выбранный фильтр: accentSoft, галочка, accent-текст.',
      'FilterChip({required Widget label, required bool selected, required ValueChanged<bool>? onSelected})',
      componentSpec(
        height: AppSpacing.xxl,
        hugWidth: true,
        fill: 'accentSoft',
        stroke: 'accentLine',
        strokeWidth: 0.5,
        radius: 'sm',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          textNode('Glyph', '✓', 'labelSmall', 'accent'),
          _label('Фильтр', 'labelSmall', 'accent'),
        ],
      ),
    ),
    _c(
      'ChoiceChip',
      'Одиночный выбор из набора. Заливка surface2.',
      'ChoiceChip({required Widget label, required bool selected, required ValueChanged<bool>? onSelected})',
      componentSpec(
        height: AppSpacing.xxl,
        hugWidth: true,
        fill: 'surface2',
        radius: 'sm',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          _label('Выбор', 'labelSmall', 'textPrimary'),
        ],
      ),
    ),
  ];
}

// --- Inputs ------------------------------------------------------------------

List<Map<String, Object?>> _inputs() {
  return <Map<String, Object?>>[
    _c(
      'TextField',
      'Поле ввода 56 px: surface1, контур divider, radius md.',
      'TextField({TextEditingController? controller, String? hintText, InputDecoration? decoration})',
      componentSpec(
        width: 320,
        height: AppSpacing.massive - AppSpacing.xs,
        fill: 'surface1',
        stroke: 'divider',
        strokeWidth: 0.5,
        radius: 'md',
        layout: row(primary: 'MIN', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          textNode('Hint', 'Введите значение', 'bodyMedium', 'textMuted'),
        ],
      ),
    ),
    _c(
      'TextField / filled',
      'Заполненное поле без контура: surface2.',
      'TextField({InputDecoration? decoration}) // filled: true',
      componentSpec(
        width: 320,
        height: AppSpacing.massive - AppSpacing.xs,
        fill: 'surface2',
        radius: 'md',
        layout: row(primary: 'MIN', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          textNode('Hint', 'Введите значение', 'bodyMedium', 'textMuted'),
        ],
      ),
    ),
    _c(
      'SearchBar',
      'Поиск: pill-поле с иконкой.',
      'SearchBar({required SearchController controller, String? hintText})',
      componentSpec(
        width: 320,
        height: AppSpacing.massive - AppSpacing.xs,
        fill: 'surface2',
        radius: 'pill',
        layout: row(primary: 'MIN', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          iconNode('Icon', size: AppSpacing.lg, glyph: '?', color: 'textMuted'),
          textNode('Hint', 'Поиск', 'bodyMedium', 'textMuted'),
        ],
      ),
    ),
    _c(
      'DropdownMenu',
      'Выпадающий список: поле и шеврон справа.',
      'DropdownMenu<T>({required List<DropdownMenuEntry<T>> dropdownMenuEntries})',
      componentSpec(
        width: 320,
        height: AppSpacing.massive - AppSpacing.xs,
        fill: 'surface1',
        stroke: 'divider',
        strokeWidth: 0.5,
        radius: 'md',
        layout: row(primary: 'MIN', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          textNode('Value', 'Значение', 'bodyMedium', 'textPrimary'),
          box('Spacer', fillWidth: true, height: 1),
          textNode('Chevron', 'v', 'labelSmall', 'textMuted'),
        ],
      ),
    ),
  ];
}

// --- Surfaces ----------------------------------------------------------------

List<Map<String, Object?>> _surfaces() {
  return <Map<String, Object?>>[
    _c(
      'Card',
      'Карточка: surface1, radius md, padding 20, hug по высоте.',
      'Card({required Widget child})',
      componentSpec(
        width: 320,
        hugHeight: true,
        fill: 'surface1',
        stroke: 'divider',
        strokeWidth: 0.5,
        radius: 'md',
        layout: column(primary: 'MIN', counter: 'MIN', spacing: AppSpacing.sm),
        padding: padding(all: AppSpacing.lg),
        children: <Map<String, Object?>>[
          textNode(
            'Title',
            'Заголовок',
            'titleMedium',
            'textPrimary',
            fill: true,
          ),
          textNode(
            'Body',
            'Описание в две строки — проверка переноса.',
            'bodyMedium',
            'textSecondary',
            fill: true,
          ),
        ],
      ),
    ),
    _c(
      'ListTile',
      'Строка списка 72 px: аватар, заголовок, подпись, шеврон.',
      'ListTile({Widget? leading, required Widget title, Widget? subtitle, Widget? trailing})',
      componentSpec(
        width: 320,
        height: AppSpacing.massive + AppSpacing.xs,
        layout: row(primary: 'MIN', counter: 'CENTER', spacing: AppSpacing.sm),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          box(
            'Leading',
            width: AppSpacing.xxxl,
            height: AppSpacing.xxxl,
            fill: 'surface3',
            radius: 'pill',
            layout: row(primary: 'CENTER', counter: 'CENTER'),
            children: <Map<String, Object?>>[
              textNode('Initial', 'D', 'labelLarge', 'textSecondary'),
            ],
          ),
          box(
            'Text',
            fillWidth: true,
            layout: column(primary: 'CENTER', counter: 'MIN'),
            children: <Map<String, Object?>>[
              textNode('Title', 'Заголовок', 'titleMedium', 'textPrimary'),
              textNode('Subtitle', 'Подпись', 'bodyMedium', 'textSecondary'),
            ],
          ),
          textNode('Trailing', '›', 'titleLarge', 'textMuted'),
        ],
      ),
    ),
    _c(
      'Divider',
      'Линия-разделитель на всю ширину.',
      'Divider({double height = 16, double thickness = 1})',
      componentSpec(width: 320, height: 1, fill: 'divider'),
    ),
    _c(
      'Badge',
      'Счётчик-бейдж 24×24 на accent.',
      'Badge({required Widget label})',
      componentSpec(
        width: AppSpacing.xl,
        height: AppSpacing.xl,
        fill: 'accent',
        radius: 'pill',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        children: <Map<String, Object?>>[
          textNode('Label', '3', 'labelSmall', 'onAccent'),
        ],
      ),
    ),
    _c(
      'Tooltip',
      'Всплывающая подсказка: surface3, radius sm.',
      'Tooltip({required String message, required Widget child})',
      componentSpec(
        height: AppSpacing.xxxl - AppSpacing.xxs,
        hugWidth: true,
        fill: 'surface3',
        radius: 'sm',
        layout: row(primary: 'CENTER', counter: 'CENTER'),
        padding: padding(horizontal: AppSpacing.sm),
        children: <Map<String, Object?>>[
          textNode('Message', 'Подсказка', 'labelSmall', 'textPrimary'),
        ],
      ),
    ),
  ];
}

// --- Navigation --------------------------------------------------------------

List<Map<String, Object?>> _navigation() {
  return <Map<String, Object?>>[
    _c(
      'AppBar',
      'Верхняя панель 64 px: заголовок и два действия.',
      'AppBar({Widget? title, List<Widget>? actions})',
      componentSpec(
        width: 360,
        height: AppSpacing.massive,
        fill: 'surface1',
        layout: row(
          primary: 'SPACE_BETWEEN',
          counter: 'CENTER',
          spacing: AppSpacing.sm,
        ),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          textNode('Title', 'Экран', 'titleMedium', 'textPrimary'),
          box(
            'Actions',
            layout: row(
              primary: 'MIN',
              counter: 'CENTER',
              spacing: AppSpacing.sm,
            ),
            children: <Map<String, Object?>>[
              iconNode('First', glyph: '×', color: 'textSecondary'),
              iconNode('Second', glyph: '+', color: 'textSecondary'),
            ],
          ),
        ],
      ),
    ),
    _c(
      'NavigationBar',
      'Нижняя навигация 80 px: три пункта, активный первый.',
      'NavigationBar({required List<Widget> destinations, required int selectedIndex})',
      componentSpec(
        width: 360,
        height: AppSpacing.massive + AppSpacing.xxl,
        fill: 'surface1',
        layout: row(primary: 'MIN', counter: 'CENTER'),
        padding: padding(vertical: AppSpacing.xs),
        children: <Map<String, Object?>>[
          _destination('Dice', 'Кубики', selected: true),
          _destination('Sheets', 'Листы'),
          _destination('Rules', 'Правила'),
        ],
      ),
    ),
    _c(
      'NavigationRail',
      'Боковая навигация 80 px: те же пункты, вертикально.',
      'NavigationRail({required List<NavigationRailDestination> destinations, required int selectedIndex})',
      componentSpec(
        width: AppSpacing.xxxl * 2,
        height: 240,
        fill: 'surface1',
        layout: column(
          primary: 'MIN',
          counter: 'CENTER',
          spacing: AppSpacing.md,
        ),
        padding: padding(vertical: AppSpacing.md),
        children: <Map<String, Object?>>[
          _destination('Dice', 'Кубики', selected: true, vertical: true),
          _destination('Sheets', 'Листы', vertical: true),
          _destination('Rules', 'Правила', vertical: true),
        ],
      ),
    ),
    _c(
      'TabBar',
      'Табы: активный accent с подчёркиванием.',
      'TabBar({required List<Widget> tabs, required TabController controller})',
      componentSpec(
        width: 360,
        height: AppSpacing.huge,
        layout: row(primary: 'MIN', counter: 'CENTER'),
        children: <Map<String, Object?>>[
          _tab('First', 'Первый', selected: true),
          _tab('Second', 'Второй'),
          _tab('Third', 'Третий'),
        ],
      ),
    ),
    _c(
      'Drawer',
      'Боковое меню 320 px: заголовок и четыре пункта.',
      'Drawer({required Widget child})',
      componentSpec(
        width: 320,
        height: 360,
        fill: 'surface1',
        layout: column(primary: 'MIN', counter: 'MIN', spacing: AppSpacing.xs),
        padding: padding(all: AppSpacing.lg),
        children: <Map<String, Object?>>[
          textNode('Header', 'D&D', 'titleLarge', 'textPrimary'),
          textNode('First', 'Кубики', 'bodyLarge', 'textSecondary'),
          textNode('Second', 'Листы персонажа', 'bodyLarge', 'textSecondary'),
          textNode('Third', 'Правила', 'bodyLarge', 'textSecondary'),
          textNode('Fourth', 'Настройки', 'bodyLarge', 'textSecondary'),
        ],
      ),
    ),
  ];
}

Map<String, Object?> _destination(
  String name,
  String label, {
  bool selected = false,
  bool vertical = false,
}) {
  return box(
    name,
    fillWidth: !vertical,
    layout: column(
      primary: 'CENTER',
      counter: 'CENTER',
      spacing: AppSpacing.xxs,
    ),
    children: <Map<String, Object?>>[
      iconNode(
        'Icon',
        size: AppSpacing.xl,
        glyph: '•',
        color: selected ? 'accent' : 'textMuted',
        fill: selected ? 'accentSoft' : null,
      ),
      textNode('Label', label, 'labelSmall', selected ? 'accent' : 'textMuted'),
    ],
  );
}

Map<String, Object?> _tab(String name, String label, {bool selected = false}) {
  return box(
    name,
    fillWidth: true,
    height: AppSpacing.huge,
    layout: column(primary: 'CENTER', counter: 'CENTER'),
    children: <Map<String, Object?>>[
      textNode(
        'Label',
        label,
        'labelLarge',
        selected ? 'accent' : 'textSecondary',
      ),
      box(
        'Indicator',
        width: AppSpacing.xxl,
        height: 2,
        fill: selected ? 'accent' : null,
      ),
    ],
  );
}

// --- Dialogs -----------------------------------------------------------------

List<Map<String, Object?>> _dialogs() {
  return <Map<String, Object?>>[
    _c(
      'AlertDialog',
      'Модальное окно: surface2, radius lg, две кнопки.',
      'AlertDialog({Widget? title, Widget? content, List<Widget>? actions})',
      componentSpec(
        width: 320,
        hugHeight: true,
        fill: 'surface2',
        radius: 'lg',
        layout: column(primary: 'MIN', counter: 'MIN', spacing: AppSpacing.sm),
        padding: padding(all: AppSpacing.lg),
        children: <Map<String, Object?>>[
          textNode(
            'Title',
            'Заголовок',
            'titleMedium',
            'textPrimary',
            fill: true,
          ),
          textNode(
            'Content',
            'Текст диалога в две строки.',
            'bodyMedium',
            'textSecondary',
            fill: true,
          ),
          box(
            'Actions',
            fillWidth: true,
            layout: row(
              primary: 'MAX',
              counter: 'CENTER',
              spacing: AppSpacing.xs,
            ),
            children: <Map<String, Object?>>[
              instanceNode('Cancel', 'TextButton'),
              instanceNode('Confirm', 'FilledButton'),
            ],
          ),
        ],
      ),
    ),
    _c(
      'BottomSheet',
      'Нижний лист: ручка, заголовок, текст. Скруглены верхние углы.',
      'showModalBottomSheet<T>({required BuildContext context, required WidgetBuilder builder})',
      componentSpec(
        width: 360,
        hugHeight: true,
        fill: 'surface2',
        radius: 'lg',
        layout: column(
          primary: 'MIN',
          counter: 'CENTER',
          spacing: AppSpacing.sm,
        ),
        padding: padding(
          top: AppSpacing.sm,
          bottom: AppSpacing.lg,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
        ),
        children: <Map<String, Object?>>[
          box(
            'Handle',
            width: AppSpacing.xxxl,
            height: AppSpacing.xxs,
            fill: 'border',
            radius: 'pill',
          ),
          textNode('Title', 'Заголовок листа', 'titleMedium', 'textPrimary'),
          textNode('Body', 'Содержимое листа.', 'bodyMedium', 'textSecondary'),
        ],
      ),
    ),
    _c(
      'SnackBar',
      'Уведомление 56 px внизу экрана.',
      'SnackBar({required Widget content, SnackBarAction? action})',
      componentSpec(
        width: 360,
        height: AppSpacing.massive - AppSpacing.xs,
        fill: 'surface3',
        radius: 'sm',
        layout: row(
          primary: 'SPACE_BETWEEN',
          counter: 'CENTER',
          spacing: AppSpacing.sm,
        ),
        padding: padding(horizontal: AppSpacing.md),
        children: <Map<String, Object?>>[
          textNode('Content', 'Кубик брошен', 'bodyMedium', 'textPrimary'),
          textNode('Action', 'Отмена', 'labelLarge', 'accent'),
        ],
      ),
    ),
    _c(
      'MaterialBanner',
      'Плашка на всю ширину: текст и две кнопки.',
      'MaterialBanner({required Widget content, required List<Widget> actions})',
      componentSpec(
        width: 360,
        hugHeight: true,
        fill: 'surface2',
        stroke: 'divider',
        strokeWidth: 0.5,
        radius: 'sm',
        layout: column(primary: 'MIN', counter: 'MIN', spacing: AppSpacing.sm),
        padding: padding(all: AppSpacing.md),
        children: <Map<String, Object?>>[
          textNode(
            'Content',
            'Проверь характеристики.',
            'bodyMedium',
            'textSecondary',
            fill: true,
          ),
          box(
            'Actions',
            fillWidth: true,
            layout: row(
              primary: 'MAX',
              counter: 'CENTER',
              spacing: AppSpacing.xs,
            ),
            children: <Map<String, Object?>>[
              instanceNode('Dismiss', 'TextButton'),
              instanceNode('Confirm', 'FilledButton'),
            ],
          ),
        ],
      ),
    ),
  ];
}

// --- Progress ----------------------------------------------------------------

List<Map<String, Object?>> _progress() {
  return <Map<String, Object?>>[
    _c(
      'LinearProgressIndicator',
      'Линейный прогресс 4 px, заполнен на 40 %.',
      'LinearProgressIndicator({double? value})',
      componentSpec(
        width: 320,
        height: AppSpacing.xxs,
        fill: 'surface3',
        radius: 'pill',
        children: <Map<String, Object?>>[
          box(
            'Value',
            width: 128,
            height: AppSpacing.xxs,
            fill: 'accent',
            radius: 'pill',
          ),
        ],
      ),
    ),
    _c(
      'CircularProgressIndicator',
      'Круговой прогресс: кольцо accent 3 px.',
      'CircularProgressIndicator({double? value, double strokeWidth = 4})',
      componentSpec(
        width: AppSpacing.xxxl,
        height: AppSpacing.xxxl,
        stroke: 'accent',
        strokeWidth: 3,
        radius: 'pill',
      ),
    ),
  ];
}

// --- Data --------------------------------------------------------------------

List<Map<String, Object?>> _data() {
  return <Map<String, Object?>>[
    _c(
      'DataTable',
      'Таблица: заголовок и две строки по три колонки.',
      'DataTable({required List<DataColumn> columns, required List<DataRow> rows})',
      componentSpec(
        width: 320,
        hugHeight: true,
        fill: 'surface1',
        stroke: 'divider',
        strokeWidth: 0.5,
        radius: 'md',
        layout: column(primary: 'MIN', counter: 'MIN'),
        children: <Map<String, Object?>>[
          _dataRow('Header', 'Имя', 'КД', 'ХП', header: true),
          dividerLine(),
          _dataRow('Row1', 'Гоблин', '15', '7'),
          dividerLine(),
          _dataRow('Row2', 'Орк', '13', '15'),
        ],
      ),
    ),
  ];
}

Map<String, Object?> _dataRow(
  String name,
  String first,
  String second,
  String third, {
  bool header = false,
}) {
  final String style = header ? 'labelSmall' : 'bodyMedium';
  final String color = header ? 'textMuted' : 'textPrimary';

  return box(
    name,
    fillWidth: true,
    layout: row(primary: 'MIN', counter: 'CENTER', spacing: AppSpacing.sm),
    padding: padding(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
    children: <Map<String, Object?>>[
      textNode('First', first, style, color, fill: true),
      textNode('Second', second, style, color),
      textNode('Third', third, style, color),
    ],
  );
}

// --- Blocks ------------------------------------------------------------------

/// Блоки — композиции из уже собранных компонентов. Идут последними: реестр
/// имён заполняется по ходу сборки, иначе инстанс некуда резолвить.
List<Map<String, Object?>> _blocks() {
  return <Map<String, Object?>>[
    _c(
      'Scaffold',
      'Каркас экрана 360×640: AppBar и тело.',
      'Scaffold({AppBar? appBar, required Widget body})',
      componentSpec(
        width: 360,
        height: 640,
        fill: 'void0',
        layout: column(primary: 'MIN', counter: 'MIN'),
        children: <Map<String, Object?>>[
          instanceNode('AppBar', 'AppBar', fillWidth: true),
          box(
            'Body',
            fillWidth: true,
            layout: column(
              primary: 'MIN',
              counter: 'MIN',
              spacing: AppSpacing.md,
            ),
            padding: padding(all: AppSpacing.md),
            children: <Map<String, Object?>>[
              textNode(
                'Placeholder',
                'Содержимое экрана',
                'bodyMedium',
                'textSecondary',
              ),
            ],
          ),
        ],
      ),
    ),
    _c(
      'ListView',
      'Список: три строки ListTile подряд.',
      'ListView({required List<Widget> children})',
      componentSpec(
        width: 360,
        hugHeight: true,
        fill: 'void0',
        layout: column(primary: 'MIN', counter: 'MIN'),
        children: <Map<String, Object?>>[
          instanceNode('First', 'ListTile', fillWidth: true),
          dividerLine(),
          instanceNode('Second', 'ListTile', fillWidth: true),
          dividerLine(),
          instanceNode('Third', 'ListTile', fillWidth: true),
        ],
      ),
    ),
    _c(
      'Form',
      'Форма: два поля и кнопка отправки.',
      'Form({required GlobalKey<FormState> key, required Widget child})',
      componentSpec(
        width: 360,
        hugHeight: true,
        fill: 'void0',
        layout: column(primary: 'MIN', counter: 'MIN', spacing: AppSpacing.md),
        padding: padding(all: AppSpacing.md),
        children: <Map<String, Object?>>[
          instanceNode('Name', 'TextField', fillWidth: true),
          instanceNode('Class', 'DropdownMenu', fillWidth: true),
          instanceNode('Submit', 'FilledButton'),
        ],
      ),
    ),
    _c(
      'EmptyState',
      'Пустое состояние: иконка, заголовок, текст, кнопка.',
      'EmptyState({required Widget icon, required String title, required String message, required VoidCallback onAction})',
      componentSpec(
        width: 320,
        hugHeight: true,
        layout: column(
          primary: 'CENTER',
          counter: 'CENTER',
          spacing: AppSpacing.sm,
        ),
        padding: padding(all: AppSpacing.xl),
        children: <Map<String, Object?>>[
          iconNode(
            'Icon',
            size: AppSpacing.massive,
            glyph: '?',
            fill: 'surface3',
          ),
          textNode('Title', 'Пока пусто', 'titleMedium', 'textPrimary'),
          textNode(
            'Message',
            'Здесь появятся сохранённые персонажи.',
            'bodyMedium',
            'textSecondary',
            fill: true,
          ),
          instanceNode('Action', 'FilledButton'),
        ],
      ),
    ),
  ];
}
