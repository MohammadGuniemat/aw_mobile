import 'dart:convert';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/models/dataStaticModel/FormWaterSourceType.dart';
import 'package:aw_app/models/dataStaticModel/WaterSourceName.dart';
import 'package:aw_app/models/samplesResponse.dart';
import 'package:aw_app/presentation/pages/formMoreDetails.dart';
import 'package:aw_app/presentation/widgets/sampleWidgets/SampleDetailsWidget.dart';
import 'package:aw_app/presentation/widgets/sampleWidgets/SampleDetailsWidget.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/server/apis.dart';
import 'package:provider/provider.dart';
import 'package:aw_app/models/InsertSampleModel.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:aw_app/provider/samplesProvider.dart';
import 'package:aw_app/core/constants/SampleStatus.dart';
import 'package:collection/collection.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/provider/task_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data'; // ✅ Add this

class UpdateSamplePage extends StatefulWidget {
  final rfid;
  final SamplesResponse
  existingSample; // 👈 Pass existing SamplesResponse.. sample to update

  const UpdateSamplePage({
    required this.rfid,
    required this.existingSample,
    super.key,
  });

  @override
  State<UpdateSamplePage> createState() => _UpdateSamplePageState();
}

class _UpdateSamplePageState extends State<UpdateSamplePage> {
  Uint8List? sampleImageBytes; // Holds existing or newly picked image
  // Add keys
  final GlobalKey<SampleDetailsDropdownState> subAnalysis1Key =
      GlobalKey<SampleDetailsDropdownState>();
  final GlobalKey<SampleDetailsDropdownState> subAnalysis2Key =
      GlobalKey<SampleDetailsDropdownState>();
  final GlobalKey<SampleDetailsDropdownState> subAnalysis3Key =
      GlobalKey<SampleDetailsDropdownState>();

  final _formKey = GlobalKey<FormState>();
  TaskModel? task;

  String? form_batchNo;
  String? form_notes;
  String? form_sampleStatus;
  int? form_sampleStatusOwner;
  Map<int, Map<int, String>>? form_analysisTypeIDs;
  String? form_location;
  int? form_samplewaterSourceTypeID;
  String? form_subLocation;

  List<String> _subLocationsList = [];
  int? _selectedWaterSourceNameID;
  bool _enableSampleSubRecords = false;
  List<int> selectedAnalysisType = [];

  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController();

    // Initialize image bytes from existing sample
    sampleImageBytes = widget.existingSample.sampleImageBytes;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final taskProvider = context.read<TaskProvider>();
      final dataProvider = context.read<DataProvider>();

      try {
        // STEP 1: get analysis types for this sample
        final response = await Api.get.getAnalysisType(
          authProvider.token!,
          widget.existingSample.sampleID!,
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          print("📦 Analysis Types from API: $data");

          // Extract list of strings like ["Physical", "Chemical"]
          final List<String> analysisTypeDescs = data
              .map((item) => item['AnalysisTypeDesc'] as String)
              .toList();

          // STEP 2: map them to IDs using dataProvider
          final List<int> matchedIDs = dataProvider.analysisTypes
              .where(
                (type) => analysisTypeDescs.contains(type.analysisTypeDesc),
              )
              .map((type) => type.analysisTypeID)
              .toList();

          // STEP 3: assign to selectedAnalysisType
          setState(() {
            selectedAnalysisType = matchedIDs;
          });

          print("✅ Mapped AnalysisTypeIDs: $selectedAnalysisType");
        } else {
          print("⚠️ Failed to fetch analysis types: ${response.body}");
        }
      } catch (e) {
        print("❌ Error fetching analysis types: $e");
      }

      final foundTask = taskProvider.tasks
          .where((t) => t.rFID == widget.rfid)
          .firstOrNull;

      final foundSource = dataProvider.findWaterSourceIdByName(
        widget.existingSample.location,
      );

      setState(() {
        task = foundTask;

        // ✅ Pre-fill existing sample data
        form_batchNo = widget.existingSample.batchNo;
        form_notes = task?.notes ?? '';
        form_sampleStatus = widget.existingSample.sampleStatus;
        form_location = widget.existingSample.location;
        form_subLocation = widget.existingSample.subLocation;
        form_samplewaterSourceTypeID =
            foundSource?.waterSourceTypeID ??
            widget.existingSample.waterSourceTypeID;
        _selectedWaterSourceNameID = foundSource?.waterSourceNameID;

        notesController.text = form_notes ?? '';

        // 🧠 Initialize analysis
        form_analysisTypeIDs = {
          1: {2: 'testAnalysis'},
        };
      });

      // ✅ IMPORTANT: initialize sublocation logic
      if (foundSource != null) {
        _handleLocationChanged(foundSource.waterSourceNameID, dataProvider);
        // This ensures _enableSampleSubRecords and _subLocationsList are set.
      }
    });
  }

  // === Handle location/sub-location logic (same as before) ===
  void _handleLocationChanged(
    int? waterSourceNameID,
    DataProvider dataProvider,
  ) {
    if (waterSourceNameID == null) {
      setState(() {
        form_samplewaterSourceTypeID = null;
        form_location = null;
        _enableSampleSubRecords = false;
        _subLocationsList = [];
        form_subLocation = null;
      });
      return;
    }

    final WaterSourceName? selectedWST = dataProvider.waterSourceNames
        .firstWhereOrNull((wsn) => wsn.waterSourceNameID == waterSourceNameID);

    if (selectedWST == null) return;

    final typeID = selectedWST.waterSourceTypeID;

    print("typeID77: $typeID");

    form_samplewaterSourceTypeID = typeID;
    form_location = selectedWST.waterSourceName;

    setState(() {
      if ([1, 2, 6].contains(typeID)) {
        //خزان
        _enableSampleSubRecords = false;
        _subLocationsList = [];
      } else if ([3].contains(typeID)) {
        //شبكة
        _enableSampleSubRecords = true;
        _subLocationsList = [];
      } else if ([4].contains(typeID)) {
        //محطة تنقية
        _enableSampleSubRecords = true;
        _subLocationsList = ['In', 'Out'];
      } else if ([5].contains(typeID)) {
        //محطة تحلية
        _enableSampleSubRecords = true;
        _subLocationsList = ['RO', 'Product', 'Well'];
      } else if ([7].contains(typeID)) {
        _enableSampleSubRecords = true;
        _subLocationsList = ['In', 'Out', 'Other'];
      } else {
        _enableSampleSubRecords = false;
        _subLocationsList = [];
      }
      form_subLocation = widget.existingSample.subLocation;
    });
  }

  // === Submit update instead of insert ===
  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save all form field values
      print(
        "Rsult analysis1Key.currentState : ${subAnalysis1Key.currentState}",
      );
      print(
        "Rsult analysis2Key.currentState : ${subAnalysis2Key.currentState}",
      );
      print(
        " Rsult analysis3Key.currentState : ${subAnalysis3Key.currentState}",
      );
      // ✅ Collect analysis maps
      Map<int, Map<int, String>> analysisMap = {};
      if (subAnalysis1Key.currentState != null) {
        analysisMap.addAll(subAnalysis1Key.currentState!.getAnalysisMap());
      }
      if (subAnalysis2Key.currentState != null) {
        analysisMap.addAll(subAnalysis2Key.currentState!.getAnalysisMap());
      }
      if (subAnalysis3Key.currentState != null) {
        analysisMap.addAll(subAnalysis3Key.currentState!.getAnalysisMap());
      }

      form_analysisTypeIDs = analysisMap;

      print("UPDATE analysisMap ${form_analysisTypeIDs ?? 'N/A'}");

      print("=== UPDATE SAMPLE START ===");
      // RFID:1436
      print("RFID: ${widget.rfid}");
      // BatchNo: "B205"
      print("Batch No: ${form_batchNo ?? 'N/A'}");
      // Notes:"من ادمن جمع العين"
      print("Notes: ${form_notes ?? 'N/A'}");
      // SampleStatus: "DRAFT"
      print("Sample Status: ${form_sampleStatus ?? 'N/A'}");
      // SampleStatusOwner: ""
      print("Sample Status Owner: ${form_sampleStatusOwner ?? 'N/A'}");
      // location: "محطة تحلية بئر مذكور"
      print("Location: ${form_location ?? 'N/A'}");
      // sub_location: "Product"
      print("Sub Location: ${form_subLocation ?? 'N/A'}");
      // sample_WaterSourceTypeID: 5
      print(
        "Sample Water Source Type ID: ${form_samplewaterSourceTypeID ?? 'N/A'}",
      );
      // analysisTypeIDs: {}
      print("Selected Analysis Types IDs: $selectedAnalysisType");
      print("Image attached: ${sampleImageBytes != null ? 'Yes' : 'No'}");

      print("=== UPDATE SAMPLE END ===");
      // AnalysedAt: [{11: "2025-02-02T21:00:00.000Z"}, {13: "2028-08-25T21:00:00.000Z"}, {28: "2028-08-25T21:00:00.000Z"}]
      // Methods: [{11: 7}, {13: 8}, {28: 9}]
      // Units: [{11: 7}, {13: 8}, {28: 9}]
      // labFields: {}
      // sampleID: 1252

      // call img uploader API sampleImageBytes
    } else {
      print("Form validation failed! Please check required fields.");
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
        appBar: AppBar(title: const Text("Update Sample")),
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
    // _selectedWaterSourceNameID=widget.existingSample.location

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

    _selectedWaterSourceNameID = dataProvider
        .findWaterSourceIdByName(widget.existingSample.location)
        ?.waterSourceNameID;
    // ... (UI stays the same, just change titles and button text)

    final authProv2 = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Sample with form#: ${widget.rfid}"),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: "This form name is "),
                            TextSpan(
                              text: task?.rFName?.trim().isNotEmpty == true
                                  ? task!.rFName!.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " for the department "),
                            TextSpan(
                              text: department?.trim().isNotEmpty == true
                                  ? department!.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " from governorate "),
                            TextSpan(
                              text: governorate?.trim().isNotEmpty == true
                                  ? governorate!.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " in area "),
                            TextSpan(
                              text: area?.trim().isNotEmpty == true
                                  ? area!.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ". The water source is "),
                            TextSpan(
                              text: concatingWaterSourceName.trim().isNotEmpty
                                  ? concatingWaterSourceName.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " and water type is "),
                            TextSpan(
                              text: waterType?.trim().isNotEmpty == true
                                  ? waterType!.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ".\nCollected by "),
                            TextSpan(
                              text: user?.trim().isNotEmpty == true
                                  ? user!.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " with weather conditions "),
                            TextSpan(
                              text: weather?.trim().isNotEmpty == true
                                  ? weather!.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ".\nIt belongs to sector "),
                            TextSpan(
                              text: sector?.trim().isNotEmpty == true
                                  ? sector!.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " with status "),
                            TextSpan(
                              text: status?.trim().isNotEmpty == true
                                  ? status!.trim()
                                  : "Not Available",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      if (_enableSampleSubRecords)
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

                      // Text('sample88 $_selectedWaterSourceNameID'),
                      TextFormField(
                        initialValue: form_batchNo,
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

                      const SizedBox(height: 20),

                      // You'll need to use setState for this if it's not already a state variable:
                      // String? _selectedSampleStatus;
                    ],
                  ),
                ),
              ),

              /// building Card For Sample SubTests
              ///
              /// Physical SampleSubTests
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("PHYSICAL", style: TextStyle(fontSize: 20)),
                      SampleDetailsDropdown(
                        key: subAnalysis1Key, // ✅ Attach key
                        token: authProv2.token!,
                        sampleID: widget.existingSample.sampleID,
                        waterTypeID: waterTypeID!,
                        filter: 1,
                      ),
                    ],
                  ),
                ),
              ),

              /// Chemical SampleSubTests
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Chemical", style: TextStyle(fontSize: 20)),
                      SampleDetailsDropdown(
                        key: subAnalysis2Key, // ✅ Attach key
                        token: authProv2.token!,
                        sampleID: widget.existingSample.sampleID,
                        waterTypeID: waterTypeID!,

                        filter: 2,
                      ),
                    ],
                  ),
                ),
              ),

              /// microbiological SampleSubTests
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Microbiological", style: TextStyle(fontSize: 20)),
                      SampleDetailsDropdown(
                        key: subAnalysis3Key, // ✅ Attach key
                        token: authProv2.token!,
                        sampleID: widget.existingSample.sampleID,
                        waterTypeID: waterTypeID!,

                        filter: 3,
                      ),
                    ],
                  ),
                ),
              ),

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
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
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

              buildSampleImageUploader(),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Makes button full-width
                child: ElevatedButton(
                  onPressed: () {
                    print("Button pressed");
                    _submit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700], // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ), // Button height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Rounded corners
                    ),
                    elevation: 4, // Shadow
                  ),
                  child: const Text(
                    "SUBMIT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSampleImageUploader() {
    final ImagePicker picker = ImagePicker();

    Future<void> pickAndSet(ImageSource source) async {
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          sampleImageBytes = bytes;
        });
      }
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sample Image",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),

            sampleImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      sampleImageBytes!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text("Gallery"),
                  onPressed: () => pickAndSet(ImageSource.gallery),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text("Camera"),
                  onPressed: () => pickAndSet(ImageSource.camera),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
