import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class MonitoringStatusWidget extends StatelessWidget {
  final bool isMonitoring;
  final VoidCallback onToggle;
  final int batteryLevel;

  const MonitoringStatusWidget({
    super.key,
    required this.isMonitoring,
    required this.onToggle,
    required this.batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Мониторинг (v1.1.4)',
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMonitoring ? 'Активен' : 'Приостановлен',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isMonitoring
                            ? AppTheme.successLight
                            : AppTheme.warningLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                /*Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'battery_std',
                      color: batteryLevel > 20
                          ? AppTheme.successLight
                          : AppTheme.warningLight,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$batteryLevel%',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],
                ),*/
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onToggle,
                icon: CustomIconWidget(
                  iconName: isMonitoring ? 'pause' : 'play_arrow',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 24,
                ),
                label: Text(
                  isMonitoring ? 'Приостановить' : 'Запустить',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMonitoring
                      ? AppTheme.warningLight
                      : AppTheme.successLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            /*if (isMonitoring) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.successLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Фоновый режим активен',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.successLight,
                    ),
                  ),
                ],
              ),
            ],*/
          ],
        ),
      ),
    );
  }
}
