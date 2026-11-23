import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/app_choice_chip.dart';
import '../../../widgets/section_label.dart';
import '../domain/ability.dart';
import '../domain/ability_roller.dart';
import '../domain/ability_scores.dart';
import '../domain/character_rules.dart';
import '../domain/dnd_class.dart';
import '../domain/race.dart';
import 'character_draft.dart';
import 'widgets/ability_roll_tile.dart';

/// Создание персонажа: имя, класс, раса, подраса и броски 4d6.
class CharacterCreateScreen extends ConsumerStatefulWidget {
  const CharacterCreateScreen({super.key});

  @override
  ConsumerState<CharacterCreateScreen> createState() =>
      _CharacterCreateScreenState();
}

class _CharacterCreateScreenState extends ConsumerState<CharacterCreateScreen> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final int? id = await ref.read(characterDraftProvider.notifier).save();
    if (id == null || !mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final CharacterDraft draft = ref.watch(characterDraftProvider);
    final CharacterDraftNotifier notifier = ref.read(
      characterDraftProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Новый персонаж')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: <Widget>[
          const SectionLabel('Имя'),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            cursorColor: AppColors.accent,
            style: AppTypography.bodyLarge,
            decoration: const InputDecoration(hintText: 'Имя героя'),
            onChanged: notifier.setName,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionLabel('Класс'),
          ChoiceChipWrap<DndClass>(
            values: DndClass.values,
            selected: draft.dndClass,
            labelOf: (DndClass value) => value.label,
            onSelected: notifier.selectClass,
          ),
          ..._subclassSection(draft, notifier),
          const SizedBox(height: AppSpacing.xl),
          const SectionLabel('Раса'),
          ChoiceChipWrap<Race>(
            values: Races.all,
            selected: draft.race,
            labelOf: (Race value) => value.label,
            onSelected: notifier.selectRace,
          ),
          ..._subraceSection(draft, notifier),
          ..._flexibleSection(draft, notifier),
          const SizedBox(height: AppSpacing.xl),
          SectionLabel(
            'Характеристики',
            trailing: TextButton(
              onPressed: notifier.reroll,
              child: const Text('Перебросить'),
            ),
          ),
          _AbilityGrid(rolls: draft.rolls, scores: draft.scores),
          const SizedBox(height: AppSpacing.xl),
          _SummaryCard(draft: draft),
        ],
      ),
      bottomNavigationBar: _SaveBar(draft: draft, onSave: _save),
    );
  }

  /// Подкласс необязателен: в 5.1 он приходит на 3 уровне. Секция появляется
  /// только у классов, где он описан в справочнике.
  List<Widget> _subclassSection(
    CharacterDraft draft,
    CharacterDraftNotifier notifier,
  ) {
    final DndClass? selected = draft.dndClass;
    if (selected == null || !selected.hasSubclasses) {
      return const <Widget>[];
    }

    return <Widget>[
      const SizedBox(height: AppSpacing.lg),
      const SectionLabel('Подкласс'),
      ChoiceChipWrap<Subclass>(
        values: selected.subclasses,
        selected: draft.subclass,
        labelOf: (Subclass value) => value.label,
        onSelected: notifier.selectSubclass,
      ),
    ];
  }

  /// Подраса появляется только у рас, где она есть. Дварф без подрасы —
  /// это не «дварф по умолчанию», а незаполненный выбор.
  List<Widget> _subraceSection(
    CharacterDraft draft,
    CharacterDraftNotifier notifier,
  ) {
    final Race? race = draft.race;
    if (race == null || !race.hasSubraces) return const <Widget>[];

    return <Widget>[
      const SizedBox(height: AppSpacing.lg),
      const SectionLabel('Подраса'),
      ChoiceChipWrap<Subrace>(
        values: race.subraces,
        selected: draft.subrace,
        labelOf: (Subrace value) => value.label,
        onSelected: notifier.selectSubrace,
      ),
    ];
  }

  /// Плавающие +1 полуэльфа. Харизма заблокирована: +2 к ней уже в бонусах.
  List<Widget> _flexibleSection(
    CharacterDraft draft,
    CharacterDraftNotifier notifier,
  ) {
    final Race? race = draft.race;
    if (race == null || race.flexibleBonus == 0) return const <Widget>[];

    return <Widget>[
      const SizedBox(height: AppSpacing.lg),
      SectionLabel(
        '+1 к двум характеристикам',
        trailing: Text(
          '${draft.flexibleAbilities.length} из ${race.flexibleBonus}',
          style: AppTypography.bodyMedium,
        ),
      ),
      ChoiceChipWrap<Ability>(
        values: Ability.values,
        selected: null,
        labelOf: (Ability value) => value.label,
        isSelected: draft.flexibleAbilities.contains,
        isEnabled: (Ability value) => !race.flexibleExcluded.contains(value),
        onSelected: notifier.toggleFlexible,
      ),
    ];
  }
}

/// Сетка 2×3: шесть характеристик делятся ровно на две колонки.
class _AbilityGrid extends StatelessWidget {
  const _AbilityGrid({required this.rolls, required this.scores});

  final AbilityRolls rolls;
  final AbilityScores scores;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];

    for (int index = 0; index < Ability.values.length; index += 2) {
      final Ability left = Ability.values[index];
      final Ability right = Ability.values[index + 1];

      if (rows.isNotEmpty) rows.add(const SizedBox(height: AppSpacing.xs));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: AbilityRollTile(
                  ability: left,
                  roll: rolls[left],
                  modifier: scores.modifier(left),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AbilityRollTile(
                  ability: right,
                  roll: rolls[right],
                  modifier: scores.modifier(right),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

/// Итог до сохранения: хиты, кость и бонус мастерства.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.draft});

  final CharacterDraft draft;

  @override
  Widget build(BuildContext context) {
    final DndClass? dndClass = draft.dndClass;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadii.allMd,
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Metric(label: 'ХИТЫ', value: '${draft.maxHitPoints}'),
          _Metric(label: 'КОСТЬ', value: dndClass?.hitDiceLabel ?? '—'),
          _Metric(
            label: 'МАСТЕРСТВО',
            value: CharacterRules.signed(
              CharacterRules.proficiencyBonus(CharacterDraft.startLevel),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(value, style: AppTypography.titleLarge),
        ],
      ),
    );
  }
}

/// Нижняя панель: кнопка и причина, по которой она неактивна.
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.draft, required this.onSave});

  final CharacterDraft draft;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final String? reason = draft.incompleteReason;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (reason != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                reason,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: reason == null ? onSave : null,
            child: const Text('Сохранить персонажа'),
          ),
        ],
      ),
    );
  }
}
