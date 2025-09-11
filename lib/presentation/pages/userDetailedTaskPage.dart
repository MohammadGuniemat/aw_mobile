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
    super.initState(); // ← Only one super.initState()
    _taskProvider = context.read<TaskProvider>();
    _authProvider = context.read<AuthProvider>();
    _loadTasks();
  }

  void _loadTasks() {
    _tasksFuture = _taskProvider.loadUserSingleFilteredTasks(
      _authProvider.token!,
      widget.userId,
      widget.statusFilter,
      1,
      10,
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
            return _buildTasksList(tasks);
          }
        },
      ),
    );
  }

  Widget _buildTasksList(List<TaskModel> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final appDate = task.applicationDate != null
            ? DateFormat('dd MMM yyyy, hh:mm a').format(task.applicationDate!)
            : "N/A";

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Task Name & RFID Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.rFName ?? "Unnamed Task",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AWColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AWColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "ID: ${task.rFID ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: AWColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Application Date & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Application Date: $appDate",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(task.color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        getStatusText(task.rFStatusDesc),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(task.color),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Additional task details from API
                Text('Governorate: ${task.governorateName ?? "N/A"}'),
                Text('Sector: ${task.sectorDesc ?? "N/A"}'),
                Text('Department: ${task.departmentName ?? "N/A"}'),

                if (task.notes != null && task.notes!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        "Notes:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(task.notes!, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper functions to map status id to color and text
  Color getStatusColor(String? colorHex) {
    print(colorHex);
    if (colorHex == null || colorHex.isEmpty) {
      return Colors.grey; // Default color
    }

    try {
      // Remove the '#' if present
      String hex = colorHex.replaceFirst('#', '');

      // Ensure the hex code has 6 characters (RRGGBB)
      if (hex.length == 6) {
        // Add full opacity (FF) to make it 8 characters (AARRGGBB)
        hex = 'FF$hex';
      }

      // Parse the hex string to an integer and create Color
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      print('Error parsing color: $colorHex, error: $e');
      return Colors.grey; // Fallback color
    }
  }

  String getStatusText(String? rFStatusDesc) {
    return rFStatusDesc ?? 'UnknownStatus';

    // switch (rFStatusDesc) {
    //   case "PENDING":
    //     return "PENDING";
    //   case "SUBMITTED":
    //     return "RECEIVED";
    //   case "SUBMITTED":
    //     return "SUBMITTED";
    //   case "APPROVED":
    //     return "APPROVED";
    //   case "BLOCKED":
    //     return "BLOCKED";
    //   case "HOLD":
    //     return "HOLD";
    //   default:
    //     return "UNKNOWN";
    // }
  }
}
