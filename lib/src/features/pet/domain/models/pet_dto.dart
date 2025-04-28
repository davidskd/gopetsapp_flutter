import 'dart:convert';  

import 'pet_image_dto.dart';

/// Clase BlockPet para bloquear mascotas
class BlockPet {
  final String? petId;

  const BlockPet({
    this.petId,
  });

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
    };
  }

  factory BlockPet.fromJson(Map<String, dynamic> json) {
    return BlockPet(
      petId: json['petId'],
    );
  }
}

/// Clase ReportPet para reportar mascotas
class ReportPet {
  final String? petId;

  const ReportPet({
    this.petId,
  });

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
    };
  }

  factory ReportPet.fromJson(Map<String, dynamic> json) {
    return ReportPet(
      petId: json['petId'],
    );
  }
}

/// Data Transfer Object para enviar/recibir datos de mascota desde la API
class PetDto {
  final String? petId;
  final String? petName;
  final String? petUserId;
  final String? petBreedId;
  final String? petBreedName;
  final String? petSex;
  final String? petSexName;
  final String? petAnimalId;
  final String? petAnimalName;
  final bool? petIsActive;
  final DateTime? petCreatedAt;
  final double? petWeight;
  final bool? petIsPedigree;
  final bool? petHaveVacuumns;
  final int? petOld;
  final List<PetImageDto>? petImgs;
  final double? distanceInMeters;
  final String? typeDistance;
  final String? petTypeOld;
  
  final bool? petIsFollowing;
  final String? petOwner;
  
  final String? animalId;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final int? size;
  final int? page;
  final int? oldMin;
  final int? oldMax;
  final bool? haveVacuums;
  final String? sex;
  final bool? isPedigree;
  final String? breedId;
  final String? petstateIdName;
  final String? cityId;
  final String? countryId;
  final String? stateId;
  
  final String? matchPetFrom;
  final String? matchPetTo;
  
  final String? color;
  
  final String? petFrom;
  final String? petTo;
  final String? status;
  
  final String? petToFollowId;
  final String? petFollowId;
  
  final String? petLoggedId;
  
  final String? matchId;
  
  final String? matchPetFromName;
  final String? matchPetBreedFromName;
  
  final String? matchPetFromImgs;
  final String? matchUserIdFrom;
  final String? matchUserIdTo;
  
  final int? likesCount;
  final int? matchsCount;
  
  final String? petPrincipalImgUrl;
  
  final BlockPet blockPet;
  final ReportPet reportToPet;
  
  final String? blockPetId;
  
  final String? reportPetId;
  final String? reportDescription;
  final String? reportType;
  final String? reportDataId;
  final bool? petIsSuperUser;
  
  final String? locationName;
  
  final bool? petisActiveReminderBath;
  final bool? petisActiveReminderVaccine;
  final bool? petisActiveReminderAppointment;

  PetDto({
    this.petId,
    this.petName,
    this.petUserId,
    this.petBreedId,
    this.petBreedName,
    this.petSex,
    this.petSexName,
    this.petAnimalId,
    this.petAnimalName,
    this.petIsActive,
    this.petCreatedAt,
    this.petWeight,
    this.petIsPedigree,
    this.petHaveVacuumns,
    this.petOld,
    this.petImgs,
    this.distanceInMeters,
    this.typeDistance,
    this.petTypeOld,
    this.petIsFollowing,
    this.petOwner,
    this.animalId,
    this.latitude,
    this.longitude,
    this.distance,
    this.size,
    this.page,
    this.oldMin,
    this.oldMax,
    this.haveVacuums,
    this.sex,
    this.isPedigree,
    this.breedId,
    this.petstateIdName,
    this.cityId,
    this.countryId,
    this.stateId,
    this.matchPetFrom,
    this.matchPetTo,
    this.color,
    this.petFrom,
    this.petTo,
    this.status,
    this.petToFollowId,
    this.petFollowId,
    this.petLoggedId,
    this.matchId,
    this.matchPetFromName,
    this.matchPetBreedFromName,
    this.matchPetFromImgs,
    this.matchUserIdFrom,
    this.matchUserIdTo,
    this.likesCount,
    this.matchsCount,
    this.petPrincipalImgUrl,
    this.blockPet = const BlockPet(),
    this.reportToPet = const ReportPet(),
    this.blockPetId,
    this.reportPetId,
    this.reportDescription,
    this.reportType,
    this.reportDataId,
    this.petIsSuperUser,
    this.locationName,
    this.petisActiveReminderBath,
    this.petisActiveReminderVaccine,
    this.petisActiveReminderAppointment,
  });


  /// Serialización a JSON
  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'petName': petName,
      'petUserId': petUserId,
      'petBreedId': petBreedId,
      'petBreedName': petBreedName,
      'petSex': petSex,
      'petSexName': petSexName,
      'petAnimalId': petAnimalId,
      'petAnimalName': petAnimalName,
      'petIsActive': petIsActive,
      'petCreatedAt': petCreatedAt?.toIso8601String(),
      'petWeight': petWeight,
      'petIsPedigree': petIsPedigree,
      'petHaveVacuumns': petHaveVacuumns,
      'petOld': petOld,
      'petImgs': petImgs?.map((img) => img.toJson()).toList(),
      'distanceInMeters': distanceInMeters,
      'typeDistance': typeDistance,
      'petTypeOld': petTypeOld,
      'petIsFollowing': petIsFollowing,
      'petOwner': petOwner,
      'animalId': animalId,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'size': size,
      'page': page,
      'oldMin': oldMin,
      'oldMax': oldMax,
      'haveVacuums': haveVacuums,
      'sex': sex,
      'isPedigree': isPedigree,
      'breedId': breedId,
      'petstateIdName': petstateIdName,
      'cityId': cityId,
      'countryId': countryId,
      'stateId': stateId,
      'matchPetFrom': matchPetFrom,
      'matchPetTo': matchPetTo,
      'color': color,
      'petFrom': petFrom,
      'petTo': petTo,
      'status': status,
      'petToFollowId': petToFollowId,
      'petFollowId': petFollowId,
      'petLoggedId': petLoggedId,
      'matchId': matchId,
      'matchPetFromName': matchPetFromName,
      'matchPetBreedFromName': matchPetBreedFromName,
      'matchPetFromImgs': matchPetFromImgs,
      'matchUserIdFrom': matchUserIdFrom,
      'matchUserIdTo': matchUserIdTo,
      'likesCount': likesCount,
      'matchsCount': matchsCount,
      'petPrincipalImgUrl': petPrincipalImgUrl,
      'blockPet': blockPet.toJson(),
      'reportToPet': reportToPet.toJson(),
      'blockPetId': blockPetId,
      'reportPetId': reportPetId,
      'reportDescription': reportDescription,
      'reportType': reportType,
      'reportDataId': reportDataId,
      'petIsSuperUser': petIsSuperUser,
      'locationName': locationName,
      'petisActiveReminderBath': petisActiveReminderBath,
      'petisActiveReminderVaccine': petisActiveReminderVaccine,
      'petisActiveReminderAppointment': petisActiveReminderAppointment,
    };
  }

  /// Deserialización desde JSON
  factory PetDto.fromJson(Map<String, dynamic> json) {
    return PetDto(
      petId: json['petId'],
      petName: json['petName'],
      petUserId: json['petUserId'],
      petBreedId: json['petBreedId'],
      petBreedName: json['petBreedName'],
      petSex: json['petSex'],
      petSexName: json['petSexName'],
      petAnimalId: json['petAnimalId'],
      petAnimalName: json['petAnimalName'],
      petIsActive: json['petIsActive'],
      petCreatedAt: json['petCreatedAt'] != null 
          ? DateTime.parse(json['petCreatedAt']) 
          : null,
      petWeight: json['petWeight'] is num 
          ? (json['petWeight'] as num).toDouble() 
          : null,
      petIsPedigree: json['petIsPedigree'],
      petHaveVacuumns: json['petHaveVacuumns'],
      petOld: json['petOld'],
      petImgs: json['petImgs'] != null
          ? (json['petImgs'] as List)
              .map((item) => PetImageDto.fromJson(item))
              .toList()
          : null,
      distanceInMeters: json['distanceInMeters'] is num 
          ? (json['distanceInMeters'] as num).toDouble() 
          : null,
      typeDistance: json['typeDistance'],
      petTypeOld: json['petTypeOld'],
      petIsFollowing: json['petIsFollowing'],
      petOwner: json['petOwner'],
      animalId: json['animalId'],
      latitude: json['latitude'] is num 
          ? (json['latitude'] as num).toDouble() 
          : null,
      longitude: json['longitude'] is num 
          ? (json['longitude'] as num).toDouble() 
          : null,
      distance: json['distance'] is num 
          ? (json['distance'] as num).toDouble() 
          : null,
      size: json['size'],
      page: json['page'],
      oldMin: json['oldMin'],
      oldMax: json['oldMax'],
      haveVacuums: json['haveVacuums'],
      sex: json['sex'],
      isPedigree: json['isPedigree'],
      breedId: json['breedId'],
      petstateIdName: json['petstateIdName'],
      cityId: json['cityId'],
      countryId: json['countryId'],
      stateId: json['stateId'],
      matchPetFrom: json['matchPetFrom'],
      matchPetTo: json['matchPetTo'],
      color: json['color'],
      petFrom: json['petFrom'],
      petTo: json['petTo'],
      status: json['status'],
      petToFollowId: json['petToFollowId'],
      petFollowId: json['petFollowId'],
      petLoggedId: json['petLoggedId'],
      matchId: json['matchId'],
      matchPetFromName: json['matchPetFromName'],
      matchPetBreedFromName: json['matchPetBreedFromName'],
      matchPetFromImgs: json['matchPetFromImgs'],
      matchUserIdFrom: json['matchUserIdFrom'],
      matchUserIdTo: json['matchUserIdTo'],
      likesCount: json['likesCount'],
      matchsCount: json['matchsCount'],
      petPrincipalImgUrl: json['petPrincipalImgUrl'],
      blockPet: json['blockPet'] != null 
          ? BlockPet.fromJson(json['blockPet']) 
          : const BlockPet(),
      reportToPet: json['reportToPet'] != null 
          ? ReportPet.fromJson(json['reportToPet']) 
          : const ReportPet(),
      blockPetId: json['blockPetId'],
      reportPetId: json['reportPetId'],
      reportDescription: json['reportDescription'],
      reportType: json['reportType'],
      reportDataId: json['reportDataId'],
      petIsSuperUser: json['petIsSuperUser'],
      locationName: json['locationName'],
      petisActiveReminderBath: json['petisActiveReminderBath'],
      petisActiveReminderVaccine: json['petisActiveReminderVaccine'],
      petisActiveReminderAppointment: json['petisActiveReminderAppointment'],
    );
  }

  /// Codifica DTO a Base64 para ciertos tipos de comunicaciones
  String toJsonEncodedBase64() {
    final jsonString = json.encode(toJson());
    final bytes = utf8.encode(jsonString);
    return base64.encode(bytes);
  }
}