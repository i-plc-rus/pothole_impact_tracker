import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_export.dart';
import './widgets/impact_chart_widget.dart';
import './widgets/impact_counter_widget.dart';
import './widgets/location_status_widget.dart';
import './widgets/monitoring_status_widget.dart';
import './widgets/sensor_visualization_widget.dart';
import './widgets/statistics_cards_widget.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;

  double? _latitude;
  double? _longitude;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late StreamSubscription<Position> _positionSubscription;
  late Timer _uploadTimer;

  final String sessionId = const Uuid().v4();

  // Mock data for the dashboard
  final Map<String, dynamic> _dashboardData = {
    "monitoring_status": "active",
    "total_impacts": 1247,
    "today_impacts": 23,
    "severe_impacts": 4,
    "distance_traveled": 156.7,
    "average_speed": 45.2,
    "current_location": "-",
    "last_impact_time": "14:32",
    "battery_level": 85,
    "sensor_data": {
      "accelerometer_x": 0.0,
      "accelerometer_y": 0.0,
      "accelerometer_z": 0.0,
      "threshold": 2.5,
      "z_threshold": 3.0
    },
    "weekly_impacts": [
      // {"date": "18.11.2024", "count": 12},
      // {"date": "19.11.2024", "count": 8},
      // {"date": "20.11.2024", "count": 15},
      // {"date": "21.11.2024", "count": 23},
      // {"date": "22.11.2024", "count": 19},
      // {"date": "23.11.2024", "count": 11},
      // {"date": "24.11.2024", "count": 7}
    ]
  };

  /*Future<void> _updateLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

  setState(() {
    _latitude = position.latitude;
    _longitude = position.longitude;
    _dashboardData["current_location"] = '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}';
  });
}*/

/*void _startLocationUpdates() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  LocationPermission permission = await Geolocator.checkPermission();

  if (!serviceEnabled) return;

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
  }

  if (permission == LocationPermission.deniedForever) return;

  _positionSubscription = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // минимальное расстояние в метрах до нового события
    ),
  ).listen((Position position) {
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _dashboardData["current_location"] =
          '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}';
    });
  });
}*/

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _initSensors();
    _startUploadTimer();
  }

  Future<bool> checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Можно показать сообщение пользователю
      debugPrint("GPS is disabled.");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permission denied.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Location permission permanently denied.");
      return false;
    }

    return true;
  }

  Future<void> _initSensors() async {
    bool hasPermission = await checkAndRequestLocationPermission();
    if (!hasPermission) return;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((Position pos) {
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _dashboardData["current_location"] =
            "${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}";
      });
      LocalDatabase.insertData({
        "session_id": sessionId,
        "date_upd": DateTime.now().toIso8601String(),
        "latitude": pos.latitude,
        "longitude": pos.longitude,
        "accel_x": null,
        "accel_y": null,
        "accel_z": null,
      });
    });

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        _accelX = event.x;
        _accelY = event.y;
        _accelZ = event.z;
        _dashboardData["sensor_data"] = {
          "accelerometer_x": _accelX,
          "accelerometer_y": _accelY,
          "accelerometer_z": _accelZ,
          "threshold": 2.5,
          "z_threshold": 3.0
        };
      });
      LocalDatabase.insertData({
        "session_id": sessionId,
        "date_upd": DateTime.now().toIso8601String(),
        "latitude": null,
        "longitude": null,
        "accel_x": event.x,
        "accel_y": event.y,
        "accel_z": event.z,
      });
    });
  }

  void _startUploadTimer() {
    _uploadTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final batch = await LocalDatabase.fetchBatchAndClear();
      if (batch.isEmpty) return;

      final payload = {
        "session_id": sessionId,
        "data": batch,
      };

      try {
        final response = await http.post(
          Uri.parse("https://functions.yandexcloud.net/d4eb4avo8k55c98u2eh9"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );
        debugPrint("Upload status: ${response.statusCode}");
      } catch (e) {
        debugPrint("Upload failed: $e");
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accelerometerSubscription.cancel();
    _positionSubscription.cancel();
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
    Navigator.pushNamed(context as BuildContext, '/settings-screen');
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
            onPressed: () =>
                Navigator.pushNamed(context as BuildContext, '/impact-history'),
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
            onPressed: () => Navigator.pushNamed(
                context as BuildContext, '/settings-screen'),
            child: const Text('Открыть настройки'),
          ),
        ],
      ),
    );
  }
}

class LocalDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sensor_data.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE sensor_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id TEXT,
          date_upd TEXT,
          latitude REAL,
          longitude REAL,
          accel_x REAL,
          accel_y REAL,
          accel_z REAL
        )
      ''');
    });
    return _db!;
  }

  static Future<void> insertData(Map<String, dynamic> data) async {
    final db = await instance;
    await db.insert('sensor_log', data);
  }

  static Future<List<Map<String, dynamic>>> fetchBatchAndClear() async {
    final db = await instance;
    final data = await db.query('sensor_log');
    await db.delete('sensor_log');
    return data;
  }
}
