// import 'package:aw_app/models/formSampleUpdate.dart';
// import 'package:flutter/material.dart';
// import 'package:aw_app/core/theme/colors.dart';

// class ModalWidget extends StatefulWidget {
//   const ModalWidget({super.key});

//   @override
//   State<ModalWidget> createState() => _ModalWidgetState();
// }

// class _ModalWidgetState extends State<ModalWidget> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   final TextEditingController _batchNoController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _rfidController = TextEditingController();
//   final TextEditingController _sampleStatusController = TextEditingController();
//   final TextEditingController _subLocationController = TextEditingController();

//   // Dropdowns / int values (example defaults)
//   int? _departmentID;
//   int? _sampleStatusOwner;
//   int? _sectorID;
//   int? _statusID;
//   int? _weatherID;
//   int? _sampleWaterSourceTypeID;

//   void _submitForm() {
//     if (_formKey.currentState?.validate() ?? false) {
//       final data = FormSampleUpdate(
//         batchNo: _batchNoController.text,
//         departmentID: _departmentID ?? 0,
//         notes: _notesController.text,
//         rfid: int.tryParse(_rfidController.text) ?? 0,
//         sampleStatus: _sampleStatusController.text,
//         sampleStatusOwner: _sampleStatusOwner ?? 0,
//         sectorID: _sectorID ?? 0,
//         statusID: _statusID ?? 0,
//         weatherID: _weatherID ?? 0,
//         analysisTypeIDs: {}, // You can add a widget for this later
//         location: _locationController.text,
//         sampleWaterSourceTypeID: _sampleWaterSourceTypeID ?? 0,
//         subLocation: _subLocationController.text,
//       );

//       Navigator.pop(context, data); // return the model instance
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         AnimatedModalBarrier(
//           color: AlwaysStoppedAnimation<Color>(
//             AWColors.colorDark.withAlpha(35),
//           ),
//           dismissible: true,
//         ),
//         Center(
//           child: ListView.builder(
//             itemCount: 25, // Or however many TextFields you need
//             itemBuilder: (BuildContext context, int index) {
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Field ${index + 1}',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
