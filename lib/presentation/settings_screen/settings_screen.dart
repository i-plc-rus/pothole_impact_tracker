import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calibration_modal_widget.dart';
import './widgets/confirmation_dialog_widget.dart';
import './widgets/settings_section_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Settings state variables
  double _sensitivity = 0.7;
  bool _backgroundOperation = true;
  bool _notificationsEnabled = true;
  bool _locationHistory = true;
  bool _darkMode = false;
  bool _metricUnits = true;
  String _gpsAccuracy = 'Высокая';

  // Mock data for settings
  final List<Map<String, dynamic>> _settingsData = [
    {
      "version": "1.2.3",
      "sensorStatus": "Совместимо",
      "storageUsed": "45.2 МБ",
      "totalStorage": "100 МБ",
      "supportEmail": "support@potholetracker.ru"
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCalibrationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalibrationModalWidget(
        currentSensitivity: _sensitivity,
        onSensitivityChanged: (value) {
          setState(() {
            _sensitivity = value;
          });
        },
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialogWidget(
        title: 'Очистить данные',
        message:
            'Вы уверены, что хотите удалить все данные об ударах? Это действие нельзя отменить.',
        confirmText: 'Удалить',
        cancelText: 'Отмена',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Данные успешно очищены')),
          );
        },
      ),
    );
  }

  void _exportData(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Экспорт данных в формате \$format начат')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = _settingsData.first;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Настройки',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Мониторинг'),
            Tab(text: 'Настройки'),
            Tab(text: 'О программе'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMonitoringTab(),
            _buildSettingsTab(appData),
            _buildAboutTab(appData),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        children: [
          SettingsSectionWidget(
            title: 'Калибровка датчиков',
            children: [
              ListTile(
                title: Text(
                  'Чувствительность',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Текущий уровень: ${(_sensitivity * 100).toInt()}%',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: SizedBox(
                  width: 120.sp,
                  child: Slider(
                    value: _sensitivity,
                    onChanged: (value) {
                      setState(() {
                        _sensitivity = value;
                      });
                    },
                    divisions: 10,
                    label: '${(_sensitivity * 100).toInt()}%',
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Мастер калибровки',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Настройка чувствительности с тестированием',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'tune',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 24,
                ),
                onTap: _showCalibrationModal,
              ),
            ],
          ),
          SizedBox(height: 16.sp),
          SettingsSectionWidget(
            title: 'Параметры мониторинга',
            children: [
              SwitchListTile(
                title: Text(
                  'Фоновая работа',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Мониторинг при свернутом приложении',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                value: _backgroundOperation,
                onChanged: (value) {
                  setState(() {
                    _backgroundOperation = value;
                  });
                },
              ),
              ListTile(
                title: Text(
                  'Оптимизация батареи',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Настройки энергосбережения',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Переход к настройкам системы')),
                  );
                },
              ),
              SwitchListTile(
                title: Text(
                  'Уведомления',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Оповещения о сильных ударах',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(Map<String, dynamic> appData) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        children: [
          SettingsSectionWidget(
            title: 'Управление данными',
            children: [
              ListTile(
                title: Text(
                  'Экспорт в CSV',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Сохранить данные в таблицу',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'file_download',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 24,
                ),
                onTap: () => _exportData('CSV'),
              ),
              ListTile(
                title: Text(
                  'Экспорт в PDF',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Создать отчет в PDF',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'picture_as_pdf',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 24,
                ),
                onTap: () => _exportData('PDF'),
              ),
              ListTile(
                title: Text(
                  'Использование памяти',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  '${appData["storageUsed"]} из ${appData["totalStorage"]}',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'storage',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              ListTile(
                title: Text(
                  'Очистить данные',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
                subtitle: Text(
                  'Удалить все записи об ударах',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 24,
                ),
                onTap: _showClearDataDialog,
              ),
            ],
          ),
          SizedBox(height: 16.sp),
          SettingsSectionWidget(
            title: 'Настройки местоположения',
            children: [
              ListTile(
                title: Text(
                  'Точность GPS',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  _gpsAccuracy,
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                onTap: () {
                  _showGpsAccuracyDialog();
                },
              ),
              SwitchListTile(
                title: Text(
                  'История местоположений',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Сохранять координаты ударов',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                value: _locationHistory,
                onChanged: (value) {
                  setState(() {
                    _locationHistory = value;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16.sp),
          SettingsSectionWidget(
            title: 'Отображение',
            children: [
              SwitchListTile(
                title: Text(
                  'Темная тема',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Переключить на темное оформление',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
              ListTile(
                title: Text(
                  'Язык',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Русский',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'language',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              SwitchListTile(
                title: Text(
                  'Метрические единицы',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'км/ч, метры, килограммы',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                value: _metricUnits,
                onChanged: (value) {
                  setState(() {
                    _metricUnits = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(Map<String, dynamic> appData) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        children: [
          SettingsSectionWidget(
            title: 'Информация о приложении',
            children: [
              ListTile(
                title: Text(
                  'Версия приложения',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  appData["version"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              ListTile(
                title: Text(
                  'Совместимость датчиков',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  appData["sensorStatus"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                  ),
                ),
                trailing: CustomIconWidget(
                  iconName: 'sensors',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 24,
                ),
              ),
              ListTile(
                title: Text(
                  'Техническая поддержка',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  appData["supportEmail"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'email',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 24,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Открытие почтового клиента: ${appData["supportEmail"]}')),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Лицензии',
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Открытые лицензии компонентов',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                onTap: () {
                  showLicensePage(context: context);
                },
              ),
            ],
          ),
          SizedBox(height: 24.sp),
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'directions_car',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 48,
                ),
                SizedBox(height: 12.sp),
                Text(
                  'Pothole Impact Tracker',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Мониторинг состояния дорог и воздействия на автомобиль',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGpsAccuracyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Точность GPS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Высокая'),
              subtitle: const Text('Лучшая точность, больше энергии'),
              value: 'Высокая',
              groupValue: _gpsAccuracy,
              onChanged: (value) {
                setState(() {
                  _gpsAccuracy = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Средняя'),
              subtitle: const Text('Баланс точности и энергии'),
              value: 'Средняя',
              groupValue: _gpsAccuracy,
              onChanged: (value) {
                setState(() {
                  _gpsAccuracy = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Низкая'),
              subtitle: const Text('Экономия энергии'),
              value: 'Низкая',
              groupValue: _gpsAccuracy,
              onChanged: (value) {
                setState(() {
                  _gpsAccuracy = value!;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
