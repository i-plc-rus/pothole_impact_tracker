import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class ImpactCounterWidget extends StatelessWidget {
  final int totalImpacts;
  final int todayImpacts;

  const ImpactCounterWidget({
    super.key,
    required this.totalImpacts,
    required this.todayImpacts,
  });

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'timeline',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Счетчик ударов',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _formatNumber(totalImpacts),
                        style: AppTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Всего',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: AppTheme.lightTheme.dividerColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _formatNumber(todayImpacts),
                        style: AppTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(
                          color: AppTheme.accentLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Сегодня',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
