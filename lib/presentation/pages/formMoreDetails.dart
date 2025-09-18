import 'package:flutter/material.dart';
import 'package:aw_app/models/formSampleUpdate.dart';

class FormMoreDetails extends StatefulWidget {
  final FormSampleUpdate prefillData; // required simulated data

  const FormMoreDetails({super.key, required this.prefillData});

  @override
  State<FormMoreDetails> createState() => _FormMoreDetailsState();
}

class _FormMoreDetailsState extends State<FormMoreDetails> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with prefillData
    _controllers = List.generate(12, (index) => TextEditingController());

    // Assign values from prefillData
    _controllers[0].text = widget.prefillData.batchNo;
    _controllers[1].text = widget.prefillData.departmentID.toString();
    _controllers[2].text = widget.prefillData.notes;
    _controllers[3].text = widget.prefillData.rfid.toString();
    _controllers[4].text = widget.prefillData.sampleStatus;
    _controllers[5].text = widget.prefillData.sampleStatusOwner.toString();
    _controllers[6].text = widget.prefillData.sectorID.toString();
    _controllers[7].text = widget.prefillData.statusID.toString();
    _controllers[8].text = widget.prefillData.weatherID.toString();
    _controllers[9].text = widget.prefillData.location;
    _controllers[10].text = widget.prefillData.sampleWaterSourceTypeID
        .toString();
    _controllers[11].text = widget.prefillData.subLocation;
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form More Details")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controllers[index],
                    builder: (context, value, child) {
                      return TextField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          labelText: value.text.isEmpty
                              ? 'Field ${index + 1}'
                              : value.toString(),
                          border: const OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final values = _controllers.map((c) => c.text).toList();
              print(values);

              // Convert back to model
              final updatedData = FormSampleUpdate(
                batchNo: _controllers[0].text,
                departmentID: int.tryParse(_controllers[1].text) ?? 0,
                notes: _controllers[2].text,
                rfid: int.tryParse(_controllers[3].text) ?? 0,
                sampleStatus: _controllers[4].text,
                sampleStatusOwner: int.tryParse(_controllers[5].text) ?? 0,
                sectorID: int.tryParse(_controllers[6].text) ?? 0,
                statusID: int.tryParse(_controllers[7].text) ?? 0,
                weatherID: int.tryParse(_controllers[8].text) ?? 0,
                analysisTypeIDs: {}, // add if needed
                location: _controllers[9].text,
                sampleWaterSourceTypeID:
                    int.tryParse(_controllers[10].text) ?? 0,
                subLocation: _controllers[11].text,
              );

              print(updatedData.toJson());
            },
            child: const Text("Print Values"),
          ),
        ],
      ),
    );
  }
}
