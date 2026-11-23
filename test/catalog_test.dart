import 'package:dice_roller/catalog/main.directories.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook/widgetbook.dart';

/// Сгенерированное дерево — единственная связь каталога с кодом.
///
/// Если забыть `dart run build_runner build`, файл устареет молча:
/// каталог запустится, просто без новых use case. Тест это ловит.
void main() {
  test('Дерево каталога содержит все категории', () {
    final List<String> categories = directories
        .whereType<WidgetbookCategory>()
        .map((WidgetbookCategory category) => category.name)
        .toList();

    expect(
      categories,
      containsAll(<String>['Компоненты', 'Токены', 'Песочница']),
    );
  });

  test('Каждый компонент каталога имеет хотя бы один use case', () {
    final List<WidgetbookComponent> components = <WidgetbookComponent>[
      for (final WidgetbookNode node in _walk(directories))
        if (node is WidgetbookComponent) node,
    ];

    expect(components, isNotEmpty);
    for (final WidgetbookComponent component in components) {
      expect(component.useCases, isNotEmpty, reason: component.name);
    }
  });

  test('Имена use case не пустые и уникальны внутри компонента', () {
    for (final WidgetbookNode node in _walk(directories)) {
      if (node is! WidgetbookComponent) continue;

      final List<String> names = node.useCases
          .map((WidgetbookUseCase useCase) => useCase.name)
          .toList();

      expect(names, everyElement(isNotEmpty), reason: node.name);
      expect(names.toSet().length, names.length, reason: node.name);
    }
  });
}

/// Все узлы дерева в глубину.
Iterable<WidgetbookNode> _walk(List<WidgetbookNode> nodes) sync* {
  for (final WidgetbookNode node in nodes) {
    yield node;
    final List<WidgetbookNode>? children = node.children;
    if (children != null) yield* _walk(children);
  }
}
