import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../features/master/domain/models/country.dart';
import '../../features/master/data/services/country_service.dart';
import '../utils/string_utils.dart'; // Importamos el archivo de utilidades

class CountryDropdown extends ConsumerWidget {
  final String label;
  final Country? selectedCountry;
  final void Function(Country?) onChanged;
  final String? Function(Country?)? validator;
  final bool isRequired;
  final String? hintText;
  final String emptyText;
  
  const CountryDropdown({
    super.key,
    this.label = 'País',
    required this.selectedCountry,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    this.hintText,
    this.emptyText = 'No se encontraron países',
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesProvider);
    
    return countriesAsync.when(
      data: (countries) {
        // Simplemente usamos un FormField personalizado con un DropdownButton estándar
        return FormField<Country>(
          initialValue: selectedCountry,
          validator: validator ?? (isRequired ? (value) => value == null ? 'Por favor selecciona un país' : null : null),
          builder: (FormFieldState<Country> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label del campo
                Text(label, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                
                // Dropdown personalizado
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: state.hasError ? Colors.red : Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<Country>(
                    isExpanded: true,
                    underline: Container(), // Sin línea inferior adicional
                    value: selectedCountry,
                    hint: Text(
                      hintText ?? 'Selecciona un país',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    items: countries.map((Country country) {
                      return DropdownMenuItem<Country>(
                        value: country,
                        child: Row(
                          children: [
                            const Icon(Icons.flag, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                // Utilizamos nuestra función de normalización
                                normalizeText(country.countryName),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Country? value) {
                      onChanged(value);
                      state.didChange(value);
                    },
                  ),
                ),
                
                // Mensaje de error si existe
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
        ),
      ),
      error: (error, stack) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text('Error cargando países', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

String _safeDecodeString(String input) {
  try {
    return Uri.decodeComponent(input);
  } catch (e) {
    return input;
  }
}