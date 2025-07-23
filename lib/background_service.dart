import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;
import './presentation/main_dashboard/main_dashboard.dart'; // ваш класс LocalDatabase


Future<void> initializeService(String sessionId) async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      initialNotificationTitle: 'Сбор телеметрии',
      initialNotificationContent: 'Сбор данных для телеметрии запущен',
    ),
    iosConfiguration: IosConfiguration(),
  );

  // передаём sessionId в isolate
  service.startService();
  service.invoke('setSession', {'sessionId': sessionId});
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  String? sessionId;

  service.on('setSession').listen((event) {
    sessionId = event?['sessionId'];
  });

  Timer.periodic(const Duration(seconds: 10), (_) async {
    if (sessionId == null) return;

    final allData = await LocalDatabase.fetchBatch();
    if (allData.isEmpty) {
      debugPrint("Нет данных для отправки");
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
          Uri.parse("https://functions.yandexcloud.net/d4eb4avo8k55c98u2eh9"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );

        debugPrint("Ответ сервера: ${response.statusCode}");

        if (response.statusCode == 200) {
          final idsToDelete = chunk.map((e) => e['id'] as int).toList();
          await LocalDatabase.deleteBatch(idsToDelete);
        } else {
          debugPrint("Ошибка ответа: ${response.body}");
          break; // остановись, чтобы не удалять последующие, если API не принимает
        }

      } catch (e) {
        debugPrint("Ошибка отправки: $e");
        break; // остановись, если сеть не работает
      }
    }

  });
}