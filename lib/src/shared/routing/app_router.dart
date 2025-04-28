import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Assuming Riverpod for state management
import 'package:uywapets_flutter/src/features/auth/domain/repositories/auth_repository.dart'; // Corrected path
import 'package:uywapets_flutter/src/features/auth/presentation/screens/login_screen.dart';
import 'package:uywapets_flutter/src/features/auth/presentation/screens/pre_login_screen.dart';
import 'package:uywapets_flutter/src/features/auth/presentation/screens/register_screen.dart'; // Import RegisterScreen
import 'package:uywapets_flutter/src/features/modules/presentation/screens/modules_screen.dart'; // Import ModulesScreen
// Importamos las pantallas de perfil
import 'package:uywapets_flutter/src/features/person_profile/presentation/screens/profile_screen.dart';
import 'package:uywapets_flutter/src/features/person_profile/presentation/screens/profile_edit_screen.dart';
import 'package:uywapets_flutter/src/features/person_profile/presentation/screens/change_password_screen.dart';
// Importamos la pantalla principal de mascotas
import 'package:uywapets_flutter/src/features/pet/presentation/screens/pet_screen.dart';

/// Defines the application's routes using go_router.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider); // Watch auth state

  return GoRouter(
    initialLocation: ModulesScreen.route, // Start at the modules screen
    // navigatorKey: _rootNavigatorKey, // Use if needed for root navigation control
    debugLogDiagnostics: true, // Log navigation events in debug mode

    routes: [
      // Pre-Login Route
      GoRoute(
        path: '/prelogin',
        builder: (context, state) => const PreLoginScreen(),
      ),

      // Login Route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Register Route
      GoRoute(
        path: RegisterScreen.route, // Use route name from screen
        builder: (context, state) => const RegisterScreen(),
      ),

      // Modules Route (Main authenticated route)
      GoRoute(
        path: ModulesScreen.route, // Use route name from screen
        builder: (context, state) => const ModulesScreen(),
      ),

      // Rutas de perfil
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Ruta de mascotas
      GoRoute(
        path: '/mascota',
        builder: (context, state) => const PetScreen(),
      ),

      // TODO: Add other routes here
      // Example: Home route (potentially protected)
      // GoRoute(
      //   path: '/home',
      //   builder: (context, state) => const HomeScreen(),
      // ),
      // Example: Sign Up route
      // GoRoute(
      //   path: '/signup',
      //   builder: (context, state) => const SignUpScreen(),
      // ),
    ],

    // TODO: Add error handling (e.g., redirect to a 404 page)
    // errorBuilder: (context, state) => const NotFoundScreen(),

    // Add redirection logic based on authentication state
    redirect: (context, state) async {
      // Get authentication status (assuming async check)
      final bool loggedIn = await authRepository.isAuthenticated();

      // Define public routes (accessible without login)
      final publicRoutes = ['/login', '/prelogin', RegisterScreen.route];

      final bool isPublicRoute = publicRoutes.contains(state.matchedLocation);

      // If not logged in and trying to access a protected route, redirect to prelogin
      if (!loggedIn && !isPublicRoute) {
        return '/prelogin';
      }

      // If logged in and trying to access login/prelogin/register, redirect to modules
      if (loggedIn && isPublicRoute) {
        return ModulesScreen.route; // Redirect to the main authenticated screen
      }

      // No redirect needed
      return null;
    },
  );
});
