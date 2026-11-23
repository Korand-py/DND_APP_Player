import 'package:flutter/material.dart';

/// Палитра проекта: Premium Dark / AMOLED Luxe.
///
/// Единственный источник цветов. Хардкод `Color(0x...)` в виджетах запрещён.
abstract final class AppColors {
  // --- База ---
  /// Фон приложения. Чистый чёрный, без градиентов.
  static const Color void0 = Color(0xFF000000);

  /// Карточки, элементы списка.
  static const Color surface1 = Color(0xFF09090B);

  /// Вложенные поверхности: bottom sheet, панели.
  static const Color surface2 = Color(0xFF121212);

  /// Hover, pressed, скелетоны.
  static const Color surface3 = Color(0xFF1F1F23);

  // --- Акцент ---
  static const Color accent = Color(0xFF9880FF);

  /// Заливка выбранного элемента, слабое свечение (12%).
  static const Color accentSoft = Color(0x1F9880FF);

  /// Обводка фокуса (40%).
  static const Color accentLine = Color(0x669880FF);

  // --- Текст ---
  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  /// Текст и иконки НА акцентной заливке. Белый на [accent] не проходит по
  /// контрасту (3.06:1), этот цвет даёт 6.87:1.
  static const Color onAccent = Color(0xFF0A0612);

  // --- Линии ---
  /// Разделитель: белый с прозрачностью 10%.
  static const Color divider = Color(0x1FFFFFFF);

  /// Граница контейнера.
  static const Color border = Color(0xFF1F1F23);

  // --- Статусы ---
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4ADE80);
}
