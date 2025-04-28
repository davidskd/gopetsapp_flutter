/// Modelo para representar imágenes de mascotas
class PetImageDto {
  final String? petImgId;
  final String? petImgB64;
  final bool? petImgIsActive;
  final bool? petImgIsPrincipal;
  final String? petImgPetId;
  final String? petImgUrl;

  PetImageDto({
    this.petImgId,
    this.petImgB64,
    this.petImgIsActive,
    this.petImgIsPrincipal,
    this.petImgPetId,
    this.petImgUrl,
  });

  /// Convierte una instancia de PetImageDto a un Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'petImgId': petImgId,
      'petImgB64': petImgB64,
      'petImgIsActive': petImgIsActive,
      'petImgIsPrincipal': petImgIsPrincipal,
      'petImgPetId': petImgPetId,
      'petImgUrl': petImgUrl,
    };
  }

  /// Crea una instancia de PetImageDto a partir de un Map<String, dynamic>
  factory PetImageDto.fromJson(Map<String, dynamic> json) {
    return PetImageDto(
      petImgId: json['petImgId'],
      petImgB64: json['petImgB64'],
      petImgIsActive: json['petImgIsActive'],
      petImgIsPrincipal: json['petImgIsPrincipal'],
      petImgPetId: json['petImgPetId'],
      petImgUrl: json['petImgUrl'],
    );
  }
}