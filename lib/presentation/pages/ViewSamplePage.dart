import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // for firstOrNull
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/provider/task_provider.dart';
import 'package:aw_app/provider/samplesProvider.dart';
import 'package:aw_app/provider/data_provider.dart';

class ViewSamplePage extends StatefulWidget {
  final int rfid;

  const ViewSamplePage({required this.rfid, super.key});

  @override
  State<ViewSamplePage> createState() => _ViewSamplePageState();
}

class _ViewSamplePageState extends State<ViewSamplePage> {
  final _formKey = GlobalKey<FormState>();

  TaskModel? task;
  String? notes;

  @override
  void initState() {
    super.initState();

    // Get task from provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = context.read<TaskProvider>();
      final foundTask = taskProvider.tasks
          .where((t) => t.rFID == widget.rfid)
          .firstOrNull;

      setState(() {
        task = foundTask;
        notes = foundTask?.notes ?? '';
      });
    });
  }

  Widget infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text("$label: ${value ?? 'NOT FOUND'}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final samplesProvider = context.read<SamplesProvider>();
    final dataProvider = context.watch<DataProvider>();

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Insert Sample")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final taskMap = task!.toJson();

    // 🔹 Lookup names from models instead of showing IDs
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
    print("object ${task!.weatherID}");
    final area = dataProvider.findAreaById(task!.areaID)?.areaName;
    final waterType = dataProvider.waterTypes
        .firstWhereOrNull((w) => w.waterTypeID == task!.waterTypeID)
        ?.waterTypeName;

    final user = dataProvider.getUserById(task!.collectorID)?.userName;

    return Scaffold(
      appBar: AppBar(title: Text("Insert Sample for RFID: ${task!.rFID}")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Divider(),
              Text(
                "Task Details:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),

              // Show readable names
              infoRow("RFID", task!.rFID),
              infoRow("RFName", task!.rFName),
              infoRow("Governorate", governorate),
              infoRow("Area", area),
              infoRow("Water Type", waterType),
              // infoRow("WaterSourceTypeID", task!.waterSourceTypeID),
              // infoRow("CollectorID", task!.collectorID),
              infoRow("CollectorUserName", user),
              // must be collector name
              infoRow("Department", department),
              infoRow("Sector", sector),
              infoRow("Status", status),
              infoRow("RF_Status", task!.rFStatus),
              infoRow("Weather", weather),

              //waterSourceName
              //location
              //test type
              //batch no.
              infoRow("Notes", task!.notes),
              // SampleStatus
              /*  infoRow("ApplicationDate", task!.applicationDate),
              infoRow("OwnerID", task!.ownerID),
              infoRow("ReceivedBy", task!.receivedBy),
              infoRow("ReceivedDate", task!.receivedDate),
              infoRow("SubmittedBy", task!.submittedBy),
              infoRow("SubmittedDate", task!.submittedDate),
              infoRow("ApprovedBy", task!.approvedBy),
              infoRow("ApprovedDate", task!.approvedDate),
              infoRow("IsTemplate", task!.isTemplate),*/
              infoRow("SamplingAllowed", task!.samplingAllowed),

              const Divider(),

              // Notes input
              TextFormField(
                decoration: const InputDecoration(labelText: "Notes"),
                initialValue: notes,
                onChanged: (val) => notes = val,
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final data = {"rfid": task!.rFID, "notes": notes};

                    // Debug log
                    taskMap.forEach((key, value) => print('$key: $value'));
                    print('-------------------');

                    // Save via provider
                    // samplesProvider.insertSample(data);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sample saved!")),
                    );
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
