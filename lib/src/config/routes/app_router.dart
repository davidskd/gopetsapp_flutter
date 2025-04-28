import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/routes/auth_routes.dart';
import '../../features/person_profile/presentation/routes/person_profile_routes.dart';
// Importamos el módulo que usaremos como HomeScreen temporalmente
import '../../features/modules/presentation/screens/modules_screen.dart';

/// Provider para la configuración de rutas de la aplicación
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login', // Redirigimos al login en lugar de splash
    debugLogDiagnostics: true,
    routes: [
      // Login como pantalla inicial mientras no tengamos splash
      GoRoute(
        path: '/',
        redirect: (_, __) => '/login',
      ),
      
      // Home (pantalla principal)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const ModulesScreen(), // Usamos la pantalla de módulos como Home
      ),
      
      // Rutas de autenticación
      ...authRoutes,
      
      // Rutas de perfil de persona
      ...personProfileRoutes,
      
      // Aquí se pueden agregar más grupos de rutas
    ],
    
    // Manejo de errores (página no encontrada)
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Página no encontrada'),
      ),
      body: Center(
        child: Text(
          'La ruta ${state.matchedLocation} no existe',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ),
  );
});