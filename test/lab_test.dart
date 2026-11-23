import 'package:dice_roller/lab/result_card.dart';
import 'package:dice_roller/lab/result_hero.dart';
import 'package:dice_roller/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Вариант из лаборатории проходит ту же планку, что и продовый виджет:
/// узкий экран, длинный текст, пустое состояние. Иначе это не вариант,
/// а картинка.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: Center(child: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Герой-число не ломается на 320x568', (tester) async {
    await pump(
      tester,
      const ResultHero(sides: 20, result: 17, breakdown: '8 + 9'),
      const Size(320, 568),
    );

    expect(find.text('17'), findsOneWidget);
    expect(find.text('D20'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Карточка не ломается на 320x568', (tester) async {
    await pump(
      tester,
      const ResultCard(sides: 20, result: 17, breakdown: '8 + 9', count: 2),
      const Size(320, 568),
    );

    expect(find.text('17'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Пустой результат показывает прочерк, а не ноль', (tester) async {
    await pump(
      tester,
      const ResultCard(sides: 6, result: 0),
      const Size(360, 800),
    );

    expect(find.text('—'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Русский счёт бросков: 1 бросок, 2 броска, 5 бросков', (
    tester,
  ) async {
    const List<(int, String)> cases = [
      (1, '1 бросок'),
      (2, '2 броска'),
      (5, '5 бросков'),
      (11, '11 бросков'),
      (21, '21 бросок'),
    ];

    for (final (int count, String expected) in cases) {
      await pump(
        tester,
        ResultCard(sides: 20, result: 17, count: count),
        const Size(360, 800),
      );

      expect(
        find.textContaining(expected),
        findsOneWidget,
        reason: 'счёт $count',
      );
    }
  });
}
