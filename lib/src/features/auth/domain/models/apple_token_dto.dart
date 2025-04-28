import 'dart:convert';

class AppleTokenDto {
  final String? identityToken; // From Apple credential
  final String? email;

  AppleTokenDto({
    this.identityToken,
    this.email,
  });

   Map<String, dynamic> toJson() {
    return {
      'identityToken': identityToken,
      'email': email,
    };
  }

   String toJsonEncodedBase64() {
    final jsonString = jsonEncode(toJson());
    final bytes = utf8.encode(jsonString);
    return base64Encode(bytes);
  }
}
