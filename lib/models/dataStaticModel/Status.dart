class Status {
  final int statusID;
  final String statusDesc;

  Status({
    required this.statusID,
    required this.statusDesc,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      statusID: json['StatusID'] ?? 0,
      statusDesc: json['StatusDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'StatusID': statusID,
      'StatusDesc': statusDesc,
    };
  }
}