import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashLoadingWidget extends StatelessWidget {
  final List<Map<String, dynamic>> initializationSteps;
  final int currentStep;

  const SplashLoadingWidget({
    super.key,
    required this.initializationSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Indicator
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (currentStep + 1) / initializationSteps.length,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Initialization Steps
          ...initializationSteps.asMap().entries.map((entry) {
            final int index = entry.key;
            final Map<String, dynamic> step = entry.value;
            final bool isCompleted = step["status"] == "completed";
            final bool isCurrent = index == currentStep;
            final bool isPending = index > currentStep;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < initializationSteps.length - 1 ? 12.h : 0),
              child: Row(
                children: [
                  // Status Icon
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.white
                          : isCurrent
                              ? Colors.white.withOpacity(0.3)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isPending
                          ? Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 14.sp,
                            )
                          : isCurrent
                              ? SizedBox(
                                  width: 12.w,
                                  height: 12.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : CustomIconWidget(
                                  iconName: step["icon"] as String,
                                  color: Colors.white.withOpacity(0.4),
                                  size: 14.sp,
                                ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Step Name
                  Expanded(
                    child: Text(
                      step["name"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isCompleted || isCurrent
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontWeight:
                            isCurrent ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
