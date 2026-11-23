/// Билдеры спек для Figma-плагина.
///
/// Спека — это дерево Map, которое плагин превращает в узлы Figma. Здесь нет
/// ни одного числа «из головы»: отступы и радиусы приходят из `AppSpacing` и
/// `AppRadii`, цвета — именами токенов. Плагин уже сам решает, чем заливать.
///
/// Почему отдельный файл: и `components` (наши виджеты), и `kit` (Material)
/// описываются одинаково. Один формат — один движок в `code.js`, без второй
/// ветки сборки.
library;

/// Горизонтальный auto-layout.
Map<String, Object?> row({
  required String primary,
  required String counter,
  double spacing = 0,
}) {
  return <String, Object?>{
    'mode': 'HORIZONTAL',
    'primaryAlign': primary,
    'counterAlign': counter,
    'spacing': spacing,
  };
}

/// Вертикальный auto-layout.
Map<String, Object?> column({
  required String primary,
  required String counter,
  double spacing = 0,
}) {
  return <String, Object?>{
    'mode': 'VERTICAL',
    'primaryAlign': primary,
    'counterAlign': counter,
    'spacing': spacing,
  };
}

/// Отступы. `top`/`bottom` перекрывают `vertical`, если заданы.
Map<String, Object?> padding({
  double all = 0,
  double horizontal = 0,
  double vertical = 0,
  double? top,
  double? bottom,
  double? left,
  double? right,
}) {
  final double fallbackHorizontal = all == 0 ? horizontal : all;
  final double fallbackVertical = all == 0 ? vertical : all;

  return <String, Object?>{
    'top': top ?? fallbackVertical,
    'right': right ?? fallbackHorizontal,
    'bottom': bottom ?? fallbackVertical,
    'left': left ?? fallbackHorizontal,
  };
}

/// Текст с токеном типографики. `fill` — растянуть по ширине родителя.
Map<String, Object?> textNode(
  String name,
  String text,
  String style,
  String color, {
  bool fill = false,
}) {
  return <String, Object?>{
    'type': 'text',
    'name': name,
    'text': text,
    'style': style,
    'color': color,
    if (fill) 'width': 'FILL',
  };
}

/// Фрейм внутри компонента.
Map<String, Object?> box(
  String name, {
  double? width,
  double? height,
  String? fill,
  String? stroke,
  double strokeWidth = 1,
  String? radius,
  Map<String, Object?>? layout,
  Map<String, Object?>? padding,
  List<Map<String, Object?>> children = const <Map<String, Object?>>[],
  bool fillWidth = false,
}) {
  return <String, Object?>{
    'type': 'frame',
    'name': name,
    ...boxFields(
      width: width,
      height: height,
      fill: fill,
      stroke: stroke,
      strokeWidth: strokeWidth,
      radius: radius,
      layout: layout,
      padding: padding,
      children: children,
      fillWidth: fillWidth,
    ),
  };
}

/// Верхний уровень компонента: те же поля, что у фрейма, но без `type` —
/// тип узла задаёт `figma.createComponent()`.
Map<String, Object?> componentSpec({
  double? width,
  double? height,
  String? fill,
  String? stroke,
  double strokeWidth = 1,
  String? radius,
  Map<String, Object?>? layout,
  Map<String, Object?>? padding,
  List<Map<String, Object?>> children = const <Map<String, Object?>>[],
  bool fillWidth = false,
  bool hugWidth = false,
  bool hugHeight = false,
}) {
  return <String, Object?>{
    ...boxFields(
      width: width,
      height: height,
      fill: fill,
      stroke: stroke,
      strokeWidth: strokeWidth,
      radius: radius,
      layout: layout,
      padding: padding,
      children: children,
      fillWidth: fillWidth,
    ),
    if (hugWidth) 'hugWidth': true,
    if (hugHeight) 'hugHeight': true,
  };
}

/// Общие поля геометрии. Вынесено, чтобы компонент и фрейм не разъезжались.
Map<String, Object?> boxFields({
  double? width,
  double? height,
  String? fill,
  String? stroke,
  double strokeWidth = 1,
  String? radius,
  Map<String, Object?>? layout,
  Map<String, Object?>? padding,
  List<Map<String, Object?>> children = const <Map<String, Object?>>[],
  bool fillWidth = false,
}) {
  return <String, Object?>{
    'width': ?(fillWidth ? 'FILL' : width),
    'height': ?height,
    'fill': ?fill,
    'stroke': ?stroke,
    'strokeWidth': ?(stroke == null ? null : strokeWidth),
    'radius': ?radius,
    'layout': ?layout,
    'padding': ?padding,
    if (children.isNotEmpty) 'children': children,
  };
}

/// Инстанс уже собранного компонента. Плагин резолвит имя через реестр.
Map<String, Object?> instanceNode(
  String name,
  String component, {
  double? width,
  double? height,
  bool fillWidth = false,
}) {
  return <String, Object?>{
    'type': 'instance',
    'name': name,
    'component': component,
    'width': ?(fillWidth ? 'FILL' : width),
    'height': ?height,
  };
}

/// Иконка-заглушка: круг или квадрат с безопасным глифом Inter.
///
/// Настоящие Material-иконки — шрифт `MaterialIcons`, которого в Figma может
/// не быть. Врать векторной формой хуже, чем честно показать плейсхолдер.
Map<String, Object?> iconNode(
  String name, {
  double size = 24,
  String? glyph,
  String color = 'textPrimary',
  String? fill = 'surface3',
  String? radius,
}) {
  return box(
    name,
    width: size,
    height: size,
    fill: fill,
    radius: radius,
    layout: row(primary: 'CENTER', counter: 'CENTER'),
    children: <Map<String, Object?>>[
      if (glyph != null) textNode('Glyph', glyph, 'labelSmall', color),
    ],
  );
}

/// Вертикальный отступ-распорка. В auto-layout это пустой фрейм фиксированной
/// высоты: Figma не умеет «spacer» без узла.
Map<String, Object?> gap(double size, {bool horizontal = false}) {
  return box(
    'Gap',
    width: horizontal ? size : 1,
    height: horizontal ? 1 : size,
  );
}

/// Горизонтальная линия-разделитель: тянется по ширине родителя.
Map<String, Object?> dividerLine({String color = 'divider'}) {
  return box('Divider', fillWidth: true, height: 1, fill: color);
}
