import 'package:flutter/material.dart';
import 'dart:math';

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
    final double zThreshold = (sensorData["z_threshold"] as num?)?.toDouble() ?? 3.0;

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
            _buildSensorReading('Z', accelerometerZ - 9.8, zThreshold), // вычитаем гравитацию

            const SizedBox(height: 16),

            // Threshold indicators
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'tune',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Порог X/Y: ${threshold.toStringAsFixed(1)} м/с²',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Порог Z (откл. от 9.8): ${zThreshold.toStringAsFixed(1)} м/с²',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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

  Widget _buildSensorReading(String axis, double value, double threshold) {
    final bool isAboveThreshold = value.abs() > threshold;
    final Color indicatorColor =
        isAboveThreshold ? AppTheme.errorLight : AppTheme.successLight;

    final String displayValue = axis == 'Z'
        ? '${(value + 9.8).toStringAsFixed(2)} м/с²' // показать нормализованное значение
        : '${value.toStringAsFixed(2)} м/с²';

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: indicatorColor.withOpacity(0.1),
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
                    displayValue,
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
                    .withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
