import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/character/domain/ability.dart';
import '../features/character/domain/character.dart';
import '../features/character/domain/character_rules.dart';
import '../features/character/presentation/active_character.dart';
import '../features/character/presentation/character_create_screen.dart';
import '../features/character/presentation/character_providers.dart';
import '../features/character/presentation/characters_screen.dart';
import '../features/character/presentation/widgets/confirm_delete.dart';
import '../screens/dice_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/roll_button.dart';
import '../widgets/section_label.dart';

/// Вкладка персонажа: выбор (если несколько), затем лист с бросками.
class SpecificationsScreen extends ConsumerStatefulWidget {
  const SpecificationsScreen({super.key, this.onRollRequest});

  /// Если задан, бросок открывается во вкладке кубиков (меню остаётся видно).
  final void Function({required String label, required int modifier})?
  onRollRequest;

  @override
  ConsumerState<SpecificationsScreen> createState() =>
      _SpecificationsScreenState();
}

class _SpecificationsScreenState extends ConsumerState<SpecificationsScreen> {
  int? _pickedId;

  void _openCreate() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CharacterCreateScreen()),
    );
  }

  /// Список персонажей — второй путь к удалению (свайпом) и выбору героя.
  void _openCharacters() {
    Navigator.of(context).push<void>(CharactersScreen.route());
  }

  void _pick(Character character) {
    final int? id = character.id;
    if (id != null) {
      ref.read(activeCharacterIdProvider.notifier).select(id);
    }
    setState(() => _pickedId = id);
  }

  /// Удаление с главного экрана: подтверждение, запись в базу, сброс выбора.
  ///
  /// `activeCharacterProvider` сам подменит удалённого следующего, но локальный
  /// `_pickedId` надо сбросить явно — иначе он продолжит ссылаться на пустоту.
  Future<void> _delete(Character character) async {
    final int? id = character.id;
    if (id == null) return;

    final bool confirmed = await confirmDelete(context, character.name);
    if (!confirmed || !mounted) return;

    await ref.read(characterRepositoryProvider).delete(id);
    if (!mounted) return;

    if (_pickedId == id) {
      ref.read(activeCharacterIdProvider.notifier).clear();
      setState(() => _pickedId = null);
    }
  }

  void _openRoll({
    required String label,
    required int modifier,
  }) {
    final void Function({required String label, required int modifier})?
    onRollRequest = widget.onRollRequest;
    if (onRollRequest != null) {
      onRollRequest(label: label, modifier: modifier);
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DiceScreen(rollLabel: label, rollModifier: modifier),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Character>> characters = ref.watch(charactersProvider);

    return SafeArea(
      child: characters.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (Object error, StackTrace stack) => _TabMessage(
          title: 'Не удалось загрузить персонажей',
          message: '$error',
          actionLabel: 'Повторить',
          onAction: () => ref.invalidate(charactersProvider),
        ),
        data: (List<Character> items) {
          if (items.isEmpty) {
            return _EmptyCharacterState(onCreate: _openCreate);
          }

          final Character? active = ref.watch(activeCharacterProvider);
          final bool mustPick = items.length > 1 && _pickedId == null;
          final Character? shown = mustPick
              ? null
              : _resolveShown(items, active, _pickedId);

          if (shown == null) {
            return _CharacterPicker(
              items: items,
              onPick: _pick,
              onCreate: _openCreate,
            );
          }

          return _CharacterSheetTab(
            character: shown,
            hasMany: items.length > 1,
            onChangeCharacter: () => setState(() => _pickedId = null),
            onCreate: _openCreate,
            onOpenCharacters: _openCharacters,
            onDelete: () => _delete(shown),
            onRoll: _openRoll,
          );
        },
      ),
    );
  }

  Character? _resolveShown(
    List<Character> items,
    Character? active,
    int? pickedId,
  ) {
    if (pickedId != null) {
      for (final Character c in items) {
        if (c.id == pickedId) return c;
      }
    }
    return active ?? items.first;
  }
}

class _CharacterPicker extends StatelessWidget {
  const _CharacterPicker({
    required this.items,
    required this.onPick,
    required this.onCreate,
  });

  final List<Character> items;
  final ValueChanged<Character> onPick;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Выберите персонажа', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Сначала выберите героя, затем откроется его лист.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final Character character = items[index];
                return _PickTile(
                  character: character,
                  onTap: () => onPick(character),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          RollButton(label: 'Создать персонажа', onPressed: onCreate),
        ],
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({required this.character, required this.onTap});

  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface1,
      borderRadius: AppRadii.allMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.allMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.allMd,
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      character.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${character.classLabel} · ${character.originLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterSheetTab extends StatefulWidget {
  const _CharacterSheetTab({
    required this.character,
    required this.hasMany,
    required this.onChangeCharacter,
    required this.onCreate,
    required this.onOpenCharacters,
    required this.onDelete,
    required this.onRoll,
  });

  final Character character;
  final bool hasMany;
  final VoidCallback onChangeCharacter;
  final VoidCallback onCreate;
  final VoidCallback onOpenCharacters;
  final VoidCallback onDelete;
  final void Function({required String label, required int modifier}) onRoll;

  @override
  State<_CharacterSheetTab> createState() => _CharacterSheetTabState();
}

class _CharacterSheetTabState extends State<_CharacterSheetTab> {
  late int _hp;
  late int _mana;

  int get _manaMax => 10 + widget.character.level;

  @override
  void initState() {
    super.initState();
    _hp = widget.character.maxHitPoints;
    _mana = _manaMax;
  }

  @override
  void didUpdateWidget(covariant _CharacterSheetTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character.id != widget.character.id ||
        oldWidget.character.maxHitPoints != widget.character.maxHitPoints ||
        oldWidget.character.level != widget.character.level) {
      _hp = widget.character.maxHitPoints;
      _mana = _manaMax;
    }
  }

  void _changeHp(int delta) {
    setState(() {
      _hp = (_hp + delta).clamp(0, widget.character.maxHitPoints);
    });
  }

  void _changeMana(int delta) {
    setState(() {
      _mana = (_mana + delta).clamp(0, _manaMax);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Character character = widget.character;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            0,
          ),
          child: Row(
            children: <Widget>[
              if (widget.hasMany)
                IconButton(
                  onPressed: widget.onChangeCharacter,
                  tooltip: 'Выбрать персонажа',
                  icon: const Icon(Icons.switch_account_outlined),
                )
              else
                const SizedBox(width: AppSpacing.huge),
              Expanded(
                child: Text(
                  'Лист персонажа',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall,
                ),
              ),
              IconButton(
                onPressed: widget.onOpenCharacters,
                tooltip: 'Персонажи',
                icon: const Icon(Icons.group_outlined),
              ),
              IconButton(
                onPressed: widget.onDelete,
                tooltip: 'Удалить персонажа',
                icon: const Icon(Icons.delete_outline_rounded),
              ),
              IconButton(
                onPressed: widget.onCreate,
                tooltip: 'Создать персонажа',
                icon: const Icon(Icons.person_add_outlined),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: <Widget>[
              _SheetHeader(
                character: character,
                hp: _hp,
                hpMax: character.maxHitPoints,
                mana: _mana,
                manaMax: _manaMax,
                onHpMinus: () => _changeHp(-1),
                onHpPlus: () => _changeHp(1),
                onManaMinus: () => _changeMana(-1),
                onManaPlus: () => _changeMana(1),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionLabel('Характеристики'),
              _StatsCard(character: character, onRoll: widget.onRoll),
              const SizedBox(height: AppSpacing.xl),
              const SectionLabel('Спасброски'),
              _SavesCard(character: character, onRoll: widget.onRoll),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Нажмите на характеристику или спасбросок, чтобы бросить куб с модификатором.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.character,
    required this.hp,
    required this.hpMax,
    required this.mana,
    required this.manaMax,
    required this.onHpMinus,
    required this.onHpPlus,
    required this.onManaMinus,
    required this.onManaPlus,
  });

  final Character character;
  final int hp;
  final int hpMax;
  final int mana;
  final int manaMax;
  final VoidCallback onHpMinus;
  final VoidCallback onHpPlus;
  final VoidCallback onManaMinus;
  final VoidCallback onManaPlus;

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
          _ResourceBar(
            label: 'HP',
            value: hp,
            max: hpMax,
            color: AppColors.error,
            onMinus: onHpMinus,
            onPlus: onHpPlus,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ResourceBar(
            label: 'МАНА',
            value: mana,
            max: manaMax,
            color: AppColors.accent,
            onMinus: onManaMinus,
            onPlus: onManaPlus,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
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

class _ResourceBar extends StatelessWidget {
  const _ResourceBar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final int value;
  final int max;
  final Color color;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final double progress = max <= 0 ? 0 : (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(label, style: AppTypography.labelSmall),
            const Spacer(),
            IconButton(
              onPressed: onMinus,
              tooltip: 'Уменьшить $label',
              icon: const Icon(Icons.remove_rounded, size: 18),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(
                width: AppSpacing.xxl,
                height: AppSpacing.xxl,
              ),
              padding: EdgeInsets.zero,
            ),
            SizedBox(
              width: AppSpacing.massive,
              child: Text(
                '$value / $max',
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium,
              ),
            ),
            IconButton(
              onPressed: onPlus,
              tooltip: 'Увеличить $label',
              icon: const Icon(Icons.add_rounded, size: 18),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(
                width: AppSpacing.xxl,
                height: AppSpacing.xxl,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        ClipRRect(
          borderRadius: AppRadii.allSm,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surface3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
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
  const _StatsCard({required this.character, required this.onRoll});

  final Character character;
  final void Function({required String label, required int modifier}) onRoll;

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: <Widget>[
        for (final Ability ability in Ability.values)
          _StatRow(
            label: ability.label,
            value: '${character.scores[ability]}',
            modifier: CharacterRules.signed(character.modifier(ability)),
            onTap: () => onRoll(
              label: '${ability.label} · проверка',
              modifier: character.modifier(ability),
            ),
          ),
      ],
    );
  }
}

class _SavesCard extends StatelessWidget {
  const _SavesCard({required this.character, required this.onRoll});

  final Character character;
  final void Function({required String label, required int modifier}) onRoll;

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: <Widget>[
        for (final Ability ability in Ability.values)
          _StatRow(
            label: ability.label,
            modifier: CharacterRules.signed(character.savingThrow(ability)),
            proficient: character.dndClass.hasSavingThrowProficiency(ability),
            onTap: () => onRoll(
              label: '${ability.label} · спасбросок',
              modifier: character.savingThrow(ability),
            ),
          ),
      ],
    );
  }
}

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
            height: 0.5,
            thickness: 0.5,
          ),
        );
      }
      rows.add(children[index]);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadii.allMd,
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.modifier,
    required this.onTap,
    this.value,
    this.proficient = false,
  });

  final String label;
  final String modifier;
  final String? value;
  final bool proficient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? score = value;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
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
        ),
      ),
    );
  }
}

class _EmptyCharacterState extends StatelessWidget {
  const _EmptyCharacterState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Icon(
            Icons.person_add_alt_1_outlined,
            size: AppSpacing.huge,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Нет персонажей',
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Создайте персонажа, чтобы открыть его лист и бросать кубы с модификаторами.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          RollButton(label: 'Создать персонажа', onPressed: onCreate),
        ],
      ),
    );
  }
}

class _TabMessage extends StatelessWidget {
  const _TabMessage({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, textAlign: TextAlign.center, style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          RollButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}
