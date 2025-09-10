import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/core/theme/colors.dart';

class UserDetailedTasksPage extends StatelessWidget {
  final List<TaskModel> tasks;
  final String statusTitle;

  const UserDetailedTasksPage({
    Key? key,
    required this.tasks,
    required this.statusTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(statusTitle),
        backgroundColor: AWColors.primary,
        foregroundColor: AWColors.background,
        centerTitle: true,
        elevation: 4,
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                "No tasks available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final appDate = task.applicationDate != null
                    ? DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(task.applicationDate!)
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
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: getStatusColor(
                                  task.rFStatus,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                getStatusText(task.rFStatus),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: getStatusColor(task.rFStatus),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Notes
                        if (task.notes != null && task.notes!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Notes:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.notes!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Helper functions to map status id to color and text
  Color getStatusColor(int? statusId) {
    switch (statusId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.teal;
      case 5:
        return Colors.red;
      case 6:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(int? statusId) {
    switch (statusId) {
      case 1:
        return "PENDING";
      case 2:
        return "RECEIVED";
      case 3:
        return "SUBMITTED";
      case 4:
        return "APPROVED";
      case 5:
        return "BLOCKED";
      case 6:
        return "HOLD";
      default:
        return "UNKNOWN";
    }
  }
}
