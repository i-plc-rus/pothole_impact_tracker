import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class ImpactMetricsWidget extends StatelessWidget {
  final double magnitude;
  final double duration;
  final double vehicleSpeed;
  final double latitude;
  final double longitude;

  const ImpactMetricsWidget({
    super.key,
    required this.magnitude,
    required this.duration,
    required this.vehicleSpeed,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Метрики удара',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Сила удара',
                      '${magnitude.toStringAsFixed(1)}g',
                      'gps_fixed',
                      _getMagnitudeColor(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Длительность',
                      '${(duration * 1000).toInt()}мс',
                      'timer',
                      AppTheme.accentLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Скорость',
                      '${vehicleSpeed.toStringAsFixed(1)} км/ч',
                      'speed',
                      AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Точность GPS',
                      '±3.2м',
                      'my_location',
                      AppTheme.successLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
              SizedBox(height: 16),
              _buildCoordinatesSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 16,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Координаты',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Широта:',
                    style: AppTheme.lightTheme.textTheme.labelSmall,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      latitude.toStringAsFixed(6),
                      style: AppTheme.getMonospaceStyle(
                        isLight: true,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Долгота:',
                    style: AppTheme.lightTheme.textTheme.labelSmall,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      longitude.toStringAsFixed(6),
                      style: AppTheme.getMonospaceStyle(
                        isLight: true,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getMagnitudeColor() {
    if (magnitude >= 8.0) {
      return AppTheme.errorLight;
    } else if (magnitude >= 5.0) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.successLight;
    }
  }
}
