import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmationDialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.isDestructive = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.sp),
      ),
      title: Row(
        children: [
          if (isDestructive)
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
          if (isDestructive) SizedBox(width: 8.sp),
          Expanded(
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isDestructive
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTheme.lightTheme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            cancelText,
            style: TextStyle(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: isDestructive
                ? AppTheme.lightTheme.colorScheme.onError
                : AppTheme.lightTheme.colorScheme.onPrimary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
