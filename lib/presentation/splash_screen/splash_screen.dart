import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/splash_loading_widget.dart';
import './widgets/splash_logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _initializationSteps = [
    {
      "id": 1,
      "name": "Инициализация акселерометра",
      "status": "pending",
      "icon": "sensors",
    },
    {
      "id": 2,
      "name": "Проверка гироскопа",
      "status": "pending",
      "icon": "rotate_right",
    },
    {
      "id": 3,
      "name": "Настройка GPS",
      "status": "pending",
      "icon": "location_on",
    },
    {
      "id": 4,
      "name": "Загрузка данных",
      "status": "pending",
      "icon": "storage",
    },
  ];

  int _currentStep = 0;
  bool _hasPermissions = false;
  bool _sensorsAvailable = true;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _logoAnimationController.forward();
  }

  Future<void> _startInitialization() async {
    // Simulate initialization process
    for (int i = 0; i < _initializationSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        setState(() {
          _currentStep = i;
          _initializationSteps[i]["status"] = "completed";
        });
      }

      // Simulate different scenarios
      if (i == 0) {
        // Check accelerometer availability
        _sensorsAvailable = true; // Mock: sensors available
      } else if (i == 2) {
        // Check location services
        _locationEnabled = true; // Mock: location enabled
      } else if (i == 3) {
        // Check permissions
        _hasPermissions = true; // Mock: permissions granted
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (!_sensorsAvailable) {
      _showCompatibilityWarning();
      return;
    }

    if (!_hasPermissions) {
      _fadeAnimationController.forward().then((_) {
        Navigator.pushReplacementNamed(context, '/permission-request-screen');
      });
    } else {
      _fadeAnimationController.forward().then((_) {
        Navigator.pushReplacementNamed(context, '/main-dashboard');
      });
    }
  }

  void _showCompatibilityWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Предупреждение о совместимости',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          content: Text(
            'Ваше устройство не поддерживает необходимые датчики для мониторинга ударов. Приложение может работать в ограниченном режиме.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/main-dashboard');
              },
              child: const Text('Продолжить'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.lightTheme.colorScheme.primary
                      .withOpacity(0.8),
                  AppTheme.lightTheme.colorScheme.secondary,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo Section
                  AnimatedBuilder(
                    animation: _logoScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: SplashLogoWidget(
                          onAnimationComplete: () {},
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 48.h),

                  // App Title
                  Text(
                    'Pothole Impact Tracker',
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'Мониторинг дорожных ударов',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 1),

                  // Loading Section
                  SplashLoadingWidget(
                    initializationSteps: _initializationSteps,
                    currentStep: _currentStep,
                  ),

                  SizedBox(height: 32.h),

                  // Loading Text
                  Text(
                    'Загрузка...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Version Info
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Text(
                      'Версия 1.0.0',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
