import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:uywapets_flutter/src/features/modules/data/repositories/module_repository_impl.dart'; // Import Impl
import 'package:uywapets_flutter/src/features/modules/data/services/module_service.dart'; // Import Service Provider
import '../models/module.dart';

/// Provider for ModuleRepository
final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  final moduleService = ref.watch(moduleServiceProvider); // Depend on ModuleService provider
  return ModuleRepositoryImpl(moduleService);
});

abstract class ModuleRepository {
  /// Fetches the list of available modules.
  ///
  /// Throws an exception if the request fails.
  Future<List<Module>> getModules();
}
