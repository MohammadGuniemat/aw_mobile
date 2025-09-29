import 'dart:typed_data';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/models/dataStaticModel/WaterSourceName.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aw_app/models/SamplesResponse.dart';
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

  String? form_location;
  String? form_batchNo;
  String? form_sampleStatus;
  int? form_sampleStatusOwner;
  int? form_waterSourceTypeID;
  String? form_subLocation;
  String? form_sampleDatetime;
  String? form_sampleAnalyseDatetime;
  Uint8List? form_sampleImageBytes;

  final ImagePicker _picker = ImagePicker();
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
      });
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => form_sampleImageBytes = bytes);
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final sample = SamplesResponse(
        sampleID: 0,
        rfid: widget.rfid,
        sampleStatus: form_sampleStatus ?? 'N/A',
        waterSourceTypeID: form_waterSourceTypeID ?? 0,
        location: form_location ?? 'N/A',
        sampleDatetime: form_sampleDatetime,
        batchNo: form_batchNo ?? 'N/A',
        sampleStatusOwner: form_sampleStatusOwner ?? 0,
        subLocation: form_subLocation ?? 'N/A',
        sampleImageBytes: form_sampleImageBytes,
        sampleAnalyseDatetime: form_sampleAnalyseDatetime,
      );

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
    final selectedWaterSourceName =
        dataProvider.waterSourceTypes
            .firstWhereOrNull(
              (wn) => wn.waterSourceTypeID == formWaterSourceType,
            )
            ?.waterSourceTypesName ??
        "Not Found";
    final user = dataProvider.getUserById(task!.collectorID)?.userName;
    final notes = task?.notes ?? '';

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
                          labelText: "Water Source Type *",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: dataProvider.waterSourceTypes
                            .map(
                              (w) => DropdownMenuItem(
                                value: w.waterSourceTypeID,
                                child: Text(w.waterSourceTypesName),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => form_waterSourceTypeID = val,
                        validator: (val) => val == null ? "Required" : null,
                        onSaved: (val) => form_waterSourceTypeID = val,
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

                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: "Additional Notes",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Sample Status *",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: Samplestatus.sampleStatusList
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => form_sampleStatus = val,
                        validator: (val) => val == null ? "Required" : null,
                        onSaved: (val) => form_sampleStatus = val,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Take Photo"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: Colors.green[50],
                                foregroundColor: Colors.green[800],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (form_sampleImageBytes != null)
                            Expanded(
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.memory(form_sampleImageBytes!),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

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
