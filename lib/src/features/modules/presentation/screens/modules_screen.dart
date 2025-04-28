import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Needed for service init
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import GoRouter for navigation
import 'package:uywapets_flutter/src/features/auth/domain/repositories/auth_repository.dart'; // Import Auth Repository Provider
import 'package:uywapets_flutter/src/features/modules/domain/models/module.dart'; // Import the Module model
import 'package:uywapets_flutter/src/features/modules/domain/repositories/module_repository.dart'; // Import repository provider
import 'package:uywapets_flutter/src/core/services/permission_service.dart'; // Permiso de ubicación
import 'package:uywapets_flutter/src/features/person_profile/data/services/person_service.dart'; // Cambiamos a usar el servicio existente

// Change to ConsumerStatefulWidget
class ModulesScreen extends ConsumerStatefulWidget {
  static const String route = '/modules'; // Define the route name

  const ModulesScreen({super.key});

  @override
  ConsumerState<ModulesScreen> createState() => _ModulesScreenState(); // Change to ConsumerState
}

// Change to ConsumerState
class _ModulesScreenState extends ConsumerState<ModulesScreen> {
  // State variables & Dependencies
  bool _isLoading = true;
  bool _isError = false;
  List<Module> _modules = [];
  bool _isUpdatingLocation = false;

  @override
  void initState() {
    super.initState();
    // Fetch modules immediately when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchModules();
      _updateUserLocation(); // Actualizar la ubicación del usuario
    });
  }

  // Método para actualizar la ubicación del usuario
  Future<void> _updateUserLocation() async {
    try {
      setState(() {
        _isUpdatingLocation = true;
      });
      
      // Primero verificamos los permisos de ubicación
      final permissionService = ref.read(permissionServiceProvider);
      final hasLocationPermission = await permissionService.requestLocationPermission();
      
      if (!hasLocationPermission) {
        print("No se concedió permiso de ubicación");
        return;
      }
      
      // Si tenemos permiso, actualizamos la ubicación
      final personService = ref.read(personServiceProvider);
      await personService.updateLocation();
      
      print("Ubicación actualizada exitosamente");
    } catch (e) {
      print("Error al actualizar la ubicación: $e");
      // No mostramos error al usuario ya que esta operación es en segundo plano
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingLocation = false;
        });
      }
    }
  }

  Future<void> _fetchModules() async {
    // Don't reset modules list here, keep old data while loading if desired
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      // Get the repository using ref.read (since we only need it once per fetch)
      final moduleRepository = ref.read(moduleRepositoryProvider);
      final fetchedModules = await moduleRepository.getModules();
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _modules = fetchedModules;
          _isLoading = false;
        });
      }
    } catch (e) {
       print("Error in _fetchModules: $e");
       if (mounted) {
         setState(() {
           _isLoading = false;
           _isError = true;
           _modules = []; // Clear modules on error
         });
       }
    }
  }

  void _goToSettings() {
    // TODO: Implement navigation to settings screen
    print('Navigate to Settings');
    // Navigator.pushNamed(context, '/settings'); // Example navigation
  }

  Future<void> _logout() async { // Make async
    try {
      // Show a loading indicator maybe? (Optional)
      // setState(() => _isLoading = true); // Need to handle this state properly if added

      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.logout(); // Call the logout method

      // Navigate to prelogin screen after logout attempt
      if (mounted) {
        context.go('/prelogin'); // Use go_router to navigate
      }

    } catch (e) {
      print("Error during logout: $e");
      if (mounted) {
        // Show error message to the user (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
        );
        // Still navigate to prelogin even if server revoke fails, as local tokens are likely cleared
        context.go('/prelogin');
      }
    } finally {
      // Hide loading indicator if shown (Optional)
      // if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onModuleTap(String route) {
    context.go('/$route');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Define height for the bottom image
    final double bottomImageHeight = screenHeight * 0.2; // Example: 20% of screen height
    final bool showBottomImage = screenHeight > 667; // Condition to show/hide image

    // Basic AppBar similar to the Ionic version
    final appBar = AppBar(
      backgroundColor: Colors.transparent, // Make AppBar transparent like ion-toolbar
      elevation: 0, // Remove shadow
      leading: IconButton( // Assuming the first button is logout based on Angular onClick()
        icon: const Icon(Icons.logout, color: Colors.black54), // Placeholder icon
        onPressed: _logout,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.black54),
          onPressed: () => context.go('/profile'), // Navegamos directamente a la ruta del perfil
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      // Wrap body in Stack for background image
      body: Stack(
        children: [
          // Conditionally display the Bottom Background Image (FIRST child, drawn at the bottom)
          if (showBottomImage)
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/paisaje1.png', // Path to the image
                width: double.infinity, // Stretch to fit width
                height: bottomImageHeight, // Set the defined height
                fit: BoxFit.cover, // Use cover to fill the height potentially cropping width
              ),
            ),
          // Main content area (RefreshIndicator + CustomScrollView)
          RefreshIndicator( // Corresponds to ion-refresher
            onRefresh: _fetchModules,
            child: CustomScrollView( // Use CustomScrollView for potentially mixed content types and slivers
              slivers: [
                SliverToBoxAdapter( // For non-list content like the profile section
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10), // Adjust spacing as needed
                    // Profile Section - Adapt styling from SCSS
                    SizedBox(
                      height: 90, // Height from .profile-picture
                      width: 90, // Width from .profile-picture
                      child: Image.asset(
                        'assets/images/logo.png', // Ensure this asset exists in Flutter project
                        fit: BoxFit.contain, // Adjust fit as needed
                      ),
                    ),
                    const SizedBox(height: 40), // Spacing from .profile-picture margin-bottom
                    const Text(
                      '¡Bienvenido a nuestra app!',
                      style: TextStyle(fontSize: 18, color: Colors.grey), // Style from .titulo1
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5), // Spacing from .titulo1 margin-top
                     const Text(
                      'Elije qué actividad deseas realizar',
                      style: TextStyle(fontSize: 18, color: Colors.grey), // Style from .titulo1
                      textAlign: TextAlign.center,
                    ),
                     const SizedBox(height: 20), // Spacing from .profile margin-bottom
                  ],
                ),
              ),
            ),
            // --- Loading State ---
            if (_isLoading)
              const SliverFillRemaining( // Use SliverFillRemaining to center loading indicator
                child: Center(child: CircularProgressIndicator()),
              ),

            // --- Error State ---
            if (!_isLoading && _isError)
              SliverFillRemaining(
                child: Center(
                  child: Column( // Similar to empty-view
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Error al cargar módulos.', // Customize error message
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchModules,
                        child: const Text('Reintentar'),
                      )
                    ],
                  ),
                ),
              ),

            // --- Empty State ---
             if (!_isLoading && !_isError && _modules.isEmpty)
              SliverFillRemaining(
                 child: Center(
                   child: Column( // Similar to empty-view
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       // Use an image like in the Angular version if available
                       // Image.asset('assets/images/pet_empty.png', width: 120),
                       const Icon(Icons.apps_outlined, size: 60, color: Colors.grey), // Placeholder icon
                       const SizedBox(height: 16),
                       const Text(
                         'No hay módulos disponibles.', // Customize empty message
                         style: TextStyle(fontSize: 16),
                         textAlign: TextAlign.center,
                       ),
                       const SizedBox(height: 8),
                       const Text(
                         'Desliza hacia abajo para refrescar.', // Corresponds to pulling text
                         style: TextStyle(fontSize: 14, color: Colors.grey),
                         textAlign: TextAlign.center,
                       ),
                     ],
                   ),
                 ),
               ),

            // --- Modules List (Centered) ---
            if (!_isLoading && !_isError && _modules.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final module = _modules[index];
                    // Parse moduleColor string to Color object
                    Color backgroundColor = _parseColor(module.moduleColor);
                    // Use moduleColor for font color as requested
                    Color fontColor = _parseColor(module.moduleColor);

                    // Wrap each item in Padding and Center
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Add vertical spacing
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _onModuleTap(module.moduleRoute), // Use actual route
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Circular background container
                            Container(
                              padding: const EdgeInsets.all(15), // Padding from .track
                              decoration: BoxDecoration(
                                color: backgroundColor, // Use parsed color
                                shape: BoxShape.circle,
                                boxShadow: [ // Basic shadow similar to .track
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: SizedBox( // Constrain image size
                                width: 75, // Adjust size as needed (smaller than .track max-width)
                                height: 75,
                                // Use Image.network for URLs
                                child: Image.network(
                                  module.moduleImage, // URL from the module data
                                  fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  print("Error loading network image: ${module.moduleImage} - $error");
                                  return const Icon(Icons.broken_image, size: 40); // Placeholder on error
                                },
                                // Optional: Add loading builder
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8), // Spacing between circle and text
                          // Module Title
                          Padding( // Add padding to prevent text touching edges
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              module.moduleName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14, // Font size from .titulo
                                fontWeight: FontWeight.bold, // Font weight from .titulo
                                color: fontColor, // Use parsed font color (restored)
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                  },
                  childCount: _modules.length,
                ),
              ),
            // Conditionally add SizedBox at the end of the slivers only if the image is shown
            if (showBottomImage)
              SliverToBoxAdapter(
                child: SizedBox(height: bottomImageHeight),
              ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  // Helper function to parse hex color string (basic implementation)
  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Add alpha if missing
    }
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      print("Error parsing color: $hexColor. Using default.");
      return Colors.grey; // Default color on error
    }
  }
}
