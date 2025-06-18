import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_export.dart';

class ImpactCardWidget extends StatelessWidget {
  final Map<String, dynamic> impact;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeLeft;

  const ImpactCardWidget({
    super.key,
    required this.impact,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onSwipeRight,
    required this.onSwipeLeft,
  });

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.errorLight;
      case 'warning':
        return AppTheme.warningLight;
      case 'normal':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${timestamp.day}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
      child: Dismissible(
        key: Key('impact_${impact["id"]}'),
        background: _buildSwipeBackground(true),
        secondaryBackground: _buildSwipeBackground(false),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            onSwipeRight();
          } else {
            onSwipeLeft();
          }
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onSwipeRight();
          } else {
            onSwipeLeft();
          }
          return false; // Don't actually dismiss
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: AppTheme.lightTheme.colorScheme.secondary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                if (isMultiSelectMode) ...[
                  Container(
                    width: 24,
                    height: 24,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.lightTheme.colorScheme.outline,
                        width: 2,
                      ),
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.onSecondary,
                            size: 16,
                          )
                        : null,
                  ),
                ],
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImageWidget(
                    imageUrl: impact["mapThumbnail"] as String,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getSeverityColor(
                                  impact["severity"] as String),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              impact["location"] as String,
                              style: AppTheme.lightTheme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        impact["magnitude"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              _getSeverityColor(impact["severity"] as String),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'access_time',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatTimestamp(impact["timestamp"] as DateTime),
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                          SizedBox(width: 16),
                          CustomIconWidget(
                            iconName: 'speed',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${impact["speed"]} км/ч',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${impact["severityLevel"]}',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: _getSeverityColor(impact["severity"] as String),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'G',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isLeftSwipe) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLeftSwipe
            ? AppTheme.lightTheme.colorScheme.secondary
            : AppTheme.successLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeftSwipe ? 'visibility' : 'file_download',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                isLeftSwipe ? 'Действия' : 'Экспорт',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
