import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aw_app/models/sampleApiModels/SubTestStringData.dart';
import 'package:aw_app/server/apis.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:collection/collection.dart';

class SampleDetailsDropdown extends StatefulWidget {
  final String token;
  final int waterTypeID;
  final int analysisTypeID;

  const SampleDetailsDropdown({
    super.key,
    required this.token,
    required this.waterTypeID,
    required this.analysisTypeID,
  });

  @override
  State<SampleDetailsDropdown> createState() => _SampleDetailsDropdownState();
}

class _SampleDetailsDropdownState extends State<SampleDetailsDropdown> {
  List<SubTestStringData> subTests = [];
  List<Unit> units = [];
  SubTestStringData? selectedSubTest;
  bool isLoading = true;
  String? error;
  String? analysisName;

  @override
  void initState() {
    super.initState();
    fetchSubTests();

    // ✅ Safely access Provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = context.read<DataProvider>();

      final analysisNameList = dataProvider.analysisTypes.firstWhereOrNull(
        (an) => an.analysisTypeID == widget.analysisTypeID,
      );

      setState(() {
        analysisName =
            analysisNameList?.analysisTypeDesc ?? 'Unknown analysisType';
      });
    });
  }

  Future<void> fetchSubTests() async {
    try {
      // SAMPLE REAL VALUES FOR SUB TESTS FETCHING * * * * * * * * *
      //[{"SubTestID":11,"SubTestSymbol":"Colour","SubTestName":"Colour","SubTestUnit":"TCU","SubTestMethodUsed":"Sensory Test","SubTestNationalStandardsA":"15","SubTestNationalStandardsB":null,"SubTestNationalStandardsC":null,"SubTestNationalStandardsD":null,"AnalysisTypeDesc":"Physical","WaterTypeName":"مياه شرب"},{
      final response = await Api.get.getSampleSubAndAnaly(
        widget.token,
        widget.waterTypeID,
        widget.analysisTypeID,
      );

      setState(() {
        subTests = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          "❌ Error: $error",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (subTests.isEmpty) {
      return const Center(child: Text("No SubTests found"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (analysisName != null) ...[
          Text(
            'Analysis: $analysisName',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
        ],
        const Text("Select a SubTest:", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        DropdownButtonFormField<SubTestStringData>(
          value: selectedSubTest,
          hint: const Text("Choose one"),
          isExpanded: true,
          items: subTests.map((subTest) {
            return DropdownMenuItem(
              value: subTest,
              child: Text(subTest.subTestName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedSubTest = value);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 16),



        DropdownButtonFormField<Unit>(
          value: selectedSubTest,
          hint: const Text("Choose one"),
          isExpanded: true,
          items: subTests.map((subTest) {
            return DropdownMenuItem(
              value: subTest,
              child: Text(subTest.subTestName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedSubTest = value);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),





        if (selectedSubTest != null) ...[
          Card(
            margin: const EdgeInsets.only(top: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "📊 Details:\n"
                "Symbol: ${selectedSubTest!.subTestSymbol}\n"
                "Unit: ${selectedSubTest!.subTestUnit}\n"
                "Method: ${selectedSubTest!.subTestMethodUsed}\n"
                "Type: ${selectedSubTest!.analysisTypeDesc ?? '-'}\n"
                "Water: ${selectedSubTest!.waterTypeName ?? '-'}",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
