class MethodUsed {
  final int methodUsedID;
  final String methodUsedName;

  MethodUsed({
    required this.methodUsedID,
    required this.methodUsedName,
  });

  factory MethodUsed.fromJson(Map<String, dynamic> json) {
    return MethodUsed(
      methodUsedID: json['MethodUsedID'] ?? 0,
      methodUsedName: json['MethodUsedName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MethodUsedID': methodUsedID,
      'MethodUsedName': methodUsedName,
    };
  }
}