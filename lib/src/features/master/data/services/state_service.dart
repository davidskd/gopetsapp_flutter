import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/state.dart';

// Provider para el servicio de provincias
final stateServiceProvider = Provider<StateService>((ref) {
  return StateService();
});

// Provider para la lista de provincias por país (obtención asíncrona)
final statesByCountryProvider = FutureProvider.family<List<States>, int>((ref, countryRefId) async {
  final stateService = ref.watch(stateServiceProvider);
  return stateService.getStatesByCountry(countryRefId);
});

class StateService {
  // URL base para el API de GoPets
  final String baseUrl = 'https://gopets-services.azurewebsites.net';

  // Método para obtener la lista de provincias por país
  Future<List<States>> getStatesByCountry(int countryRefId) async {
    try {
      // Realizamos la petición HTTP al API
      final response = await http.get(
        Uri.parse('$baseUrl/states/country/$countryRefId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Verificamos si la respuesta es exitosa
      if (response.statusCode == 200) {
        // Decodificamos la respuesta JSON
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Verificamos si hay datos en la respuesta
        if (responseData.containsKey('data')) {
          final List<dynamic> statesData = responseData['data'];
          
          // Convertimos cada elemento del JSON a un objeto State
          final states = statesData
              .map((stateData) => States.fromJson(stateData))
              .toList();
          
          return states;
        } else {
          throw Exception('Formato de respuesta inesperado: no se encontró la clave "data"');
        }
      } else {
        throw Exception('Error al obtener provincias: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error en getStatesByCountry: $e');
      rethrow;
    }
  }
}