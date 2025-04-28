import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:http/http.dart' as http;
import 'package:uywapets_flutter/src/features/auth/data/services/auth_service.dart'; // Import AuthService and its provider
// TODO: Import a shared error handler or define specific exceptions if needed

/// Provider for ModuleService
final moduleServiceProvider = Provider<ModuleService>((ref) {
  final authService = ref.watch(authServiceProvider); // Depend on AuthService provider
  return ModuleService(authService);
});

class ModuleService {
  final AuthService _authService; // Add AuthService dependency
  // Get the base URL from environment variables
  final String? _baseUrl = dotenv.env['HOST_NODE'];

  // Constructor requiring AuthService
  ModuleService(this._authService);

  /// Fetches the list of active modules from the backend API.
  ///
  /// Returns the raw response body as a String on success.
  /// Throws an exception if the request fails or the base URL is not set.
  Future<String> fetchActiveModules() async {
    if (_baseUrl == null) {
      throw Exception('HOST_NODE environment variable is not set.');
    }

    final url = Uri.parse('$_baseUrl/api/modules/actives');
    print('Fetching modules from: $url'); // For debugging

    try {
      // Get the access token from AuthService
      final String? token = await _authService.getAccessToken();

      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add Authorization header
        },
      );

      if (response.statusCode == 200) {
        // Return the raw response body for the repository to handle parsing
        return response.body;
      } else {
        // Handle different HTTP error statuses
        print('Error fetching modules: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load modules (Status code: ${response.statusCode})');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Error fetching modules: $e');
      throw Exception('Failed to load modules: $e');
    }
  }
}
