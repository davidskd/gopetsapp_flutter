import '../models/person.dart';

/// Interfaz para el repositorio de perfil de persona
abstract class PersonRepository {
  /// Obtiene el perfil del usuario actual
  Future<Person> getProfile();
  
  /// Actualiza el perfil del usuario
  Future<Person> updateProfile(Person person);
  
  /// Sube una imagen de perfil 
  /// [imagePathOrBase64] puede ser la ruta de un archivo o directamente la cadena base64
  /// [isBase64] indica si se está enviando una cadena base64 directamente o una ruta de archivo
  Future<String> uploadProfileImage(String imagePathOrBase64, {bool isBase64 = false});
  
  /// Cambia la contraseña del usuario
  Future<bool> changePassword(String currentPassword, String newPassword);
  
  /// Elimina la cuenta del usuario (requiere contraseña para confirmación)
  Future<bool> deleteAccount(String password);
}