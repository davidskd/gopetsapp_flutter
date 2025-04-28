import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../../domain/models/person.dart';
import '../providers/person_providers.dart';
import '../widgets/profile_header.dart';

/// Pantalla de perfil del usuario
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Variable para almacenar la clave global del diálogo
  final GlobalKey<State> _dialogKey = GlobalKey<State>();

  // Variable para controlar el estado de carga
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/modules'), // Navega directamente a la pantalla de módulos
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      // Usamos un Stack para mostrar el indicador de carga superpuesto a la interfaz
      body: Stack(
        children: [
          profileAsync.when(
            data: (person) => _buildProfileContent(context, person),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el perfil:\n${error.toString()}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(profileProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          // Overlay de carga que se muestra según el estado _isLoading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Subiendo imagen...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Person person) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile header with photo, name and basic info
          ProfileHeader(
            person: person,
            onEditPressed: () => _handleProfilePhotoEdit(context),
          ),
          
          const SizedBox(height: 24),
          
          // Profile options
          _buildProfileOptions(context),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildOptionTile(
              context: context,
              title: 'Información Personal',
              subtitle: 'Edita tu información de contacto',
              icon: Icons.person_outline,
              onTap: () => context.push('/profile/edit'),
            ),
            const Divider(height: 1),
            _buildOptionTile(
              context: context,
              title: 'Cambiar Contraseña',
              subtitle: 'Actualiza tu contraseña',
              icon: Icons.lock_outline,
              onTap: () => context.push('/profile/change-password'),
            ),
            const Divider(height: 1),
            _buildOptionTile(
              context: context,
              title: 'Configuración de Notificaciones',
              subtitle: 'Gestiona tus notificaciones',
              icon: Icons.notifications_outlined,
              onTap: () => context.push('/notifications/settings'),
            ),
            const Divider(height: 1),
            _buildOptionTile(
              context: context,
              title: 'Preferencias',
              subtitle: 'Ajusta tus preferencias de la aplicación',
              icon: Icons.settings_outlined,
              onTap: () => context.push('/settings'),
            ),
            const Divider(height: 1),
            _buildOptionTile(
              context: context,
              title: 'Cerrar Sesión',
              subtitle: 'Salir de tu cuenta',
              icon: Icons.exit_to_app,
              onTap: () => _handleLogout(context),
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _handleProfilePhotoEdit(BuildContext context) {
    // Mostrar opciones para cambiar foto de perfil
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cambiar foto de perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context);
                _selectImageFromGallery(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(context);
              },
            ),
            if (ref.read(profileProvider).valueOrNull?.personProfileImage != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto actual', 
                  style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePhoto(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectImageFromGallery(BuildContext context) async {    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        // Mostrar indicador de carga
        setState(() {
          _isLoading = true;
        });
        
        try {
          // Leer el archivo como bytes y convertir a base64
          final bytes = await image.readAsBytes();
          final base64Image = base64Encode(bytes);
          
          // Usar el nuevo método que acepta base64
          final editNotifier = ref.read(profileEditProvider.notifier);
          await editNotifier.uploadProfileImage(base64Image, isBase64: true);
          
          // Refrescar el perfil para mostrar la nueva imagen
          ref.refresh(profileProvider);
          
          if (mounted) {
            // Ocultar indicador de carga
            setState(() {
              _isLoading = false;
            });
            
            // Mostrar mensaje de éxito
            _showFeedbackMessage('Imagen actualizada correctamente');
          }
        } catch (e) {
          if (mounted) {
            // Ocultar indicador de carga
            setState(() {
              _isLoading = false;
            });
            
            // Mostrar mensaje de error
            _showFeedbackMessage('Error al actualizar imagen: $e');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showFeedbackMessage('Error al seleccionar imagen: $e');
      }
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null && mounted) {
        // Mostrar indicador de carga
        setState(() {
          _isLoading = true;
        });
        
        try {
          // Leer el archivo como bytes y convertir a base64
          final bytes = await photo.readAsBytes();
          final base64Image = base64Encode(bytes);
          
          // Usar el nuevo método que acepta base64
          final editNotifier = ref.read(profileEditProvider.notifier);
          await editNotifier.uploadProfileImage(base64Image, isBase64: true);
          
          // Refrescar el perfil para mostrar la nueva imagen
          ref.refresh(profileProvider);
          
          if (mounted) {
            // Ocultar indicador de carga
            setState(() {
              _isLoading = false;
            });
            
            // Mostrar mensaje de éxito
            _showFeedbackMessage('Imagen actualizada correctamente');
          }
        } catch (e) {
          if (mounted) {
            // Ocultar indicador de carga
            setState(() {
              _isLoading = false;
            });
            
            // Mostrar mensaje de error
            _showFeedbackMessage('Error al actualizar imagen: $e');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showFeedbackMessage('Error al capturar imagen: $e');
      }
    }
  }

  // Método simple para mostrar feedback al usuario sin necesidad de contexto
  void _showFeedbackMessage(String message) {
    // Solo registramos el mensaje en la consola para evitar problemas de contexto
    print('Mensaje: $message');
    
    // Podríamos implementar un banner en la UI si es necesario
    // mediante setState y una variable de estado
  }

  Future<void> _removeProfilePhoto(BuildContext context) async {
    try {
      // Aquí implementaríamos la lógica para eliminar la foto de perfil
      // Por ahora solo mostramos un mensaje
      _showFeedbackMessage('Funcionalidad en desarrollo');
      
      // Una vez implementado, sería algo como:
      // final person = ref.read(profileProvider).valueOrNull;
      // if (person != null) {
      //   final updatedPerson = person.copyWith(personProfileImage: null);
      //   await ref.read(profileEditProvider.notifier).updateProfile(updatedPerson);
      //   ref.refresh(profileProvider);
      // }
    } catch (e) {
      if (mounted) {
        _showFeedbackMessage('Error al eliminar foto: $e');
      }
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Implementar lógica de cierre de sesión
                // await ref.read(authRepositoryProvider).logout();
                context.go('/prelogin');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cerrar sesión: $e')),
                );
              }
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}