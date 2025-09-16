class FormSampleUpdate {
  final String batchNo;
  final int departmentID;
  final String notes;
  final int rfid;
  final String sampleStatus;
  final int sampleStatusOwner;
  final int sectorID;
  final int statusID;
  final int weatherID;
  final Map<int, Map<int, String>> analysisTypeIDs;
  final String location;
  final int sampleWaterSourceTypeID;
  final String subLocation;

  FormSampleUpdate({
    required this.batchNo,
    required this.departmentID,
    required this.notes,
    required this.rfid,
    required this.sampleStatus,
    required this.sampleStatusOwner,
    required this.sectorID,
    required this.statusID,
    required this.weatherID,
    required this.analysisTypeIDs,
    required this.location,
    required this.sampleWaterSourceTypeID,
    required this.subLocation,
  });

  factory FormSampleUpdate.fromJson(Map<String, dynamic> json) {
    return FormSampleUpdate(
      batchNo: json['BatchNo'],
      departmentID: json['DepartmentID'],
      notes: json['Notes'],
      rfid: json['RFID'],
      sampleStatus: json['SampleStatus'],
      sampleStatusOwner: json['SampleStatusOwner'],
      sectorID: json['SectorID'],
      statusID: json['StatusID'],
      weatherID: json['WeatherID'],
      analysisTypeIDs: Map<int, Map<int, String>>.from(
        json['analysisTypeIDs'].map(
          (key, value) => MapEntry(
            int.parse(key),
            Map<int, String>.from(
              value.map((k, v) => MapEntry(int.parse(k), v)),
            ),
          ),
        ),
      ),
      location: json['location'],
      sampleWaterSourceTypeID: json['sample_WaterSourceTypeID'],
      subLocation: json['sub_location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BatchNo': batchNo,
      'DepartmentID': departmentID,
      'Notes': notes,
      'RFID': rfid,
      'SampleStatus': sampleStatus,
      'SampleStatusOwner': sampleStatusOwner,
      'SectorID': sectorID,
      'StatusID': statusID,
      'WeatherID': weatherID,
      'analysisTypeIDs': analysisTypeIDs.map(
        (key, value) => MapEntry(
          key.toString(),
          value.map((k, v) => MapEntry(k.toString(), v)),
        ),
      ),
      'location': location,
      'sample_WaterSourceTypeID': sampleWaterSourceTypeID,
      'sub_location': subLocation,
    };
  }
}
