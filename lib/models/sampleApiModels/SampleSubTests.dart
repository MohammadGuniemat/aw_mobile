class SampleSubTests {
  int? sid;
  int? labTechnicianID;
  int? analysisTypeID;
  int? subTestID;
  int? sampleTestSubTestID;
  String? subTestName;
  String? subTestSymbol;
  String? subTestValue;
  int? unitID;
  int? methodUsedID;
  bool? isLabSubTest;
  DateTime? analysedAt;

  SampleSubTests({
    this.sid,
    this.labTechnicianID,
    this.analysisTypeID,
    this.subTestID,
    this.sampleTestSubTestID,
    this.subTestName,
    this.subTestSymbol,
    this.subTestValue,
    this.unitID,
    this.methodUsedID,
    this.isLabSubTest,
    this.analysedAt,
  });

  factory SampleSubTests.fromJson(Map<String, dynamic> json) {
    return SampleSubTests(
      sid: json['SID'] as int?,
      labTechnicianID: json['LabTechnicianID'] as int?,
      analysisTypeID: json['AnalysisTypeID'] as int?,
      subTestID: json['SubTestID'] as int?,
      sampleTestSubTestID: json['SampleTestSubTestID'] as int?,
      subTestName: json['SubTestName'] as String?,
      subTestSymbol: json['SubTestSymbol'] as String?,
      subTestValue: json['SubTestValue'] as String?,
      unitID: json['UnitID'] as int?,
      methodUsedID: json['MethodUsedID'] as int?,
      isLabSubTest: json['IsLabSubTest'] as bool?,
      analysedAt: json['AnalysedAt'] != null
          ? DateTime.tryParse(json['AnalysedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SID': sid,
      'LabTechnicianID': labTechnicianID,
      'AnalysisTypeID': analysisTypeID,
      'SubTestID': subTestID,
      'SampleTestSubTestID': sampleTestSubTestID,
      'SubTestName': subTestName,
      'SubTestSymbol': subTestSymbol,
      'SubTestValue': subTestValue,
      'UnitID': unitID,
      'MethodUsedID': methodUsedID,
      'IsLabSubTest': isLabSubTest,
      'AnalysedAt': analysedAt?.toIso8601String(),
    };
  }
}
