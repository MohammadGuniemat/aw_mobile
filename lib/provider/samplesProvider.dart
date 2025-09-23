import 'dart:convert';
import 'package:aw_app/models/samplesResponse.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/server/apis.dart';

class SamplesProvider extends ChangeNotifier {
  bool _isSampleLoading = false;
  String _sampleProviderMsg = "";
  // List<SamplesResponse>? _samplesList;
  List<SamplesResponse> _samplesList = [];

  bool get isSampleLoading => _isSampleLoading;
  // List<SamplesResponse>? get samplesList => _samplesList;
  List<SamplesResponse> get samplesList => _samplesList;

  String get sampleProviderMsg => _sampleProviderMsg;

  Future<void> setListOfFormSamples(String token, int rfId) async {
    _isSampleLoading = true;
    print("📡 Fetching samples for RFID: $rfId");

    notifyListeners();

    try {
      final response = await Api.get.getListOfFormSamples(token, rfId);
      print("📥 Raw API Response: $response");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📥 DATA API Response: $data");

        final forms = data['forms'] as Map<String, dynamic>?;
        // final myRecordSet = forms!['recordset'];
        final myRecordSet =
            data['forms']['recordsets'][0] as List<dynamic>? ?? [];

        // _sampleList = jsonResponse['forms']['recordsets'][0]; // first inner array

        print("myRecordSet: $myRecordSet");
        // myRecordSet: [{SampleID: 1254, RFID: 1443, SampleStatus: READY, WaterSourceTypeID: 4, Location: محطة تنقية العقبة الشمالية influent, SampleDatetime: null, BatchNo: POP, SampleStatusOwner: 1045, SubLocation: In, SampleImage: null, SampleAnalyseDatetime: null}, {SampleID: 1255, RFID: 1443, SampleStatus: READY, WaterSourceTypeID: 4, Location: محطة تنقية الطريق الخلفي influent, SampleDatetime: null, BatchNo: PUSH, SampleStatusOwner: 1045, SubLocation: Out, SampleImage: null, SampleAnalyseDatetime: null}]

        if (myRecordSet != null) {
          _samplesList = myRecordSet
              .map((e) => SamplesResponse.fromJson(e as Map<String, dynamic>))
              .toList();

          print("📦 Samples loaded: ${_samplesList?.length} items");
          _sampleProviderMsg = "Loaded ${_samplesList?.length ?? 0} samples.";

          // notifyListeners();
        }
        if (_samplesList.isEmpty) {
          _sampleProviderMsg = "✅ Sample Lists Empty !!!";
        } else {
          _sampleProviderMsg = "✅ Sample Lists fetched successfully";
        }
        // if (myRecordSet.isEmpty ?? true) {
        //   _sampleProviderMsg = "✅ Sample Lists Empty !!!";
        // } else {
        //   _sampleProviderMsg = "✅ Sample Lists fetched successfully";
        // }

        // print("✅ Sample Msg ${data['message'] ?? ''}");
        // print("✅ Recordset count: ${myRecordSet.length ?? 0}");

        print("✅ Sample Msg ${data['message'] ?? ''}");
        print("✅ Recordset count: ${_samplesList.length}");
      } else {
        _sampleProviderMsg =
            "❌ Failed to get list of samples: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      _sampleProviderMsg = "❌ Exception while getting samples: $e";
    }
    print('_sampleList: ${_samplesList}');
    _isSampleLoading = false;
    notifyListeners();
  }
}
