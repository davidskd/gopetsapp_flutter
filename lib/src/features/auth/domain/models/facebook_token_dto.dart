import 'dart:convert';

class FacebookTokenDto {
  final String? token; // Corresponds to idToken from Firebase Auth credential? Or FB Access Token? Angular code uses idToken.
  final String? birthday;
  final String? email;
  final String? picture;
  final String? userId; // Firebase User ID (uid)
  final String? firstName;
  final String? lastName;

  FacebookTokenDto({
    this.token,
    this.birthday,
    this.email,
    this.picture,
    this.userId,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'birthday': birthday,
      'email': email,
      'picture': picture,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  String toJsonEncodedBase64() {
    final jsonString = jsonEncode(toJson());
    final bytes = utf8.encode(jsonString);
    return base64Encode(bytes);
  }
}
