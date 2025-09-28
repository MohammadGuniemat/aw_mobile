class Area {
  final int areaID;
  final int governorateID;
  final String areaName;
  final String? areaDesc;

  Area({
    required this.areaID,
    required this.governorateID,
    required this.areaName,
    this.areaDesc,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      areaID: json['AreaID'] ?? 0,
      governorateID: json['GovernorateID'] ?? 0,
      areaName: json['AreaName'] ?? '',
      areaDesc: json['AreaDesc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AreaID': areaID,
      'GovernorateID': governorateID,
      'AreaName': areaName,
      'AreaDesc': areaDesc,
    };
  }
}