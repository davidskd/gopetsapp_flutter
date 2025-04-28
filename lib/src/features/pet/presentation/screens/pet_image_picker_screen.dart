import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uywapets_flutter/src/core/services/permission_service.dart';

class PetImagePickerScreen extends ConsumerStatefulWidget {
  final int petId;
  
  const PetImagePickerScreen({super.key, required this.petId});
  
  @override
  ConsumerState<PetImagePickerScreen> createState() => _PetImagePickerScreenState();
}

class _PetImagePickerScreenState extends ConsumerState<PetImagePickerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;
  String? _errorMessage;
  
  // Método para solicitar permisos y abrir la cámara
  Future<void> _takePhoto() async {
    // Primero verificamos y solicitamos los permisos necesarios
    final permissionService = ref.read(permissionServiceProvider);
    final hasPermission = await permissionService.requestMediaPermission();
    
    if (!hasPermission) {
      // Si no tenemos permisos, mostramos un diálogo explicativo
      if (!mounted) return;
      await permissionService.showPermissionDialog(
        context,
        title: 'Permiso de cámara',
        content: 'Se necesita acceso a la cámara para tomar fotos de tu mascota.',
        permissionType: 'media',
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al acceder a la cámara: $e';
      });
    }
  }
  
  // Método para solicitar permisos y abrir la galería
  Future<void> _pickFromGallery() async {
    // Primero verificamos y solicitamos los permisos necesarios
    final permissionService = ref.read(permissionServiceProvider);
    final hasPermission = await permissionService.requestMediaPermission();
    
    if (!hasPermission) {
      // Si no tenemos permisos, mostramos un diálogo explicativo
      if (!mounted) return;
      await permissionService.showPermissionDialog(
        context,
        title: 'Permiso de galería',
        content: 'Se necesita acceso a la galería para seleccionar fotos de tu mascota.',
        permissionType: 'media',
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al acceder a la galería: $e';
      });
    }
  }
  
  // Método para subir la imagen seleccionada
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Por favor, selecciona una imagen primero';
      });
      return;
    }
    
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });
    
    try {
      // Aquí iría tu lógica para subir la imagen a tu backend
      // Ejemplo: final imageUrl = await petRepository.uploadPetImage(widget.petId, _selectedImage!.path);
      
      await Future.delayed(const Duration(seconds: 2)); // Simula la subida
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen subida correctamente')),
      );
      
      Navigator.of(context).pop(true); // Regresa a la pantalla anterior con éxito
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al subir la imagen: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto de mascota'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Selecciona o toma una foto para tu mascota',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Muestra la imagen seleccionada o un placeholder
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.pets, size: 80, color: Colors.grey),
                      ),
              ),
              
              const SizedBox(height: 24),
              
              // Botones para seleccionar imagen
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Mensaje de error si existe
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Botón para subir la imagen
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedImage != null && !_isUploading ? _uploadImage : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Guardar Imagen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}