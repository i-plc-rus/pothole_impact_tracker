import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class WeatherConditionsWidget extends StatelessWidget {
  final int temperature;
  final String conditions;
  final String roadConditions;

  const WeatherConditionsWidget({
    super.key,
    required this.temperature,
    required this.conditions,
    required this.roadConditions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Погодные условия',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTemperatureColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: _getWeatherIcon(),
                      color: _getTemperatureColor(),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${temperature > 0 ? '+' : ''}$temperature°C',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            color: _getTemperatureColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          conditions,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.2),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getRoadConditionColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'warning',
                      color: _getRoadConditionColor(),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Состояние дороги',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          roadConditions,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: _getRoadConditionColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningLight.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.warningLight,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Неблагоприятные погодные условия могут увеличить риск ударов',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.warningLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getWeatherIcon() {
    switch (conditions.toLowerCase()) {
      case 'снег':
        return 'ac_unit';
      case 'дождь':
        return 'water_drop';
      case 'туман':
        return 'cloud';
      case 'ясно':
        return 'wb_sunny';
      case 'облачно':
        return 'cloud_queue';
      default:
        return 'wb_cloudy';
    }
  }

  Color _getTemperatureColor() {
    if (temperature <= -10) {
      return AppTheme.accentLight;
    } else if (temperature <= 0) {
      return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    } else if (temperature <= 15) {
      return AppTheme.successLight;
    } else if (temperature <= 25) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.errorLight;
    }
  }

  Color _getRoadConditionColor() {
    switch (roadConditions.toLowerCase()) {
      case 'скользко':
      case 'лед':
        return AppTheme.errorLight;
      case 'мокро':
      case 'слякоть':
        return AppTheme.warningLight;
      case 'сухо':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
