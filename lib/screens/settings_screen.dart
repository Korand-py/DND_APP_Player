import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Экран настроек приложения.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Настройки', style: AppTypography.headlineMedium),
            SizedBox(height: AppSpacing.md),
            Text(
              'Раздел в разработке.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
