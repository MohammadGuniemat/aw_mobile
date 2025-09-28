class AnalysisType {
  final int analysisTypeID;
  final String analysisTypeDesc;

  AnalysisType({
    required this.analysisTypeID,
    required this.analysisTypeDesc,
  });

  factory AnalysisType.fromJson(Map<String, dynamic> json) {
    return AnalysisType(
      analysisTypeID: json['AnalysisTypeID'] ?? 0,
      analysisTypeDesc: json['AnalysisTypeDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AnalysisTypeID': analysisTypeID,
      'AnalysisTypeDesc': analysisTypeDesc,
    };
  }
}