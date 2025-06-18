import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class DateRangeSelectorWidget extends StatefulWidget {
  final int impactCount;
  final Function(DateTime start, DateTime end) onDateRangeChanged;

  const DateRangeSelectorWidget({
    super.key,
    required this.impactCount,
    required this.onDateRangeChanged,
  });

  @override
  State<DateRangeSelectorWidget> createState() =>
      _DateRangeSelectorWidgetState();
}

class _DateRangeSelectorWidgetState extends State<DateRangeSelectorWidget> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _showDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      locale: Locale('ru', 'RU'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      widget.onDateRangeChanged(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showDatePicker,
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Период',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      Text(
                        '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${widget.impactCount} ударов',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
