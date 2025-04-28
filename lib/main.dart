import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uywapets_flutter/src/core/services/push_notification_service.dart';
import 'package:uywapets_flutter/src/app.dart';

// Define the background message handler in this file
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp();
  print('Recibida notificación en segundo plano: ${message.notification?.title}');
  // Here you can implement additional logic to handle background notifications
}

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAU_EYhbuxDt59Mk78J0SqsgqX2zVKLzf8",
      authDomain: "uywa-app-6192a.firebaseapp.com",
      projectId: "uywa-app-6192a",
      storageBucket: "uywa-app-6192a",
      messagingSenderId: "500815938879",
      appId: "1:500815938879:android:d3f5a7c8b9e1a2f3443f8a",
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
