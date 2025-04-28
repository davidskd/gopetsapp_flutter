import 'dart:convert';

import '../../domain/models/module.dart';
import '../../domain/repositories/module_repository.dart';
import '../services/module_service.dart';

class ModuleRepositoryImpl implements ModuleRepository {
  final ModuleService _moduleService;

  // Constructor allowing dependency injection (e.g., with Riverpod/Provider)
  ModuleRepositoryImpl(this._moduleService);

  @override
  Future<List<Module>> getModules() async {
    try {
      // 1. Fetch raw data from the service
      final String responseBody = await _moduleService.fetchActiveModules();

      // 2. Decode the JSON response
      // Assuming the API returns a structure like: { "success": bool, "data": [module_json], "message": string }
      // Adjust parsing based on the actual API response structure.
      final Map<String, dynamic> decodedResponse = jsonDecode(responseBody);

      // Check if the response indicates success and contains data
      if (decodedResponse.containsKey('data') && decodedResponse['data'] is List) {
         final List<dynamic> dataList = decodedResponse['data'];

         // 3. Map the JSON list to a List<Module>
         // This requires Module.fromJson to be implemented in the model.
         final List<Module> modules = dataList
             .map((item) => Module.fromJson(item as Map<String, dynamic>))
             .toList();

         // Optional: Sort modules based on moduleOrder if needed
         modules.sort((a, b) => a.moduleOrder.compareTo(b.moduleOrder));

         return modules;

      } else {
         // Handle cases where 'data' key is missing or not a list
         print('Error: API response format unexpected. Response: $decodedResponse');
         throw Exception('Formato de respuesta inesperado de la API.');
      }

    } catch (e) {
      // Re-throw the exception to be handled by the caller (e.g., the screen's state management)
      print('Error in ModuleRepositoryImpl: $e');
      // Consider wrapping the original exception or throwing a custom domain exception
      throw Exception('No se pudieron obtener los módulos: $e');
    }
  }
}

// TODO: Implement Module.fromJson in ../domain/models/module.dart
