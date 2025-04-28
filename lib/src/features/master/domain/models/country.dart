class Country {
  final String countryId;
  final int countryRefId;
  final String countryName;

  Country({
    required this.countryId,
    required this.countryRefId,
    required this.countryName,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryId: json['countryId'] ?? '',
      countryRefId: json['countryRefId'] ?? 0,
      countryName: json['countryName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryId': countryId,
      'countryRefId': countryRefId,
      'countryName': countryName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && runtimeType == other.runtimeType && countryId == other.countryId;

  @override
  int get hashCode => countryId.hashCode;

  @override
  String toString() => countryName;
}