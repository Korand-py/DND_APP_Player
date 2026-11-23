import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// Подтверждение удаления. Возвращает `true`, только если игрок нажал «Удалить».
///
/// Удаление персонажа необратимо и локально: отменить его нечем, поэтому
/// диалог обязателен и в списке, и на листе персонажа.
Future<bool> confirmDelete(BuildContext context, String name) async {
  final bool? answer = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.allLg),
        title: const Text('Удалить персонажа?'),
        content: Text('$name исчезнет без возможности отменить.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      );
    },
  );

  return answer ?? false;
}
