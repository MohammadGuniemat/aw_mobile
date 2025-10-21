import 'dart:convert';
import 'package:aw_app/models/sampleApiModels/SubTestStringData.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/models/sampleApiModels/SampleSubTests.dart';
import 'package:aw_app/models/dataStaticModel/unit.dart';
import 'package:aw_app/models/dataStaticModel/MethodUsed.dart';
import 'package:aw_app/server/apis.dart';
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
  State<SampleDetailsDropdown> createState() => _SampleDetailsDropdownState();
}

class _SampleDetailsDropdownState extends State<SampleDetailsDropdown> {
  List<Unit> units = [];
  List<MethodUsed> methodsUsed = [];
  List<SampleSubTests> subTests = [];
  List<SubTestStringData> allSubTests = [];

  bool isLoading = true;
  String? error;

  // Helper to safely trim text
  String safeText(String? value) =>
      (value?.trim().isNotEmpty ?? false) ? value!.trim() : 'Not Available';

  @override
  void initState() {
    super.initState();

    // Safe access to Provider after widget mounts
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

  // Fetch all subtests for water type and analysis type
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

      debugPrint(
        'Fetched ${allSubTests.length} possible subtests for waterType ${widget.waterTypeID}',
      );
    } catch (e, st) {
      debugPrint('fetchAllSubTests error: $e\n$st');
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Fetch sample's own subtests
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

      debugPrint(
        'Fetched ${subTests.length} subtests for sample ${widget.sampleID}',
      );
    } catch (e, st) {
      debugPrint('fetchSubTests error: $e\n$st');
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Combined reload
  Future<void> reloadAll() async {
    setState(() => isLoading = true);
    await fetchAllSubTests();
    await fetchSubTests();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("❌ Error: $error", style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: reloadAll,
            ),
          ],
        ),
      );
    }

    if (subTests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("No SubTests found"),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
              onPressed: reloadAll,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔄 Reload button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reload All'),
              onPressed: reloadAll,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "All SubTests Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 12),

          // 🧪 Subtest Cards
          ...subTests.map((s) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.5,
                        ),
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
                          const TextSpan(text: ").\nValue: "),
                          TextSpan(
                            text: safeText(s.subTestValue),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ", UnitID: "),
                          TextSpan(
                            text: s.unitID?.toString() ?? 'Not Available',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ", MethodUsedID: "),
                          TextSpan(
                            text: s.methodUsedID?.toString() ?? 'Not Available',
                            style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ", Type: "),
                          TextSpan(
                            text:
                                s.analysisTypeID?.toString() ?? 'Not Available',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ", Analysed At: "),
                          TextSpan(
                            text:
                                s.analysedAt?.toIso8601String() ??
                                'Not Available',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ", For Lab Tech: "),
                          TextSpan(
                            text: s.isLabSubTest == true ? 'Yes' : 'No',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🔽 SubTest Value Input
                    TextFormField(
                      initialValue: s.subTestValue,
                      decoration: const InputDecoration(
                        labelText: 'SubTest Value',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        // Handle value change
                      },
                    ),
                    // 🔽 Select Unit
                    const SizedBox(height: 8),

                    DropdownButtonFormField(
                      value: s.unitID, // default selected value
                      decoration: const InputDecoration(
                        labelText: 'Select Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: units.map((u) {
                        return DropdownMenuItem(
                          value: u.unitID,
                          child: Text(u.unitName ?? 'Unknown Unit'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // Handle unit change
                      },
                    ),

                    const SizedBox(height: 8),

                    // 🔽 Select Method Used
                    DropdownButtonFormField(
                      value: s.methodUsedID, // default selected value
                      decoration: const InputDecoration(
                        labelText: 'Select Method Used',
                        border: OutlineInputBorder(),
                      ),
                      items: methodsUsed.map((m) {
                        return DropdownMenuItem(
                          value: m.methodUsedID,
                          child: Text(m.methodUsedName ?? 'Unknown Method'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // Handle method change
                      },
                    ),

                    const SizedBox(height: 8),

                    // 🔽 Is Lab SubTest Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: (s.isLabSubTest ?? false)
                            ? const Color.fromARGB(
                                255,
                                240,
                                243,
                                240,
                              ).withOpacity(0.1)
                            : const Color.fromARGB(
                                255,
                                243,
                                239,
                                239,
                              ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (s.isLabSubTest ?? false)
                              ? Colors.green
                              : Colors.red,
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                (s.isLabSubTest ?? false)
                                    ? Icons.science_rounded
                                    : Icons.science_outlined,
                                color: (s.isLabSubTest ?? false)
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (s.isLabSubTest ?? false)
                                    ? "Lab SubTest (Enabled)"
                                    : "Lab SubTest (Disabled)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (s.isLabSubTest ?? false)
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),

                          // ✅ Modern toggle switch
                          Switch(
                            value: s.isLabSubTest ?? false,
                            activeColor: Colors.white,
                            activeTrackColor: Colors.green,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.redAccent.withOpacity(
                              0.6,
                            ),
                            onChanged: (value) {
                              setState(() {
                                s.isLabSubTest = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    // 🔽 Analysed At Date Picker
                    GestureDetector(
                      onTap: () async {
                        // Step 1️⃣: Pick date
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: s.analysedAt ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          // Step 2️⃣: Pick time after date
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: s.analysedAt != null
                                ? TimeOfDay.fromDateTime(s.analysedAt!)
                                : TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              s.analysedAt = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: s.analysedAt != null
                                ? "${s.analysedAt!.day.toString().padLeft(2, '0')}-${s.analysedAt!.month.toString().padLeft(2, '0')}-${s.analysedAt!.year} "
                                      "${s.analysedAt!.hour.toString().padLeft(2, '0')}:${s.analysedAt!.minute.toString().padLeft(2, '0')}"
                                : '',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Analysed At',
                            helperText: 'Tap to select date and time',
                            prefixIcon: const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                            suffixIcon: const Icon(
                              Icons.access_time,
                              color: Colors.blueAccent,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.blue.withOpacity(0.05),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          // 🔽 Add New Subtest Dropdown
          const SizedBox(height: 16),
          DropdownButtonFormField(
            decoration: const InputDecoration(
              labelText: 'Add New SubTest',
              border: OutlineInputBorder(),
            ),
            items: allSubTests.map((subTest) {
              return DropdownMenuItem(
                value: subTest.subTestID,
                child: Text(subTest.subTestName ?? 'Unknown SubTest'),
              );
            }).toList(),
            onChanged: (value) {
              // Handle add subtest
            },
          ),
        ],
      ),
    );
  }
}
