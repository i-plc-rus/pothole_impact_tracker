import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class SensorVisualizationWidget extends StatelessWidget {
  final Map<String, dynamic> sensorData;

  const SensorVisualizationWidget({
    super.key,
    required this.sensorData,
  });

  @override
  Widget build(BuildContext context) {
    final double accelerometerX =
        (sensorData["accelerometer_x"] as num).toDouble();
    final double accelerometerY =
        (sensorData["accelerometer_y"] as num).toDouble();
    final double accelerometerZ =
        (sensorData["accelerometer_z"] as num).toDouble();
    final double threshold = (sensorData["threshold"] as num).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'sensors',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Датчики в реальном времени',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Accelerometer readings
            _buildSensorReading('X', accelerometerX, threshold),
            const SizedBox(height: 12),
            _buildSensorReading('Y', accelerometerY, threshold),
            const SizedBox(height: 12),
            _buildSensorReading('Z', accelerometerZ, threshold),

            const SizedBox(height: 16),

            // Threshold indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'tune',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Порог срабатывания: ${threshold.toStringAsFixed(1)} м/с²',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorReading(String axis, double value, double threshold) {
    final bool isAboveThreshold = value.abs() > threshold;
    final Color indicatorColor =
        isAboveThreshold ? AppTheme.errorLight : AppTheme.successLight;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: indicatorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              axis,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: indicatorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${value.toStringAsFixed(2)} м/с²',
                    style: AppTheme.getMonospaceStyle(
                      isLight: true,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isAboveThreshold)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.errorLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ПРЕВЫШЕН',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (value.abs() / (threshold * 2)).clamp(0.0, 1.0),
                backgroundColor: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
