class Governorate {
  final int governorateID;
  final String governorateName;
  final String governorateDesc;

  Governorate({
    required this.governorateID,
    required this.governorateName,
    required this.governorateDesc,
  });

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(
      governorateID: json['GovernorateID'] ?? 0,
      governorateName: json['GovernorateName'] ?? '',
      governorateDesc: json['GovernorateDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GovernorateID': governorateID,
      'GovernorateName': governorateName,
      'GovernorateDesc': governorateDesc,
    };
  }
}