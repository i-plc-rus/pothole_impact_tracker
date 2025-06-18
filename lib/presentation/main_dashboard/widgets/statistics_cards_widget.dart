import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class StatisticsCardsWidget extends StatelessWidget {
  final int todayImpacts;
  final int severeImpacts;
  final double distanceTraveled;
  final double averageSpeed;

  const StatisticsCardsWidget({
    super.key,
    required this.todayImpacts,
    required this.severeImpacts,
    required this.distanceTraveled,
    required this.averageSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Статистика за сегодня',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildStatCard(
                icon: 'warning',
                title: 'Сильные удары',
                value: severeImpacts.toString(),
                color: AppTheme.errorLight,
                context: context,
              ),
              _buildStatCard(
                icon: 'route',
                title: 'Пройдено',
                value: '${distanceTraveled.toStringAsFixed(1)} км',
                color: AppTheme.accentLight,
                context: context,
              ),
              _buildStatCard(
                icon: 'speed',
                title: 'Средняя скорость',
                value: '${averageSpeed.toStringAsFixed(0)} км/ч',
                color: AppTheme.successLight,
                context: context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            _showDetailDialog(context, title, value);
          },
          onLongPress: () {
            _showContextMenu(context, title);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, String title, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Текущее значение: $value',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Подробная статистика будет доступна в разделе "История"',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Поделиться'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Подробности'),
              onTap: () {
                Navigator.pop(context);
                _showDetailDialog(context, title, 'Подробная информация');
              },
            ),
          ],
        ),
      ),
    );
  }
}
