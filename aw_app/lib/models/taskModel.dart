class TaskModel {
  int? rFID;
  String? rFName;
  int? governorateID;
  int? sectorID;
  int? statusID;
  int? departmentID;
  int? collectorID;
  int? rFStatus;
  int? weatherID;
  DateTime? applicationDate;
  int? ownerID;
  int? receivedBy;
  DateTime? receivedDate;
  int? submittedBy;
  DateTime? submittedDate;
  int? approvedBy;
  DateTime? approvedDate;
  String? notes;
  int? areaID;
  int? waterTypeID;
  bool? isTemplate;
  bool? samplingAllowed;

  TaskModel({
    this.rFID,
    this.rFName,
    this.governorateID,
    this.sectorID,
    this.statusID,
    this.departmentID,
    this.collectorID,
    this.rFStatus,
    this.weatherID,
    this.applicationDate,
    this.ownerID,
    this.receivedBy,
    this.receivedDate,
    this.submittedBy,
    this.submittedDate,
    this.approvedBy,
    this.approvedDate,
    this.notes,
    this.areaID,
    this.waterTypeID,
    this.isTemplate,
    this.samplingAllowed,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? date) {
      if (date == null || date.isEmpty) return null;
      try {
        return DateTime.parse(date);
      } catch (e) {
        return null;
      }
    }

    return TaskModel(
      rFID: json['RFID'] is int
          ? json['RFID']
          : int.tryParse(json['RFID']?.toString() ?? ''),
      rFName: json['RFName']?.toString(),
      governorateID: json['GovernorateID'] is int
          ? json['GovernorateID']
          : int.tryParse(json['GovernorateID']?.toString() ?? ''),
      sectorID: json['SectorID'] is int
          ? json['SectorID']
          : int.tryParse(json['SectorID']?.toString() ?? ''),
      statusID: json['StatusID'] is int
          ? json['StatusID']
          : int.tryParse(json['StatusID']?.toString() ?? ''),
      departmentID: json['DepartmentID'] is int
          ? json['DepartmentID']
          : int.tryParse(json['DepartmentID']?.toString() ?? ''),
      collectorID: json['CollectorID'] is int
          ? json['CollectorID']
          : int.tryParse(json['CollectorID']?.toString() ?? ''),
      rFStatus: json['RF_Status'] is int
          ? json['RF_Status']
          : int.tryParse(json['RF_Status']?.toString() ?? ''),
      weatherID: json['WeatherID'] is int
          ? json['WeatherID']
          : int.tryParse(json['WeatherID']?.toString() ?? ''),
      applicationDate: parseDate(json['ApplicationDate']),
      ownerID: json['ownerID'] is int
          ? json['ownerID']
          : int.tryParse(json['ownerID']?.toString() ?? ''),
      receivedBy: json['ReceivedBy'] is int
          ? json['ReceivedBy']
          : int.tryParse(json['ReceivedBy']?.toString() ?? ''),
      receivedDate: parseDate(json['ReceivedDate']),
      submittedBy: json['SubmittedBy'] is int
          ? json['SubmittedBy']
          : int.tryParse(json['SubmittedBy']?.toString() ?? ''),
      submittedDate: parseDate(json['SubmittedDate']),
      approvedBy: json['ApprovedBy'] is int
          ? json['ApprovedBy']
          : int.tryParse(json['ApprovedBy']?.toString() ?? ''),
      approvedDate: parseDate(json['ApprovedDate']),
      notes: json['Notes']?.toString(),
      areaID: json['AreaID'] is int
          ? json['AreaID']
          : int.tryParse(json['AreaID']?.toString() ?? ''),
      waterTypeID: json['WaterTypeID'] is int
          ? json['WaterTypeID']
          : int.tryParse(json['WaterTypeID']?.toString() ?? ''),
      isTemplate: json['IsTemplate'] is bool ? json['IsTemplate'] : null,
      samplingAllowed: json['Sampling_allowed'] is bool
          ? json['Sampling_allowed']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RFID': rFID,
      'RFName': rFName,
      'GovernorateID': governorateID,
      'SectorID': sectorID,
      'StatusID': statusID,
      'DepartmentID': departmentID,
      'CollectorID': collectorID,
      'RF_Status': rFStatus,
      'WeatherID': weatherID,
      'ApplicationDate': applicationDate?.toIso8601String(),
      'ownerID': ownerID,
      'ReceivedBy': receivedBy,
      'ReceivedDate': receivedDate?.toIso8601String(),
      'SubmittedBy': submittedBy,
      'SubmittedDate': submittedDate?.toIso8601String(),
      'ApprovedBy': approvedBy,
      'ApprovedDate': approvedDate?.toIso8601String(),
      'Notes': notes,
      'AreaID': areaID,
      'WaterTypeID': waterTypeID,
      'IsTemplate': isTemplate,
      'Sampling_allowed': samplingAllowed,
    };
  }
}
