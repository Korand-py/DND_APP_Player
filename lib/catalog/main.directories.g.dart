// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dice_roller/catalog/tokens.dart' as _dice_roller_catalog_tokens;
import 'package:dice_roller/catalog/use_cases.dart'
    as _dice_roller_catalog_use_cases;
import 'package:dice_roller/lab/lab_use_cases.dart'
    as _dice_roller_lab_lab_use_cases;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Компоненты',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'CountStepper',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Счётчик',
            builder: _dice_roller_catalog_use_cases.countStepperUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'DiceSelector',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Выбор кубика',
            builder: _dice_roller_catalog_use_cases.diceSelectorUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'DiceShape',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Кубик',
            builder: _dice_roller_catalog_use_cases.diceShapeUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ModifierCard',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Карточка модификатора',
            builder: _dice_roller_catalog_use_cases.modifierCardUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SectionLabel',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Подпись группы',
            builder: _dice_roller_catalog_use_cases.sectionLabelUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Кнопки',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'RollButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Кнопка броска',
                builder: _dice_roller_catalog_use_cases.rollButtonUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Персонаж',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AbilityRollTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Плитка характеристики',
                builder: _dice_roller_catalog_use_cases.abilityRollTileUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'CharacterTile',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Строка персонажа',
                builder: _dice_roller_catalog_use_cases.characterTileUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'Формы',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AppChoiceChip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Чип выбора',
                builder: _dice_roller_catalog_use_cases.appChoiceChipUseCase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Лаборатория',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'ResultCard',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'B · карточка',
            builder: _dice_roller_lab_lab_use_cases.resultCardUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ResultHero',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'A · герой-число',
            builder: _dice_roller_lab_lab_use_cases.resultHeroUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Песочница',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'Playground',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Песочница',
            builder: _dice_roller_catalog_use_cases.playgroundUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Токены',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'PalettePage',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Палитра',
            builder: _dice_roller_catalog_tokens.palettePageUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SpacingPage',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Отступы',
            builder: _dice_roller_catalog_tokens.spacingPageUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'TypographyPage',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Типографика',
            builder: _dice_roller_catalog_tokens.typographyPageUseCase,
          ),
        ],
      ),
    ],
  ),
];
