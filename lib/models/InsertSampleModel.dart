class InsertSampleModel {
  final String batchNo;
  final String notes;
  final int rfid;
  final String sampleStatus;
  final int sampleStatusOwner;
  final Map<String, dynamic> analysisTypeIDs; // since it's {}
  final String location;
  final int sampleWaterSourceTypeID;
  final String subLocation;

  InsertSampleModel({
    required this.batchNo,
    required this.notes,
    required this.rfid,
    required this.sampleStatus,
    required this.sampleStatusOwner,
    required this.analysisTypeIDs,
    required this.location,
    required this.sampleWaterSourceTypeID,
    required this.subLocation,
  });

  // Factory constructor to create object from JSON
  factory InsertSampleModel.fromJson(Map<String, dynamic> json) {
    return InsertSampleModel(
      batchNo: json['BatchNo'] ?? '',
      notes: json['Notes'] ?? '',
      rfid: json['RFID'] ?? 0,
      sampleStatus: json['SampleStatus'] ?? '',
      sampleStatusOwner: json['SampleStatusOwner'] ?? 0,
      analysisTypeIDs: json['analysisTypeIDs'] ?? {},
      location: json['location'] ?? '',
      sampleWaterSourceTypeID: json['sample_WaterSourceTypeID'] ?? 0,
      subLocation: json['sub_location'] ?? '',
    );
  }

  // Convert object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'BatchNo': batchNo,
      'Notes': notes,
      'RFID': rfid,
      'SampleStatus': sampleStatus,
      'SampleStatusOwner': sampleStatusOwner,
      'analysisTypeIDs': analysisTypeIDs,
      'location': location,
      'sample_WaterSourceTypeID': sampleWaterSourceTypeID,
      'sub_location': subLocation,
    };
  }
}
