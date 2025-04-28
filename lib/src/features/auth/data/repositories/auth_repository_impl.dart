import '../../domain/models/token_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

/// Concrete implementation of the [AuthRepository] interface.
/// This class interacts with the [AuthService] to perform authentication
/// operations against the data source (e.g., API).
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  /// Creates an instance of [AuthRepositoryImpl].
  /// Requires an instance of [AuthService] to delegate operations to.
  AuthRepositoryImpl(this._authService);

  @override
  Future<TokenResponse> loginWithEmailPassword(String email, String password) {
    // Delegate the call to the AuthService
    return _authService.authenticate(email, password);
  }

  @override
  Future<TokenResponse> loginWithSocial(String accessToken, String provider) {
    // Delegate the call to the AuthService
    return _authService.authenticateSocial(accessToken, provider);
  }

  @override
  Future<void> logout() {
    // Delegate the call to the AuthService
    return _authService.logout();
  }

  @override
  Future<bool> isAuthenticated() {
    // Delegate the call to the AuthService
    return _authService.isAuthenticated();
  }

  @override
  Future<String?> getAccessToken() {
    // Delegate the call to the AuthService
    return _authService.getAccessToken();
  }

  // Implement other methods from AuthRepository by delegating to _authService
  // e.g.,
  // @override
  // Future<void> refreshToken() {
  //   return _authService.refreshToken(); // Assuming AuthService has this method
  // }
}
