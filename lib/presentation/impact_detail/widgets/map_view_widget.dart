import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_export.dart';

class MapViewWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;
  final double accuracy;

  const MapViewWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.accuracy,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _copyCoordinates() {
    final coordinates =
        '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}';
    Clipboard.setData(ClipboardData(text: coordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Координаты скопированы: \$coordinates')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Местоположение удара',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _toggleExpanded,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isExpanded ? 300 : 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Mock map background with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.accentLight.withOpacity(0.1),
                          AppTheme.successLight.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),

                  // Mock road pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MockMapPainter(),
                    ),
                  ),

                  // Impact location pin
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.errorLight,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.errorLight.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CustomIconWidget(
                            iconName: 'location_on',
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.scaffoldBackgroundColor
                                .withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Удар',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand/Collapse indicator
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.scaffoldBackgroundColor
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName:
                            _isExpanded ? 'fullscreen_exit' : 'fullscreen',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 16,
                      ),
                    ),
                  ),

                  // Accuracy indicator
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.scaffoldBackgroundColor
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'gps_fixed',
                            color: AppTheme.successLight,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '±${widget.accuracy.toStringAsFixed(1)}м',
                            style: AppTheme.lightTheme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12),

        // Address and coordinates
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'place',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.address,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'my_location',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
                      style: AppTheme.getMonospaceStyle(
                        isLight: true,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _copyCoordinates,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: CustomIconWidget(
                        iconName: 'copy',
                        color: AppTheme.accentLight,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3)
      ..strokeWidth = 2;

    // Draw mock road lines
    for (int i = 0; i < 5; i++) {
      final y = size.height * (i + 1) / 6;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    for (int i = 0; i < 5; i++) {
      final x = size.width * (i + 1) / 6;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw mock buildings
    final buildingPaint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.outline.withOpacity(0.1);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.2,
          size.height * 0.15),
      buildingPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.7, size.height * 0.2, size.width * 0.25,
          size.height * 0.2),
      buildingPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.7, size.width * 0.3,
          size.height * 0.25),
      buildingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
