import 'package:flutter/material.dart';

/// Clase que contiene los colores principales de la aplicación UywaPets
class AppColors {
  // Colores principales
  static const Color primaryBlue = Color(0xFF4AB3ED);
  static const Color primaryYellow = Color(0xFFFFC247);
  
  // Variantes de colores principales (más claros y más oscuros)
  static const Color primaryBlueLight = Color(0xFF7CCBF9);
  static const Color primaryBlueDark = Color(0xFF2A8BC0);
  
  static const Color primaryYellowLight = Color(0xFFFFD77F);
  static const Color primaryYellowDark = Color(0xFFE0A41F);
  
  // Colores neutrales
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color info = primaryBlue;
  static const Color warning = primaryYellow;
  static const Color danger = Color(0xFFF44336);
}