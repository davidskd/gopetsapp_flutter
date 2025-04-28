import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
 
import '../../domain/models/pet_dto.dart';
import '../providers/pet_providers.dart';

class PetInfoScreen extends ConsumerWidget {
  final int petId;

  const PetInfoScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(petByIdProvider(petId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información de Mascota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/pets/$petId/edit'),
          ),
        ],
      ),
      body: petAsync.when(
        data: (pet) => _buildPetDetail(context, pet, ref),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar los detalles',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: () => ref.refresh(petByIdProvider(petId)),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildPetDetail(BuildContext context, PetDto pet, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto de perfil con fondo
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen de mascota o imagen por defecto con fondo degradado
                if (pet.petPrincipalImgUrl != null && pet.petPrincipalImgUrl!.isNotEmpty)
                  Image.network(
                    pet.petPrincipalImgUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.blue.shade300, Colors.blue.shade700],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.pets, size: 80, color: Colors.white70),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blue.shade300, Colors.blue.shade700],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.pets, size: 80, color: Colors.white70),
                    ),
                  ),
                  
                // Overlay con degradado para mejorar legibilidad del nombre
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Nombre y especie/raza
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.petName ?? 'Nombre no disponible',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${pet.petBreedName}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botón para actualizar localización
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: 'updateLocation',
                    onPressed: () => _updateLocation(context, pet, ref),
                    child: const Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),

          // Información detallada
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Características principales
                _buildSection(
                  title: 'Características',
                  children: [
                    _buildInfoRow(
                      icon: Icons.cake,
                      label: 'Edad',
                      value: pet.petOld?.toString() ?? 'No registrada',
                    ),
                    _buildInfoRow(
                      icon: pet.petSex == 'M' ? Icons.male : Icons.female,
                      label: 'Género',
                      value: pet.petSex ?? 'No especificado',
                    ),
                    _buildInfoRow(
                      icon: Icons.colorize,
                      label: 'Color',
                      value: pet.color ?? 'No especificado',
                    ),
                    _buildInfoRow(
                      icon: Icons.monitor_weight,
                      label: 'Peso',
                      value: pet.petWeight != null ? '${pet.petWeight} kg' : 'No registrado',
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Información médica
                _buildSection(
                  title: 'Información médica',
                  children: [
                    _buildInfoRow(
                      icon: Icons.medical_services,
                      label: 'Pedigree',
                      value: pet.petIsPedigree?.toString() ?? 'No especificado',
                    ),
                     
                  ],
                ),
                
           
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openMap(double latitude, double longitude) {
    // Implementar apertura de mapa con las coordenadas
    // Se puede usar url_launcher para abrir Google Maps
    print('Abrir mapa en: $latitude, $longitude');
  }

  Future<void> _updateLocation(BuildContext context, PetDto pet, WidgetRef ref) async {
    // En una aplicación real, aquí se obtendría la ubicación actual
    // utilizando el paquete geolocator
    
    // Simulamos la obtención de ubicación para este ejemplo
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar ubicación'),
        content: const Text('¿Deseas actualizar la ubicación actual de tu mascota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Mostrar indicador de carga
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Obteniendo ubicación actual...')),
                );
              }
              
              try {
                // En un caso real aquí se obtendría la ubicación y se haría geocoding
                // Simulamos una ubicación y dirección
                const double latitude = -16.5000;
                const double longitude = -68.1500;
                const String location = 'La Paz, Bolivia';
                
                // Actualizar la ubicación en el backend
                await ref.read(petListNotifierProvider.notifier)
                  .updatePetLocation(petId, latitude, longitude, location);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ubicación actualizada correctamente')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar ubicación: $e')),
                  );
                }
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}