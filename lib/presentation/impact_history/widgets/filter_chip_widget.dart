import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.lightTheme.colorScheme.secondary
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppTheme.lightTheme.colorScheme.secondary
                : AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isActive
                    ? AppTheme.lightTheme.colorScheme.onSecondary
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            if (isActive) ...[
              SizedBox(width: 8),
              CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
