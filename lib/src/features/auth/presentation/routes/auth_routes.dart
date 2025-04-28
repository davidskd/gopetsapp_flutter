import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
//import '../screens/forgot_password_screen.dart';

/// Rutas para la funcionalidad de autenticación
final List<RouteBase> authRoutes = [
  // Ruta de inicio de sesión
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),
  
  // Ruta de registro
  GoRoute(
    path: '/register',
    name: 'register',
    builder: (context, state) => const RegisterScreen(),
  ),
  
  // Ruta de recuperación de contraseña
  /* GoRoute(
    path: '/forgot-password',
    name: 'forgotPassword',
    builder: (context, state) => const ForgotPasswordScreen(),
  ), */
];