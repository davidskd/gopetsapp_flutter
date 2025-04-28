import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/person.dart';
import '../providers/person_providers.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos del formulario
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores vacíos
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
    
    // Los valores se cargarán cuando el perfil esté disponible en didChangeDependencies
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profileState = ref.read(profileProvider);
    
    if (profileState.hasValue && profileState.valueOrNull != null) {
      final person = profileState.valueOrNull!;
      
      // Actualizar controladores con los datos del perfil
      _firstNameController.text = person.personName ?? '';
      _lastNameController.text = person.personLastName ?? '';
      _emailController.text = person.personEmail ?? '';
      _phoneController.text = person.personCellphone ?? '';
      _addressController.text = person.address ?? '';
      _cityController.text = person.city ?? '';
      _countryController.text = person.country ?? '';
    }
  }

  @override
  void dispose() {
    // Liberar los controladores
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Obtener el perfil actual
      final currentProfile = ref.read(profileProvider).valueOrNull;
      if (currentProfile == null) {
        throw Exception('No se pudo cargar el perfil para actualizar');
      }
      
      // Crear un nuevo objeto Person con los datos actualizados
      final updatedProfile = currentProfile.copyWith(
        personName: _firstNameController.text,
        personLastName: _lastNameController.text,
        personEmail: _emailController.text,
        personCellphone: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        country: _countryController.text,
      );
      
      // Guardar los cambios usando el notifier
      await ref.read(profileEditProvider.notifier).updateProfile(updatedProfile);
      
      // Refrescar el perfil en el provider principal
      ref.refresh(profileProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        
        // Navegar de vuelta a la pantalla de perfil
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar perfil: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveProfile,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      onChanged: _onFieldChanged,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre
            _buildTextField(
              controller: _firstNameController,
              label: 'Nombre',
              icon: Icons.person_outline,
              validator: (value) => 
                  value == null || value.isEmpty ? 'Campo requerido' : null,
            ),
            
            const SizedBox(height: 16),
            
            // Apellido
            _buildTextField(
              controller: _lastNameController,
              label: 'Apellido',
              icon: Icons.person_outline,
              validator: (value) => 
                  value == null || value.isEmpty ? 'Campo requerido' : null,
            ),
            
            const SizedBox(height: 16),
            
            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Correo Electrónico',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo requerido';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Dirección de correo inválida';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Teléfono
            _buildTextField(
              controller: _phoneController,
              label: 'Teléfono',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 16),
            
            // Dirección
            _buildTextField(
              controller: _addressController,
              label: 'Dirección',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // Ciudad
            _buildTextField(
              controller: _cityController,
              label: 'Ciudad',
              icon: Icons.location_city_outlined,
            ),
            
            const SizedBox(height: 16),
            
            // País
            _buildTextField(
              controller: _countryController,
              label: 'País',
              icon: Icons.flag_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // Botón de guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('GUARDAR CAMBIOS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}