
import '../models/pet_dto.dart';

/// Interfaz que define las operaciones disponibles para el repositorio de mascotas
abstract class PetRepository {
  /// Obtiene todas las mascotas del usuario actual
  Future<List<PetDto>> getPets();
  
  /// Obtiene una mascota por su ID
  Future<PetDto> getPetById(int id);
   
  
  /// Actualiza la ubicación geográfica de una mascota
  Future<bool> updatePetLocation(int id, double latitude, double longitude, String location);
  
  /// Carga una imagen de perfil para la mascota
  Future<String?> uploadPetImage(int petId, String imagePath);
}