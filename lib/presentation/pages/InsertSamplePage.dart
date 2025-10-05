import 'dart:typed_data';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/models/dataStaticModel/FormWaterSourceType.dart';
import 'package:aw_app/models/dataStaticModel/WaterSourceName.dart';
import 'package:aw_app/presentation/pages/formMoreDetails.dart';
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

class InsertSamplePage extends StatefulWidget {
  final int rfid;
  const InsertSamplePage({required this.rfid, super.key});

  @override
  State<InsertSamplePage> createState() => _InsertSamplePageState();
}

class _InsertSamplePageState extends State<InsertSamplePage> {
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
  int? form_samplewaterSourceTypeID; //Optional for further waterSourceNameID
  String? form_subLocation;

  // === NEW/UPDATED STATE VARIABLES FOR DYNAMIC SUB LOCATION ===
  bool _eableSampleSubRecords = false;
  List<String> _subLocationsList = [];
  int?
  _selectedWaterSourceNameID; // 👈 FIX: Used to hold the selected Location ID and prevent the assertion error.
  // ==========================================================

  // using for sub test renderer
  List<int> selectedAnalysisType = [];

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

  // === FUNCTION TO HANDLE LOCATION CHANGE LOGIC ===
  void _handleLocationChanged(
    int? waterSourceNameID,
    DataProvider dataProvider,
  ) {
    if (waterSourceNameID == null) {
      setState(() {
        form_samplewaterSourceTypeID = null;
        form_location = null;
        _eableSampleSubRecords = false;
        _subLocationsList = [];
        form_subLocation = null;
      });
      return;
    }

    // 1. Find the WaterSourceTypeID from the selected WaterSourceNameID
    final WaterSourceName? selectedWST = dataProvider.waterSourceNames
        .firstWhereOrNull((wsn) => wsn.waterSourceNameID == waterSourceNameID);

    if (selectedWST == null) return;

    final typeID = selectedWST.waterSourceTypeID;

    // Update form data immediately
    form_samplewaterSourceTypeID = typeID;
    form_location = selectedWST.waterSourceName;

    // Update state variables to control UI rendering
    setState(() {
      // Logic mirrored from the React implementation:
      if ([1, 2, 6].contains(typeID)) {
        // بئر خزان ضخ تعطيل - No sub-location
        _eableSampleSubRecords = false;
        _subLocationsList = [];
      } else if ([3].contains(typeID)) {
        // شبكات تفعيل انبوت - Free text input
        _eableSampleSubRecords = true;
        _subLocationsList = [];
      } else if ([4].contains(typeID)) {
        // عادمة تفعيل ان اوت
        _eableSampleSubRecords = true;
        _subLocationsList = ['In', 'Out'];
      } else if ([5].contains(typeID)) {
        // تحليه تفعيل بثلاث خيارات
        _eableSampleSubRecords = true;
        _subLocationsList = ['RO', 'Product', 'Well'];
      } else if ([7].contains(typeID)) {
        // معالجة تفعيل ان اوت وخيار
        _eableSampleSubRecords = true;
        _subLocationsList = ['In', 'Out', 'Other'];
      } else {
        // Default
        _eableSampleSubRecords = false;
        _subLocationsList = [];
      }

      // Clear subLocation value when the location type changes
      form_subLocation = null;
    });
  }
  // ========================================================

  void _submit(BuildContext context) async {
    print("=== SUBMIT START ===");

    final authProvider = context.read<AuthProvider>();
    final sampleProvider = context.read<SamplesProvider>();

    final token = authProvider.token ?? '';
    form_sampleStatusOwner = authProvider.userID;

    if (_formKey.currentState!.validate()) {
      // 1. Manually collect data from AnalysisTypesWidget keys BEFORE saving the form.
      form_analysisTypeIDs = {};

      // Collect data from the first analysis widget (if it was rendered)
      if (analysis1Key.currentState != null &&
          selectedAnalysisType.contains(1)) {
        final data = analysis1Key.currentState!.getSelectedValues();
        if (data.isNotEmpty) {
          form_analysisTypeIDs!.addAll(data);
        }
      }

      // Collect data from the second analysis widget (if it was rendered)
      if (analysis2Key.currentState != null &&
          selectedAnalysisType.contains(2)) {
        final data = analysis2Key.currentState!.getSelectedValues();
        if (data.isNotEmpty) {
          form_analysisTypeIDs!.addAll(data);
        }
      }

      // Collect data from the third analysis widget (if it was rendered)
      if (analysis3Key.currentState != null &&
          selectedAnalysisType.contains(3)) {
        final data = analysis3Key.currentState!.getSelectedValues();
        if (data.isNotEmpty) {
          form_analysisTypeIDs!.addAll(data);
        }
      }

      // 2. Save other form fields (like batchNo, notes, etc.)
      _formKey.currentState!.save();

      final sample = InsertSampleModel(
        batchNo: form_batchNo ?? 'N/A',
        notes: form_notes ?? '',
        rfid: widget.rfid,
        sampleStatus: form_sampleStatus ?? 'N/A',
        sampleStatusOwner: form_sampleStatusOwner ?? 0,
        // The analysis data is now correctly populated here:
        analysisTypeIDs: form_analysisTypeIDs ?? {},
        location: form_location ?? 'N/A',
        sampleWaterSourceTypeID: form_samplewaterSourceTypeID ?? 0,
        subLocation: form_subLocation ?? 'N/A',
      );

      final sampleMap = sample.toJson();

      // 🔥 Debug print
      print("🚀 Sending sample data to API:");
      sampleMap.forEach((k, v) => print("  $k: $v"));
      print(
        "  analysisTypeIDs: ${form_analysisTypeIDs}",
      ); // Verify the analysis data

      try {
        final response = await Api.post.insertSample(token, sampleMap);

        if (response.statusCode == 200) {
          sampleProvider.setListOfFormSamples(token, widget.rfid);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => FormMoreDetails(rfid: widget.rfid),
            ),
          );
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
    final waterTypeID = dataProvider.waterTypes
        .firstWhereOrNull((w) => w.waterTypeID == task!.waterTypeID)
        ?.waterTypeID;

    List<FormWaterSourceType>? ListOfWaterFormSourceType = dataProvider
        .findListOfWaterFormSourceTypeById(task!.rFID);
    print("formWaterSourceType22 ${ListOfWaterFormSourceType?.length}");

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

                      // Location Dropdown (WaterSourceName)
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: "Location *",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        // 👈 FIX: Use the state variable to hold the selected value
                        value: _selectedWaterSourceNameID,
                        items: listOfwaterSourceName
                            .map(
                              (w) => DropdownMenuItem(
                                value: w.waterSourceNameID,
                                child: Text(w.waterSourceName),
                              ),
                            )
                            .toList(),
                        // === UPDATED onChanged CALL ===
                        onChanged: (val) {
                          setState(() {
                            // 👈 FIX: Update the state variable immediately
                            _selectedWaterSourceNameID = val;
                          });
                          if (val != null) {
                            _handleLocationChanged(val, dataProvider);
                          }
                        },
                        // ==============================
                        validator: (val) => val == null ? "Required" : null,
                      ),
                      const SizedBox(height: 16),

                      // === DYNAMIC SUB LOCATION FIELD ===
                      if (_eableSampleSubRecords)
                        if (_subLocationsList.isNotEmpty)
                          // Renders a Dropdown if a list of sub-locations is available (Types 4, 5, 7)
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Sub Location *",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            value: form_subLocation,
                            items: _subLocationsList
                                .map(
                                  (sub) => DropdownMenuItem(
                                    value: sub,
                                    child: Text(sub),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                form_subLocation = val;
                              });
                            },
                            validator: (val) => val == null ? "Required" : null,
                            onSaved: (val) => form_subLocation = val,
                          )
                        else
                          // Renders a TextFormField if sub-location is enabled but no predefined list exists (Type 3)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Sub Location *",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            initialValue: form_subLocation,
                            onSaved: (val) => form_subLocation = val,
                            validator: (val) =>
                                val == null || val.isEmpty ? "Required" : null,
                          )
                      else
                        // Renders a disabled TextFormField when sub-location is not enabled (Types 1, 2, 6)
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Sub Location (N/A)",
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[200], // Greyed out
                          ),
                          enabled: false,
                          initialValue: '',
                          onSaved: (val) => form_subLocation = null,
                        ),

                      // ==================================
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

                      // Test Types Dropdown
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
                              selectedAnalysisType.add(value!);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // AnalysisTypeWidget renderings
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
                                if (analysis1Key.currentState != null) {
                                  analysis1Key.currentState!.clearAllSubTests();
                                }
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
                                if (analysis2Key.currentState != null) {
                                  analysis2Key.currentState!.clearAllSubTests();
                                }
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
                                if (analysis3Key.currentState != null) {
                                  analysis3Key.currentState!.clearAllSubTests();
                                }
                                setState(() {
                                  selectedAnalysisType.remove(3);
                                });
                              },
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // You'll need to use setState for this if it's not already a state variable:
                      // String? _selectedSampleStatus;
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Sample Status *",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        // Use the form variable to hold the value
                        value: form_sampleStatus,
                        items: Samplestatus.sampleStatusList
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),

                        onChanged: (val) {
                          // Use setState to update the UI and the form variable
                          setState(() {
                            form_sampleStatus = val;
                          });
                        },

                        // The validator goes here, directly in the widget definition
                        validator: (val) => val == null ? "Required" : null,

                        // The onSaved callback goes here
                        onSaved: (val) => form_sampleStatus = val,
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
