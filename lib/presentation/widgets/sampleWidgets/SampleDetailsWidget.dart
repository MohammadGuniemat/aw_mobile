import 'package:aw_app/models/dataStaticModel/unit.dart';
import 'package:aw_app/models/sampleApiModels/SubTestStringData.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:aw_app/server/apis.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  Unit? selectedUnit;
  bool isLoading = true;
  String? error;
  String? analysisName;

  @override
  void initState() {
    super.initState();
    fetchSubTests();

    // ✅ Load analysis name + units after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = context.read<DataProvider>();

      final analysis = dataProvider.analysisTypes.firstWhereOrNull(
        (a) => a.analysisTypeID == widget.analysisTypeID,
      );

      setState(() {
        analysisName = analysis?.analysisTypeDesc ?? 'Unknown Analysis';
        units = dataProvider.units
            .cast<Unit>(); // ✅ Assuming DataProvider provides this
      });
    });
  }

  Future<void> fetchSubTests() async {
    try {
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

        const Text("Select a SubTest:", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),

        /// SubTest Dropdown
        DropdownButtonFormField<SubTestStringData>(
          value: selectedSubTest,
          hint: const Text("Choose SubTest"),
          isExpanded: true,
          items: subTests.map((subTest) {
            return DropdownMenuItem<SubTestStringData>(
              value: subTest,
              child: Text(subTest.subTestName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedSubTest = value;

              // Auto-select unit if available in the subTest data
              selectedUnit = units.firstWhereOrNull(
                (u) => u.unitName == value?.subTestUnit,
              );
            });
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
        const Text("Select a Unit:", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),

        /// Unit Dropdown
        DropdownButtonFormField<Unit>(
          value: selectedUnit,
          hint: const Text("Choose Unit"),
          isExpanded: true,
          items: units.map((unit) {
            return DropdownMenuItem<Unit>(
              value: unit,
              child: Text(unit.unitName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedUnit = value);
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

        /// Details Card
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
