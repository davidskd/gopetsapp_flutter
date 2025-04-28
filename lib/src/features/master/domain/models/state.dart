class States {
  final String stateId;
  final int stateRefId;
  final int stateCountryRefId;
  final String stateName;

  States({
    required this.stateId,
    required this.stateRefId,
    required this.stateCountryRefId,
    required this.stateName,
  });

  factory States.fromJson(Map<String, dynamic> json) {
    return States(
      stateId: json['stateId'] ?? '',
      stateRefId: json['stateRefId'] ?? 0,
      stateCountryRefId: json['stateCountryRefId'] ?? 0,
      stateName: json['stateName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stateId': stateId,
      'stateRefId': stateRefId,
      'stateCountryRefId': stateCountryRefId,
      'stateName': stateName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is States && runtimeType == other.runtimeType && stateId == other.stateId;

  @override
  int get hashCode => stateId.hashCode;

  @override
  String toString() => stateName;
}