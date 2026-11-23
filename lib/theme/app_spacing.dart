import 'package:flutter/widgets.dart';

/// Spacing-ряд проекта. Промежуточных значений (13, 18, 27) не существует.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  /// Горизонтальный padding экрана.
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg);

  /// Padding карточки.
  static const EdgeInsets card = EdgeInsets.all(lg);
}

/// Радиусы. Один экран — один радиус у группы однотипных элементов.
abstract final class AppRadii {
  /// Чипы, мелкие элементы. 12 — как `radius/sm` в `design_system.json`:
  /// раньше здесь стояло 6, и Figma с кодом расходились.
  static const double sm = 12;

  /// Карточки, кнопки.
  static const double md = 16;

  /// Bottom sheet, модалки.
  static const double lg = 24;

  /// Pill-кнопки.
  static const double pill = 999;

  static const BorderRadius allSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius allMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius allLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius allPill = BorderRadius.all(Radius.circular(pill));
}
