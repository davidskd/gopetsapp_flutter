import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/country.dart';

// Provider para el servicio de países
final countryServiceProvider = Provider<CountryService>((ref) {
  return CountryService();
});

// Provider para la lista de países (obtención asíncrona)
final countriesProvider = FutureProvider<List<Country>>((ref) async {
  final countryService = ref.watch(countryServiceProvider);
  return countryService.getCountries();
});

class CountryService {
  // URL base para el API de GoPets
  final String baseUrl = 'https://gopets-services.azurewebsites.net';

  // Método para obtener la lista de países activos
  Future<List<Country>> getCountries() async {
    try {
      // Realizar la petición HTTP al API
      final response = await http.get(
        Uri.parse('$baseUrl/countries/actives'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Verificar si la respuesta es exitosa
      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Verificar si hay datos en la respuesta
        if (responseData.containsKey('data')) {
          final List<dynamic> countriesData = responseData['data'];
          
          // Convertir cada elemento del JSON a un objeto Country
          final countries = countriesData
              .map((countryData) => Country.fromJson(countryData))
              .toList();
          
          return countries;
        } else {
          throw Exception('Formato de respuesta inesperado: no se encontró la clave "data"');
        }
      } else {
        throw Exception('Error al obtener países: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error en getCountries: $e');
      rethrow;
    }
  }
}