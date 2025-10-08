class SubTestStringData {
  final int subTestID;
  final String subTestSymbol;
  final String subTestName;
  final String subTestUnit;
  final String subTestMethodUsed;
  final String? subTestNationalStandardsA;
  final String? subTestNationalStandardsB;
  final String? subTestNationalStandardsC;
  final String? subTestNationalStandardsD;
  final String analysisTypeDesc;
  final String waterTypeName;

  SubTestStringData({
    required this.subTestID,
    required this.subTestSymbol,
    required this.subTestName,
    required this.subTestUnit,
    required this.subTestMethodUsed,
    this.subTestNationalStandardsA,
    this.subTestNationalStandardsB,
    this.subTestNationalStandardsC,
    this.subTestNationalStandardsD,
    required this.analysisTypeDesc,
    required this.waterTypeName,
  });

  factory SubTestStringData.fromJson(Map<String, dynamic> json) {
    return SubTestStringData(
      subTestID: json['SubTestID'] ?? 0,
      subTestSymbol: json['SubTestSymbol'] ?? '',
      subTestName: json['SubTestName'] ?? '',
      subTestUnit: json['SubTestUnit'] ?? '',
      subTestMethodUsed: json['SubTestMethodUsed'] ?? '',
      subTestNationalStandardsA: json['SubTestNationalStandardsA'],
      subTestNationalStandardsB: json['SubTestNationalStandardsB'],
      subTestNationalStandardsC: json['SubTestNationalStandardsC'],
      subTestNationalStandardsD: json['SubTestNationalStandardsD'],
      analysisTypeDesc: json['AnalysisTypeDesc'] ?? '',
      waterTypeName: json['WaterTypeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SubTestID': subTestID,
      'SubTestSymbol': subTestSymbol,
      'SubTestName': subTestName,
      'SubTestUnit': subTestUnit,
      'SubTestMethodUsed': subTestMethodUsed,
      'SubTestNationalStandardsA': subTestNationalStandardsA,
      'SubTestNationalStandardsB': subTestNationalStandardsB,
      'SubTestNationalStandardsC': subTestNationalStandardsC,
      'SubTestNationalStandardsD': subTestNationalStandardsD,
      'AnalysisTypeDesc': analysisTypeDesc,
      'WaterTypeName': waterTypeName,
    };
  }

  @override
  String toString() {
    return 'SubTestData(subTestID: $subTestID, name: $subTestName, type: $analysisTypeDesc, waterType: $waterTypeName)';
  }
}
