import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../auth/data/services/auth_service.dart';
import '../../domain/models/pet_dto.dart';

/// Provider para el servicio de mascotas
final petServiceProvider = Provider<PetService>((ref) {
  final authService = ref.read(authServiceProvider);
  return PetService(authService);
});

class PetService {
  final AuthService _authService;
  final _storage = const FlutterSecureStorage();
  final String? _host = dotenv.env['HOST_NODE'];
  final String? _hosta = dotenv.env['HOST'];
  
  // URLs para las operaciones con mascotas
  late final String _urlPets;
  late final String _urlPetById;
  late final String _urlPetLocation;
  late final String _urlPetImage;

  PetService(this._authService) {
    if (_host == null) {
      throw Exception("Environment variable HOST is not set.");
    }
    
    _urlPets = '$_host/api/pets/user/actives';
    _urlPetById = '$_host/api/pets/'; // Se añade ID al hacer la petición
    _urlPetLocation = '$_host/api/v1/pets/location/'; // Se añade ID al hacer la petición
    _urlPetImage = '$_host/api/v1/pets/image/'; // Se añade ID al hacer la petición
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

  /// Obtiene todas las mascotas del usuario actual desde la API
  Future<List<PetDto>> getPets() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(_urlPets),
        headers: headers,
      );

 
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> petsJson = responseData['data'];
          //print('petsJson: $petsJson');
          return petsJson
              .map((petJson) => PetDto.fromJson(petJson as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to get pets: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error getting pets: $e');
      rethrow;
    }
  }

  /// Obtiene una mascota específica por su ID
  Future<PetDto> getPetById(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_urlPetById$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          return PetDto.fromJson(responseData['data']);
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to get pet: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error getting pet by ID: $e');
      rethrow;
    }
  }

  /// Crea una nueva mascota
  Future<PetDto> createPet(PetDto petDto) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(_urlPets),
        headers: headers,
        body: json.encode(petDto.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          return PetDto.fromJson(responseData['data']);
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to create pet: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating pet: $e');
      rethrow;
    }
  }

  /// Actualiza una mascota existente
  Future<PetDto> updatePet(PetDto petDto) async {
    if (petDto.petId == null) {
      throw Exception('Pet ID is required for updating');
    }

    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_urlPetById${petDto.petId}'),
        headers: headers,
        body: json.encode(petDto.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          return PetDto.fromJson(responseData['data']);
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to update pet: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating pet: $e');
      rethrow;
    }
  }

  /// Elimina una mascota por su ID
  Future<bool> deletePet(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_urlPetById$id'),
        headers: headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting pet: $e');
      rethrow;
    }
  }

  /// Actualiza la ubicación geográfica de una mascota
  Future<bool> updatePetLocation(int id, double latitude, double longitude, String location) async {
    try {
      final headers = await _getAuthHeaders();
      final body = json.encode({
        'latitude': latitude,
        'longitude': longitude,
        'location': location,
      });
      
      final response = await http.put(
        Uri.parse('$_urlPetLocation$id'),
        headers: headers,
        body: body,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating pet location: $e');
      rethrow;
    }
  }

  /// Carga una imagen de perfil para la mascota
  Future<String?> uploadPetImage(int petId, String imagePath) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Crear una solicitud multipart para subir la imagen
      final uri = Uri.parse('$_urlPetImage$petId');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Añadir el archivo de imagen a la solicitud
      final file = File(imagePath);
      final fileStream = http.ByteStream(file.openRead());
      final length = await file.length();
      
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: imagePath.split('/').last,
      );
      
      request.files.add(multipartFile);
      
      // Enviar la solicitud
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is String) {
          // La API devuelve la URL de la imagen subida
          return responseData['data'];
        }
      }
      
      throw Exception('Failed to upload image: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error uploading pet image: $e');
      rethrow;
    }
  }
}