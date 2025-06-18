import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class ImpactSeverityBadgeWidget extends StatelessWidget {
  final String severity;

  const ImpactSeverityBadgeWidget({
    super.key,
    required this.severity,
  });

  Color _getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.errorLight;
      case 'moderate':
        return AppTheme.warningLight;
      case 'warning':
        return AppTheme.warningLight;
      case 'normal':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getSeverityText() {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'Критический';
      case 'moderate':
        return 'Умеренный';
      case 'warning':
        return 'Предупреждение';
      case 'normal':
        return 'Нормальный';
      default:
        return 'Неизвестно';
    }
  }

  IconData _getSeverityIcon() {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.warning;
      case 'moderate':
        return Icons.info;
      case 'warning':
        return Icons.warning_amber;
      case 'normal':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: _getSeverityIcon().codePoint.toString(),
            color: color,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            _getSeverityText(),
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
