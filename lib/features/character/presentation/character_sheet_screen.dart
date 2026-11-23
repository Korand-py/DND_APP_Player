import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/section_label.dart';
import '../domain/ability.dart';
import '../domain/character.dart';
import '../domain/character_rules.dart';
import 'character_providers.dart';
import 'widgets/confirm_delete.dart';

/// Лист персонажа: всё, что нужно за столом, без редактирования.
class CharacterSheetScreen extends ConsumerWidget {
  const CharacterSheetScreen({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
        actions: <Widget>[
          IconButton(
            onPressed: () => _delete(context, ref),
            tooltip: 'Удалить персонажа',
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: <Widget>[
          _SheetHeader(character: character),
          const SizedBox(height: AppSpacing.xl),
          const SectionLabel('Характеристики'),
          _StatsCard(character: character),
          const SizedBox(height: AppSpacing.xl),
          const SectionLabel('Спасброски'),
          _SavesCard(character: character),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await confirmDelete(context, character.name);
    if (!confirmed || !context.mounted) return;

    final int? id = character.id;
    if (id != null) {
      await ref.read(characterRepositoryProvider).delete(id);
    }
    if (!context.mounted) return;

    Navigator.of(context).pop();
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadii.allMd,
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            character.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${character.classLabel} · ${character.originLabel}',
            maxLines: 2,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          // Wrap, а не Row: «МАСТЕРСТВО» не влезает в четверть узкого экрана.
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _HeaderMetric(label: 'ХИТЫ', value: '${character.maxHitPoints}'),
              _HeaderMetric(label: 'УРОВЕНЬ', value: '${character.level}'),
              _HeaderMetric(label: 'КОСТЬ', value: character.hitDiceLabel),
              _HeaderMetric(
                label: 'МАСТЕРСТВО',
                value: CharacterRules.signed(character.proficiencyBonus),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: AppTypography.labelSmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: AppTypography.titleLarge),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: <Widget>[
        for (final Ability ability in Ability.values)
          _StatRow(
            label: ability.label,
            value: '${character.scores[ability]}',
            modifier: CharacterRules.signed(character.modifier(ability)),
          ),
      ],
    );
  }
}

class _SavesCard extends StatelessWidget {
  const _SavesCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: <Widget>[
        for (final Ability ability in Ability.values)
          _StatRow(
            label: ability.label,
            modifier: CharacterRules.signed(character.savingThrow(ability)),
            proficient: character.dndClass.hasSavingThrowProficiency(ability),
          ),
      ],
    );
  }
}

/// Карточка со списком строк и тонкими разделителями между ними.
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];

    for (int index = 0; index < children.length; index++) {
      if (index > 0) {
        rows.add(
          const Divider(
            color: AppColors.divider,
            height: AppSpacing.lg,
            thickness: 0.5,
          ),
        );
      }
      rows.add(children[index]);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadii.allMd,
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(children: rows),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.modifier,
    this.value,
    this.proficient = false,
  });

  final String label;

  /// Итог броска: для характеристик — модификатор, для спасброска — его сумма.
  final String modifier;

  /// Само значение характеристики. У спасброска его нет.
  final String? value;

  final bool proficient;

  @override
  Widget build(BuildContext context) {
    final String? score = value;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (proficient)
          Text(
            'владение',
            style: AppTypography.labelSmall.copyWith(color: AppColors.accent),
          ),
        if (proficient) const SizedBox(width: AppSpacing.sm),
        if (score != null) ...<Widget>[
          Text(score, style: AppTypography.titleMedium),
          const SizedBox(width: AppSpacing.sm),
        ],
        SizedBox(
          width: AppSpacing.huge,
          child: Text(
            modifier,
            textAlign: TextAlign.end,
            style: AppTypography.titleMedium.copyWith(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}
