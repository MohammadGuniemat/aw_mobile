import 'dart:typed_data';

class SamplesResponse {
  final int sampleID;
  final int rfid;//from form
  final String sampleStatus;
  final int waterSourceTypeID;
  final String location;
  final String? sampleDatetime;
  final String? batchNo;
  final int sampleStatusOwner;
  final String subLocation;
  final Uint8List? sampleImageBytes; // <- use Uint8List for images
  final String? sampleAnalyseDatetime;

  SamplesResponse({
    required this.sampleID,
    required this.rfid,
    required this.sampleStatus,
    required this.waterSourceTypeID,
    required this.location,
    this.sampleDatetime,
    required this.batchNo,
    required this.sampleStatusOwner,
    required this.subLocation,
    this.sampleImageBytes,
    this.sampleAnalyseDatetime,
  });

  factory SamplesResponse.fromJson(Map<String, dynamic> json) {
    Uint8List? imageBytes;
    if (json['SampleImage'] != null && json['SampleImage']['data'] != null) {
      imageBytes = Uint8List.fromList(
        List<int>.from(json['SampleImage']['data']),
      );
    }

    return SamplesResponse(
      sampleID: json['SampleID'] ?? 0,
      rfid: json['RFID'] ?? 0,
      sampleStatus: json['SampleStatus'] ?? 'N/A',
      waterSourceTypeID: json['WaterSourceTypeID'] ?? 0,
      location: json['Location'] ?? 'N/A',
      sampleDatetime: json['SampleDatetime'],
      batchNo: json['BatchNo'] ?? 'N/A',
      sampleStatusOwner: json['SampleStatusOwner'] ?? 0,
      subLocation: json['SubLocation'] ?? 'N/A',
      sampleImageBytes: imageBytes,
      sampleAnalyseDatetime: json['SampleAnalyseDatetime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "SampleID": sampleID,
      "RFID": rfid,
      "SampleStatus": sampleStatus,
      "WaterSourceTypeID": waterSourceTypeID,
      "Location": location,
      "SampleDatetime": sampleDatetime,
      "BatchNo": batchNo,
      "SampleStatusOwner": sampleStatusOwner,
      "SubLocation": subLocation,
      "SampleImage": sampleImageBytes != null
          ? sampleImageBytes!.toList()
          : null,
      "SampleAnalyseDatetime": sampleAnalyseDatetime,
    };
  }
}
