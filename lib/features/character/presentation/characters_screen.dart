import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../domain/character.dart';
import 'character_create_screen.dart';
import 'character_providers.dart';
import 'character_sheet_screen.dart';
import 'widgets/character_tile.dart';
import 'widgets/confirm_delete.dart';

/// Список персонажей — точка входа в систему персонажей.
class CharactersScreen extends ConsumerWidget {
  const CharactersScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CharactersScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Character>> characters = ref.watch(
      charactersProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Персонажи'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _openCreate(context),
            tooltip: 'Новый персонаж',
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: characters.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (Object error, StackTrace stack) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(charactersProvider),
        ),
        data: (List<Character> items) => items.isEmpty
            ? _EmptyState(onCreate: () => _openCreate(context))
            : _CharacterList(items: items),
      ),
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CharacterCreateScreen()),
    );
  }
}

class _CharacterList extends ConsumerWidget {
  const _CharacterList({required this.items});

  final List<Character> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final Character character = items[index];
        final int? id = character.id;

        return Dismissible(
          key: ValueKey<int>(id ?? index),
          direction: DismissDirection.endToStart,
          background: const _DeleteBackground(),
          confirmDismiss: (DismissDirection direction) =>
              confirmDelete(context, character.name),
          onDismissed: (DismissDirection direction) {
            if (id != null) {
              ref.read(characterRepositoryProvider).delete(id);
            }
          },
          child: CharacterTile(
            character: character,
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => CharacterSheetScreen(character: character),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Подложка свайпа: единственный способ удалить персонажа из списка.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.centerRight,
      decoration: const BoxDecoration(
        color: AppColors.surface3,
        borderRadius: AppRadii.allMd,
      ),
      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(
              Icons.group_outlined,
              size: AppSpacing.huge,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Пока ни одного героя',
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Характеристики бросятся 4d6, бонусы расы и подрасы применятся сами. '
              'Хиты и модификаторы считаются из значений, а не хранятся рядом.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onCreate,
              child: const Text('Создать персонажа'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Не удалось прочитать базу персонажей.\n$message',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
