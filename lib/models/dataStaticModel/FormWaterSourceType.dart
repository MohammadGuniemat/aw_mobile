class FormWaterSourceType {
  final int formWaterSourceTypeID;
  final int rfid;
  final int waterSourceTypeID;

  FormWaterSourceType({
    required this.formWaterSourceTypeID,
    required this.rfid,
    required this.waterSourceTypeID,
  });

  factory FormWaterSourceType.fromJson(Map<String, dynamic> json) {
    return FormWaterSourceType(
      formWaterSourceTypeID: json['FormWaterSourceTypeID'] ?? 0,
      rfid: json['RFID'] ?? 0,
      waterSourceTypeID: json['WaterSourceTypeID'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FormWaterSourceTypeID': formWaterSourceTypeID,
      'RFID': rfid,
      'WaterSourceTypeID': waterSourceTypeID,
    };
  }
}