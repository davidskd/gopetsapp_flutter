import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/person_service.dart';
import '../../data/repositories/person_repository_impl.dart';
import '../../domain/models/person.dart';
import '../../domain/repositories/person_repository.dart';

/// Provider para el repositorio de persona
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final personService = ref.watch(personServiceProvider);
  return PersonRepositoryImpl(personService);
});

/// Provider para obtener el perfil de persona
final profileProvider = FutureProvider<Person>((ref) async {
  final repository = ref.watch(personRepositoryProvider);
  return await repository.getProfile();
});

/// Provider para manejar las operaciones de edición del perfil
final profileEditProvider = StateNotifierProvider<ProfileEditNotifier, AsyncValue<Person>>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  
  // Obtenemos el perfil actual si está disponible, o creamos uno vacío
  final currentProfile = ref.watch(profileProvider).valueOrNull ?? const Person();
  
  return ProfileEditNotifier(repository, currentProfile);
});

/// Provider para manejar el cambio de contraseña
final passwordChangeProvider = StateNotifierProvider<PasswordChangeNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return PasswordChangeNotifier(repository);
});

/// Provider para manejar la eliminación de la cuenta
final accountDeletionProvider = StateNotifierProvider<AccountDeletionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return AccountDeletionNotifier(repository);
});

/// Notifier para las operaciones de edición del perfil
class ProfileEditNotifier extends StateNotifier<AsyncValue<Person>> {
  final PersonRepository _repository;
  final Person _initialProfile;
  
  ProfileEditNotifier(this._repository, this._initialProfile) 
      : super(AsyncValue.data(_initialProfile));
  
  /// Actualiza el perfil del usuario
  Future<void> updateProfile(Person updatedProfile) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateProfile(updatedProfile);
      state = AsyncValue.data(updated);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  /// Sube una imagen de perfil
  /// [imagePathOrBase64] puede ser la ruta de un archivo o directamente la cadena base64
  /// [isBase64] indica si se está enviando una cadena base64 directamente o una ruta de archivo
  Future<void> uploadProfileImage(String imagePathOrBase64, {bool isBase64 = false}) async {
    state = const AsyncValue.loading();
    try {
      final imageUrl = await _repository.uploadProfileImage(imagePathOrBase64, isBase64: isBase64);
      // Actualizar el perfil con la nueva imagen
      if (state.hasValue && state.valueOrNull != null) {
        final currentPerson = state.valueOrNull!;
        final updatedPerson = currentPerson.copyWith(personProfileImage: imageUrl);
        state = AsyncValue.data(updatedPerson);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  /// Restaura el estado al perfil inicial
  void reset() {
    state = AsyncValue.data(_initialProfile);
  }
}

/// Notifier para las operaciones de cambio de contraseña
class PasswordChangeNotifier extends StateNotifier<AsyncValue<void>> {
  final PersonRepository _repository;
  
  PasswordChangeNotifier(this._repository) : super(const AsyncValue.data(null));
  
  /// Cambia la contraseña del usuario
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.changePassword(currentPassword, newPassword);
      state = const AsyncValue.data(null);
      return success;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Notifier para las operaciones de eliminación de cuenta
class AccountDeletionNotifier extends StateNotifier<AsyncValue<void>> {
  final PersonRepository _repository;
  
  AccountDeletionNotifier(this._repository) : super(const AsyncValue.data(null));
  
  /// Elimina la cuenta del usuario
  Future<bool> deleteAccount(String password) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.deleteAccount(password);
      state = const AsyncValue.data(null);
      return success;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}