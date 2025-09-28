class WaterType {
  final int waterTypeID;
  final String waterTypeName;

  WaterType({
    required this.waterTypeID,
    required this.waterTypeName,
  });

  factory WaterType.fromJson(Map<String, dynamic> json) {
    return WaterType(
      waterTypeID: json['WaterTypeID'] ?? 0,
      waterTypeName: json['WaterTypeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'WaterTypeID': waterTypeID,
      'WaterTypeName': waterTypeName,
    };
  }
}