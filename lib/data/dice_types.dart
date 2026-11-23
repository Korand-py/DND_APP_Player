// Типы кубов
import 'package:dice_roller/theme/app_colors.dart';
import 'package:flutter/material.dart';

const List<int> diceTypes = [4, 6, 8, 10, 12, 20, 100];

// Характеристики + модификаторы (характеристика | значение | модификатор)
var specifications = {
  'Сила': (1, -1, AppColors.error, const Color.fromARGB(136, 244, 67, 54)),
  "Ловкость": (2, 2, AppColors.success, const Color.fromARGB(124, 76, 175, 79)),
  "Телосложение": (3, 3, Colors.yellow, const Color.fromARGB(135, 255, 193, 7)),
  "Интелект": (
    6,
    6,
    Colors.lightBlueAccent,
    const Color.fromARGB(154, 33, 149, 243),
  ),
  "Мудрость": (8, 8, AppColors.accent, const Color.fromARGB(136, 104, 58, 183)),
  "Харизма": (
    8,
    8,
    Colors.orangeAccent,
    const Color.fromARGB(158, 255, 153, 0),
  ),
};

List<String> specificationsList = specifications.keys.toList();
