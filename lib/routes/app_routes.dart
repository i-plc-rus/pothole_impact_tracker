import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/permission_request_screen/permission_request_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/impact_history/impact_history.dart';
import '../presentation/main_dashboard/main_dashboard.dart';
import '../presentation/impact_detail/impact_detail.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String permissionRequestScreen = '/permission-request-screen';
  static const String mainDashboard = '/main-dashboard';
  static const String impactHistory = '/impact-history';
  static const String impactDetail = '/impact-detail';
  static const String settingsScreen = '/settings-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    permissionRequestScreen: (context) => const PermissionRequestScreen(),
    mainDashboard: (context) => const MainDashboard(),
    impactHistory: (context) => const ImpactHistory(),
    impactDetail: (context) => const ImpactDetail(),
    settingsScreen: (context) => const SettingsScreen(),
  };
}
