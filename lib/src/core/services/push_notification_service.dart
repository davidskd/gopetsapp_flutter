import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uywapets_flutter/src/core/services/permission_service.dart';

// Remove the duplicate background handler definition - it's now in main.dart

// Provider para el servicio de notificaciones push
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final permissionService = ref.read(permissionServiceProvider);
  return PushNotificationService(permissionService);
});

// Provider para el stream de notificaciones
final notificationStreamProvider = StreamProvider<RemoteMessage>((ref) {
  final controller = StreamController<RemoteMessage>();
  
  ref.read(pushNotificationServiceProvider).onMessageOpenedApp.listen((message) {
    controller.add(message);
  });
  
  ref.onDispose(() {
    controller.close();
  });
  
  return controller.stream;
});

class PushNotificationService {
  final PermissionService _permissionService;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  PushNotificationService(this._permissionService) {
    // Inicializar el servicio
    _init();
  }
  
  // Getter para acceder al Stream de notificaciones cuando la app está abierta desde segundo plano
  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;
  
  // Inicializa el servicio de notificaciones
  Future<void> _init() async {
    // Background handler is now set up in main.dart
    // No need to set it up again here
    
    // Solicitar permiso para notificaciones
    await _requestPermission();
    
    // Configurar manejadores para diferentes estados de la app
    _setupForegroundNotification();
    _setupNotificationOpenedApp();
    
    // Obtener el token FCM
    _getToken();
  }
  
  // Solicita permiso para enviar notificaciones
  Future<bool> _requestPermission() async {
    return await _permissionService.requestNotificationPermission();
  }
  
  // Configura el manejo de notificaciones cuando la app está en primer plano
  void _setupForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación recibida en primer plano: ${message.notification?.title}');
      
      // Aquí puedes mostrar una notificación local o actualizar la interfaz de usuario
      if (message.notification != null) {
        // Puedes usar flutter_local_notifications para mostrar una notificación local
        // cuando la app está en primer plano
      }
    });
  }
  
  // Configura el manejo cuando se abre la app desde una notificación
  void _setupNotificationOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App abierta desde notificación: ${message.notification?.title}');
      
      // Aquí puedes navegar a una pantalla específica basada en los datos de la notificación
      if (message.data.containsKey('type')) {
        // Ejemplo: if (message.data['type'] == 'pet') navigate to pet screen
      }
    });
  }
  
  // Obtiene el token FCM para este dispositivo
  Future<String?> _getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    // Aquí deberías enviar el token a tu backend para almacenarlo
    // Ejemplo: await apiService.registerDevice(token);
    
    return token;
  }
  
  // Actualiza el token FCM en caso de que caduque
  void _tokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      print('FCM Token actualizado: $token');
      
      // Actualizar el token en tu backend
      // Ejemplo: await apiService.updateDeviceToken(token);
    });
  }
  
  // Suscribe al dispositivo a un tema específico
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }
  
  // Cancela la suscripción del dispositivo a un tema específico
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
  
  // Configura el canal para notificaciones en iOS
  Future<void> setForegroundNotificationPresentationOptions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}