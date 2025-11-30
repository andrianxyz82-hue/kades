import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppGradients {
  // Yellow gradient for Internal Storage
  static const yellowGradientStart = Color(0xFFFFD700);
  static const yellowGradientEnd = Color(0xFFFFA500);
  
  static const yellowGradient = LinearGradient(
    colors: [yellowGradientStart, yellowGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
