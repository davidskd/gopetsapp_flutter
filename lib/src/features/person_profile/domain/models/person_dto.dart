import 'dart:convert';
import 'person.dart';

/// DTO (Data Transfer Object) para la comunicación con la API
class PersonDto {
  final String? personId;
  final String? personName;
  final String? personLastName;
  final String? personEmail;
  final String? personCellphone;
  final String? address;
  final String? city;
  final String? country;
  final String? personProfileImage;
  final String? personBirthday;
  final String? personSex;
  final String? personDocumentTypeId;
  final String? personUserId;
  final String? personUserName;
  final bool? active;

  PersonDto({
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
    this.personUserId,
    this.personUserName,
    this.active,
  });

  /// Convierte una instancia de PersonDto a un Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      if (personId != null) 'personId': personId,
      if (personName != null) 'personName': personName,
      if (personLastName != null) 'personLastName': personLastName,
      if (personEmail != null) 'personEmail': personEmail,
      if (personCellphone != null) 'personCellphone': personCellphone,
      if (personProfileImage != null) 'personProfileImage': personProfileImage,
      if (personBirthday != null) 'personBirthday': personBirthday,
      if (personSex != null) 'personSex': personSex,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (personDocumentTypeId != null) 'personDocumentTypeId': personDocumentTypeId,
      if (personUserId != null) 'personUserId': personUserId,
      if (personUserName != null) 'personUserName': personUserName,
      if (active != null) 'active': active,
    };
  }

  /// Crea una instancia de PersonDto a partir de un Map<String, dynamic>
  factory PersonDto.fromJson(Map<String, dynamic> json) {
    return PersonDto(
      personId: json['personId'],
      personName: json['personName'],
      personLastName: json['personLastName'],
      personEmail: json['personEmail'],
      personCellphone: json['personCellphone'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      personProfileImage: json['personProfileImage'],
      personBirthday: json['personBirthday'],
      personSex: json['personSex'],
      personDocumentTypeId: json['personDocumentTypeId'],
      personUserId: json['personUserId'],
      personUserName: json['personUserName'],
      active: json['active'],
    );
  }

  /// Convierte el DTO a un modelo de dominio
  Person toDomain() {
    return Person(
      personId: personId,
      personName: personName,
      personLastName: personLastName,
      personEmail: personEmail,
      personCellphone: personCellphone,
      address: address,
      city: city,
      country: country,
      personProfileImage: personProfileImage,
      personBirthday: personBirthday,
      personSex: personSex,
      personDocumentTypeId: personDocumentTypeId,
      // documentNumber no está disponible en PersonDto
      active: active,
    );
  }

  /// Crea un DTO a partir de un modelo de dominio
  factory PersonDto.fromDomain(Person person) {
    return PersonDto(
      personId: person.personId,
      personName: person.personName,
      personLastName: person.personLastName,
      personEmail: person.personEmail,
      personCellphone: person.personCellphone,
      address: person.address,
      city: person.city,
      country: person.country,
      personProfileImage: person.personProfileImage,
      personBirthday: person.personBirthday,
      personSex: person.personSex,
      personDocumentTypeId: person.personDocumentTypeId,
      // personUserId y personUserName no tienen equivalentes directos en Person
      active: person.active,
    );
  }

  /// Codifica DTO a Base64 para ciertos tipos de comunicaciones
  String toJsonEncodedBase64() {
    final jsonString = json.encode(toJson());
    final bytes = utf8.encode(jsonString);
    return base64.encode(bytes);
  }
}