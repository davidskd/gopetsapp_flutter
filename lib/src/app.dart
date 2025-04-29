import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uywapets_flutter/src/shared/routing/app_router.dart';
import 'package:uywapets_flutter/src/core/services/permission_service.dart';
import 'package:uywapets_flutter/src/theme/app_theme.dart'; // Importamos el tema personalizado

// Change MyApp to a ConsumerWidget to access providers
class MyApp extends ConsumerStatefulWidget { // Cambiado a ConsumerStatefulWidget para usar initState
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Solicitamos los permisos básicos cuando se inicia la app
    _requestInitialPermissions();
  }

  // Método para solicitar los permisos básicos al iniciar la app
  Future<void> _requestInitialPermissions() async {
    // Obtenemos el servicio de permisos a través del provider
    final permissionService = ref.read(permissionServiceProvider);
    
    // Solicitamos el permiso de notificaciones al inicio
    // Los demás permisos los solicitaremos cuando sean necesarios
    await permissionService.requestNotificationPermission();
    
    // También podemos solicitar todos los permisos necesarios a la vez
    // await permissionService.checkAndRequestPermissions(
    //   notification: true,
    //   location: false, // Solo solicitamos ubicación cuando sea necesario
    //   media: false,    // Solo solicitamos multimedia cuando sea necesario
    // );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Watch the appRouterProvider para obtener la instancia de GoRouter
    final goRouter = ref.watch(appRouterProvider);

    // MaterialApp.router now uses the router configuration from the provider
    return MaterialApp.router(
      title: 'UywaPets Flutter',
      theme: AppTheme.lightTheme, // Aplicamos nuestro tema personalizado
      // Provide the router configuration obtained from the provider
      routerConfig: goRouter,
    );
  }
}
