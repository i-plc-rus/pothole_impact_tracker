import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ImpactChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> weeklyData;

  const ImpactChartWidget({
    super.key,
    required this.weeklyData,
  });

  @override
  State<ImpactChartWidget> createState() => _ImpactChartWidgetState();
}

class _ImpactChartWidgetState extends State<ImpactChartWidget> {
  bool _isWeeklyView = true;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('График ударов',
                    style: AppTheme.lightTheme.textTheme.titleMedium),
                Container(
                    decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _buildToggleButton('Неделя', _isWeeklyView, () {
                        setState(() {
                          _isWeeklyView = true;
                        });
                      }),
                      _buildToggleButton('Месяц', !_isWeeklyView, () {
                        setState(() {
                          _isWeeklyView = false;
                        });
                      }),
                    ])),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                  height: 200,
                  child: Semantics(
                      label: "График ударов по дням",
                      child: BarChart(BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(),
                          barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                  tooltipRoundedRadius: 8,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    final date =
                                        widget.weeklyData[group.x.toInt()]
                                            ["date"] as String;
                                    final count = rod.toY.round();
                                    return BarTooltipItem(
                                        '$date\n$count ударов',
                                        AppTheme.lightTheme.textTheme.bodySmall!
                                            .copyWith(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.onPrimary));
                                  })),
                          titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= 0 &&
                                            value.toInt() <
                                                widget.weeklyData.length) {
                                          final date =
                                              widget.weeklyData[value.toInt()]
                                                  ["date"] as String;
                                          final day = date.split('.')[0];
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Text(day,
                                                  style: AppTheme.lightTheme
                                                      .textTheme.bodySmall));
                                        }
                                        return const Text('');
                                      },
                                      reservedSize: 30)),
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 5,
                                      getTitlesWidget: (value, meta) {
                                        return Text(value.toInt().toString(),
                                            style: AppTheme.lightTheme.textTheme
                                                .bodySmall);
                                      },
                                      reservedSize: 32))),
                          borderData: FlBorderData(show: false),
                          barGroups: _buildBarGroups(),
                          gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 5,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                    color: AppTheme.lightTheme.dividerColor,
                                    strokeWidth: 1);
                              }))))),
            ])));
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6)),
            child: Text(text,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onSecondary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.w400))));
  }

  double _getMaxY() {
    if (widget.weeklyData.isEmpty) return 30;
    final maxValue = widget.weeklyData
        .map((item) => (item["count"] as int).toDouble())
        .reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.weeklyData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final count = (data["count"] as int).toDouble();

      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            toY: count,
            color: AppTheme.accentLight,
            width: 16,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(4))),
      ]);
    }).toList();
  }
}
