class SubTest {
  final int id;
  final String symbol;
  final String name;
  final String unit;
  final String methodUsed;
  final String? nationalStandardA;
  final String? nationalStandardB;
  final String? nationalStandardC;
  final String? nationalStandardD;
  final String analysisTypeDesc;
  final String waterTypeName;

  SubTest({
    required this.id,
    required this.symbol,
    required this.name,
    required this.unit,
    required this.methodUsed,
    this.nationalStandardA,
    this.nationalStandardB,
    this.nationalStandardC,
    this.nationalStandardD,
    required this.analysisTypeDesc,
    required this.waterTypeName,
  });

  factory SubTest.fromJson(Map<String, dynamic> json) {
    return SubTest(
      id: json['SubTestID'],
      symbol: json['SubTestSymbol'],
      name: json['SubTestName'],
      unit: json['SubTestUnit'],
      methodUsed: json['SubTestMethodUsed'],
      nationalStandardA: json['SubTestNationalStandardsA']?.toString(),
      nationalStandardB: json['SubTestNationalStandardsB']?.toString(),
      nationalStandardC: json['SubTestNationalStandardsC']?.toString(),
      nationalStandardD: json['SubTestNationalStandardsD']?.toString(),
      analysisTypeDesc: json['AnalysisTypeDesc'],
      waterTypeName: json['WaterTypeName'],
    );
  }
}
