import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'timeline',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 60,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'История пуста',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Начните мониторинг дорожных условий, чтобы увидеть историю ударов и анализировать качество дорог.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/main-dashboard');
              },
              child: Text('Начать мониторинг'),
            ),
          ],
        ),
      ),
    );
  }
}
