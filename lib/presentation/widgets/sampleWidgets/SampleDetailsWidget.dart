// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:aw_app/models/sampleApiModels/SubTestStringData.dart';
import 'package:aw_app/models/sampleApiModels/SampleSubTests.dart';
import 'package:aw_app/models/dataStaticModel/MethodUsed.dart';
import 'package:aw_app/models/dataStaticModel/unit.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:aw_app/server/apis.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SampleDetailsDropdown extends StatefulWidget {
  final String token;
  final int sampleID;
  final int waterTypeID;
  final dynamic filter;

  const SampleDetailsDropdown({
    super.key,
    required this.token,
    required this.sampleID,
    required this.waterTypeID,
    required this.filter,
  });

  @override
  State<SampleDetailsDropdown> createState() => SampleDetailsDropdownState();
}

class SampleDetailsDropdownState extends State<SampleDetailsDropdown> {
  List<Unit> units = [];
  List<MethodUsed> methodsUsed = [];
  List<SampleSubTests> subTests = [];
  List<SubTestStringData> allSubTests = [];
  int? selectedNewSubTestID;

  bool isLoading = true;
  String? error;

  String safeText(String? value) =>
      (value?.trim().isNotEmpty ?? false) ? value!.trim() : 'Not Available';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      setState(() {
        units = dataProvider.units;
        methodsUsed = dataProvider.methodUsed;
      });
      fetchAllSubTests();
      fetchSubTests();
    });
  }

  Future<void> fetchAllSubTests() async {
    try {
      final response = await Api.get.getSampleSubAndAnaly(
        widget.token,
        widget.waterTypeID,
        widget.filter,
      );
      if (!mounted) return;
      setState(() {
        allSubTests = response.whereType<SubTestStringData>().toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchSubTests() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response = await Api.get.getSampleSubTestsList(
        widget.token,
        widget.sampleID,
      );
      if (!mounted) return;
      setState(() {
        subTests = response
            .where((st) => st.analysisTypeID == widget.filter)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> reloadAll() async {
    setState(() => isLoading = true);
    await fetchAllSubTests();
    await fetchSubTests();
  }

  void deleteSubTest(int subTestID) {
    setState(() {
      subTests.removeWhere((s) => s.subTestID == subTestID);
    });
  }

  /// ✅ Build analysis map for submit
  Map<int, Map<int, String>> getAnalysisMap() {
    final Map<int, Map<int, String>> result = {};

    for (var s in subTests) {
      final typeID = s.analysisTypeID;
      final value = s.subTestValue ?? '';

      // Skip empty values if you want only filled subtests
      if (value.trim().isEmpty) continue;

      if (!result.containsKey(typeID)) {
        result[typeID!] = {};
      }

      result[typeID]![s.subTestID!] = value;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reload All'),
              onPressed: reloadAll,
            ),
          ),
          const SizedBox(height: 16),

          if (error != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "❌ Error: $error",
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: reloadAll,
                ),
              ],
            ),

          Text(
            "All SubTests Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 12),

          if (subTests.isEmpty) const Center(child: Text("No SubTests found")),
          ...subTests.map((s) => buildSubTestCard(s)).toList(),

          buildAddNewSubtestDropdown(),
        ],
      ),
    );
  }

  Widget buildSubTestCard(SampleSubTests s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  const TextSpan(text: "📊 Subtest: "),
                  TextSpan(
                    text: safeText(s.subTestName),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: " (Symbol: "),
                  TextSpan(
                    text: safeText(s.subTestSymbol),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: "). Value: "),
                  TextSpan(
                    text: safeText(s.subTestValue),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: s.subTestValue,
              decoration: const InputDecoration(
                labelText: 'SubTest Value',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => s.subTestValue = v,
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField(
              value: s.unitID,
              decoration: const InputDecoration(
                labelText: 'Select Unit',
                border: OutlineInputBorder(),
              ),
              items: units
                  .map(
                    (u) => DropdownMenuItem(
                      value: u.unitID,
                      child: Text(u.unitName ?? 'Unknown Unit'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => s.unitID = v),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField(
              value: s.methodUsedID,
              decoration: const InputDecoration(
                labelText: 'Select Method Used',
                border: OutlineInputBorder(),
              ),
              items: methodsUsed
                  .map(
                    (m) => DropdownMenuItem(
                      value: m.methodUsedID,
                      child: Text(m.methodUsedName ?? 'Unknown Method'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => s.methodUsedID = v),
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: Text(
                s.isLabSubTest == true
                    ? "Lab SubTest (Enabled)"
                    : "Lab SubTest (Disabled)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: s.isLabSubTest == true ? Colors.green : Colors.red,
                ),
              ),
              value: s.isLabSubTest ?? false,
              activeColor: Colors.green,
              onChanged: (val) => setState(() => s.isLabSubTest = val),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteSubTest(s.subTestID!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddNewSubtestDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: selectedNewSubTestID,
          decoration: const InputDecoration(
            labelText: 'Add New SubTest',
            border: OutlineInputBorder(),
          ),
          items: allSubTests
              .map(
                (st) => DropdownMenuItem<int>(
                  value: st.subTestID,
                  child: Text(st.subTestName ?? 'Unknown SubTest'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;

            final selected = allSubTests.firstWhere(
              (st) => st.subTestID == value,
            );
            final exists = subTests.any(
              (s) => s.subTestID == selected.subTestID,
            );
            if (exists) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '⚠️ SubTest "${selected.subTestName}" already exists',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            setState(() {
              subTests.add(
                SampleSubTests(
                  subTestID: selected.subTestID,
                  subTestName: selected.subTestName,
                  subTestSymbol: selected.subTestSymbol,
                  unitID: 14,
                  methodUsedID: 14,
                  subTestValue: '',
                  analysisTypeID: widget.filter,
                  analysedAt: DateTime.now(),
                  isLabSubTest: false,
                ),
              );
              selectedNewSubTestID = null;
            });

            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ SubTest "${selected.subTestName}" added successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ],
    );
  }
}
