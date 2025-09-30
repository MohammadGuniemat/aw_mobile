import 'dart:typed_data';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/models/dataStaticModel/WaterSourceName.dart';
import 'package:aw_app/presentation/widgets/analysisTypesWidget.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aw_app/models/InsertSampleModel.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:aw_app/provider/samplesProvider.dart';
import 'package:aw_app/core/constants/SampleStatus.dart';
import 'package:collection/collection.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/provider/task_provider.dart';

class InsertSamplePage extends StatefulWidget {
  final int rfid;
  const InsertSamplePage({required this.rfid, super.key});

  @override
  State<InsertSamplePage> createState() => _InsertSamplePageState();
}

class _InsertSamplePageState extends State<InsertSamplePage> {
  final _formKey = GlobalKey<FormState>();
  TaskModel? task;

  String? form_batchNo;
  String? form_notes;
  //int rfid
  String? form_sampleStatus;
  int? form_sampleStatusOwner;
  Map<String, dynamic>? form_analysisTypeIDs;
  String? form_location;
  int? form_sampleWaterSourceTypeID;
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

  // Future<void> _pickImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  //   if (image != null) {
  //     final bytes = await image.readAsBytes();
  //     setState(() => form_sampleImageBytes = bytes);
  //   }
  // }

  void _submit(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    form_sampleStatusOwner = authProvider.userID ?? -11;

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
        sampleWaterSourceTypeID: form_sampleWaterSourceTypeID ?? 0,
        subLocation: form_subLocation ?? 'N/A',
      );

      // Convert to Map
      final sampleMap = sample.toJson();

      // Loop through key-value pairs
      sampleMap.forEach((key, value) {
        print("$key is Key : Value is $value");
      });

      final samplesProvider = context.read<SamplesProvider>();

      // samplesProvider.insertSample(sample);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sample saved successfully!")),
      );
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
        appBar: AppBar(title: const Text("Insert Sample")),
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
    final formWaterSourceType = dataProvider
        .findWaterFormSourceTypeById(task!.rFID)
        ?.waterSourceTypeID;
    // fill the form record
    form_sampleWaterSourceTypeID = formWaterSourceType;
    final selectedWaterSourceName =
        dataProvider.waterSourceTypes
            .firstWhereOrNull(
              (wn) => wn.waterSourceTypeID == formWaterSourceType,
            )
            ?.waterSourceTypesName ??
        "Not Found";
    final user = dataProvider.getUserById(task!.collectorID)?.userName;
    final notes = task?.notes ?? '';

    final listOfwaterSourceName = dataProvider.waterSourceNames
        .where(
          (w) =>
              w.waterSourceTypeID == formWaterSourceType &&
              w.areaID == task!.areaID,
        )
        // .map((w) => w.waterSourceName)
        .toList();
    print(
      "listOfwaterSourceName: ${listOfwaterSourceName.toString()}",
    ); // will print list of strings

    return Scaffold(
      appBar: AppBar(
        title: Text("Insert Sample - RFID: ${widget.rfid}"),
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
                      _buildInfoCard("Water Source", selectedWaterSourceName),
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
                                value: w.waterSourceNameID,
                                child: Text(w.waterSourceName),
                                // child: Text(w.waterSourceNameID.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => form_samplewaterSourceNameID = val,
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
                          print(
                            "http://10.10.15.21:3003/api/subtests/$formWaterSourceType/$value ",
                          );
                          setState(() {
                            // update some state variable instead of calling build()
                            selectedAnalysisType.add(value!);
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      if (selectedAnalysisType.contains(1))
                        AnalysisTypesWidget(
                          analysisId: 1,
                          w_type: formWaterSourceType,
                        ),
                      if (selectedAnalysisType.contains(2))
                        AnalysisTypesWidget(
                          analysisId: 2,
                          w_type: formWaterSourceType,
                        ),
                      if (selectedAnalysisType.contains(3))
                        AnalysisTypesWidget(
                          analysisId: 3,
                          w_type: formWaterSourceType,
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
