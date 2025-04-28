import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Normaliza un texto que podría contener caracteres acentuados (tildes)
/// que no se muestran correctamente.
String normalizeText(String text) {
  try {
    // Primero detectamos si el texto tiene problemas de codificación
    if (text.contains('Ã') || text.contains('Â') || text.contains('â€')) {
      // Intentar "reparar" el texto que fue codificado incorrectamente
      final bytes = text.codeUnits;
      return utf8.decode(bytes, allowMalformed: true);
    }
    
    // Si no se detecta el problema típico, devolvemos el texto original
    return text;
  } catch (e) {
    debugPrint('Error al normalizar texto: $e');
    return text; // Devolver el texto original en caso de error
  }
}