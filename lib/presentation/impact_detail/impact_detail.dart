import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import './widgets/impact_metrics_widget.dart';
import './widgets/impact_severity_badge_widget.dart';
import './widgets/map_view_widget.dart';
import './widgets/related_impacts_widget.dart';
import './widgets/sensor_chart_widget.dart';
import './widgets/weather_conditions_widget.dart';

class ImpactDetail extends StatefulWidget {
  const ImpactDetail({super.key});

  @override
  State<ImpactDetail> createState() => _ImpactDetailState();
}

class _ImpactDetailState extends State<ImpactDetail> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  // Mock impact data
  final Map<String, dynamic> impactData = {
    "id": "impact_001",
    "severity": "critical",
    "timestamp": "2024-01-15T14:30:25.000Z",
    "magnitude": 8.5,
    "duration": 0.8,
    "vehicleSpeed": 45.2,
    "location": {
      "latitude": 55.7558,
      "longitude": 37.6176,
      "address": "ул. Тверская, 15, Москва",
      "accuracy": 3.2
    },
    "sensorData": {
      "accelerometer": [
        {"time": 0.0, "x": 0.1, "y": 0.2, "z": 9.8},
        {"time": 0.1, "x": 2.5, "y": 1.8, "z": 11.2},
        {"time": 0.2, "x": 8.5, "y": 3.2, "z": 15.6},
        {"time": 0.3, "x": 12.8, "y": 7.4, "z": 18.9},
        {"time": 0.4, "x": 15.2, "y": 9.8, "z": 22.1},
        {"time": 0.5, "x": 8.9, "y": 5.6, "z": 16.3},
        {"time": 0.6, "x": 3.2, "y": 2.1, "z": 12.4},
        {"time": 0.7, "x": 1.1, "y": 0.8, "z": 10.2},
        {"time": 0.8, "x": 0.2, "y": 0.1, "z": 9.9}
      ],
      "gyroscope": [
        {"time": 0.0, "x": 0.01, "y": 0.02, "z": 0.01},
        {"time": 0.1, "x": 0.15, "y": 0.12, "z": 0.08},
        {"time": 0.2, "x": 0.45, "y": 0.38, "z": 0.22},
        {"time": 0.3, "x": 0.78, "y": 0.65, "z": 0.41},
        {"time": 0.4, "x": 0.92, "y": 0.88, "z": 0.56},
        {"time": 0.5, "x": 0.56, "y": 0.42, "z": 0.33},
        {"time": 0.6, "x": 0.28, "y": 0.19, "z": 0.15},
        {"time": 0.7, "x": 0.08, "y": 0.06, "z": 0.04},
        {"time": 0.8, "x": 0.02, "y": 0.01, "z": 0.01}
      ]
    },
    "weather": {
      "temperature": -5,
      "conditions": "Снег",
      "roadConditions": "Скользко"
    },
    "notes": "Большая яма на правой полосе движения"
  };

  final List<Map<String, dynamic>> relatedImpacts = [
    {
      "id": "impact_002",
      "severity": "moderate",
      "timestamp": "2024-01-15T12:15:30.000Z",
      "distance": 25.5,
      "magnitude": 5.2
    },
    {
      "id": "impact_003",
      "severity": "warning",
      "timestamp": "2024-01-14T16:45:12.000Z",
      "distance": 78.3,
      "magnitude": 3.8
    },
    {
      "id": "impact_004",
      "severity": "critical",
      "timestamp": "2024-01-13T09:22:45.000Z",
      "distance": 92.1,
      "magnitude": 9.1
    }
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  void _showMoreActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text('Редактировать заметки'),
              onTap: () {
                Navigator.pop(context);
                _editNotes();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: AppTheme.warningLight,
                size: 24,
              ),
              title: Text('Отметить как ложное срабатывание'),
              onTap: () {
                Navigator.pop(context);
                _markAsFalsePositive();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report_problem',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: Text('Сообщить о проблеме дороги'),
              onTap: () {
                Navigator.pop(context);
                _reportRoadIssue();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'navigation',
                color: AppTheme.accentLight,
                size: 24,
              ),
              title: Text('Навигация к месту удара'),
              onTap: () {
                Navigator.pop(context);
                _navigateToLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareImpact() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Отчет об ударе экспортирован в PDF'),
        action: SnackBarAction(
          label: 'Поделиться',
          onPressed: () {},
        ),
      ),
    );
  }

  void _editNotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактировать заметки'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Добавьте заметки об ударе...',
          ),
          maxLines: 3,
          controller: TextEditingController(text: impactData["notes"]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Заметки сохранены')),
              );
            },
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _markAsFalsePositive() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ложное срабатывание'),
        content: Text(
            'Отметить этот удар как ложное срабатывание? Это поможет улучшить точность обнаружения.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Удар отмечен как ложное срабатывание')),
              );
            },
            child: Text('Отметить'),
          ),
        ],
      ),
    );
  }

  void _reportRoadIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Отчет о проблеме дороги отправлен в дорожные службы')),
    );
  }

  void _navigateToLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Открытие навигации к месту удара...'),
        action: SnackBarAction(
          label: 'Выбрать приложение',
          onPressed: () {},
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return "${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _showAppBarTitle ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 200),
                      child: Text(
                        'Детали удара',
                        style: AppTheme.lightTheme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _shareImpact,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'share',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showMoreActions,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'more_vert',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with severity and timestamp
                    Row(
                      children: [
                        ImpactSeverityBadgeWidget(
                          severity: impactData["severity"],
                        ),
                        Spacer(),
                        Text(
                          _formatTimestamp(impactData["timestamp"]),
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Map View
                    MapViewWidget(
                      latitude: impactData["location"]["latitude"],
                      longitude: impactData["location"]["longitude"],
                      address: impactData["location"]["address"],
                      accuracy: impactData["location"]["accuracy"],
                    ),
                    SizedBox(height: 24),

                    // Sensor Data Visualization
                    Text(
                      'Данные датчиков',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 16),
                    SensorChartWidget(
                      accelerometerData:
                          (impactData["sensorData"]["accelerometer"] as List)
                              .map((item) => item as Map<String, dynamic>)
                              .toList(),
                      gyroscopeData:
                          (impactData["sensorData"]["gyroscope"] as List)
                              .map((item) => item as Map<String, dynamic>)
                              .toList(),
                    ),
                    SizedBox(height: 24),

                    // Impact Metrics
                    ImpactMetricsWidget(
                      magnitude: impactData["magnitude"],
                      duration: impactData["duration"],
                      vehicleSpeed: impactData["vehicleSpeed"],
                      latitude: impactData["location"]["latitude"],
                      longitude: impactData["location"]["longitude"],
                    ),
                    SizedBox(height: 24),

                    // Weather Conditions
                    WeatherConditionsWidget(
                      temperature: impactData["weather"]["temperature"],
                      conditions: impactData["weather"]["conditions"],
                      roadConditions: impactData["weather"]["roadConditions"],
                    ),
                    SizedBox(height: 24),

                    // Related Impacts
                    RelatedImpactsWidget(
                      impacts: relatedImpacts,
                    ),
                    SizedBox(height: 24),

                    // Notes Section
                    if (impactData["notes"] != null &&
                        (impactData["notes"] as String).isNotEmpty) ...[
                      Text(
                        'Заметки',
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          impactData["notes"],
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
