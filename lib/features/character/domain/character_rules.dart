/// Правила 5e, которые нужны вне UI.
///
/// Чистые функции без состояния: их проверяет unit-тест, а не виджет-тест.
/// Никакого Flutter здесь быть не должно — домен обязан собираться под `dart`.
abstract final class CharacterRules {
  /// Минимальный и максимальный уровень персонажа в SRD.
  static const int minLevel = 1;
  static const int maxLevel = 20;

  /// Модификатор характеристики = floor((значение − 10) / 2).
  ///
  /// Именно `floor`, а не `~/`. В Dart `(9 - 10) ~/ 2` даёт 0, потому что
  /// деление усекается к нулю, а по правилам должно быть −1. Python в прототипе
  /// использовал `//`, то есть floor, — при переносе на Dart это первое, что
  /// молча ломается на нечётных значениях.
  static int abilityModifier(int score) => ((score - 10) / 2).floor();

  /// Бонус мастерства по уровню: 1–4 → +2, 5–8 → +3, 9–12 → +4,
  /// 13–16 → +5, 17–20 → +6.
  static int proficiencyBonus(int level) =>
      2 + (level.clamp(minLevel, maxLevel) - 1) ~/ 4;

  /// Хиты: максимум кости на 1 уровне, среднее значение на каждом следующем.
  ///
  /// Прототип считал `уровень × кость + модификатор`, то есть на 20 уровне давал
  /// 20d10 максимума — вдвое больше таблицы. Здесь честное среднее.
  static int maxHitPoints({
    required int level,
    required int hitDie,
    required int constitutionModifier,
  }) {
    final int lvl = level.clamp(minLevel, maxLevel);
    final int perLevel = hitDie ~/ 2 + 1 + constitutionModifier;
    final int total = hitDie + constitutionModifier + (lvl - 1) * perLevel;

    // Отрицательный модификатор Телосложения не может убить персонажа.
    return total < 1 ? 1 : total;
  }

  /// Знаковый формат модификатора: `+2`, `-1`, `+0`.
  ///
  /// Плюс обязателен: «2» читается как значение характеристики, «+2» — как
  /// модификатор. В D&D это разные числа.
  static String signed(int value) => value >= 0 ? '+$value' : '$value';
}
