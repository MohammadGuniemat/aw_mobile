import 'dart:convert';

import 'package:aw_app/models/subTestModel.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as context;
import 'package:provider/provider.dart';
import 'package:aw_app/server/apis.dart';

class AnalysisTypesWidget extends StatelessWidget {
  final int? analysisId;
  final int? w_type;
  List<SubTest>? subTests;

  AnalysisTypesWidget({
    Key? key,
    required this.analysisId,
    required this.w_type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example data based on analysisId, replace with your logic
    final authProvider = context.watch<AuthProvider>();
    final token = authProvider.token;

    if (analysisId == null || w_type == null || token == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final ApiEndPoint = "/subtests/$w_type/$analysisId";

    Future getSubTests(String _token, String EndPoint) async {
      try {
        final response = await Api.get.getSubTests(_token, EndPoint);

        if (response.statusCode == 200) {
          print('response.body: ${response.body}');
          print('jsonDecode(response.body): ${jsonDecode(response.body)}');
          subTests = jsonDecode(
            response.body,
          ).map((e) => SubTest.fromJson(e)).toList();
        } else {
          print(
            'response did not returned, it is with code ${response.statusCode}',
          );
        }
      } catch (e) {
        print('error SubTests: $e');
      }
    }

    //call method
    getSubTests(token, ApiEndPoint);

    final analysisData = _getAnalysisData(analysisId!);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${analysisData[0].split(':')[1]} ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          ...analysisData.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(item, style: TextStyle(fontSize: 16)),
            ),
          ),
          Text("data52"),
          DropdownMenu<int>(
            dropdownMenuEntries: subTests!.map(
                  (st) => DropdownMenuEntry<int>(
                    value: st.id, // 👈 the value you want
                    label: st.name, // 👈 the text to show
                  ),
                )
                .toList(),
            onSelected: (value) {
              print("Selected SubTestID: $value");
            },
          ),
        ],
      ),
    );
  }

  List<String> _getAnalysisData(int id) {
    // Dummy data for demonstration
    switch (id) {
      case 1:
        return ['Sub-Tests For:Physical', 'ID: $id', 'Date: 2024-06-01'];
      case 2:
        return ['Sub-Tests For:Chemical', 'ID: $id', 'Date: 2024-06-05'];
      case 3:
        return ['Sub-Tests For:Microbiology', 'ID: $id', 'Date: N/A'];
      default:
        return ['Sub-Tests For:UN-KNOWN', 'ID: $id', 'Date: N/A'];
    }
  }
}
