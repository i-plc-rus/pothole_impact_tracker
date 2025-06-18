import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import './widgets/automotive_icon_widget.dart';
import './widgets/permission_card_widget.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  // Mock permission data
  final List<Map<String, dynamic>> permissionData = [
    {
      "id": 1,
      "title": "Службы геолокации",
      "description":
          "Необходимо для картирования ударов и определения местоположения повреждений дорожного покрытия",
      "iconName": "location_on",
      "isGranted": false,
      "isRequired": true,
    },
    {
      "id": 2,
      "title": "Доступ к датчикам",
      "description":
          "Акселерометр и гироскоп для мониторинга ударов подвески и вибраций автомобиля",
      "iconName": "sensors",
      "isGranted": false,
      "isRequired": true,
    },
    {
      "id": 3,
      "title": "Фоновая обработка",
      "description":
          "Непрерывная работа для постоянного мониторинга состояния дороги во время поездки",
      "iconName": "settings_applications",
      "isGranted": false,
      "isRequired": true,
    },
    {
      "id": 4,
      "title": "Оптимизация батареи",
      "description":
          "Исключение из режима энергосбережения для стабильной работы датчиков",
      "iconName": "battery_charging_full",
      "isGranted": false,
      "isRequired": true,
    },
  ];

  bool _isProcessing = false;
  double _progressValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    AutomotiveIconWidget(),
                    const SizedBox(height: 32),
                    _buildPermissionsList(),
                    const SizedBox(height: 24),
                    _buildProgressIndicator(),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/splash-screen'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Настройки разрешений',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Необходимые разрешения',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Для корректной работы мониторинга ударов требуются следующие разрешения:',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: permissionData.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final permission = permissionData[index];
            return PermissionCardWidget(
              title: permission["title"] as String,
              description: permission["description"] as String,
              iconName: permission["iconName"] as String,
              isGranted: permission["isGranted"] as bool,
              isRequired: permission["isRequired"] as bool,
              onToggle: () => _handleIndividualPermission(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final grantedCount =
        permissionData.where((p) => (p["isGranted"] as bool)).length;
    final totalCount = permissionData.length;
    final progress = totalCount > 0 ? grantedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Прогресс настройки',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$grantedCount/$totalCount',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _isProcessing ? _progressValue : progress,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.secondary,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            progress == 1.0
                ? 'Все разрешения настроены'
                : 'Требуется настройка ${totalCount - grantedCount} разрешений',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final allGranted = permissionData.every((p) => p["isGranted"] as bool);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () => _handleGrantAllPermissions(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: allGranted
                  ? AppTheme.lightTheme.colorScheme.tertiary
                  : AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Настройка разрешений...',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    allGranted ? 'Продолжить' : 'Разрешить все',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isProcessing ? null : () => _handleSkip(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Пропустить',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleIndividualPermission(int index) async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate permission request delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      permissionData[index]["isGranted"] =
          !(permissionData[index]["isGranted"] as bool);
      _isProcessing = false;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleGrantAllPermissions(BuildContext context) async {
    final allGranted = permissionData.every((p) => p["isGranted"] as bool);

    if (allGranted) {
      // Navigate to dashboard if all permissions are already granted
      HapticFeedback.mediumImpact();
      Navigator.pushNamed(context, '/main-dashboard');
      return;
    }

    setState(() {
      _isProcessing = true;
      _progressValue = 0.0;
    });

    // Simulate sequential permission requests
    for (int i = 0; i < permissionData.length; i++) {
      if (!(permissionData[i]["isGranted"] as bool)) {
        await Future.delayed(const Duration(milliseconds: 600));

        setState(() {
          permissionData[i]["isGranted"] = true;
          _progressValue = (i + 1) / permissionData.length;
        });

        HapticFeedback.selectionClick();
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isProcessing = false;
    });

    // Success haptic feedback
    HapticFeedback.mediumImpact();

    // Navigate to dashboard
    Navigator.pushNamed(context, '/main-dashboard');
  }

  void _handleSkip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Ограниченная функциональность',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Без необходимых разрешений приложение будет работать с ограниченной функциональностью:\n\n• Отсутствие мониторинга ударов\n• Нет данных о местоположении\n• Ограниченная статистика\n\nВы можете настроить разрешения позже в настройках.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/main-dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Продолжить'),
            ),
          ],
        );
      },
    );
  }
}
