import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalibrationModalWidget extends StatefulWidget {
  final double currentSensitivity;
  final ValueChanged<double> onSensitivityChanged;

  const CalibrationModalWidget({
    super.key,
    required this.currentSensitivity,
    required this.onSensitivityChanged,
  });

  @override
  State<CalibrationModalWidget> createState() => _CalibrationModalWidgetState();
}

class _CalibrationModalWidgetState extends State<CalibrationModalWidget> {
  late double _tempSensitivity;
  bool _isTestingImpact = false;

  // Mock sensor data
  final List<Map<String, dynamic>> _sensorReadings = [
    {"axis": "X", "value": 0.12, "unit": "g"},
    {"axis": "Y", "value": -0.05, "unit": "g"},
    {"axis": "Z", "value": 9.81, "unit": "g"},
  ];

  @override
  void initState() {
    super.initState();
    _tempSensitivity = widget.currentSensitivity;
  }

  void _testImpact() {
    setState(() {
      _isTestingImpact = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTestingImpact = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тест удара завершен')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      child: Column(
        children: [
          Container(
            width: 40.sp,
            height: 4.sp,
            margin: EdgeInsets.symmetric(vertical: 12.sp),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2.sp),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Калибровка датчиков',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSensorReadings(),
                  SizedBox(height: 24.sp),
                  _buildSensitivityControl(),
                  SizedBox(height: 24.sp),
                  _buildTestSection(),
                  SizedBox(height: 24.sp),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorReadings() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'sensors',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 8.sp),
              Text(
                'Показания датчиков',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          ..._sensorReadings.map((reading) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ось ${reading["axis"]}:',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${reading["value"].toStringAsFixed(2)} ${reading["unit"]}',
                      style: AppTheme.getMonospaceStyle(
                        isLight: true,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSensitivityControl() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'tune',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 8.sp),
              Text(
                'Чувствительность',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 16.sp),
          Row(
            children: [
              Text(
                'Низкая',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: _tempSensitivity,
                  onChanged: (value) {
                    setState(() {
                      _tempSensitivity = value;
                    });
                  },
                  divisions: 20,
                  label: '${(_tempSensitivity * 100).toInt()}%',
                ),
              ),
              Text(
                'Высокая',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          Center(
            child: Text(
              'Текущий уровень: ${(_tempSensitivity * 100).toInt()}%',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'science',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 8.sp),
              Text(
                'Тестирование',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          Text(
            'Нажмите кнопку и слегка встряхните устройство для проверки настроек чувствительности.',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
          SizedBox(height: 16.sp),
          Center(
            child: ElevatedButton.icon(
              onPressed: _isTestingImpact ? null : _testImpact,
              icon: _isTestingImpact
                  ? SizedBox(
                      width: 16.sp,
                      height: 16.sp,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : CustomIconWidget(
                      iconName: 'play_arrow',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
              label: Text(_isTestingImpact ? 'Тестирование...' : 'Тест удара'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTestingImpact
                    ? AppTheme.lightTheme.colorScheme.outline
                    : AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
        ),
        SizedBox(width: 16.sp),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onSensitivityChanged(_tempSensitivity);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Настройки сохранены')),
              );
            },
            child: const Text('Сохранить'),
          ),
        ),
      ],
    );
  }
}
