class TaskConfigModel {
  final int rFStatusID; // RF_StatusID
  final String statusDesc; // RF_StatusDesc
  final String color; // Color as hex string

  TaskConfigModel({
    required this.rFStatusID,
    required this.statusDesc,
    required this.color,
  });

  factory TaskConfigModel.fromJson(Map<String, dynamic> json) {
    return TaskConfigModel(
      rFStatusID: json['RF_StatusID'] != null
          ? int.tryParse(json['RF_StatusID'].toString()) ?? 0
          : 0,
      statusDesc: json['RF_StatusDesc']?.toString() ?? 'N/A',
      color: json['Color']?.toString() ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RF_StatusID': rFStatusID,
      'RF_StatusDesc': statusDesc,
      'Color': color,
    };
  }

  @override
  String toString() =>
      'rFStatusID: $rFStatusID, statusDesc: $statusDesc, color: $color';
}
