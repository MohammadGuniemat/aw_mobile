class Department {
  final int departmentID;
  final String departmentDesc;
  final String departmentName;

  Department({
    required this.departmentID,
    required this.departmentDesc,
    required this.departmentName,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      departmentID: json['DepartmentID'] ?? 0,
      departmentDesc: json['DepartmentDesc'] ?? '',
      departmentName: json['DepartmentName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DepartmentID': departmentID,
      'DepartmentDesc': departmentDesc,
      'DepartmentName': departmentName,
    };
  }
}