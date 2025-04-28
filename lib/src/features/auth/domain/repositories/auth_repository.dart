import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uywapets_flutter/src/features/auth/data/repositories/auth_repository_impl.dart'; // Import implementation
import 'package:uywapets_flutter/src/features/auth/data/services/auth_service.dart'; // Import AuthService provider
import '../models/token_response.dart'; // Assuming TokenResponse is the primary model for login success

/// Provider for the AuthRepository interface.
/// This allows different parts of the app to access the repository implementation
/// without being directly coupled to it.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Watch the AuthService provider to get its instance
  final authService = ref.watch(authServiceProvider);
  // Pass the AuthService instance to the AuthRepositoryImpl constructor
  return AuthRepositoryImpl(authService);
});

/// Abstract interface for authentication operations.
/// This defines the contract that the application layers (e.g., presentation)
/// will use to interact with authentication features, decoupling them from
/// the specific data source implementation (API service).
abstract class AuthRepository {

  /// Authenticates a user with email and password.
  /// Returns a [TokenResponse] on success.
  /// Throws an exception on failure.
  Future<TokenResponse> loginWithEmailPassword(String email, String password);

  /// Authenticates a user using a social provider token.
  /// Returns a [TokenResponse] on success.
  /// Throws an exception on failure.
  Future<TokenResponse> loginWithSocial(String accessToken, String provider);

  /// Logs the current user out.
  /// Handles token revocation and local token clearing.
  Future<void> logout();

  /// Checks if a user is currently authenticated (e.g., has valid tokens stored).
  /// Note: This might just check for token existence locally.
  /// A more robust check might involve validating the token against the server.
  Future<bool> isAuthenticated();

  /// Retrieves the currently stored access token, if any.
  Future<String?> getAccessToken();

  // Add other methods as needed, mirroring the capabilities required by the app
  // and provided by the AuthService, e.g.:
  // Future<void> refreshToken();
  // Future<User> getUserProfile();
  // Future<void> changePassword(String oldPassword, String newPassword);
  // Future<void> requestPasswordRecovery(String email);
  // Future<void> verifyOtp(String otp);
}
