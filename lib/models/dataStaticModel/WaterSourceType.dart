class WaterSourceType {
  final int waterSourceTypeID;
  final String waterSourceTypesName;
  final int waterTypeID;

  WaterSourceType({
    required this.waterSourceTypeID,
    required this.waterSourceTypesName,
    required this.waterTypeID,
  });

  factory WaterSourceType.fromJson(Map<String, dynamic> json) {
    return WaterSourceType(
      waterSourceTypeID: json['WaterSourceTypeID'] ?? 0,
      waterSourceTypesName: json['WaterSourceTypesName'] ?? '',
      waterTypeID: json['WaterTypeID'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'WaterSourceTypeID': waterSourceTypeID,
      'WaterSourceTypesName': waterSourceTypesName,
      'WaterTypeID': waterTypeID,
    };
  }
}