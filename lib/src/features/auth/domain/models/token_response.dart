/// Represents the response received after successful authentication.
class TokenResponse {
  final String accessToken;
  final String tokenType;
  final String refreshToken;
  final int expiresIn;
  final String scope;
  // Add any other fields returned by your API, e.g., jti

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.refreshToken,
    required this.expiresIn,
    required this.scope,
    // Add other fields here
  });

  /// Creates a TokenResponse from a JSON map.
  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      scope: json['scope'] as String,
      // Map other fields here
    );
  }

  /// Converts this TokenResponse instance to a JSON map.
  /// Useful for storing the entire response if needed, though typically
  /// you'd store tokens individually and securely.
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'scope': scope,
      // Add other fields here
    };
  }
}
