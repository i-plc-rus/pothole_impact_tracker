import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class PermissionCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;
  final bool isGranted;
  final bool isRequired;
  final VoidCallback onToggle;

  const PermissionCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.iconName,
    required this.isGranted,
    required this.isRequired,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted
              ? AppTheme.lightTheme.colorScheme.tertiary.withOpacity(0.3)
              : AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
          width: isGranted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isGranted
                      ? AppTheme.lightTheme.colorScheme.tertiary
                          .withOpacity(0.1)
                      : AppTheme.lightTheme.colorScheme.secondary
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: isGranted
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.lightTheme.colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Обязательно',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isGranted
                            ? AppTheme.lightTheme.colorScheme.tertiary
                                .withOpacity(0.1)
                            : AppTheme.lightTheme.colorScheme.outline
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isGranted ? 'Разрешено' : 'Не настроено',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isGranted
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onToggle,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isGranted
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.lightTheme.colorScheme.secondary,
                ),
                foregroundColor: isGranted
                    ? AppTheme.lightTheme.colorScheme.tertiary
                    : AppTheme.lightTheme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: isGranted ? 'check_circle' : 'settings',
                    color: isGranted
                        ? AppTheme.lightTheme.colorScheme.tertiary
                        : AppTheme.lightTheme.colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isGranted ? 'Настроено' : 'Настроить',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
