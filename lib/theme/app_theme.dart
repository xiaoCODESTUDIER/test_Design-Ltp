import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData getAppTheme() {
    return ThemeData(
      primaryColor: ColorConfigs.primary,
      secondaryHeaderColor: ColorConfigs.secondary,
      scaffoldBackgroundColor: ColorConfigs.background,
    );
  }
}