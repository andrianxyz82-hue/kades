import 'package:flutter/material.dart';

class AppColors {
  // Gradient Colors
  static const blueGradientStart = Color(0xFF3C7BFD);
  static const blueGradientEnd = Color(0xFF1A5DFF);
  
  static const purpleGradientStart = Color(0xFF6A5DFB);
  static const purpleGradientEnd = Color(0xFF5140FF);
  
  // Background Gradient
  static const backgroundGradientStart = Color(0xFFE8F0FE);
  static const backgroundGradientEnd = Color(0xFFEDE7F6);
  
  // Card Colors
  static const cardWhite = Color(0xFFFFFFFF);
  static const cardShadow = Color(0x1A000000);
  
  // Icon Colors
  static const iconYellow = Color(0xFFFFD700);
  static const iconRed = Color(0xFFFF6B6B);
  static const iconBlue = Color(0xFF4A90E2);
  static const iconPurple = Color(0xFF9B59B6);
  
  // Text Colors
  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const textLight = Color(0xFFB2BEC3);
  
  // Button Colors
  static const buttonClean = Color(0xFFFFFFFF);
  
  // Gradients
  static const blueGradient = LinearGradient(
    colors: [blueGradientStart, blueGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const purpleGradient = LinearGradient(
    colors: [purpleGradientStart, purpleGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const backgroundGradient = LinearGradient(
    colors: [backgroundGradientStart, backgroundGradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
