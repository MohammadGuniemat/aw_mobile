class RFStatus {
  final int rfStatusID;
  final String rfStatusDesc;
  final String color;

  RFStatus({
    required this.rfStatusID,
    required this.rfStatusDesc,
    required this.color,
  });

  factory RFStatus.fromJson(Map<String, dynamic> json) {
    return RFStatus(
      rfStatusID: json['RF_StatusID'] ?? 0,
      rfStatusDesc: json['RF_StatusDesc'] ?? '',
      color: json['Color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RF_StatusID': rfStatusID,
      'RF_StatusDesc': rfStatusDesc,
      'Color': color,
    };
  }
}