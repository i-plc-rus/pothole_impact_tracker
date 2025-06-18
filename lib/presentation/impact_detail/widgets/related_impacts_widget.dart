import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class RelatedImpactsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> impacts;

  const RelatedImpactsWidget({
    super.key,
    required this.impacts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Связанные удары',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            Spacer(),
            Text(
              'В радиусе 100м',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        impacts.isEmpty ? _buildEmptyState() : _buildImpactsList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'location_searching',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'Нет связанных ударов',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'В радиусе 100 метров не обнаружено других ударов',
            style: AppTheme.lightTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactsList() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: impacts.length,
        separatorBuilder: (context, index) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          final impact = impacts[index];
          return _buildImpactCard(impact);
        },
      ),
    );
  }

  Widget _buildImpactCard(Map<String, dynamic> impact) {
    final severity = impact["severity"] as String;
    final timestamp = impact["timestamp"] as String;
    final distance = impact["distance"] as double;
    final magnitude = impact["magnitude"] as double;

    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(severity).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getSeverityColor(severity).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getSeverityText(severity),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getSeverityColor(severity),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '${magnitude.toStringAsFixed(1)}g',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: _getSeverityColor(severity),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${distance.toStringAsFixed(0)}м от текущего',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          Spacer(),
          Text(
            _formatTimestamp(timestamp),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
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

  String _getSeverityText(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'Критич.';
      case 'moderate':
        return 'Умерен.';
      case 'warning':
        return 'Предупр.';
      case 'normal':
        return 'Норм.';
      default:
        return 'Неизв.';
    }
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'Только что';
    }
  }
}
