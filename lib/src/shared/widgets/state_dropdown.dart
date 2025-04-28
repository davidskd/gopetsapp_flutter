import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/master/domain/models/state.dart';
import '../../features/master/data/services/state_service.dart';
import '../utils/string_utils.dart'; // Importamos las utilidades

class StateDropdown extends ConsumerWidget {
  final String label;
  final int? countryRefId;
  final States? selectedState;
  final void Function(States?) onChanged;
  final String? Function(States?)? validator;
  final bool isRequired;
  final String? hintText;
  final String emptyText;
  
  const StateDropdown({
    super.key,
    this.label = 'Provincia',
    required this.countryRefId,
    required this.selectedState,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    this.hintText,
    this.emptyText = 'No se encontraron provincias',
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si no hay país seleccionado, mostramos el dropdown deshabilitado
    if (countryRefId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<States>(
                isExpanded: true,
                hint: Text(
                  'Seleccione un país primero',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                onChanged: null, // Deshabilitado
                items: const [], // Sin items
              ),
            ),
          ),
        ],
      );
    }

    // Si hay país seleccionado, obtenemos las provincias para ese país
    final statesAsync = ref.watch(statesByCountryProvider(countryRefId!));
    
    return statesAsync.when(
      data: (states) {
        // Si no hay provincias disponibles para este país
        if (states.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<States>(
                    isExpanded: true,
                    hint: Text(
                      emptyText,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    onChanged: null, // Deshabilitado
                    items: const [], // Sin items
                  ),
                ),
              ),
            ],
          );
        }

        // FormField con dropdown para las provincias
        return FormField<States>(
          initialValue: selectedState,
          validator: validator ?? (isRequired ? (value) => value == null ? 'Por favor selecciona una provincia' : null : null),
          builder: (FormFieldState<States> state) {
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<States>(
                      isExpanded: true,
                      value: selectedState,
                      hint: Text(
                        hintText ?? 'Selecciona una provincia',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      items: states.map((States provinceState) {
                        return DropdownMenuItem<States>(
                          value: provinceState,
                          child: Text(
                            // Utilizamos la función de normalización
                            normalizeText(provinceState.stateName),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (States? value) {
                        onChanged(value);
                        state.didChange(value);
                      },
                    ),
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
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error cargando provincias: ${error.toString()}', 
                      style: const TextStyle(color: Colors.red),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
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