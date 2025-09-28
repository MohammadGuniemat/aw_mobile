class WaterSourceName {
  final int waterSourceNameID;
  final int waterSourceTypeID;
  final int areaID;
  final String waterSourceName;

  WaterSourceName({
    required this.waterSourceNameID,
    required this.waterSourceTypeID,
    required this.areaID,
    required this.waterSourceName,
  });

  factory WaterSourceName.fromJson(Map<String, dynamic> json) {
    return WaterSourceName(
      waterSourceNameID: json['WaterSourceNameID'] ?? 0,
      waterSourceTypeID: json['WaterSourceTypeID'] ?? 0,
      areaID: json['AreaID'] ?? 0,
      waterSourceName: json['WaterSourceName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'WaterSourceNameID': waterSourceNameID,
      'WaterSourceTypeID': waterSourceTypeID,
      'AreaID': areaID,
      'WaterSourceName': waterSourceName,
    };
  }
}
