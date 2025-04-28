import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uywapets_flutter/src/features/person_profile/data/services/person_service.dart';
import 'package:uywapets_flutter/src/features/person_profile/domain/models/person_dto.dart';

import '../../domain/models/person.dart';
import '../../domain/repositories/person_repository.dart'; 

/// Implementación del repositorio de perfil de persona
class PersonRepositoryImpl implements PersonRepository {

  final PersonService _personService;

  // Constructor allowing dependency injection (e.g., with Riverpod/Provider)
  PersonRepositoryImpl(this._personService);

  @override
  Future<Person> getProfile() async {
    try {
      final personDto = await _personService.getProfile();
      return personDto.toDomain();
    } catch (e) {
      throw _mapException(e);
    }
  }
  
  @override
  Future<Person> updateProfile(Person person) async {
    try {
      final personDto = PersonDto.fromDomain(person);
      final updatedDto = await _personService.updateProfile(personDto);
      return updatedDto.toDomain();
    } catch (e) {
      throw _mapException(e);
    }
  }
  
  @override
  Future<String> uploadProfileImage(String imagePathOrBase64, {bool isBase64 = false}) async {
    try {
      return await _personService.uploadProfileImage(imagePathOrBase64, isBase64: isBase64);
    } catch (e) {
      throw _mapException(e);
    }
  }
  
  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      return await _personService.changePassword(currentPassword, newPassword);
    } catch (e) {
      throw _mapException(e);
    }
  }
  
  @override
  Future<bool> deleteAccount(String password) async {
    try {
      return await _personService.deleteAccount(password);
    } catch (e) {
      throw _mapException(e);
    }
  }
  
  /// Mapea las excepciones de la API a excepciones del dominio
  Exception _mapException(dynamic e) {
    if (e is Exception) {
      return e;
    }
    return Exception('Error en el repositorio: $e');
  }
}