import 'package:flutter/material.dart';

class TaskModel {
  // Original fields
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

  // New fields from [FORM-INFO] view
  String? governorateName;
  String? sectorDesc;
  String? statusDesc;
  String? departmentName;
  String? collectorName;
  String? rFStatusDesc;
  String? weatherDesc;
  String? collectorUserName;
  String? ownerUserName;
  String? areaName;
  String? waterTypeName;
  String? color;

  TaskModel({
    // Original parameters
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

    // New parameters from view
    this.governorateName,
    this.sectorDesc,
    this.statusDesc,
    this.departmentName,
    this.collectorName,
    this.rFStatusDesc,
    this.weatherDesc,
    this.collectorUserName,
    this.ownerUserName,
    this.areaName,
    this.waterTypeName,
    this.color,
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

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return null;
    }

    return TaskModel(
      // Original field mappings
      rFID: parseInt(json['RFID']),
      rFName: json['RFName']?.toString(),
      governorateID: parseInt(json['GovernorateID']),
      sectorID: parseInt(json['SectorID']),
      statusID: parseInt(json['StatusID']),
      departmentID: parseInt(json['DepartmentID']),
      collectorID: parseInt(json['CollectorID']),
      rFStatus: parseInt(json['RF_Status']),
      weatherID: parseInt(json['WeatherID']),
      applicationDate: parseDate(json['ApplicationDate']),
      ownerID: parseInt(json['ownerID']),
      receivedBy: parseInt(json['ReceivedBy']),
      receivedDate: parseDate(json['ReceivedDate']),
      submittedBy: parseInt(json['SubmittedBy']),
      submittedDate: parseDate(json['SubmittedDate']),
      approvedBy: parseInt(json['ApprovedBy']),
      approvedDate: parseDate(json['ApprovedDate']),
      notes: json['Notes']?.toString(),
      areaID: parseInt(json['AreaID']),
      waterTypeID: parseInt(json['WaterTypeID']),
      isTemplate: parseBool(json['IsTemplate']),
      samplingAllowed: parseBool(json['Sampling_allowed']),

      // New field mappings from view
      governorateName: json['GovernorateName']?.toString(),
      sectorDesc: json['SectorDesc']?.toString(),
      statusDesc: json['StatusDesc']?.toString(),
      departmentName: json['DepartmentName']?.toString(),
      collectorName: json['CollectorName']?.toString(),
      rFStatusDesc: json['RF_StatusDesc']?.toString(),
      weatherDesc: json['WeatherDesc']?.toString(),
      collectorUserName: json['CollectorUserName']?.toString(),
      ownerUserName: json['OwnerUserName']?.toString(),
      areaName: json['AreaName']?.toString(),
      waterTypeName: json['WaterTypeName']?.toString(),
      color: json['Color']?.toString(),
      // color: Colors.red.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Original fields
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

      // New fields from view
      'GovernorateName': governorateName,
      'SectorDesc': sectorDesc,
      'StatusDesc': statusDesc,
      'DepartmentName': departmentName,
      'CollectorName': collectorName,
      'RF_StatusDesc': rFStatusDesc,
      'WeatherDesc': weatherDesc,
      'CollectorUserName': collectorUserName,
      'OwnerUserName': ownerUserName,
      'AreaName': areaName,
      'WaterTypeName': waterTypeName,
      'Color': color,
    };
  }

  // @override
  // String toString() {
  //   return 'TaskModel{RFID: $rFID, RFName: $rFName, Governorate: $governorateName, Status: $rFStatusDesc}';
  // }
}
