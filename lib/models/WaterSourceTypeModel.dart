class WaterSourceType {
  final int id;
  final String name;

  WaterSourceType._internal(this.id, this.name);

  // Static list of all water source types
  static final List<WaterSourceType> types = [
    WaterSourceType._internal(1, "خزان"),
    WaterSourceType._internal(2, "محطة ضخ"),
    WaterSourceType._internal(3, "شبكات"),
    WaterSourceType._internal(4, "محطة تنقية"),
    WaterSourceType._internal(5, "محطة تحلية"),
    WaterSourceType._internal(6, "بئر"),
    WaterSourceType._internal(7, "محطة معالجة"),
  ];

  // Static helper to get name by ID
  static String getNameById(int id) {
    final found = types.firstWhere(
      (e) => e.id == id,
      orElse: () => WaterSourceType._internal(0, "Unknown"),
    );
    return found.name;
  }
}
