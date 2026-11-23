import 'dart:convert';
import 'dart:io';

import 'package:dice_roller/theme/app_colors.dart';
import 'package:dice_roller/theme/app_spacing.dart';
import 'package:dice_roller/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'kit_spec.dart';
import 'material_kit.dart';

/// Экспорт дизайн-системы из Dart в JSON для Figma-плагина.
///
/// Запуск: `flutter test tool/export_design_system_test.dart`
/// Результат: `figma_ds/design_system.json`
///
/// Почему тест, а не `dart run`: `AppColors`/`AppTypography` живут в пакете,
/// который импортирует `flutter/material.dart`. Чистый `dart run` его не
/// поднимет, а `flutter test` — поднимает без эмулятора и без окна.
///
/// Файл ничего не проверяет по смыслу: это детерминированный генератор.
/// Единственная защита — тест падает, если токены расползлись (например,
/// появился цвет без имени).
void main() {
  test('Экспорт дизайн-системы в figma_ds/design_system.json', () {
    final Map<String, Object?> data = _buildDesignSystem();
    final String json = '${const JsonEncoder.withIndent('  ').convert(data)}\n';

    final File file = File('figma_ds/design_system.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(json);

    // Plugin API не читает локальные файлы: единственный способ доставить
    // токены плагину — зашить их в code.js. Иначе при первом запуске каталог
    // пустой и сборка недоступна, пока не выберешь JSON руками.
    final int embedded = _embedIntoPlugin(data);

    // ignore: avoid_print
    print('figma_ds/design_system.json — ${json.length} байт');
    // ignore: avoid_print
    print('figma_ds/code.js — встроено $embedded байт');
    // ignore: avoid_print
    print(
      'цветов: ${(data['colors'] as List<Object?>).length}, '
      'отступов: ${(data['spacing'] as List<Object?>).length}, '
      'радиусов: ${(data['radii'] as List<Object?>).length}, '
      'стилей: ${(data['typography'] as List<Object?>).length}, '
      'компонентов: ${(data['components'] as List<Object?>).length}, '
      'kit: ${_kitCount(data)}',
    );

    expect(file.existsSync(), isTrue);
    expect(embedded, greaterThan(0));
  });
}

/// Маркеры сгенерированного блока в `figma_ds/code.js`.
const String _embedStart = '// >>> embedded-design-system';
const String _embedEnd = '// <<< embedded-design-system';

/// Перезаписывает блок `EMBEDDED_DESIGN_SYSTEM` в `code.js`.
///
/// Возвращает длину вшитого JSON (0 — маркеров нет, файл не тронут).
int _embedIntoPlugin(Map<String, Object?> data) {
  final File file = File('figma_ds/code.js');
  if (!file.existsSync()) return 0;

  final String source = file.readAsStringSync();
  final int start = source.indexOf(_embedStart);
  final int end = source.indexOf(_embedEnd);

  if (start < 0 || end < start) return 0;

  // Компактный JSON: одна строка вместо 73 КБ pretty-print в коде плагина.
  final String payload = const JsonEncoder().convert(data);
  final String block =
      '$_embedStart\n'
      '// Блок генерируется `flutter test tool/export_design_system_test.dart`.\n'
      '// Руками не править: при следующем экспорте содержимое перезапишется.\n'
      'const EMBEDDED_DESIGN_SYSTEM = $payload;\n'
      '$_embedEnd';

  final String updated =
      source.substring(0, start) +
      block +
      source.substring(end + _embedEnd.length);

  file.writeAsStringSync(updated);
  return payload.length;
}

/// Сколько компонентов в kit-разделе: нужно только для отчёта экспортёра.
int _kitCount(Map<String, Object?> data) {
  final Map<String, Object?> kit = data['kit']! as Map<String, Object?>;
  final List<Object?> groups = kit['groups']! as List<Object?>;

  int total = 0;
  for (final Object? group in groups) {
    final Map<String, Object?> map = group! as Map<String, Object?>;
    total += (map['items']! as List<Object?>).length;
  }
  return total;
}

Map<String, Object?> _buildDesignSystem() {
  return <String, Object?>{
    'name': 'DND Design System',
    'version': 1,
    'colors': <Map<String, Object?>>[
      _color('void0', AppColors.void0),
      _color('surface1', AppColors.surface1),
      _color('surface2', AppColors.surface2),
      _color('surface3', AppColors.surface3),
      _color('accent', AppColors.accent),
      _color('accentSoft', AppColors.accentSoft),
      _color('accentLine', AppColors.accentLine),
      _color('textPrimary', AppColors.textPrimary),
      _color('textSecondary', AppColors.textSecondary),
      _color('textMuted', AppColors.textMuted),
      _color('onAccent', AppColors.onAccent),
      _color('divider', AppColors.divider),
      _color('border', AppColors.border),
      _color('error', AppColors.error),
      _color('success', AppColors.success),
    ],
    'spacing': <Map<String, Object?>>[
      _token('xxs', AppSpacing.xxs),
      _token('xs', AppSpacing.xs),
      _token('sm', AppSpacing.sm),
      _token('md', AppSpacing.md),
      _token('lg', AppSpacing.lg),
      _token('xl', AppSpacing.xl),
      _token('xxl', AppSpacing.xxl),
      _token('xxxl', AppSpacing.xxxl),
      _token('huge', AppSpacing.huge),
      _token('massive', AppSpacing.massive),
    ],
    'radii': <Map<String, Object?>>[
      _token('sm', AppRadii.sm),
      _token('md', AppRadii.md),
      _token('lg', AppRadii.lg),
      _token('pill', AppRadii.pill),
    ],
    'typography': <Map<String, Object?>>[
      _textStyle('displayHero', AppTypography.displayHero, 'textPrimary'),
      _textStyle('displayLarge', AppTypography.displayLarge, 'textPrimary'),
      _textStyle('displayMedium', AppTypography.displayMedium, 'textPrimary'),
      _textStyle('headlineMedium', AppTypography.headlineMedium, 'textPrimary'),
      _textStyle('titleLarge', AppTypography.titleLarge, 'textPrimary'),
      _textStyle('titleMedium', AppTypography.titleMedium, 'textPrimary'),
      _textStyle('bodyLarge', AppTypography.bodyLarge, 'textPrimary'),
      _textStyle('bodyMedium', AppTypography.bodyMedium, 'textSecondary'),
      _textStyle('labelLarge', AppTypography.labelLarge, 'onAccent'),
      _textStyle('labelSmall', AppTypography.labelSmall, 'textMuted'),
    ],
    'components': _components(),
    'kit': materialKit(),
  };
}

/// Цвет в трёх видах: hex без альфы, alpha отдельно, ARGB-строка для отладки.
/// Figma хочет `{r,g,b,a}` в диапазоне 0..1 — плагин собирает это из hex+alpha.
Map<String, Object?> _color(String name, Color color) {
  final int argb = color.toARGB32();
  final int a = (argb >> 24) & 0xFF;
  final int r = (argb >> 16) & 0xFF;
  final int g = (argb >> 8) & 0xFF;
  final int b = argb & 0xFF;

  return <String, Object?>{
    'name': name,
    'hex':
        '#${r.toRadixString(16).padLeft(2, '0')}'
                '${g.toRadixString(16).padLeft(2, '0')}'
                '${b.toRadixString(16).padLeft(2, '0')}'
            .toUpperCase(),
    'alpha': double.parse((a / 255).toStringAsFixed(4)),
    'argb': argb.toRadixString(16).padLeft(8, '0').toUpperCase(),
  };
}

Map<String, Object?> _token(String name, double value) {
  return <String, Object?>{'name': name, 'value': value};
}

/// `height` в [TextStyle] — множитель, а Figma ждёт пиксели. Пересчитываем.
Map<String, Object?> _textStyle(
  String name,
  TextStyle style,
  String colorToken,
) {
  final double fontSize = style.fontSize ?? 14;
  final double lineHeight = fontSize * (style.height ?? 1.0);

  return <String, Object?>{
    'name': name,
    'fontFamily': style.fontFamily ?? AppTypography.fontFamily,
    'fontSize': fontSize,
    'fontWeight': style.fontWeight?.value ?? 400,
    'lineHeight': double.parse(lineHeight.toStringAsFixed(2)),
    'letterSpacing': style.letterSpacing ?? 0,
    'color': colorToken,
  };
}

/// Компоненты описаны в терминах токенов, а не пикселей: плагин сам решает,
/// чем заливать и какой радиус ставить. Размеры взяты из реальных виджетов,
/// поэтому Figma-компонент и Dart-виджет не разъезжаются.
List<Map<String, Object?>> _components() {
  return <Map<String, Object?>>[
    // lib/widgets/roll_button.dart: height 56, полная ширина, акцент.
    <String, Object?>{
      'name': 'RollButton',
      'dart': 'lib/widgets/roll_button.dart',
      'description': 'Основное действие экрана: полная ширина, 56 px.',
      'width': 320,
      'height': 56,
      'fill': 'accent',
      'radius': 'md',
      'layout': row(primary: 'CENTER', counter: 'CENTER'),
      'padding': padding(horizontal: AppSpacing.md),
      'children': <Map<String, Object?>>[
        textNode('Label', 'Бросить', 'titleMedium', 'onAccent'),
      ],
    },

    // lib/widgets/dice_selector.dart: height 40, pill, hug по ширине.
    <String, Object?>{
      'name': 'DiceChip/Default',
      'dart': 'lib/widgets/dice_selector.dart',
      'description': 'Чип выбора кубика, невыбранный.',
      'height': 40,
      'hugWidth': true,
      'stroke': 'divider',
      'strokeWidth': 0.5,
      'radius': 'pill',
      'layout': row(primary: 'CENTER', counter: 'CENTER'),
      'padding': padding(horizontal: AppSpacing.md),
      'children': <Map<String, Object?>>[
        textNode('Label', 'D20', 'labelLarge', 'textSecondary'),
      ],
    },
    <String, Object?>{
      'name': 'DiceChip/Selected',
      'dart': 'lib/widgets/dice_selector.dart',
      'description': 'Чип выбора кубика, выбранный.',
      'height': 40,
      'hugWidth': true,
      'fill': 'accentSoft',
      'stroke': 'accentLine',
      'strokeWidth': 0.5,
      'radius': 'pill',
      'layout': row(primary: 'CENTER', counter: 'CENTER'),
      'padding': padding(horizontal: AppSpacing.md),
      'children': <Map<String, Object?>>[
        textNode('Label', 'D20', 'labelLarge', 'accent'),
      ],
    },

    // lib/widgets/count_stepper.dart: 56 px, две кнопки 56×56, центр — поле.
    <String, Object?>{
      'name': 'CountStepper',
      'dart': 'lib/widgets/count_stepper.dart',
      'description': 'Счётчик количества: − значение +, в одной рамке.',
      'width': 320,
      'height': 56,
      'fill': 'surface1',
      'stroke': 'divider',
      'strokeWidth': 0.5,
      'radius': 'md',
      'layout': row(primary: 'MIN', counter: 'CENTER'),
      'padding': padding(),
      'children': <Map<String, Object?>>[
        _iconButton('Decrement', '−'),
        _fillBox('Value', <Map<String, Object?>>[
          textNode('Count', '1', 'titleLarge', 'textPrimary'),
        ]),
        _iconButton('Increment', '+'),
      ],
    },

    // CardTheme из lib/theme/app_theme.dart: контейнер для композиции экранов.
    <String, Object?>{
      'name': 'SurfaceCard',
      'dart': 'lib/theme/app_theme.dart',
      'description':
          'Карточка: surface1, radius md, обводка divider, padding 20.',
      'width': 320,
      'hugHeight': true,
      'fill': 'surface1',
      'stroke': 'divider',
      'strokeWidth': 0.5,
      'radius': 'md',
      'layout': column(primary: 'MIN', counter: 'MIN', spacing: AppSpacing.sm),
      'padding': padding(all: AppSpacing.lg),
      'children': <Map<String, Object?>>[
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
    },

    // lib/widgets/dice_shape.dart: 200×200, форма рисуется DicePainter.
    // В Figma — пунктирный placeholder, чтобы не притворяться финальной формой.
    <String, Object?>{
      'name': 'DiceShape',
      'dart': 'lib/widgets/dice_shape.dart',
      'description': 'Кубик 200×200. Форма рисуется кодом, здесь placeholder.',
      'width': 200,
      'height': 200,
      'stroke': 'border',
      'strokeWidth': 1,
      'strokeDash': <double>[4, 4],
      'radius': 'lg',
      'layout': row(primary: 'CENTER', counter: 'CENTER'),
      'padding': padding(),
      'children': <Map<String, Object?>>[
        textNode('Result', '20', 'displayHero', 'textPrimary'),
      ],
    },
  ];
}

/// Кнопка-иконка 56×56 из CountStepper: тот же размер, что в Dart.
Map<String, Object?> _iconButton(String name, String glyph) {
  return <String, Object?>{
    'type': 'frame',
    'name': name,
    'width': 56,
    'height': 56,
    'radius': 'md',
    'layout': row(primary: 'CENTER', counter: 'CENTER'),
    'children': <Map<String, Object?>>[
      textNode('Glyph', glyph, 'titleLarge', 'textSecondary'),
    ],
  };
}

/// Центральная часть CountStepper: тянется по ширине (FILL).
Map<String, Object?> _fillBox(
  String name,
  List<Map<String, Object?>> children,
) {
  return <String, Object?>{
    'type': 'frame',
    'name': name,
    'width': 'FILL',
    'height': 56,
    'layout': row(primary: 'CENTER', counter: 'CENTER'),
    'children': children,
  };
}
