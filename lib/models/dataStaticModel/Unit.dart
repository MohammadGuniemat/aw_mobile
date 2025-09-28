class Unit {
  final int unitID;
  final String unitName;

  Unit({
    required this.unitID,
    required this.unitName,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unitID: json['UnitID'] ?? 0,
      unitName: json['UnitName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UnitID': unitID,
      'UnitName': unitName,
    };
  }
}