import 'package:go_router/go_router.dart';

import '../screens/change_password_screen.dart';
import '../screens/profile_edit_screen.dart';
import '../screens/profile_screen.dart';

/// Rutas para la funcionalidad de perfil de persona
final List<RouteBase> personProfileRoutes = [
  GoRoute(
    path: '/profile',
    name: 'profile',
    builder: (context, state) => const ProfileScreen(),
  ),
  GoRoute(
    path: '/profile/edit',
    name: 'profile-edit',
    builder: (context, state) => const ProfileEditScreen(),
  ),
  GoRoute(
    path: '/profile/change-password',
    name: 'change-password',
    builder: (context, state) => const ChangePasswordScreen(),
  ),
];