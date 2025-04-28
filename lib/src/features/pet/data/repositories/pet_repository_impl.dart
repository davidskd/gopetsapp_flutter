import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import '../../domain/models/pet_dto.dart';
import '../../domain/repositories/pet_repository.dart';
import '../services/pet_service.dart';

/// Provider para el repositorio de mascotas
final petRepositoryProvider = Provider<PetRepository>((ref) {
  final petService = ref.read(petServiceProvider);
  return PetRepositoryImpl(petService);
});

/// Implementación del repositorio de mascotas
class PetRepositoryImpl implements PetRepository {
  final PetService _petService;

  PetRepositoryImpl(this._petService);

  @override
  Future<List<PetDto>> getPets() async {
    try {
      final dtos = await _petService.getPets();
      return dtos;
    } catch (e) {
      throw Exception('Error al obtener mascotas: $e');
    }
  }

  @override
  Future<PetDto> getPetById(int id) async {
    try {
      final dto = await _petService.getPetById(id);
      return dto;//.toDomain();
    } catch (e) {
      throw Exception('Error al obtener mascota con ID $id: $e');
    }
  }

 
  

  @override
  Future<bool> deletePet(int id) async {
    try {
      return await _petService.deletePet(id);
    } catch (e) {
      throw Exception('Error al eliminar mascota con ID $id: $e');
    }
  }

  @override
  Future<bool> updatePetLocation(int id, double latitude, double longitude, String location) async {
    try {
      return await _petService.updatePetLocation(id, latitude, longitude, location);
    } catch (e) {
      throw Exception('Error al actualizar ubicación de mascota: $e');
    }
  }

  @override
  Future<String?> uploadPetImage(int petId, String imagePath) async {
    try {
      return await _petService.uploadPetImage(petId, imagePath);
    } catch (e) {
      throw Exception('Error al subir imagen de mascota: $e');
    }
  }
}