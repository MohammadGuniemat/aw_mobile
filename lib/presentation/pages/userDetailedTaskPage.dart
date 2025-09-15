import 'package:aw_app/provider/auth_provider.dart';
import 'package:aw_app/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:provider/provider.dart';

class UserDetailedTasksPage extends StatefulWidget {
  final int userId;
  final String statusFilter;

  const UserDetailedTasksPage({
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

  @override
  void initState() {
    super.initState();
    _taskProvider = context.read<TaskProvider>();
    _authProvider = context.read<AuthProvider>();
    _loadTasks();
  }

  void _loadTasks() {
    _tasksFuture = _taskProvider.loadUserSingleFilteredTasks(
      _authProvider.token!,
      widget.userId,
      widget.statusFilter,
      10, //current page index
      10, //total recordes per page
    );
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
      ),
      body: FutureBuilder<List<TaskModel>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
                    side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                  ),
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top: Task Name & RFID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                task.rFName ?? "Unnamed Task",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
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
                            _buildIconInfoRow(
                              Icons.apartment,
                              "Sector",
                              task.sectorDesc,
                              color: AWColors.colorDark,
                            ),
                            _buildIconInfoRow(
                              Icons.business,
                              "Department",
                              task.departmentName,
                              color: AWColors.colorDark,
                            ),
                            _buildIconInfoRow(
                              Icons.person,
                              "Collector",
                              task.collectorName,
                              color: AWColors.colorDark,
                            ),
                            _buildIconInfoRow(
                              Icons.person_outline,
                              "Collector User",
                              task.collectorUserName,
                              color: AWColors.colorDark,
                            ),
                            _buildIconInfoRow(
                              Icons.person_pin,
                              "Owner",
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
                              Icons.water_drop,
                              "Water Type",
                              task.waterTypeName,
                              color: AWColors.colorDark,
                            ),
                            _buildIconInfoRow(
                              task.weatherDesc == 'Rain'
                                  ? Icons.water_drop
                                  : Icons.wb_sunny,
                              "Weather",
                              task.weatherDesc,
                              color: getWeatherColor(task.weatherDesc),
                            ),
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
                        if (task.notes != null && task.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              width: double.infinity,
                              // color: const Color.fromARGB(113, 63, 132, 145),
                              // padding: EdgeInsets.all(10),
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
          const SizedBox(width: 6),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
