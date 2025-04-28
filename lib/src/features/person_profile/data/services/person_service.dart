import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../auth/data/services/auth_service.dart';
import '../../domain/models/person_dto.dart';

/// Provider para el servicio de perfil de persona
final personServiceProvider = Provider<PersonService>((ref) {
  final authService = ref.read(authServiceProvider);
  return PersonService(authService);
});

class PersonService {
  final AuthService _authService;
  final _storage = const FlutterSecureStorage();
  final String? _host = dotenv.env['HOST'];
  final String? _hostNode = dotenv.env['HOST_NODE'];
  
  // URLs para las operaciones con perfil de persona
  late final String _urlProfile;
  late final String _urlChangePassword;
  late final String _urlUploadImage;
  late final String _urlDeleteAccount;

  PersonService(this._authService) {
    if (_host == null) {
      throw Exception("Environment variable HOST is not set.");
    }
    
    _urlProfile = '$_host/persons/user';
    _urlChangePassword = '$_host/api/v1/profile/change-password';
    _urlUploadImage = '$_host/persons/edit-image-profile';
    _urlDeleteAccount = '$_host/api/v1/profile/delete-account';
  }

  /// Obtiene los encabezados de autorización para las solicitudes API
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Obtiene el perfil del usuario actual
  Future<PersonDto> getProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(_urlProfile),
        headers: headers,
      );

      print(response);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          return PersonDto.fromJson(responseData['data']);
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to get profile: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error getting profile: $e');
      rethrow;
    }
  }

  /// Actualiza el perfil del usuario
  Future<PersonDto> updateProfile(PersonDto profileDto) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse(_urlProfile),
        headers: headers,
        body: json.encode(profileDto.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          return PersonDto.fromJson(responseData['data']);
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to update profile: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Cambia la contraseña del usuario
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(_urlChangePassword),
        headers: headers,
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  /// Carga una nueva imagen de perfil
  /// [imageBase64] puede ser la ruta de un archivo o directamente la cadena base64
  /// [isBase64] indica si imageBase64 ya es una cadena base64 o es una ruta de archivo
  Future<String> uploadProfileImage(String imageBase64, {bool isBase64 = false}) async {
    try {
      print('uploadProfileImage - Recibido: ${isBase64 ? "cadena base64" : "ruta de archivo"}');
      
      String base64Image;
      
      if (!isBase64) {
        // Si es una ruta de archivo, convertimos a base64
        final File file = File(imageBase64);
        final exists = await file.exists();
        print('uploadProfileImage - ¿El archivo existe?: $exists');
        
        if (!exists) {
          throw Exception('El archivo de imagen no existe');
        }
        
        final List<int> imageBytes = await file.readAsBytes();
        base64Image = base64Encode(imageBytes);
        print('uploadProfileImage - Archivo convertido a base64');
      } else {
        // Si ya es una cadena base64, la usamos directamente
        base64Image = imageBase64;
        print('uploadProfileImage - Usando cadena base64 proporcionada');
      }
      
      final headers = await _getAuthHeaders();
      
      print('Obtener personId y personUserId del perfil actual');
      // Obtener personId y personUserId del perfil actual
      final personDto = await getProfile();
      final String? personId = personDto.personId;
      final String? personUserId = personDto.personUserId;
      final String? currentImageUrl = personDto.personProfileImage;
      
      if (personId == null || personUserId == null) {
        throw Exception('No se pudo obtener la información del usuario para actualizar la imagen');
      }
      
      print('personId: $personId, personUserId: $personUserId');
      
      // Crear el cuerpo de la solicitud con el formato esperado por el backend
      final requestBody = json.encode({
        "personId": personId,
        "personUserId": personUserId,
        "personProfileImage": base64Image
      });
      
      print('Enviando solicitud a: $_urlUploadImage');
      
      // Enviar la solicitud
      final response = await http.put(
        Uri.parse(_urlUploadImage),
        headers: headers,
        body: requestBody,
      );
      
      print('Código de respuesta: ${response.statusCode}');
      
      // Si la respuesta es exitosa, consideramos que la imagen se subió correctamente
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Generamos un timestamp para evitar caché de imágenes
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        if (response.body.isNotEmpty) {
          try {
            // Intentamos parsear el cuerpo de la respuesta
            final responseData = json.decode(response.body) as Map<String, dynamic>;
            print('Respuesta recibida: $responseData');
            
            // Extraemos la URL de la imagen si está disponible en la respuesta
            if (responseData.containsKey('data') && 
                responseData['data'] != null &&
                responseData['data'] is Map<String, dynamic>) {
              
              final data = responseData['data'] as Map<String, dynamic>;
              if (data.containsKey('personProfileImage') && 
                  data['personProfileImage'] != null &&
                  data['personProfileImage'] is String) {
                return data['personProfileImage'] as String;
              }
            }
            
            // Si llegamos aquí, es que no pudimos encontrar la URL en el formato esperado
            print('No se encontró la URL de imagen en la respuesta');
          } catch (e) {
            print('Error al procesar la respuesta: $e');
            // Continuamos con el flujo alternativo
          }
        }
        
        // Si no podemos extraer la URL de la respuesta, intentamos refrescar el perfil
        try {
          // Esperamos un momento para que el servidor procese la imagen
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Intentar refrescar el perfil para obtener la URL actualizada
          final updatedProfile = await getProfile();
          if (updatedProfile.personProfileImage != null && 
              updatedProfile.personProfileImage!.isNotEmpty) {
            return '${updatedProfile.personProfileImage!}?t=$timestamp';
          }
        } catch (refreshError) {
          print('Error al refrescar perfil para obtener URL de imagen: $refreshError');
          // Continuamos con el flujo alternativo
        }
        
        // Última opción: devolver la URL anterior o un placeholder con timestamp
        return currentImageUrl != null 
            ? '$currentImageUrl?t=$timestamp' 
            : 'image_updated_$timestamp';
      }
      
      throw Exception('Error al subir la imagen: ${response.statusCode}');
    } catch (e) {
      print('Error en uploadProfileImage: $e');
      throw Exception('Error al actualizar imagen: $e');
    }
  }

  /// Elimina la cuenta del usuario
  Future<bool> deleteAccount(String password) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(_urlDeleteAccount),
        headers: headers,
        body: json.encode({
          'password': password,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
  
  /// Actualiza la ubicación del usuario
  /// Este método obtiene la ubicación actual del usuario y la envía al servidor
  Future<bool> updateLocation() async {
    try {
      // Obtenemos la ubicación actual usando directamente Geolocator
      // que funciona tanto en web como en móvil
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      // Obtenemos el nombre de la ubicación
      String locationName = await _getLocationName(position);
      
      // URL para actualizar la ubicación
      final updateLocationUrl = '$_hostNode/api/persons/geo';
      
      // Creamos el objeto de solicitud en el formato esperado por el API
      final requestData = {
        "location": {
          "coordinates": [
            position.longitude,
            position.latitude
          ],
          "type": "Point"
        },
        "fechaacceso": DateTime.now().toIso8601String(),
        "locationName": locationName
      };
      
      // Obtenemos los encabezados de autorización
      final headers = await _getAuthHeaders();
      
      // Realizamos la solicitud PUT al servidor
      final response = await http.put(
        Uri.parse(updateLocationUrl),
        headers: headers,
        body: json.encode(requestData),
      );
      
      // Verificamos si la solicitud fue exitosa
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Ubicación actualizada exitosamente');
        return true;
      } else {
        print('Error al actualizar ubicación: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en updateLocation: $e');
      return false; // Retornamos false en caso de error
    }
  }
  
  /// Método auxiliar para obtener el nombre de la ubicación a partir de coordenadas
  Future<String> _getLocationName(Position position) async {
    try {
      // Intentamos obtener el nombre de la ubicación
      // En plataforma web, geocoding puede no funcionar igual que en móvil
      // por lo que manejo posibles errores
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
        );
        
        // Si encontramos lugares, formateamos el primero
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Formato: "Localidad, Ciudad/Provincia"
          final locality = place.locality ?? '';
          final adminArea = place.administrativeArea ?? '';
          
          if (locality.isNotEmpty || adminArea.isNotEmpty) {
            return [if (locality.isNotEmpty) locality, if (adminArea.isNotEmpty) adminArea]
                .join(', ');
          }
        }
      } catch (geocodeError) {
        print('Error en geocoding: $geocodeError - usando coordenadas como respaldo');
      }
      
      // Si geocoding falló o no hay resultados, usamos las coordenadas como respaldo
      return 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      print('Error obteniendo nombre de ubicación: $e');
      return 'Ubicación desconocida';
    }
  }
}