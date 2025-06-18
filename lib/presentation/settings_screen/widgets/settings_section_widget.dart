import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.sp, 16.sp, 16.sp, 8.sp),
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children.map((child) => _wrapWithDivider(
              child, children.indexOf(child) == children.length - 1)),
        ],
      ),
    );
  }

  Widget _wrapWithDivider(Widget child, bool isLast) {
    return Column(
      children: [
        child,
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
            indent: 16.sp,
            endIndent: 16.sp,
          ),
      ],
    );
  }
}
