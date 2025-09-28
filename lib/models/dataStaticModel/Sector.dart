class Sector {
  final int sectorID;
  final String sectorDesc;

  Sector({
    required this.sectorID,
    required this.sectorDesc,
  });

  factory Sector.fromJson(Map<String, dynamic> json) {
    return Sector(
      sectorID: json['SectorID'] ?? 0,
      sectorDesc: json['SectorDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SectorID': sectorID,
      'SectorDesc': sectorDesc,
    };
  }
}