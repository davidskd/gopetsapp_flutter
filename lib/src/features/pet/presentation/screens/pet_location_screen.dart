import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uywapets_flutter/src/core/services/permission_service.dart';

class PetLocationScreen extends ConsumerStatefulWidget {
  final int petId;
  
  const PetLocationScreen({super.key, required this.petId});

  @override
  ConsumerState<PetLocationScreen> createState() => _PetLocationScreenState();
}

class _PetLocationScreenState extends ConsumerState<PetLocationScreen> {
  bool _isLoading = false;
  Position? _currentPosition;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // Método para verificar y solicitar permiso de ubicación
  Future<void> _checkLocationPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Usar el servicio de permisos para solicitar acceso a la ubicación
      final permissionService = ref.read(permissionServiceProvider);
      final hasPermission = await permissionService.requestLocationPermission();

      if (hasPermission) {
        // Si se concedió el permiso, obtenemos la ubicación actual
        await _getCurrentLocation();
      } else {
        // Si no se concedió el permiso, mostramos un mensaje explicativo
        setState(() {
          _errorMessage = 'Se requiere permiso de ubicación para esta función';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al solicitar permisos: $e';
        _isLoading = false;
      });
    }
  }

  // Método para obtener la ubicación actual
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      
      // Aquí podrías actualizar la ubicación de la mascota en la base de datos
      // Por ejemplo: petRepository.updatePetLocation(widget.petId, position.latitude, position.longitude);
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener la ubicación: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de la Mascota'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkLocationPermission,
                    child: const Text('Intentar de nuevo'),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentPosition != null) ...[
                    Text('Latitud: ${_currentPosition!.latitude}'),
                    Text('Longitud: ${_currentPosition!.longitude}'),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Actualizar ubicación'),
                  ),
                ],
              ),
            ),
    );
  }
}