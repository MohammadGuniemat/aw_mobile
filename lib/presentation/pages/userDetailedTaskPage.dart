import 'package:aw_app/models/dataStaticModel/Department.dart';
import 'package:aw_app/models/dataStaticModel/Weather.dart';
import 'package:aw_app/models/dataStaticModel/sector.dart';
import 'package:aw_app/models/formSampleUpdate.dart';
import 'package:aw_app/presentation/pages/formMoreDetails.dart';
import 'package:aw_app/presentation/widgets/modalWidget.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:aw_app/provider/samplesProvider.dart';
import 'package:aw_app/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:provider/provider.dart';

// final simulatedSample = FormSampleUpdate.fromJson({
//   "BatchNo": "B1",
//   "DepartmentID": 0,
//   "Notes": "",
//   "RFID": 1435,
//   "SampleStatus": "COLLECTED",
//   "SampleStatusOwner": 1038,
//   "SectorID": 0,
//   "StatusID": 0,
//   "WeatherID": 0,
//   "analysisTypeIDs": {},
//   "location": "محطة تحلية قطر",
//   "sample_WaterSourceTypeID": 5,
//   "sub_location": "Product",
// });

class UserDetailedTasksPage extends StatefulWidget {
  // Simulated API response mapped to your model

  final int userId;
  final String statusFilter;

  UserDetailedTasksPage({
    Key? key,
    required this.userId,
    required this.statusFilter,
  }) : super(key: key);

  @override
  _UserDetailedTasksPageState createState() => _UserDetailedTasksPageState();
}

class _UserDetailedTasksPageState extends State<UserDetailedTasksPage> {
  late Future<List<TaskModel>> _tasksFuture;
  late TaskProvider _taskProvider;
  late AuthProvider _authProvider;
  late SamplesProvider _samplesProvider;
  late DataProvider _dataProvider;
  late List<Sector> _sectorsList;
  late List<Department> _departmentsList;
  late List<Weather> _weathersList;
  late Map<int, Map<String, int>> selectedFormValuesByRFID;

  @override
  void initState() {
    super.initState();
    _taskProvider = context.read<TaskProvider>();
    _authProvider = context.read<AuthProvider>();
    _samplesProvider = context.read<SamplesProvider>();
    _dataProvider = context.read<DataProvider>();
    _sectorsList = _dataProvider.sectors.toList().cast<Sector>();
    _departmentsList = _dataProvider.departments.cast<Department>();
    _weathersList = _dataProvider.weather.toList().cast<Weather>();
    selectedFormValuesByRFID = {};

    _loadTasks();
  }

  void getSectors() {
    print("object");
    List myList = _dataProvider.sectors.toList();
    print("myList $myList");
    print("myList ${myList.length}");

    for (var element in myList) {
      print("sectorDesc ${element.sectorDesc}");
      print("sectorID ${element.sectorID}");
    }
  }

  void _loadTasks() {
    _tasksFuture = _taskProvider.loadUserSingleFilteredTasks(
      _authProvider.token!,
      widget.userId,
      widget.statusFilter,
      1, //current page index
      10, //total recordes per page
    );
  }

  void _loadSampleListForForm(int rfid) async {
    await _samplesProvider.setListOfFormSamples(_authProvider.token!, rfid);
    print("✅ Samples fetched, navigating to FormMoreDetails...");

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FormMoreDetails(rfid: rfid)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.statusFilter),
        backgroundColor: AWColors.primary,
        foregroundColor: AWColors.background,
        centerTitle: true,
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
              icon: const Icon(Icons.replay_outlined),
              onPressed: () {
                _authProvider.getUserInfo();
                _authProvider.refreshSingleUserInfo();
                _taskProvider.reloadTasks(
                  _authProvider.token!,
                  _authProvider.userID!,
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<TaskModel>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          // Get isLoading reactively
          final isLoading = context.select<SamplesProvider, bool>(
            (provider) => provider.isSampleLoading,
          );
          if (snapshot.connectionState == ConnectionState.waiting ||
              isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No tasks available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final appDate = task.applicationDate != null
                    ? DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(task.applicationDate!)
                    : "N/A";
                final statusColor = getStatusColor(task.color);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),

                    side: BorderSide(
                      color: const Color.fromARGB(115, 117, 10, 138),
                      width: 1.8,
                    ),
                  ),
                  // color: const Color.fromARGB(132, 233, 211, 231),
                  borderOnForeground: true,
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => {
                                _loadSampleListForForm(task.rFID!),
                              },
                              color: const Color.fromARGB(255, 2, 139, 251),
                              style: IconButton.styleFrom(),

                              icon: const Icon(
                                Icons
                                    .bar_chart, // Example icon related to 'samples' or 'list'
                              ),

                              tooltip: 'Show Samples',
                            ),
                            Text(
                              task.rFName ?? "Unnamed Task",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final rfid = task.rFID!;
                                final formData =
                                    selectedFormValuesByRFID[rfid] ??
                                    {
                                      'DepartmentID': task.departmentID ?? -1,
                                      'SectorID': task.sectorID ?? -1,
                                      'WeatherID': task.weatherID ?? -1,
                                    };

                                print(
                                  "📝 Submitting for RFID: $rfid with data: $formData",
                                );

                                // Example placeholder for your API call
                                // await _samplesProvider.submitTaskForm(_authProvider.token!, rfid, formData);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "✅ Submitted RFID $rfid successfully!",
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.save),
                              color: const Color.fromARGB(255, 2, 139, 251),
                            ),
                          ],
                        ),
                        // Top: Task Name & RFID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(height: 50),
                            // ElevatedButton(
                            //   // token and RFID are in the caleed function body
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: AWColors.colorDark,
                            //   ),
                            //   onPressed: () => {getSectors()},
                            //   child: const Text(
                            //     'SHOW SAMPLES',
                            //     style: TextStyle(color: AWColors.colorLight),
                            //   ),
                            // ),
                            Column(
                              children: [
                                // Text(
                                //   'MUST IMPLEMENT PAGINATION',
                                //   style: TextStyle(color: Colors.red),
                                // ),

                                // Selector<SamplesProvider, String>(
                                //   selector: (context, provider) =>
                                //       provider.sampleProviderMsg,
                                //   builder: (context, message, child) {
                                //     return Text(
                                //       message ?? 'Getting Samples List ...',
                                //     );
                                //   },
                                // ),
                                // Text(
                                //   _sampleGettingMS(),
                                //   style: TextStyle(color: Colors.red),
                                // ),
                              ],
                            ),
                            const SizedBox(width: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "ID: ${task.rFID ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(172, 0, 0, 0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Status & Application Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  appDate,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                task.rFStatusDesc ?? "Unknown Status",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(172, 0, 0, 0),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Info Rows with Icons
                        GridView.count(
                          crossAxisCount: 2, // 3 items per row
                          shrinkWrap:
                              true, // Allows GridView to size itself based on content
                          physics:
                              NeverScrollableScrollPhysics(), // Prevents scrolling inside parent scroll view
                          childAspectRatio:
                              5, // Adjust this to control width/height ratio
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                          children: [
                            _buildIconInfoRow(
                              Icons.location_city,
                              "Governorate",
                              task.governorateName,
                              color: AWColors.colorDark,
                            ),
                            // _buildIconInfoRow(
                            //   Icons.apartment,
                            //   "Sector",
                            //   task.sectorDesc,
                            //   color: AWColors.colorDark,
                            // ),

                            // ⚠️ ASSUMPTION: Update the type of the list you use for the dropdown
                            // We'll use the provider's list, cast to List<dynamic> temporarily for flexibility,
                            // but List<Sector> is ideal if you define the Sector class.
                            // For Sectors
                            CustomTaskDropdown<Sector>(
                              items: _sectorsList,
                              initValue: task.sectorID,
                              label: "Sector *",
                              getId: (s) => s.sectorID,
                              getDesc: (s) => s.sectorDesc,
                              onChanged: (id) {
                                final rfid = task.rFID!;
                                selectedFormValuesByRFID.putIfAbsent(
                                  rfid,
                                  () => {
                                    'DepartmentID': -1,
                                    'SectorID': -1,
                                    'WeatherID': -1,
                                  },
                                );
                                selectedFormValuesByRFID[rfid]!['SectorID'] =
                                    id ?? -1;
                                print(
                                  "✅ [RFID $rfid] Sector selected: ${selectedFormValuesByRFID[rfid]!['SectorID']}",
                                );
                              },
                            ),

                            CustomTaskDropdown<Department>(
                              items: _departmentsList,
                              initValue: task.departmentID,
                              label: "Department *",
                              getId: (d) => d.departmentID,
                              getDesc: (d) => d.departmentName,
                              onChanged: (id) {
                                final rfid = task.rFID!;
                                selectedFormValuesByRFID.putIfAbsent(
                                  rfid,
                                  () => {
                                    'DepartmentID': -1,
                                    'SectorID': -1,
                                    'WeatherID': -1,
                                  },
                                );
                                selectedFormValuesByRFID[rfid]!['DepartmentID'] =
                                    id ?? -1;
                                print(
                                  "✅ [RFID $rfid] Department selected: ${selectedFormValuesByRFID[rfid]!['DepartmentID']}",
                                );
                              },
                            ),

                            CustomTaskDropdown<Weather>(
                              items: _weathersList,
                              initValue: task.weatherID,
                              label: "Weather *",
                              getId: (w) => w.weatherID,
                              getDesc: (w) => w.weatherDesc,
                              onChanged: (id) {
                                final rfid = task.rFID!;
                                selectedFormValuesByRFID.putIfAbsent(
                                  rfid,
                                  () => {
                                    'DepartmentID': -1,
                                    'SectorID': -1,
                                    'WeatherID': -1,
                                  },
                                );
                                selectedFormValuesByRFID[rfid]!['WeatherID'] =
                                    id ?? -1;
                                print(
                                  "✅ [RFID $rfid] Weather selected: ${selectedFormValuesByRFID[rfid]!['WeatherID']}",
                                );
                              },
                            ),

                            // _buildIconInfoRow(
                            //   Icons.business,
                            //   "Department",
                            //   task.departmentName,
                            //   color: AWColors.colorDark,
                            // ),
                            _buildIconInfoRow(
                              Icons.person_pin,
                              "Assigned By",
                              task.ownerUserName,
                              color: AWColors.colorDark,
                            ),
                            _buildIconInfoRow(
                              Icons.map,
                              "Area",
                              task.areaName,
                              color: AWColors.colorDark,
                            ),
                            _buildIconInfoRow(
                              task.waterTypeName == 'مياه شرب'
                                  ? Icons.water_drop
                                  : Icons.fire_truck,
                              "Water Type",
                              task.waterTypeName,
                              color: task.waterTypeName == 'مياه شرب'
                                  ? Color.fromARGB(255, 10, 112, 138)
                                  : Color.fromARGB(255, 245, 79, 2),
                            ),
                            // _buildIconInfoRow(
                            //   task.weatherDesc == 'Rain'
                            //       ? Icons.water_drop
                            //       : Icons.wb_sunny,
                            //   "Weather",
                            //   task.weatherDesc,
                            //   color: getWeatherColor(task.weatherDesc),
                            // ),
                            _buildIconInfoRow(
                              task.samplingAllowed == true
                                  ? Icons.check_circle
                                  : Icons.error,
                              "Sampling Allowed",
                              task.samplingAllowed == true ? "Yes" : "No",
                              color: task.samplingAllowed == true
                                  ? const Color.fromARGB(255, 14, 236, 6)
                                  : const Color.fromARGB(255, 245, 11, 69),
                            ),
                          ],
                        ),

                        Divider(height: 20, color: Colors.grey.shade300),

                        // Notes
                        // if (task.notes != null && task.notes!.isNotEmpty)
                        if (true)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              width: double.infinity,

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.read_more,
                                    size: 20,
                                    color: AWColors.colorDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text("Note:"),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      task.notes ?? 'Note not Avaliable !',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildIconInfoRow(
    IconData icon,
    String title,
    String? value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey.shade700),

          // const SizedBox(width: 2),
          const SizedBox(width: 20),
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 13,
              // fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 20, 20, 20),
            ),
          ),

          Expanded(
            child: Text(
              value ?? "N/A",
              style: TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.grey;
    try {
      String hex = colorHex.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  Color getWeatherColor(String? weatherDesc) {
    switch (weatherDesc?.toLowerCase()) {
      case "rain":
        return Colors.blue.shade700;
      case "dry":
        return Colors.orange.shade600;
      case "cloudy":
        return const Color.fromARGB(255, 184, 7, 7);
      case "storm":
        return Colors.deepPurple.shade700;
      default:
        return Colors.grey;
    }
  }
}

// ----------------------------------------------------
// 🎯 Define a reusable, self-contained custom widget
// ----------------------------------------------------
class CustomTaskDropdown<T> extends StatefulWidget {
  final List<T> items;
  final int Function(T) getId;
  final String Function(T) getDesc;
  final String label;
  final int? initValue;
  final void Function(int?)? onChanged;
  final String? Function(int?)? validator;

  const CustomTaskDropdown({
    super.key,
    required this.items,
    this.initValue,
    required this.getId,
    required this.getDesc,
    this.label = "Select",
    this.onChanged,
    this.validator,
  });

  @override
  State<CustomTaskDropdown<T>> createState() => _CustomTaskDropdownState<T>();
}

class _CustomTaskDropdownState<T> extends State<CustomTaskDropdown<T>> {
  int? _selectedValue;
  bool _isDisabled = false;

  @override
  void initState() {
    super.initState();

    // If initValue matches an existing item, preselect and disable dropdown
    if (widget.initValue != null &&
        widget.items.any((e) => widget.getId(e) == widget.initValue)) {
      _selectedValue = widget.initValue;
      _isDisabled = true;
    } else {
      _selectedValue = null;
      _isDisabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add placeholder + actual items
    final dropdownItems = [
      const DropdownMenuItem<int>(
        value: null,
        child: Text(
          "Select One of Choices",
          style: TextStyle(color: Colors.grey),
        ),
      ),
      ...widget.items.map(
        (item) => DropdownMenuItem<int>(
          value: widget.getId(item),
          child: Text(widget.getDesc(item)),
        ),
      ),
    ];

    return AbsorbPointer(
      absorbing: _isDisabled, // 👈 disables touch input if true
      child: Opacity(
        opacity: _isDisabled ? 0.6 : 1.0, // visually indicate disabled state
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
          ),
          value: _selectedValue,
          items: dropdownItems,
          onChanged: _isDisabled
              ? null
              : (newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                  widget.onChanged?.call(newValue);
                },
          validator:
              widget.validator ??
              (val) => val == null ? "Please select one of the choices" : null,
        ),
      ),
    );
  }
}
