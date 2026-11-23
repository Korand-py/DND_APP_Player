import 'package:dice_roller/catalog/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Каталог — отдельное приложение, и оно тоже может падать.
///
/// Тест поднимает настоящий `CatalogApp` с аддонами и сгенерированным
/// деревом: ловит и ошибки Widgetbook API, и пустой каталог после
/// забытого `build_runner`.
void main() {
  testWidgets('Каталог поднимается и показывает дерево компонентов', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CatalogApp());
    await tester.pumpAndSettle();

    expect(find.text('Компоненты'), findsWidgets);
    expect(find.text('Токены'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
