import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/models/token_response.dart';
// Import other necessary models (User, Person, etc.) when needed

/// Provider for the AuthService.
final authServiceProvider = Provider<AuthService>((ref) {
  // AuthService seems to handle its own dependencies (dotenv, http, secure_storage) internally.
  return AuthService();
});

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String? _host = dotenv.env['HOST'];
  final String? _clientId = dotenv.env['CLIENT_ID'];
  final String? _clientSecret = dotenv.env['CLIENT_SECRET'];

  // --- URLs ---
  // It's good practice to check if env variables are loaded
  late final String _urlOauth;
  late final String _urlOauthSocial;
  late final String _urlRevokeToken;
  // Add other URLs from Angular service as needed

  AuthService() {
    // Initialize URLs, potentially throwing an error if env vars are missing
    if (_host == null || _clientId == null || _clientSecret == null) {
      throw Exception("Environment variables HOST, CLIENT_ID, or CLIENT_SECRET are not set.");
    }
    _urlOauth = '$_host/generate-token';
    _urlOauthSocial = '$_host/authenticate-social';
    _urlRevokeToken = '$_host/v2/revoke-token';
    // Initialize other URLs...
  }

  String _getBasicAuthHeader() {
    final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
    return 'Basic $credentials';
  }

  Future<String?> getFcmToken() async {
    // TODO: Implement actual FCM token retrieval logic for Flutter
    // For now, returning a placeholder or null
    // Potentially read from secure storage if saved previously
    return await _storage.read(key: 'fcmToken') ?? 'dummy_fcm_token_for_flutter'; // Placeholder
  }

  /// Authenticates the user with username and password.
  Future<TokenResponse> authenticate(String username, String password) async {
    final fcmToken = await getFcmToken();
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Application-Credentials': _getBasicAuthHeader(),
      'fcm-token': fcmToken ?? '', // Handle null case
    };
    final body = {
      'grant_type': 'password',
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(_urlOauth),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Assuming the API returns a JSON object directly containing the token fields
        // Adjust parsing based on the actual API response structure (e.g., if nested under 'data')
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Check if the actual token data is nested, e.g., under a 'data' key
        if (responseData.containsKey('data') && responseData['data'] is Map) {
           final tokenResponse = TokenResponse.fromJson(responseData['data'] as Map<String, dynamic>);
           await _saveTokens(tokenResponse); // Save tokens upon successful login
           return tokenResponse;
        } else {
          // Handle cases where the structure is different or unexpected
           throw Exception('Unexpected API response structure for token data.');
        }

      } else {
        // Handle error responses (e.g., 400, 401, 500)
        // You might want to parse the error message from response.body
        throw Exception('Failed to authenticate: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // Handle network errors or parsing errors
      print('Error during authentication: $e');
      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

  /// Authenticates the user using social provider credentials.
  /// The `payload` can be an ID token (Google) or a base64 encoded DTO (Facebook, Apple).
  Future<TokenResponse> authenticateSocial(String payload, String authProvider) async {
     final fcmToken = await getFcmToken();
     final Map<String, String> headers = {
      'Content-Type': 'application/json', // Keep as JSON based on Angular service
      'Auth-Provider': authProvider, // GOOGLE, FACEBOOK, APPLE
      'Application-Credentials': _getBasicAuthHeader(),
      'fcm-token': fcmToken ?? '',
      // The 'credential' header value depends on the provider
      'credential': (authProvider == 'GOOGLE') ? 'Bearer $payload' : payload,
    };
    // The body seems to be empty based on the Angular implementation for social login
    final body = json.encode({});

    //print('Authenticating with $authProvider...');
    //print('Headers: $headers');
    // print('Payload: $payload'); // Avoid printing sensitive tokens/DTOs in production

    try {
      final response = await http.post(
        Uri.parse(_urlOauthSocial),
        headers: headers,
        body: body,
      );

       if (response.statusCode == 200) {
         final Map<String, dynamic> responseData = json.decode(response.body);
         if (responseData.containsKey('data') && responseData['data'] is Map) {
           final tokenResponse = TokenResponse.fromJson(responseData['data'] as Map<String, dynamic>);
           
           print('Guardando token: $tokenResponse');
           await _saveTokens(tokenResponse);
           return tokenResponse;
         } else {
            throw Exception('Unexpected API response structure for social token data.');
         }
       } else {
         throw Exception('Failed to authenticate with social provider: ${response.statusCode} ${response.body}');
       }
    } catch (e) {
      print('Error during social authentication: $e');
      rethrow;
    }
  }

  /// Saves access and refresh tokens securely.
  Future<void> _saveTokens(TokenResponse tokenResponse) async {
    await _storage.write(key: 'accessToken', value: tokenResponse.accessToken);
    await _storage.write(key: 'refreshToken', value: tokenResponse.refreshToken);
    // Optionally save other details like expiry time if needed for proactive refresh
  }

  /// Retrieves the stored access token.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  /// Retrieves the stored refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  /// Checks if the user is currently authenticated (has tokens).
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
    // Note: This doesn't check token validity. A check against expiry or a validation endpoint might be needed.
  }

  /// Clears the stored tokens (logout).
  Future<void> logout() async {
    // Optional: Call the revoke token endpoint before clearing local tokens
    try {
      await _revokeToken();
    } catch (e) {
      print("Error revoking token (proceeding with local logout): $e");
      // Decide if logout should fail if revoke fails, or just log and continue
    }
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    // Clear any other related stored data (e.g., user profile)
  }

  /// Calls the revoke token endpoint.
  Future<void> _revokeToken() async {
    final fcmToken = await getFcmToken();
    final accessToken = await getAccessToken(); // Need access token for user ID usually

    if (accessToken == null) {
      print("No access token found, cannot revoke.");
      return; // Or throw an error?
    }

    // --- Need to decode token to get userId ---
    // This requires a JWT decoding library (e.g., dart_jsonwebtoken or similar)
    // Or, if the userId is available elsewhere (e.g., stored after login), use that.
    // Placeholder: Assume userId is obtained somehow.
    String? userId; // = decodeToken(accessToken)['userId']; // Pseudocode

    if (userId == null) {
       print("Could not extract userId from token, cannot revoke.");
       // Potentially try revoking without userId if the API allows?
       return;
    }
    // --- End of token decoding section ---


    final concat = "$fcmToken|$userId"; // As per Angular service

    final headers = {
      // Authorization might be needed depending on the endpoint security
      // 'Authorization': 'Bearer $accessToken',
      'fcm-token': concat,
    };

     try {
      final response = await http.delete(
        Uri.parse(_urlRevokeToken),
        headers: headers,
      );

       if (response.statusCode != 200 && response.statusCode != 204) {
         // Handle revoke error
         throw Exception('Failed to revoke token: ${response.statusCode} ${response.body}');
       }
       print("Token revoked successfully.");
     } catch (e) {
       print('Error during token revocation: $e');
       rethrow;
     }
  }

  // --- TODO: Implement other methods from Angular AuthService ---
  // - refreshToken()
  // - checkTokenValidity() (if needed, API might not have direct equivalent to /oauth/check_token)
  // - SMS/OTP/Email verification methods
  // - recoverAccount()
  // - deleteAccount()
  // - changePassword()
  // - getPerson() / saveImage() etc.

}
