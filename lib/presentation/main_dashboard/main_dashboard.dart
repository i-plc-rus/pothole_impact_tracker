import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

import '../../../core/app_export.dart';
import './widgets/impact_chart_widget.dart';
import './widgets/impact_counter_widget.dart';
import './widgets/location_status_widget.dart';
import './widgets/monitoring_status_widget.dart';
import './widgets/sensor_visualization_widget.dart';
import './widgets/statistics_cards_widget.dart';




class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isMonitoring = true;
  bool _isRefreshing = false;

  // Подписка на акселерометр
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;

  // Mock data for the dashboard
  final Map<String, dynamic> _dashboardData = {
    "monitoring_status": "active",
    "total_impacts": 1247,
    "today_impacts": 23,
    "severe_impacts": 4,
    "distance_traveled": 156.7,
    "average_speed": 45.2,
    "current_location": "Москва, Россия",
    "last_impact_time": "14:32",
    "battery_level": 85,
    "sensor_data": {
      "accelerometer_x": 0.0,
      "accelerometer_y": 0.0,
      "accelerometer_z": 0.0,
      "threshold": 2.5
    },
    "weekly_impacts": [
      {"date": "18.11.2024", "count": 12},
      {"date": "19.11.2024", "count": 8},
      {"date": "20.11.2024", "count": 15},
      {"date": "21.11.2024", "count": 23},
      {"date": "22.11.2024", "count": 19},
      {"date": "23.11.2024", "count": 11},
      {"date": "24.11.2024", "count": 7}
    ]
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      setState(() {
        _accelX = event.x;
        _accelY = event.y;
        _accelZ = event.z;

        _dashboardData["sensor_data"] = {
          "accelerometer_x": _accelX,
          "accelerometer_y": _accelY,
          "accelerometer_z": _accelZ,
          "threshold": 2.5
        };
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      // Update mock data with new values
      _dashboardData["today_impacts"] =
          (_dashboardData["today_impacts"] as int) + 1;
      _dashboardData["total_impacts"] =
          (_dashboardData["total_impacts"] as int) + 1;
    });
  }

  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;
      _dashboardData["monitoring_status"] = _isMonitoring ? "active" : "paused";
    });
  }

  void _navigateToCalibration() {
    Navigator.pushNamed(context, '/settings-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              color: AppTheme.lightTheme.cardColor,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Панель'),
                  Tab(text: 'История'),
                  Tab(text: 'Настройки'),
                ],
              ),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildHistoryTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCalibration,
        child: CustomIconWidget(
          iconName: 'tune',
          color: AppTheme.lightTheme.colorScheme.onSecondary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monitoring Status
            MonitoringStatusWidget(
              isMonitoring: _isMonitoring,
              onToggle: _toggleMonitoring,
              batteryLevel: _dashboardData["battery_level"] as int,
            ),
            const SizedBox(height: 24),

            // Impact Counter
            ImpactCounterWidget(
              totalImpacts: _dashboardData["total_impacts"] as int,
              todayImpacts: _dashboardData["today_impacts"] as int,
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            StatisticsCardsWidget(
              todayImpacts: _dashboardData["today_impacts"] as int,
              severeImpacts: _dashboardData["severe_impacts"] as int,
              distanceTraveled: _dashboardData["distance_traveled"] as double,
              averageSpeed: _dashboardData["average_speed"] as double,
            ),
            const SizedBox(height: 24),

            // Impact Chart
            ImpactChartWidget(
              weeklyData: (_dashboardData["weekly_impacts"] as List)
                  .map((item) => item as Map<String, dynamic>)
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Sensor Visualization
            SensorVisualizationWidget(
              sensorData: _dashboardData["sensor_data"] as Map<String, dynamic>,
            ),
            const SizedBox(height: 24),

            // Location Status
            LocationStatusWidget(
              currentLocation: _dashboardData["current_location"] as String,
              lastImpactTime: _dashboardData["last_impact_time"] as String,
            ),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'История ударов',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь будет отображаться\nистория зафиксированных ударов',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/impact-history'),
            child: const Text('Открыть историю'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Настройки',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Калибровка датчиков\nи настройки приложения',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
            child: const Text('Открыть настройки'),
          ),
        ],
      ),
    );
  }
}
