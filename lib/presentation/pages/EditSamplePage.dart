import 'dart:typed_data';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/models/dataStaticModel/FormWaterSourceType.dart';
import 'package:aw_app/models/dataStaticModel/WaterSourceName.dart';
import 'package:aw_app/presentation/widgets/analysisTypesWidget.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/server/apis.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aw_app/models/InsertSampleModel.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:aw_app/provider/samplesProvider.dart';
import 'package:aw_app/core/constants/SampleStatus.dart';
import 'package:collection/collection.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/provider/task_provider.dart';

class EditSamplePage extends StatefulWidget {
  final int rfid;
  const EditSamplePage({required this.rfid, super.key});

  @override
  State<EditSamplePage> createState() => _EditSamplePageState();
}

class _EditSamplePageState extends State<EditSamplePage> {
  final GlobalKey<AnalysisTypesWidgetState> analysis1Key =
      GlobalKey<AnalysisTypesWidgetState>();
  final GlobalKey<AnalysisTypesWidgetState> analysis2Key =
      GlobalKey<AnalysisTypesWidgetState>();
  final GlobalKey<AnalysisTypesWidgetState> analysis3Key =
      GlobalKey<AnalysisTypesWidgetState>();

  final _formKey = GlobalKey<FormState>();
  TaskModel? task;

  String? form_batchNo;
  String? form_notes;
  //int rfid
  String? form_sampleStatus;
  int? form_sampleStatusOwner;
  Map<int, Map<int, String>>? form_analysisTypeIDs;
  String? form_location;
  int? form_samplewaterSourceNameID; //Optional for further waterSourceNameID
  String? form_subLocation;

  // using for sub test renderer
  List<int> selectedAnalysisType = [];

  // final ImagePicker _picker = ImagePicker();
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = context.read<TaskProvider>();
      final foundTask = taskProvider.tasks
          .where((t) => t.rFID == widget.rfid)
          .firstOrNull;
      setState(() {
        task = foundTask;
        notesController.text = task?.notes ?? '';
        form_notes = task?.notes ?? '';
      });
    });
  }

  void _submit(BuildContext context) async {
    print("=== SUBMIT START ===");

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token ?? '';

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final sample = InsertSampleModel(
        batchNo: form_batchNo ?? 'N/A',
        notes: form_notes ?? '',
        rfid: widget.rfid,
        sampleStatus: form_sampleStatus ?? 'N/A',
        sampleStatusOwner: form_sampleStatusOwner ?? 0,
        analysisTypeIDs: form_analysisTypeIDs ?? {},
        location: form_location ?? 'N/A',
        sampleWaterSourceTypeID: form_samplewaterSourceNameID ?? 0,
        subLocation: form_subLocation ?? 'N/A',
      );

      final sampleMap = sample.toJson();

      // 🔥 Debug print
      print("🚀 Sending sample data to API:");
      sampleMap.forEach((k, v) => print("  $k: $v"));

      try {
        final response = await Api.post.insertSample(token, sampleMap);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Sample inserted successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ Failed: ${response.body}")),
          );
        }
      } catch (e) {
        print("❌ API error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Error while inserting sample")),
        );
      }
    }
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$title: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AWColors.colorDark,
              ),
            ),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : 'Not Available',
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("TASK NOT FOUND !!")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final governorate = dataProvider
        .findGovernorateById(task!.governorateID)
        ?.governorateName;
    final sector = dataProvider.sectors
        .firstWhereOrNull((s) => s.sectorID == task!.sectorID)
        ?.sectorDesc;
    final status = dataProvider.findStatusById(task!.statusID)?.statusDesc;
    final department = dataProvider.departments
        .firstWhereOrNull((d) => d.departmentID == task!.departmentID)
        ?.departmentName;
    final weather = dataProvider.getWeatherById(task!.weatherID)?.weatherDesc;
    final area = dataProvider.findAreaById(task!.areaID)?.areaName;
    final waterType = dataProvider.waterTypes
        .firstWhereOrNull((w) => w.waterTypeID == task!.waterTypeID)
        ?.waterTypeName;
    final waterTypeID = dataProvider.waterTypes
        .firstWhereOrNull((w) => w.waterTypeID == task!.waterTypeID)
        ?.waterTypeID;
    // get Water Type 1 مياه شرب 2 مياه عادمة
    // final singleSampleWaterSourceTypeNameID = dataProvider
    //     .findWaterFormSourceTypeById(task!.rFID)
    //     ?.waterSourceTypeID;

    List<FormWaterSourceType>? ListOfWaterFormSourceType = dataProvider
        .findListOfWaterFormSourceTypeById(task!.rFID);
    print("formWaterSourceType22 ${ListOfWaterFormSourceType?.length}");

    // concatanating if there is more that one formWater Source Type [
    // {
    //     "FormWaterSourceTypeID": 1801,
    //     "RFID": 1427,
    //     "WaterSourceTypeID": 1
    // },
    // {
    //     "FormWaterSourceTypeID": 1802,
    //     "RFID": 1427,
    //     "WaterSourceTypeID": 2
    // },
    // {
    //     "FormWaterSourceTypeID": 1803,
    //     "RFID": 1427,
    //     "WaterSourceTypeID": 3
    // },

    if (ListOfWaterFormSourceType != null &&
        ListOfWaterFormSourceType.isNotEmpty) {
      // Concatenate WaterSourceTypeID values into a single string
      final concatenated = ListOfWaterFormSourceType.map(
        (e) => e.waterSourceTypeID.toString(),
      ).join(", ");

      print("Water Source Types: $concatenated");
    }

    // Concatenate WaterSourceTypeID into NAMES into a single string
    String concatingWaterSourceName = 'Not Initalized';
    if (ListOfWaterFormSourceType != null &&
        ListOfWaterFormSourceType.isNotEmpty) {
      concatingWaterSourceName = ListOfWaterFormSourceType.map((wf) {
        final name = dataProvider.waterSourceTypes
            .firstWhere((wn) => wn.waterSourceTypeID == wf.waterSourceTypeID)
            .waterSourceTypesName;

        return name;
      }).join(", ");

      print("Water Source Names: $concatingWaterSourceName");
    }

    // fill the form record

    final user = dataProvider.getUserById(task!.collectorID)?.userName;
    final notes = task?.notes ?? '';

    List<WaterSourceName> listOfwaterSourceName = [];

    if (ListOfWaterFormSourceType != null &&
        ListOfWaterFormSourceType.isNotEmpty) {
      final ids = ListOfWaterFormSourceType.map(
        (wf) => wf.waterSourceTypeID,
      ).toList();

      listOfwaterSourceName = dataProvider.waterSourceNames
          .where(
            (w) =>
                ids.contains(w.waterSourceTypeID) && // ✅ check membership
                w.areaID == task!.areaID,
          )
          .toList();

      print("listOfwaterSourceName1: $listOfwaterSourceName");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("EDITING Sample - RFID: ${widget.rfid}"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Form & Sample Information",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard("Department", department ?? ''),
                      _buildInfoCard("Task Name", task!.rFName ?? ''),
                      _buildInfoCard("Governorate", governorate ?? ''),
                      _buildInfoCard("Area", area ?? ''),
                      _buildInfoCard("Water Source", concatingWaterSourceName),
                      _buildInfoCard("Water Type", waterType ?? ''),
                      _buildInfoCard("Collector", user ?? ''),
                      _buildInfoCard("Weather", weather ?? ''),
                      _buildInfoCard("Status", status ?? ''),
                      _buildInfoCard("Sector", sector ?? ''),
                      if (notes.isNotEmpty) _buildInfoCard("Notes", notes),
                    ],
                  ),
                ),
              ),

              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sample Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: "Water Source Name *",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: listOfwaterSourceName
                            .map(
                              (w) => DropdownMenuItem(
                                value: w.waterSourceTypeID,
                                child: Text(w.waterSourceName),
                                // child: Text(w.waterSourceNameID.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          form_samplewaterSourceNameID = val;
                          print('VALUE3 $val');
                        },
                        validator: (val) => val == null ? "Required" : null,
                        onSaved: (val) => form_samplewaterSourceNameID = val,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Location *",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Required" : null,
                        onSaved: (val) => form_location = val,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Sub Location",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSaved: (val) => form_subLocation = val,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Batch No",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSaved: (val) => form_batchNo = val,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: "Additional Notes",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                        ),
                        onSaved: (val) => form_notes = val,

                        maxLines: 3,
                      ),

                      const SizedBox(height: 20),

                      //Test Types
                      DropdownMenu<int>(
                        width: 300,
                        label: const Text("Select Analysis Type"),
                        dropdownMenuEntries: dataProvider.analysisTypes
                            .map(
                              (type) => DropdownMenuEntry<int>(
                                value: type.analysisTypeID,
                                label: type.analysisTypeDesc,
                              ),
                            )
                            .toList(),
                        onSelected: (value) {
                          print("Selected AnalysisType ID: $value");

                          if (!selectedAnalysisType.contains(value!)) {
                            setState(() {
                              // update some state variable instead of calling build()
                              selectedAnalysisType.add(value!);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      if (selectedAnalysisType.contains(1))
                        Row(
                          children: [
                            Expanded(
                              child: AnalysisTypesWidget(
                                key: analysis1Key,
                                analysisId: 1,
                                w_type: waterTypeID,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Clear the child widget's state first
                                if (analysis1Key.currentState != null) {
                                  analysis1Key.currentState!.clearAllSubTests();
                                }

                                // Then remove it from the list and rebuild
                                setState(() {
                                  selectedAnalysisType.remove(1);
                                });
                              },
                            ),
                          ],
                        ),

                      if (selectedAnalysisType.contains(2))
                        Row(
                          children: [
                            Expanded(
                              child: AnalysisTypesWidget(
                                key: analysis2Key,
                                analysisId: 2,
                                w_type: waterTypeID,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Clear the child widget's state first
                                if (analysis2Key.currentState != null) {
                                  analysis2Key.currentState!.clearAllSubTests();
                                }

                                // Then remove it from the list and rebuild
                                setState(() {
                                  selectedAnalysisType.remove(2);
                                });
                              },
                            ),
                          ],
                        ),

                      if (selectedAnalysisType.contains(3))
                        Row(
                          children: [
                            Expanded(
                              child: AnalysisTypesWidget(
                                key: analysis3Key,
                                analysisId: 3,
                                w_type: waterTypeID,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Clear the child widget's state first
                                if (analysis3Key.currentState != null) {
                                  analysis3Key.currentState!.clearAllSubTests();
                                }

                                // Then remove it from the list and rebuild
                                setState(() {
                                  selectedAnalysisType.remove(3);
                                });
                              },
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      DropdownMenu<String>(
                        width: 300,
                        label: const Text("Sample Status"),
                        dropdownMenuEntries: Samplestatus.sampleStatusList
                            .map(
                              (status) => DropdownMenuEntry<String>(
                                value: status,
                                label: status,
                              ),
                            )
                            .toList(),
                        onSelected: (val) {
                          form_sampleStatus = val;
                        },
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Submit Sample",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
