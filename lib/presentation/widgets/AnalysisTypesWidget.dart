import 'dart:convert';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/models/subTestModel.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aw_app/server/apis.dart';

class AnalysisTypesWidget extends StatefulWidget {
  final int? analysisId;
  final int? w_type;

  const AnalysisTypesWidget({
    Key? key,
    required this.analysisId,
    required this.w_type,
  }) : super(key: key);

  @override
  State<AnalysisTypesWidget> createState() => AnalysisTypesWidgetState();
}

class AnalysisTypesWidgetState extends State<AnalysisTypesWidget> {
  List<SubTest> selectedList = [];
  final Map<int, TextEditingController> controllers = {}; // store controllers

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<int, Map<int, String>> getSelectedValues() {
    final Map<int, Map<int, String>> analysisTypeIDs = {};
    final Map<int, String> subTestMap = {};

    for (var st in selectedList) {
      final value = controllers[st.id]?.text ?? '';
      if (value.isNotEmpty) {
        subTestMap[st.id] = value;
      }
    }

    if (subTestMap.isNotEmpty) {
      analysisTypeIDs[widget.analysisId!] = subTestMap;
    }

    return analysisTypeIDs;
  }

  void clearAllSubTests() {
    selectedList.clear();
    controllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dataProvider = context.watch<DataProvider>();
    final token = authProvider.token;

    if (widget.analysisId == null || widget.w_type == null || token == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final apiEndPoint = "/subtests/${widget.w_type}/${widget.analysisId}";
    print("W_typeID:${widget.w_type} analysisId: ${widget.analysisId}");

    return FutureBuilder(
      future: Api.get.getSubTests(token, apiEndPoint),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (!snapshot.hasData || snapshot.data!.statusCode != 200) {
          return const Text("No data found");
        }

        final List<dynamic> decoded = jsonDecode(snapshot.data!.body);
        final List<SubTest> subTests = decoded
            .map((e) => SubTest.fromJson(e))
            .cast<SubTest>()
            .toList();

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                Text(
                  "Analysis: ${dataProvider.getAnalysisTypeId(widget.analysisId!)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AWColors.colorDark,
                  ),
                ),
                const SizedBox(height: 12),

                /// Dropdown
                DropdownMenu<SubTest>(
                  width: double.infinity,
                  menuHeight: 300,
                  label: const Text("Select SubTest"),
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  initialSelection: subTests.isNotEmpty ? subTests.first : null,
                  dropdownMenuEntries: subTests
                      .map(
                        (st) => DropdownMenuEntry<SubTest>(
                          value: st,
                          label: st.name,
                        ),
                      )
                      .toList(),
                  onSelected: (value) {
                    if (value != null &&
                        !selectedList.any((st) => st.id == value.id)) {
                      setState(() {
                        selectedList.add(value);
                        controllers[value.id] = TextEditingController();
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                /// SubTest list
                if (selectedList.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedList.length,
                    itemBuilder: (context, index) {
                      final st = selectedList[index];
                      final controller = controllers[st.id]!;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: ListTile(
                          title: Text(st.name),
                          subtitle: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: "Enter value",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              isDense: true,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedList.remove(st);
                                controllers.remove(st.id);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "No subtests selected !!!.",
                        style: TextStyle(color: Color.fromARGB(255, 255, 2, 2)),
                      ),
                      Icon(Icons.warning_amber, color: Colors.red),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
