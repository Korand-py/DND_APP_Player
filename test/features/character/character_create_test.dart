import 'package:dice_roller/features/character/data/app_database.dart';
import 'package:dice_roller/features/character/data/drift_character_repository.dart';
import 'package:dice_roller/features/character/domain/ability_scores.dart';
import 'package:dice_roller/features/character/domain/character.dart';
import 'package:dice_roller/features/character/domain/dnd_class.dart';
import 'package:dice_roller/features/character/domain/race.dart';
import 'package:dice_roller/features/character/presentation/character_providers.dart';
import 'package:dice_roller/features/character/presentation/characters_screen.dart';
import 'package:dice_roller/screens/specifications_screen.dart';
import 'package:dice_roller/theme/app_theme.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Character _fighter() {
  return Character(
    name: 'Торин',
    dndClass: DndClass.fighter,
    race: Races.dwarf,
    subrace: Races.dwarf.subraces.last,
    level: 1,
    scores: const AbilityScores(
      strength: 16,
      dexterity: 12,
      constitution: 15,
      intelligence: 8,
      wisdom: 10,
      charisma: 9,
    ),
    createdAt: DateTime(2026, 1, 1),
  );
}

/// Поднимает приложение на базе в памяти, выполняет [body] и размонтирует
/// дерево до конца теста.
///
/// Размонтирование именно внутри тела, а не в `addTearDown`: Drift при отмене
/// стрима ставит нулевой таймер, а flutter_test проверяет «нет ли висящих
/// таймеров» раньше, чем запускает teardown-колбэки.
Future<void> _withApp(
  WidgetTester tester, {
  required Widget home,
  Future<void> Function(AppDatabase database)? seed,
  required Future<void> Function() body,
}) async {
  final AppDatabase database = AppDatabase.forTesting(NativeDatabase.memory());

  try {
    if (seed != null) await seed(database);

    await tester.pumpWidget(
      ProviderScope(
        // `Override` не экспортируется в Riverpod 3 — тип выводится из контекста.
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: buildAppTheme(), home: home),
      ),
    );
    await tester.pumpAndSettle();

    await body();
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  }
}

Future<void> _withCharacters(
  WidgetTester tester, {
  Future<void> Function(AppDatabase database)? seed,
  required Future<void> Function() body,
}) {
  return _withApp(
    tester,
    home: const CharactersScreen(),
    seed: seed,
    body: body,
  );
}

/// В форме два `Scrollable`: `ListView` и внутренний скролл `TextField`.
/// Без явного finder-а `scrollUntilVisible` падает на «Too many elements».
final Finder _formScrollable = find.byType(Scrollable).first;

ElevatedButton _saveButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Сохранить персонажа'),
  );
}

void _usePhone(WidgetTester tester, {Size size = const Size(420, 900)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Создание персонажа заканчивается строкой в списке', (
    tester,
  ) async {
    _usePhone(tester);

    await _withCharacters(
      tester,
      body: () async {
        expect(find.text('Пока ни одного героя'), findsOneWidget);

        await tester.tap(find.text('Создать персонажа'));
        await tester.pumpAndSettle();

        // Пока не заполнено — кнопка выключена, а причина написана над ней.
        expect(_saveButton(tester).onPressed, isNull);
        expect(find.text('Впиши имя персонажа'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'Торин');
        await tester.pump();

        for (final String label in <String>[
          'Воин',
          'Чемпион',
          'Дварф',
          'Горный',
        ]) {
          await tester.scrollUntilVisible(
            find.text(label),
            120,
            scrollable: _formScrollable,
          );
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
        }

        expect(_saveButton(tester).onPressed, isNotNull);

        await tester.tap(find.text('Сохранить персонажа'));
        await tester.pumpAndSettle();

        expect(find.text('Торин'), findsOneWidget);
        expect(find.textContaining('Чемпион'), findsWidgets);
        expect(find.text('Пока ни одного героя'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  testWidgets('Лист персонажа показывает спасброски с владением', (
    tester,
  ) async {
    _usePhone(tester);

    await _withCharacters(
      tester,
      seed: (AppDatabase database) =>
          DriftCharacterRepository(database).create(_fighter()),
      body: () async {
        await tester.tap(find.text('Торин'));
        await tester.pumpAndSettle();

        expect(find.text('СПАСБРОСКИ'), findsOneWidget);
        // Воин владеет СИЛ и ТЕЛ — ровно две отметки.
        expect(find.text('владение'), findsNWidgets(2));
        expect(find.text('d10'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  testWidgets('Экран создания влезает в 320x568', (tester) async {
    _usePhone(tester, size: const Size(320, 568));

    await _withCharacters(
      tester,
      body: () async {
        await tester.tap(find.text('Создать персонажа'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('ХАРАКТЕРИСТИКИ'),
          200,
          scrollable: _formScrollable,
        );

        expect(tester.takeException(), isNull);
      },
    );
  });

  testWidgets('Удаление с главного экрана требует подтверждения', (
    tester,
  ) async {
    _usePhone(tester);

    await _withApp(
      tester,
      home: const Scaffold(body: SpecificationsScreen()),
      seed: (AppDatabase database) =>
          DriftCharacterRepository(database).create(_fighter()),
      body: () async {
        expect(find.text('Торин'), findsOneWidget);

        await tester.tap(find.byTooltip('Удалить персонажа'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Отмена'));
        await tester.pumpAndSettle();

        expect(find.text('Торин'), findsOneWidget);

        await tester.tap(find.byTooltip('Удалить персонажа'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Удалить'));
        await tester.pumpAndSettle();

        expect(find.text('Нет персонажей'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  testWidgets('Иконка в шапке открывает список персонажей', (tester) async {
    _usePhone(tester);

    await _withApp(
      tester,
      home: const Scaffold(body: SpecificationsScreen()),
      seed: (AppDatabase database) =>
          DriftCharacterRepository(database).create(_fighter()),
      body: () async {
        await tester.tap(find.byTooltip('Персонажи'));
        await tester.pumpAndSettle();

        expect(find.text('Персонажи'), findsOneWidget);
        expect(find.text('Торин'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
