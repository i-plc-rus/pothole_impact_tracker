import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class LocationStatusWidget extends StatelessWidget {
  final String currentLocation;
  final String lastImpactTime;

  const LocationStatusWidget({
    super.key,
    required this.currentLocation,
    required this.lastImpactTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Местоположение и статус',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Current location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.accentLight,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Текущее местоположение',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentLocation,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Last impact time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: AppTheme.warningLight,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Последний удар',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Сегодня в $lastImpactTime',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // GPS status indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.successLight.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'gps_fixed',
                    color: AppTheme.successLight,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GPS активен • Точность: высокая',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.successLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
