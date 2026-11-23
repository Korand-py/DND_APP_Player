import 'package:dice_roller/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

/// Точка входа каталога. Запуск:
/// `flutter run -d windows -t lib/catalog/main.dart`.
///
/// Каталог не входит в сборку приложения: `lib/main.dart` его не импортирует,
/// поэтому tree shaking выбрасывает его целиком.
/// Живёт в `lib/`, потому что build_runner сканирует только `lib/`.
void main() => runApp(const CatalogApp());

@widgetbook.App()
class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = buildAppTheme();

    return Widgetbook.material(
      directories: directories,
      themeMode: ThemeMode.dark,
      darkTheme: theme,
      addons: [
        MaterialThemeAddon(
          themes: [WidgetbookTheme(name: 'Premium Dark', data: theme)],
        ),
        ViewportAddon(_viewports),
        AlignmentAddon(),
        TextScaleAddon(),
        GridAddon(),
        InspectorAddon(),
      ],
    );
  }
}

/// Три реальных размера Android плюс широкий — для проверки адаптива.
const List<ViewportData> _viewports = [
  ViewportData(
    name: '320×568',
    width: 320,
    height: 568,
    pixelRatio: 2,
    platform: TargetPlatform.android,
  ),
  ViewportData(
    name: '360×800',
    width: 360,
    height: 800,
    pixelRatio: 3,
    platform: TargetPlatform.android,
  ),
  ViewportData(
    name: '430×932',
    width: 430,
    height: 932,
    pixelRatio: 3,
    platform: TargetPlatform.android,
  ),
  ViewportData(
    name: '800×1280',
    width: 800,
    height: 1280,
    pixelRatio: 1,
    platform: TargetPlatform.android,
  ),
];
