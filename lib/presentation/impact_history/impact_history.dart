import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/impact_card_widget.dart';

class ImpactHistory extends StatefulWidget {
  const ImpactHistory({super.key});

  @override
  State<ImpactHistory> createState() => _ImpactHistoryState();
}

class _ImpactHistoryState extends State<ImpactHistory>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isMultiSelectMode = false;
  final List<int> _selectedImpacts = [];
  String _searchQuery = '';
  final List<String> _activeFilters = ['Все', 'Сегодня'];

  // Mock data for impact history
  final List<Map<String, dynamic>> _impactHistory = [
    {
      "id": 1,
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "severity": "critical",
      "severityLevel": 8.5,
      "location": "ул. Ленина, 45",
      "coordinates": {"lat": 55.7558, "lng": 37.6176},
      "magnitude": "Сильный удар",
      "description": "Глубокая яма на проезжей части",
      "speed": 45,
      "mapThumbnail":
          "https://images.unsplash.com/photo-1524661135-423995f22d0b?w=300&h=200&fit=crop",
    },
    {
      "id": 2,
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "severity": "warning",
      "severityLevel": 5.2,
      "location": "Московский проспект, 123",
      "coordinates": {"lat": 55.7512, "lng": 37.6184},
      "magnitude": "Средний удар",
      "description": "Неровность дорожного покрытия",
      "speed": 35,
      "mapThumbnail":
          "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=300&h=200&fit=crop",
    },
    {
      "id": 3,
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
      "severity": "normal",
      "severityLevel": 3.1,
      "location": "ул. Пушкина, 12",
      "coordinates": {"lat": 55.7489, "lng": 37.6156},
      "magnitude": "Легкий удар",
      "description": "Небольшая неровность",
      "speed": 25,
      "mapThumbnail":
          "https://images.unsplash.com/photo-1486162928267-e6274cb3106f?w=300&h=200&fit=crop",
    },
    {
      "id": 4,
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "severity": "critical",
      "severityLevel": 9.2,
      "location": "Кольцевая дорога, км 15",
      "coordinates": {"lat": 55.7601, "lng": 37.6234},
      "magnitude": "Очень сильный удар",
      "description": "Большая яма после дождя",
      "speed": 60,
      "mapThumbnail":
          "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=300&h=200&fit=crop",
    },
    {
      "id": 5,
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
      "severity": "warning",
      "severityLevel": 4.8,
      "location": "ул. Гагарина, 78",
      "coordinates": {"lat": 55.7445, "lng": 37.6098},
      "magnitude": "Средний удар",
      "description": "Трещина в асфальте",
      "speed": 40,
      "mapThumbnail":
          "https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=300&h=200&fit=crop",
    },
  ];

  List<Map<String, dynamic>> get _filteredImpacts {
    List<Map<String, dynamic>> filtered = _impactHistory;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((impact) {
        final location = (impact["location"] as String).toLowerCase();
        final magnitude = (impact["magnitude"] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return location.contains(query) || magnitude.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading delay
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(Duration(seconds: 1));
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedImpacts.clear();
      }
    });
  }

  void _toggleImpactSelection(int impactId) {
    setState(() {
      if (_selectedImpacts.contains(impactId)) {
        _selectedImpacts.remove(impactId);
      } else {
        _selectedImpacts.add(impactId);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Фильтры',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Готово'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildFilterSection('Уровень серьезности', [
                  'Все уровни',
                  'Критический',
                  'Предупреждение',
                  'Нормальный'
                ]),
                SizedBox(height: 24),
                _buildFilterSection('Период времени',
                    ['Сегодня', 'Вчера', 'Неделя', 'Месяц', 'Все время']),
                SizedBox(height: 24),
                _buildFilterSection('Радиус поиска',
                    ['1 км', '5 км', '10 км', '25 км', 'Без ограничений']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map((option) => FilterChip(
                    label: Text(option),
                    selected: _activeFilters.contains(option),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _activeFilters.add(option);
                        } else {
                          _activeFilters.remove(option);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildSearchBar(),
            _buildDateRangeSelector(),
            _buildFilterChips(),
            Expanded(
              child: _filteredImpacts.isEmpty
                  ? EmptyStateWidget()
                  : _buildImpactList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                // Manual impact logging
                HapticFeedback.mediumImpact();
              },
              child: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 24,
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (_isMultiSelectMode) ...[
            IconButton(
              onPressed: _toggleMultiSelect,
              icon: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
            Text(
              'Выбрано: \${_selectedImpacts.length}',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                // Delete selected impacts
                HapticFeedback.heavyImpact();
              },
              icon: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.errorLight,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () {
                // Share selected impacts
              },
              icon: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/main-dashboard'),
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
            Text(
              'История ударов',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            Spacer(),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
              icon: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'Статистика'),
          Tab(text: 'История'),
          Tab(text: 'Карта'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Поиск по местоположению или серьезности...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(12),
            child: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          suffixIcon: IconButton(
            onPressed: _showFilterBottomSheet,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return DateRangeSelectorWidget(
      impactCount: _filteredImpacts.length,
      onDateRangeChanged: (start, end) {
        // Handle date range change
      },
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _activeFilters.length,
        itemBuilder: (context, index) {
          return FilterChipWidget(
            label: _activeFilters[index],
            isActive: true,
            onTap: () {
              setState(() {
                _activeFilters.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildImpactList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredImpacts.length + (_isLoading ? 3 : 0),
        itemBuilder: (context, index) {
          if (index >= _filteredImpacts.length) {
            return _buildSkeletonCard();
          }

          final impact = _filteredImpacts[index];
          return ImpactCardWidget(
            impact: impact,
            isSelected: _selectedImpacts.contains(impact["id"]),
            isMultiSelectMode: _isMultiSelectMode,
            onTap: () {
              if (_isMultiSelectMode) {
                _toggleImpactSelection(impact["id"] as int);
              } else {
                Navigator.pushNamed(context, '/impact-detail');
              }
            },
            onLongPress: () {
              if (!_isMultiSelectMode) {
                _toggleMultiSelect();
                _toggleImpactSelection(impact["id"] as int);
              }
            },
            onSwipeRight: () {
              _showQuickActions(impact);
            },
            onSwipeLeft: () {
              _showExportOptions(impact);
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> impact) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Подробности'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/impact-detail');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Поделиться отчетом'),
              onTap: () {
                Navigator.pop(context);
                // Share functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: Text('Удалить'),
              onTap: () {
                Navigator.pop(context);
                // Delete functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(Map<String, dynamic> impact) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_download',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Экспорт данных'),
              onTap: () {
                Navigator.pop(context);
                // Export functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
