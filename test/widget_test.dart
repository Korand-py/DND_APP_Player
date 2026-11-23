import 'package:dice_roller/screens/dice_screen.dart';
import 'package:dice_roller/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpScreen(WidgetTester tester, Widget screen, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: screen));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Экран кубиков показывает выбор кубика', (tester) async {
    await pumpScreen(tester, const DiceScreen(), const Size(420, 860));

    expect(find.text('D&D DICE'), findsOneWidget);
    expect(find.text('D6'), findsOneWidget);
    expect(find.text('Бросить'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('Бросок выдаёт результат и не ломает лейаут', (tester) async {
    await pumpScreen(tester, const DiceScreen(), const Size(420, 860));

    await tester.tap(find.text('Бросить'));
    await tester.pumpAndSettle();

    expect(find.text('—'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Переключение кубика сбрасывает результат', (tester) async {
    await pumpScreen(tester, const DiceScreen(), const Size(420, 860));

    await tester.tap(find.text('Бросить'));
    await tester.pumpAndSettle();
    expect(find.text('—'), findsNothing);

    await tester.tap(find.text('D20'));
    await tester.pumpAndSettle();

    expect(find.text('—'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Узкий экран 320x568 не даёт overflow', (tester) async {
    await pumpScreen(tester, const DiceScreen(), const Size(320, 568));

    expect(find.text('Бросить'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
