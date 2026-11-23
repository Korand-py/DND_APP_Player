import 'package:dice_roller/theme/app_colors.dart';
import 'package:dice_roller/theme/app_spacing.dart';
import 'package:dice_roller/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Страницы токенов: то, из чего собирается любой экран.
///
/// Здесь нет ни одного значения, которого нет в `lib/theme/`.
/// Если страница расходится с кодом — значит токен переименовали,
/// и это видно сразу.

@widgetbook.UseCase(name: 'Палитра', type: PalettePage, path: '[Токены]')
Widget palettePageUseCase(BuildContext context) => const PalettePage();

@widgetbook.UseCase(name: 'Типографика', type: TypographyPage, path: '[Токены]')
Widget typographyPageUseCase(BuildContext context) => const TypographyPage();

@widgetbook.UseCase(name: 'Отступы', type: SpacingPage, path: '[Токены]')
Widget spacingPageUseCase(BuildContext context) => const SpacingPage();

/// Все цвета проекта. Пара «образец + имя» — чтобы имя не искали в коде.
class PalettePage extends StatelessWidget {
  const PalettePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Палитра',
      note: 'Единственный источник цветов. Хардкод Color(0x...) запрещён.',
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          for (final (String name, Color color) in _swatches)
            _Swatch(name: name, color: color),
        ],
      ),
    );
  }
}

/// Шкала от displayHero до labelSmall. Вес — пара fontWeight + fontVariations.
class TypographyPage extends StatelessWidget {
  const TypographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Типографика',
      note: 'Inter, вариативный. Один шрифт на весь проект.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (String name, TextStyle style) in _typeSamples) ...[
            Text('Aa', style: style),
            Text(name, style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Ряд 4–64. Промежуточных значений нет — поэтому нет и «на глаз».
class SpacingPage extends StatelessWidget {
  const SpacingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Отступы',
      note: 'Ряд 4–64. Промежуточных значений не существует.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (String name, double value) in _spaceSamples)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: AppSpacing.massive,
                    child: Text(name, style: AppTypography.labelSmall),
                  ),
                  Container(
                    width: value,
                    height: AppSpacing.xxs,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${value.toInt()}', style: AppTypography.labelSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Общая обёртка страницы токенов: заголовок, пояснение, содержимое.
class _PageShell extends StatelessWidget {
  const _PageShell({
    required this.title,
    required this.note,
    required this.child,
  });

  final String title;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.void0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(note, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSpacing.xxxl * 1.5,
          height: AppSpacing.xxxl,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadii.allSm,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(name, style: AppTypography.labelSmall),
      ],
    );
  }
}

const List<(String, Color)> _swatches = [
  ('void0', AppColors.void0),
  ('surface1', AppColors.surface1),
  ('surface2', AppColors.surface2),
  ('surface3', AppColors.surface3),
  ('accent', AppColors.accent),
  ('accentSoft', AppColors.accentSoft),
  ('accentLine', AppColors.accentLine),
  ('textPrimary', AppColors.textPrimary),
  ('textSecondary', AppColors.textSecondary),
  ('textMuted', AppColors.textMuted),
  ('onAccent', AppColors.onAccent),
  ('divider', AppColors.divider),
  ('border', AppColors.border),
  ('error', AppColors.error),
  ('success', AppColors.success),
];

const List<(String, TextStyle)> _typeSamples = [
  ('displayHero', AppTypography.displayHero),
  ('displayLarge', AppTypography.displayLarge),
  ('displayMedium', AppTypography.displayMedium),
  ('headlineMedium', AppTypography.headlineMedium),
  ('titleLarge', AppTypography.titleLarge),
  ('titleMedium', AppTypography.titleMedium),
  ('bodyLarge', AppTypography.bodyLarge),
  ('bodyMedium', AppTypography.bodyMedium),
  ('labelLarge', AppTypography.labelLarge),
  ('labelSmall', AppTypography.labelSmall),
];

const List<(String, double)> _spaceSamples = [
  ('xxs', AppSpacing.xxs),
  ('xs', AppSpacing.xs),
  ('sm', AppSpacing.sm),
  ('md', AppSpacing.md),
  ('lg', AppSpacing.lg),
  ('xl', AppSpacing.xl),
  ('xxl', AppSpacing.xxl),
  ('xxxl', AppSpacing.xxxl),
  ('huge', AppSpacing.huge),
  ('massive', AppSpacing.massive),
];
