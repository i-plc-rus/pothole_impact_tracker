import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SensorChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> accelerometerData;
  final List<Map<String, dynamic>> gyroscopeData;

  const SensorChartWidget({
    super.key,
    required this.accelerometerData,
    required this.gyroscopeData,
  });

  @override
  State<SensorChartWidget> createState() => _SensorChartWidgetState();
}

class _SensorChartWidgetState extends State<SensorChartWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  double _selectedTime = 0.0;
  bool _showDataPoint = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<FlSpot> _getAccelerometerSpots(String axis) {
    return widget.accelerometerData.map((data) {
      final time = (data['time'] as num).toDouble();
      final value = (data[axis] as num).toDouble();
      return FlSpot(time, value);
    }).toList();
  }

  List<FlSpot> _getGyroscopeSpots(String axis) {
    return widget.gyroscopeData.map((data) {
      final time = (data['time'] as num).toDouble();
      final value = (data[axis] as num).toDouble();
      return FlSpot(time, value);
    }).toList();
  }

  void _onChartTap(FlTouchEvent event, LineTouchResponse? response) {
    if (response?.lineBarSpots?.isNotEmpty == true) {
      HapticFeedback.selectionClick();
      final spot = response!.lineBarSpots!.first;
      setState(() {
        _selectedTime = spot.x;
        _showDataPoint = true;
      });

      // Hide data point after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showDataPoint = false;
          });
        }
      });
    }
  }

  Widget _buildAccelerometerChart() {
    return Container(
        height: 250,
        padding: EdgeInsets.all(16),
        child: LineChart(LineChartData(
            gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 5,
                verticalInterval: 0.2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      strokeWidth: 1);
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      strokeWidth: 1);
                }),
            titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 0.2,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text('${value.toStringAsFixed(1)}с',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall));
                        })),
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text('${value.toInt()}g',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall));
                        }))),
            borderData: FlBorderData(
                show: true,
                border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2))),
            minX: 0,
            maxX: 0.8,
            minY: 0,
            maxY: 25,
            lineBarsData: [
              // X-axis
              LineChartBarData(
                  spots: _getAccelerometerSpots('x'),
                  isCurved: true,
                  color: AppTheme.errorLight,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.errorLight.withValues(alpha: 0.1))),
              // Y-axis
              LineChartBarData(
                  spots: _getAccelerometerSpots('y'),
                  isCurved: true,
                  color: AppTheme.successLight,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.successLight.withValues(alpha: 0.1))),
              // Z-axis
              LineChartBarData(
                  spots: _getAccelerometerSpots('z'),
                  isCurved: true,
                  color: AppTheme.accentLight,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentLight.withValues(alpha: 0.1))),
            ],
            lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: _onChartTap,
                touchTooltipData:
                    LineTouchTooltipData(getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final textStyle = AppTheme.lightTheme.textTheme.labelSmall
                        ?.copyWith(
                            color: touchedSpot.bar.color,
                            fontWeight: FontWeight.bold);
                    return LineTooltipItem(
                        '${touchedSpot.y.toStringAsFixed(2)}g',
                        textStyle ?? TextStyle());
                  }).toList();
                })))));
  }

  Widget _buildGyroscopeChart() {
    return Container(
        height: 250,
        padding: EdgeInsets.all(16),
        child: LineChart(LineChartData(
            gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 0.2,
                verticalInterval: 0.2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      strokeWidth: 1);
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      strokeWidth: 1);
                }),
            titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 0.2,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text('${value.toStringAsFixed(1)}с',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall));
                        })),
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.2,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(value.toStringAsFixed(1),
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall));
                        }))),
            borderData: FlBorderData(
                show: true,
                border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2))),
            minX: 0,
            maxX: 0.8,
            minY: 0,
            maxY: 1.0,
            lineBarsData: [
              // X-axis
              LineChartBarData(
                  spots: _getGyroscopeSpots('x'),
                  isCurved: true,
                  color: AppTheme.errorLight,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.errorLight.withValues(alpha: 0.1))),
              // Y-axis
              LineChartBarData(
                  spots: _getGyroscopeSpots('y'),
                  isCurved: true,
                  color: AppTheme.successLight,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.successLight.withValues(alpha: 0.1))),
              // Z-axis
              LineChartBarData(
                  spots: _getGyroscopeSpots('z'),
                  isCurved: true,
                  color: AppTheme.accentLight,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentLight.withValues(alpha: 0.1))),
            ],
            lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: _onChartTap,
                touchTooltipData:
                    LineTouchTooltipData(getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final textStyle = AppTheme.lightTheme.textTheme.labelSmall
                        ?.copyWith(
                            color: touchedSpot.bar.color,
                            fontWeight: FontWeight.bold);
                    return LineTooltipItem(touchedSpot.y.toStringAsFixed(3),
                        textStyle ?? TextStyle());
                  }).toList();
                })))));
  }

  Widget _buildLegend() {
    return Container(
        padding: EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildLegendItem('X', AppTheme.errorLight),
          _buildLegendItem('Y', AppTheme.successLight),
          _buildLegendItem('Z', AppTheme.accentLight),
        ]));
  }

  Widget _buildLegendItem(String axis, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      SizedBox(width: 6),
      Text(axis,
          style: AppTheme.lightTheme.textTheme.labelMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2))),
        child: Column(children: [
          // Tab Bar
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2)))),
              child: TabBar(controller: _tabController, tabs: [
                Tab(text: 'Акселерометр'),
                Tab(text: 'Гироскоп'),
              ])),

          // Chart Content
          SizedBox(
              height: 320,
              child: TabBarView(controller: _tabController, children: [
                Column(children: [
                  _buildAccelerometerChart(),
                  _buildLegend(),
                ]),
                Column(children: [
                  _buildGyroscopeChart(),
                  _buildLegend(),
                ]),
              ])),

          // Timeline scrubber
          Container(
              padding: EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Временная шкала',
                        style: AppTheme.lightTheme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 8),
                            overlayShape:
                                RoundSliderOverlayShape(overlayRadius: 16)),
                        child: Slider(
                            value: _selectedTime,
                            min: 0.0,
                            max: 0.8,
                            divisions: 8,
                            label: '${_selectedTime.toStringAsFixed(1)}с',
                            onChanged: (value) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedTime = value;
                                _showDataPoint = true;
                              });
                            })),
                  ])),
        ]));
  }
}
