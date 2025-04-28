import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/pet_repository_impl.dart'; 
import '../../domain/models/pet_dto.dart';
import '../../domain/repositories/pet_repository.dart';

/// Provider de estado para la lista de mascotas
final petsProvider = FutureProvider.autoDispose<List<PetDto>>((ref) async {
  final repository = ref.read(petRepositoryProvider);
  return repository.getPets();
});

/// Provider de estado para una mascota específica por ID
final petByIdProvider = FutureProvider.family.autoDispose<PetDto, int>((ref, id) async {
  final repository = ref.read(petRepositoryProvider);
  return repository.getPetById(id);
});

/// Provider de estado para la mascota seleccionada actualmente
final selectedPetProvider = StateProvider<PetDto?>((ref) => null);

/// Provider que mantiene la lista de mascotas en memoria (para operaciones CRUD)
final petListNotifierProvider = StateNotifierProvider<PetListNotifier, AsyncValue<List<PetDto>>>((ref) {
  final repository = ref.read(petRepositoryProvider);
  return PetListNotifier(repository);
});

/// Notifier para la lista de mascotas que maneja operaciones CRUD
class PetListNotifier extends StateNotifier<AsyncValue<List<PetDto>>> {
  final PetRepository petRepository;
  
  PetListNotifier(this.petRepository) : super(const AsyncValue.loading()) {
    loadPets();
  }
  
  /// Carga todas las mascotas
  Future<void> loadPets() async {
    try {
      state = const AsyncValue.loading();
      final pets = await petRepository.getPets();
      state = AsyncValue.data(pets);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Añade una mascota a la lista
  /* Future<void> addPet(Pet pet) async {
    try {
      final newPet = await petRepository.createPet(pet);
      state.whenData((pets) {
        state = AsyncValue.data([...pets, newPet]);
      });
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Actualiza una mascota en la lista
  Future<void> updatePet(Pet updatedPet) async {
    try {
      if (updatedPet.petId == null) {
        throw Exception('Pet ID is required for updating');
      }
      
      final updated = await petRepository.updatePet(updatedPet);
      
      state.whenData((pets) {
        state = AsyncValue.data(
          pets.map((pet) => pet.petId == updated.petId ? updated : pet).toList(),
        );
      });
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Elimina una mascota de la lista
  Future<void> deletePet(int id) async {
    try {
      final success = await petRepository.deletePet(id);
      
      if (success) {
        state.whenData((pets) {
          state = AsyncValue.data(
            pets.where((pet) => pet.petId != id).toList(),
          );
        });
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  } */
  
  /// Actualiza la ubicación de una mascota
  Future<void> updatePetLocation(int id, double latitude, double longitude, String location) async {
    try {
      final success = await petRepository.updatePetLocation(id, latitude, longitude, location);
      
      if (success) {
        state.whenData((pets) {
          state = AsyncValue.data(
            pets.map((pet) {
              if (pet.petId == id) {
                return pet;//.copyWith(
                  //latitude: latitude,
                  //longitude: longitude, 
                  //lastUpdate: DateTime.now(),
               // );
              }
              return pet;
            }).toList(),
          );
        });
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Sube una imagen para una mascota
  Future<void> uploadPetImage(int id, String imagePath) async {
    try {
      final imageUrl = await petRepository.uploadPetImage(id, imagePath);
      
      if (imageUrl != null) {
        state.whenData((pets) {
          state = AsyncValue.data(
            pets.map((pet) {
              if (pet.petId == id) {
                return pet;//.copyWith(petPrincipalImgUrl: imageUrl);
              }
              return pet;
            }).toList(),
          );
        });
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}