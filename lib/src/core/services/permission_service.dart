import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

/// Provider para el servicio de permisos
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

/// Clase que maneja los permisos de la aplicación
class PermissionService {
  /// Solicita permisos de ubicación
  /// Retorna true si los permisos fueron concedidos
  Future<bool> requestLocationPermission() async {
    // En plataforma web, usamos directamente Geolocator en lugar de permission_handler
    if (kIsWeb) {
      try {
        // En web, Geolocator maneja los permisos directamente
        LocationPermission permission = await Geolocator.checkPermission();
        
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        return permission == LocationPermission.always || 
               permission == LocationPermission.whileInUse;
      } catch (e) {
        print("Error solicitando permisos de ubicación en web: $e");
        return false;
      }
    } else {
      // En plataformas móviles, usamos permission_handler como antes
      bool hasPermission = await Permission.locationWhenInUse.isGranted;
      
      if (!hasPermission) {
        final status = await Permission.locationWhenInUse.request();
        hasPermission = status.isGranted;
        
        if (hasPermission && !kIsWeb && Platform.isAndroid) {
          await Permission.locationAlways.request();
        }
      }
      
      return hasPermission;
    }
  }

  /// Solicita permisos para acceder a la cámara y galería
  /// Retorna true si ambos permisos fueron concedidos
  Future<bool> requestMediaPermission() async {
    // Primero solicitamos permiso para la cámara
    final cameraStatus = await Permission.camera.request();
    
    // Luego solicitamos permisos para acceder a fotos/videos
    // Manejamos diferentes permisos según la versión de Android
    bool mediaPermissionsGranted = false;
    
    if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
      mediaPermissionsGranted = true;
    } else {
      // Solicitamos los permisos relevantes según la plataforma
      final photoStatus = await Permission.photos.request();
      final videoStatus = await Permission.videos.request();
      final storageStatus = await Permission.storage.request();
      
      // Verificamos si al menos uno de los permisos fue concedido
      mediaPermissionsGranted = photoStatus.isGranted || 
                               videoStatus.isGranted || 
                               storageStatus.isGranted;
    }
    
    return cameraStatus.isGranted && mediaPermissionsGranted;
  }

  /// Solicita permisos para enviar notificaciones
  /// Retorna true si los permisos fueron concedidos
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Verifica el estado de los permisos y solicita los que faltan
  /// Útil para llamar al inicio de la aplicación o en la pantalla de configuración
  Future<Map<String, bool>> checkAndRequestPermissions({
    bool location = false,
    bool media = false,
    bool notification = false,
  }) async {
    final Map<String, bool> results = {};
    
    if (location) {
      results['location'] = await requestLocationPermission();
    }
    
    if (media) {
      results['media'] = await requestMediaPermission();
    }
    
    if (notification) {
      results['notification'] = await requestNotificationPermission();
    }
    
    return results;
  }
  
  /// Muestra un diálogo explicando por qué se necesita un permiso
  /// y proporciona opciones para solicitarlo o ir a la configuración
  Future<void> showPermissionDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String permissionType,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              
              // Determinar qué permiso solicitar basado en el tipo
              switch (permissionType) {
                case 'location':
                  await requestLocationPermission();
                  break;
                case 'media':
                  await requestMediaPermission();
                  break;
                case 'notification':
                  await requestNotificationPermission();
                  break;
                default:
                  // Si no es ninguno de los anteriores, abrir la configuración
                  await openAppSettings();
              }
            },
            child: const Text('Conceder'),
          ),
        ],
      ),
    );
  }
}