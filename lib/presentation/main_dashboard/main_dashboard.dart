import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_export.dart';
import './widgets/location_status_widget.dart';
import './widgets/monitoring_status_widget.dart';
import './widgets/sensor_visualization_widget.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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

  double _gyroscopeX = 0.0;
  double _gyroscopeY = 0.0;
  double _gyroscopeZ = 0.0;

  double _magnetometerX = 0.0;
  double _magnetometerY = 0.0;
  double _magnetometerZ = 0.0;


  double? _latitude;
  double? _longitude;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<Position>? _positionSubscription;
  //late Timer _uploadTimer;
  late Timer _uploadTimerLocation;
  late Timer _uploadTimerAccelerometer;
  late Timer _uploadTimerGyroscope;
  late Timer _uploadTimerMagnetometer;

  //final String sessionId = const Uuid().v4();
  late final String sessionId;

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
      "z_threshold": 3.0,
      "gyroscope_x": 0.0,
      "gyroscope_y": 0.0,
      "gyroscope_z": 0.0,
      "magnetometer_x": 0.0,
      "magnetometer_y": 0.0,
      "magnetometer_z": 0.0,
    },
    "weekly_impacts": [
      {"date": "18.06.2025", "count": 12},
      {"date": "19.06.2025", "count": 8},
      {"date": "20.06.2025", "count": 15},
    ]
  };

  List<Map<String, dynamic>> _gyroBuffer = [];
  List<Map<String, dynamic>> _accelerometerBuffer = [];
  List<Map<String, dynamic>> _locationBuffer = [];
  List<Map<String, dynamic>> _magnetometerBuffer = [];



  @override
  void initState() {
    super.initState();
    SessionManager.getSessionId().then((id) {
      sessionId = id;
      _initSensors();
    });

    _tabController = TabController(length: 1, vsync: this);
    WakelockPlus.enable();

    _startUploadTimerLocation();
    _startUploadTimerAccelerometer();
    _startUploadTimerGyroscope();
    _startUploadTimerMagnetometer();
    //_startUploadTimerGyroscope();

    _startGyroBufferUploader();
    _startLocationBufferUploader();
    _startAccelerometerBufferUploader();
    _startMagnetometerBufferUploader();

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      _startUploadTimerLocation();
      _startUploadTimerAccelerometer();
      _startUploadTimerGyroscope();
      _startUploadTimerMagnetometer();
    });*/
  }

  Future<bool> checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, включите GPS')),
      );
      debugPrint("GPS is disabled.");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Разрешение на геолокацию отклонено')),
        );
        debugPrint("Location permission denied.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Разрешение на геолокацию отклонено навсегда')),
      );
      debugPrint("Location permission permanently denied.");
      return false;
    }

    return true;
  }

  void _startGyroBufferUploader() {
    Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_gyroBuffer.isEmpty) return;

      final db = await LocalDatabase.instance;
      final batch = db.batch();

      for (var entry in _gyroBuffer) {
        batch.insert('gyroscope_data', entry);
      }

      try {
        await batch.commit(noResult: true);
        _gyroBuffer.clear();
      } catch (e) {
        print("Gyro batch insert error: $e");
      }
    });
  }

  void _startLocationBufferUploader() {
    Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_locationBuffer.isEmpty) return;

      final db = await LocalDatabase.instance;
      final batch = db.batch();

      for (var entry in _locationBuffer) {
        batch.insert('location_data', entry);
      }

      try {
        await batch.commit(noResult: true);
        _locationBuffer.clear();
      } catch (e) {
        print("Location batch insert error: $e");
      }
    });
  }

  void _startAccelerometerBufferUploader() {
    Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_accelerometerBuffer.isEmpty) return;

      final db = await LocalDatabase.instance;
      final batch = db.batch();

      for (var entry in _accelerometerBuffer) {
        batch.insert('accelerometer_data', entry);
      }

      try {
        await batch.commit(noResult: true);
        _accelerometerBuffer.clear();
      } catch (e) {
        print("Accelerometer batch insert error: $e");
      }
    });
  }

  void _startMagnetometerBufferUploader() {
    Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_magnetometerBuffer.isEmpty) return;

      final db = await LocalDatabase.instance;
      final batch = db.batch();

      for (var entry in _magnetometerBuffer) {
        batch.insert('magnetometer_data', entry);
      }

      try {
        await batch.commit(noResult: true);
        _magnetometerBuffer.clear();
      } catch (e) {
        print("Magnetometer batch insert error: $e");
      }
    });
  }

  Future<void> _initSensors() async {
    bool hasPermission = await checkAndRequestLocationPermission();
    if (!hasPermission) return;

    if (_accelerometerSubscription != null ||
        _gyroscopeSubscription != null ||
        _magnetometerSubscription != null ||
        _positionSubscription != null) {
      return;
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        timeLimit: null,
      ),
    ).listen((Position pos) {
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _dashboardData["current_location"] =
        "${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}";
      });

      LocalDatabase.insertLocation({
        "session_id": sessionId,
        "date_upd": DateTime.now().toUtc().toIso8601String(),
        "latitude": pos.latitude,
        "longitude": pos.longitude,
        "accuracy": pos.accuracy,
        "speed": pos.speed,
        "heading": pos.heading,
      });
    });

    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      setState(() {
        _gyroscopeX = event.x;
        _gyroscopeY = event.y;
        _gyroscopeZ = event.z;
        _dashboardData["sensor_data"] = {
          "accelerometer_x": _accelX,
          "accelerometer_y": _accelY,
          "accelerometer_z": _accelZ,
          "threshold": 2.5,
          "z_threshold": 3.0,
          "gyroscope_x": _gyroscopeX,
          "gyroscope_y": _gyroscopeY,
          "gyroscope_z": _gyroscopeZ,
          "magnetometer_x": _magnetometerX,
          "magnetometer_y": _magnetometerY,
          "magnetometer_z": _magnetometerZ,
        };
      });
      _gyroBuffer.add({
        "session_id": sessionId,
        "date_upd": DateTime.now().toUtc().toIso8601String(),
        "gyroscope_x": _gyroscopeX,
        "gyroscope_y": _gyroscopeY,
        "gyroscope_z": _gyroscopeZ,
      });
      /*LocalDatabase.insertGyroscope({
        "session_id": sessionId,
        "date_upd": DateTime.now().toUtc().toIso8601String(),
        "gyroscope_x": _gyroscopeX,
        "gyroscope_y": _gyroscopeY,
        "gyroscope_z": _gyroscopeZ,
      });*/
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
          "z_threshold": 3.0,
          "gyroscope_x": _gyroscopeX,
          "gyroscope_y": _gyroscopeY,
          "gyroscope_z": _gyroscopeZ,
          "magnetometer_x": _magnetometerX,
          "magnetometer_y": _magnetometerY,
          "magnetometer_z": _magnetometerZ,
        };
      });
      _accelerometerBuffer.add({
        "session_id": sessionId,
        "date_upd": DateTime.now().toUtc().toIso8601String(),
        "accel_x": _accelX,
        "accel_y": _accelY,
        "accel_z": _accelZ,
      });
      // Insert combined data
      /*LocalDatabase.insertAccelerometer({
        "session_id": sessionId,
        "date_upd": DateTime.now().toUtc().toIso8601String(),
        "accel_x": _accelX,
        "accel_y": _accelY,
        "accel_z": _accelZ,
      });*/
    });

    _magnetometerSubscription = magnetometerEventStream().listen((event) {
      setState(() {
        _magnetometerX = event.x;
        _magnetometerY = event.y;
        _magnetometerZ = event.z;
        _dashboardData["sensor_data"] = {
          "accelerometer_x": _accelX,
          "accelerometer_y": _accelY,
          "accelerometer_z": _accelZ,
          "threshold": 2.5,
          "z_threshold": 3.0,
          "gyroscope_x": _gyroscopeX,
          "gyroscope_y": _gyroscopeY,
          "gyroscope_z": _gyroscopeZ,
          "magnetometer_x": _magnetometerX,
          "magnetometer_y": _magnetometerY,
          "magnetometer_z": _magnetometerZ,
        };
      });
      _magnetometerBuffer.add({
        "session_id": sessionId,
        "date_upd": DateTime.now().toUtc().toIso8601String(),
        "magnetometer_x": _magnetometerX,
        "magnetometer_y": _magnetometerY,
        "magnetometer_z": _magnetometerZ,
      });
      /*LocalDatabase.insertMagnetometer({
        "session_id": sessionId,
        "date_upd": DateTime.now().toUtc().toIso8601String(),
        "magnetometer_x": _magnetometerX,
        "magnetometer_y": _magnetometerY,
        "magnetometer_z": _magnetometerZ,
      });*/
    });

    /*_startUploadTimerLocation();
    _startUploadTimerAccelerometer();
    _startUploadTimerGyroscope();
    _startUploadTimerMagnetometer();*/
  }

  void _stopSensors() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _positionSubscription?.cancel();

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _magnetometerSubscription = null;
    _positionSubscription = null;
  }


  void _startUploadTimerLocation() {
    //return;
    //if (_uploadTimerLocation != null && _uploadTimerLocation!.isActive) return;
    _uploadTimerLocation = Timer.periodic(const Duration(seconds: 2), (_) async {
      //debugPrint("Таймер загрузки…");

      final allData = await LocalDatabase.fetchLocationBatch();
      if (allData.isEmpty) {
        debugPrint("Нет данных для отправки Location");
        return;
      }

      const batchSize = 1000;
      for (var i = 0; i < allData.length; i += batchSize) {
        final chunk = allData.sublist(
          i,
          (i + batchSize > allData.length) ? allData.length : i + batchSize,
        );

        final payload = {
          "session_id": sessionId,
          "data": chunk,
        };

        try {
          final response = await http.post(
            Uri.parse("https://functions.yandexcloud.net/d4e729sngmomsjms6dpn"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          );

          debugPrint("Ответ сервера Location: ${response.statusCode}");

          if (response.statusCode == 200) {
            final idsToDelete = chunk.map((e) => e['id'] as int).toList();
            await LocalDatabase.deleteLocationBatch(idsToDelete);
          } else {
            debugPrint("Ошибка ответа Location: ${response.body}");
            break; // остановись, чтобы не удалять последующие, если API не принимает
          }

        } catch (e) {
          debugPrint("Ошибка отправки Location: $e");
          break; // остановись, если сеть не работает
        }
      }
    });
  }

  void _startUploadTimerAccelerometer() {
    //return;
    //if (_uploadTimerAccelerometer != null && _uploadTimerAccelerometer!.isActive) return;
    _uploadTimerAccelerometer = Timer.periodic(const Duration(seconds: 3), (_) async {
      //debugPrint("Таймер загрузки…");

      final allData = await LocalDatabase.fetchAccelerometerBatch();
      if (allData.isEmpty) {
        debugPrint("Нет данных для отправки Accelerometer");
        return;
      }

      const batchSize = 1000;
      for (var i = 0; i < allData.length; i += batchSize) {
        final chunk = allData.sublist(
          i,
          (i + batchSize > allData.length) ? allData.length : i + batchSize,
        );

        final payload = {
          "session_id": sessionId,
          "data": chunk,
        };

        try {
          final response = await http.post(
            Uri.parse("https://functions.yandexcloud.net/d4emkf3qdd4j8bgl8l49"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          );

          debugPrint("Ответ сервера Accelerometer: ${response.statusCode}");

          if (response.statusCode == 200) {
            final idsToDelete = chunk.map((e) => e['id'] as int).toList();
            await LocalDatabase.deleteAccelerometerBatch(idsToDelete);
          } else {
            //debugPrint("Ошибка ответа: ${response.body}");
            break; // остановись, чтобы не удалять последующие, если API не принимает
          }

        } catch (e) {
          debugPrint("Ошибка отправки Accelerometer: $e");
          break; // остановись, если сеть не работает
        }
      }
    });
  }

  void _startUploadTimerGyroscope() {
    //if (_uploadTimerGyroscope != null && _uploadTimerGyroscope!.isActive) return;
    _uploadTimerGyroscope = Timer.periodic(const Duration(seconds: 4), (_) async {
      //debugPrint("Таймер загрузки…");

      final allData = await LocalDatabase.fetchGyroscopeBatch();
      if (allData.isEmpty) {
        debugPrint("Нет данных для отправки Gyroscope");
        return;
      }

      const batchSize = 1000;
      for (var i = 0; i < allData.length; i += batchSize) {
        final chunk = allData.sublist(
          i,
          (i + batchSize > allData.length) ? allData.length : i + batchSize,
        );

        final payload = {
          "session_id": sessionId,
          "data": chunk,
        };

        try {
          final response = await http.post(
            Uri.parse("https://functions.yandexcloud.net/d4e34tf4209tbooi34g8"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          );

          debugPrint("Ответ сервера Gyroscope: ${response.statusCode}");

          if (response.statusCode == 200) {
            final idsToDelete = chunk.map((e) => e['id'] as int).toList();
            await LocalDatabase.deleteGyroscopeBatch(idsToDelete);
          } else {
            debugPrint("Ошибка ответа Gyroscope: ${response.body}");
            break; // остановись, чтобы не удалять последующие, если API не принимает
          }

        } catch (e) {
          debugPrint("Ошибка отправки Gyroscope: $e");
          break; // остановись, если сеть не работает
        }
      }
    });
  }


  void _startUploadTimerMagnetometer() {
    //return;
    //if (_uploadTimerMagnetometer != null && _uploadTimerMagnetometer!.isActive) return;
    _uploadTimerMagnetometer = Timer.periodic(const Duration(seconds: 5), (_) async {
      //debugPrint("Таймер загрузки…");

      final allData = await LocalDatabase.fetchMagnetometerBatch();
      if (allData.isEmpty) {
        debugPrint("Нет данных для отправки Magnetometer");
        return;
      }

      const batchSize = 1000;
      for (var i = 0; i < allData.length; i += batchSize) {
        final chunk = allData.sublist(
          i,
          (i + batchSize > allData.length) ? allData.length : i + batchSize,
        );

        final payload = {
          "session_id": sessionId,
          "data": chunk,
        };

        try {
          final response = await http.post(
            Uri.parse("https://functions.yandexcloud.net/d4e75bmf64h4r2v986fq"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          );

          debugPrint("Ответ сервера Magnetometer: ${response.statusCode}");

          if (response.statusCode == 200) {
            final idsToDelete = chunk.map((e) => e['id'] as int).toList();
            await LocalDatabase.deleteMagnetometerBatch(idsToDelete);
          } else {
            debugPrint("Ошибка ответа Magnetometer: ${response.body}");
            break; // остановись, чтобы не удалять последующие, если API не принимает
          }

        } catch (e) {
          debugPrint("Ошибка отправки Magnetometer: $e");
          break; // остановись, если сеть не работает
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _positionSubscription?.cancel();
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

    if (_isMonitoring) {
      _initSensors();
    } else {
      _stopSensors();
    }
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
                  Tab(text: 'Датчики'),
                  /*Tab(text: 'История'),
                  Tab(text: 'Настройки'),*/
                ],
              ),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  //_buildHistoryTab(),
                  //_buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          debugPrint('debug'); // Log the data
          /*final batch = await LocalDatabase.fetchBatch();
          debugPrint('Fetched batch: $batch'); // Log the data
          final message = "Записей: ${batch.length}";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 4),
            ),
          );*/
        },
        child: const Icon(Icons.bug_report),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCalibration,
        child: CustomIconWidget(
          iconName: 'tune',
          color: AppTheme.lightTheme.colorScheme.onSecondary,
          size: 24,
        ),
      ),*/
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


}

class LocalDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sensor_data_1_1_8.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE accelerometer_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id TEXT,
          date_upd TEXT,
          accel_x REAL,
          accel_y REAL,
          accel_z REAL
        )
      ''');
      await db.execute('''
        CREATE TABLE gyroscope_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id TEXT,
          date_upd TEXT,
          gyroscope_x REAL,
          gyroscope_y REAL,
          gyroscope_z REAL
        )
      ''');
      await db.execute('''
        CREATE TABLE magnetometer_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id TEXT,
          date_upd TEXT,          
          magnetometer_x REAL,
          magnetometer_y REAL,
          magnetometer_z REAL
        )
      ''');
      await db.execute('''
        CREATE TABLE location_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id TEXT,
          date_upd TEXT,
          latitude REAL,
          longitude REAL,
          accuracy REAL,
          speed REAL,
          heading REAL
        )
      ''');

    });
    return _db!;
  }

  static Future<void> insertAccelerometer(Map<String, dynamic> data) async {
    final db = await instance;
    await db.insert('accelerometer_data', data);
  }

  static Future<void> insertGyroscope(Map<String, dynamic> data) async {
    final db = await instance;
    await db.insert('gyroscope_data', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertMagnetometer(Map<String, dynamic> data) async {
    final db = await instance;
    await db.insert('magnetometer_data', data);
  }
  static Future<void> insertLocation(Map<String, dynamic> data) async {
    final db = await instance;
    await db.insert('location_data', data);
  }

  static Future<List<Map<String, dynamic>>> fetchAccelerometerBatch() async {
    final db = await instance;
    return db.query('accelerometer_data');
  }
  static Future<List<Map<String, dynamic>>> fetchGyroscopeBatch() async {
    final db = await instance;
    return db.query('gyroscope_data');
  }
  static Future<List<Map<String, dynamic>>> fetchMagnetometerBatch() async {
    final db = await instance;
    return db.query('magnetometer_data');
  }
  static Future<List<Map<String, dynamic>>> fetchLocationBatch() async {
    final db = await instance;
    return db.query('location_data');
  }

  static Future<void> deleteAccelerometerBatch(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await instance;
    final idList = ids.join(',');
    await db.rawDelete('DELETE FROM accelerometer_data WHERE id IN ($idList)');
  }

  static Future<void> deleteGyroscopeBatch(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await instance;
    final idList = ids.join(',');
    await db.rawDelete('DELETE FROM gyroscope_data WHERE id IN ($idList)');
  }

  static Future<void> deleteMagnetometerBatch(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await instance;
    final idList = ids.join(',');
    await db.rawDelete('DELETE FROM magnetometer_data WHERE id IN ($idList)');
  }

  static Future<void> deleteLocationBatch(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await instance;
    final idList = ids.join(',');
    await db.rawDelete('DELETE FROM location_data WHERE id IN ($idList)');
  }

}


class SessionManager {
  static const _key = 'session_id';

  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null) return existing;

    final newId = const Uuid().v4();
    await prefs.setString(_key, newId);
    return newId;
  }
}