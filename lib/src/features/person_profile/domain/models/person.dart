import 'dart:convert';

/// Clase de modelo para la información del perfil de usuario
class Person {
  final String? personId;
  final String? personName;
  final String? personLastName;
  final String? personEmail;
  final String? personCellphone;
  final String? personProfileImage;
  final String? address;
  final String? city;
  final String? country;
  final String? personSex;
  final String? personBirthday; 
  final String? personDocumentTypeId;
  final String? personUserId;
  final String? personUserName;
  final bool? active;
  
  const Person({
    this.personId,
    this.personName,
    this.personLastName,
    this.personEmail,
    this.personCellphone,
    this.address,
    this.city,
    this.country,
    this.personProfileImage,
    this.personBirthday,
    this.personSex,
    this.personDocumentTypeId, 
    this.active,
    this.personUserId,
    this.personUserName
  });
  
  /// Obtiene el nombre completo del usuario
  String get fullName {
    if (personName != null && personLastName != null) {
      return '$personName $personLastName';
    } else if (personName != null) {
      return personName!;
    } else if (personLastName != null) {
      return personLastName!;
    } else {
      return 'Usuario';
    }
  }
  
  /// Convierte una instancia de Person a un Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      if (personId != null) 'personId': personId,
      if (personName != null) 'personName': personName,
      if (personLastName != null) 'personLastName': personLastName,
      if (personEmail != null) 'personEmail': personEmail,
      if (personCellphone != null) 'personCellphone': personCellphone,
      if (personProfileImage != null) 'personProfileImage': personProfileImage,
      if (personBirthday != null) 'personBirthday': personBirthday,
      if (personSex != null) 'gender': personSex,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (personDocumentTypeId != null) 'personDocumentTypeId': personDocumentTypeId,
      if (personUserName != null) 'personUserName': personUserName,
      if (personUserId != null) 'personUserId': personUserId,
    };
  }

  /// Crea una instancia de Person a partir de un Map<String, dynamic>
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      personId: json['personId'],
      personName: json['personName'],
      personLastName: json['personLastName'],
      personEmail: json['personEmail'],
      personCellphone: json['personCellphone'],
      personProfileImage: json['personProfileImage'],
      personBirthday: json['personBirthday'],
      personSex: json['personSex'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      personDocumentTypeId: json['personDocumentTypeId'],
      personUserName: json['personUserName'],
      personUserId: json['personUserId'],
    );
  }

  /// Crea una copia del objeto con algunos campos actualizados
  Person copyWith({
    String? personId,
    String? personName,
    String? personLastName,
    String? personEmail,
    String? personCellphone,
    String? address,
    String? city,
    String? country,
    String? personProfileImage,
    String? personBirthday,
    String? personSex,
    String? personDocumentTypeId,
    String? personUserName,
    String? personUserId,
  }) {
    return Person(
      personId: personId ?? this.personId,
      personName: personName ?? this.personName,
      personLastName: personLastName ?? this.personLastName,
      personEmail: personEmail ?? this.personEmail,
      personCellphone: personCellphone ?? this.personCellphone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      personProfileImage: personProfileImage ?? this.personProfileImage,
      personBirthday: personBirthday ?? this.personBirthday,
      personSex: personSex ?? this.personSex,
      personDocumentTypeId: personDocumentTypeId ?? this.personDocumentTypeId,
      personUserName: personUserName ?? this.personUserName,
      personUserId: personUserId ?? this.personUserId,
    );
  }
}