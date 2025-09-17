import 'package:aw_app/models/formSampleUpdate.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/core/theme/colors.dart';

class ModalWidget extends StatefulWidget {
  const ModalWidget({super.key});

  @override
  State<ModalWidget> createState() => _ModalWidgetState();
}

class _ModalWidgetState extends State<ModalWidget> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _batchNoController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _sampleStatusController = TextEditingController();
  final TextEditingController _subLocationController = TextEditingController();

  // Dropdowns / int values (example defaults)
  int? _departmentID;
  int? _sampleStatusOwner;
  int? _sectorID;
  int? _statusID;
  int? _weatherID;
  int? _sampleWaterSourceTypeID;

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = FormSampleUpdate(
        batchNo: _batchNoController.text,
        departmentID: _departmentID ?? 0,
        notes: _notesController.text,
        rfid: int.tryParse(_rfidController.text) ?? 0,
        sampleStatus: _sampleStatusController.text,
        sampleStatusOwner: _sampleStatusOwner ?? 0,
        sectorID: _sectorID ?? 0,
        statusID: _statusID ?? 0,
        weatherID: _weatherID ?? 0,
        analysisTypeIDs: {}, // You can add a widget for this later
        location: _locationController.text,
        sampleWaterSourceTypeID: _sampleWaterSourceTypeID ?? 0,
        subLocation: _subLocationController.text,
      );

      Navigator.pop(context, data); // return the model instance
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedModalBarrier(
          color: AlwaysStoppedAnimation<Color>(
            AWColors.colorDark.withAlpha(35),
          ),
          dismissible: true,
        ),
        Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sample Form',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _batchNoController,
                      decoration: const InputDecoration(
                        labelText: 'Batch No',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _rfidController,
                      decoration: const InputDecoration(
                        labelText: 'RFID',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _sampleStatusController,
                      decoration: const InputDecoration(
                        labelText: 'Sample Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _subLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Sub-location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
