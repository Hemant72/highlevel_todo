import 'package:flutter/material.dart';
import 'package:highlevel_todo/core/const/colors.dart';
import 'package:highlevel_todo/core/const/text_style.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyles.headline1,
        bodyLarge: TextStyles.bodyText1,
        bodySmall: TextStyles.caption,
      ),
    );
  }
}
