import 'package:aw_app/presentation/pages/userDetailedTaskPage.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:aw_app/provider/task_provider.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:provider/provider.dart';

class UserTasks extends StatelessWidget {
  const UserTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final tasksCounts = taskProvider.tasksCounts;

    return Column(
      children: [
        // Profile row (optional)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                'Hi, ${auth.username!.toUpperCase() ?? "Guest"}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                ' You Currently Logged as: ${auth.role ?? "No role"}',
                style: const TextStyle(fontSize: 14, color: AWColors.primary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Task section
        Expanded(
          child: (taskProvider.isLoading || auth.is_loading)
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Loading..."),
                    ],
                  ),
                )
              : taskProvider.error.isNotEmpty
              ? Center(child: Text(taskProvider.error))
              : tasksCounts.isEmpty
              ? const Center(child: Text("No tasks found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasksCounts.length,
                  itemBuilder: (context, index) {
                    final item = tasksCounts.values.toList()[index];
                    final statusId = tasksCounts.keys.toList()[index];

                    return InkWell(
                      onTap: () {
                        // Filter tasks by selected status
                        final selectedTasks = taskProvider.tasks
                            .where((task) => task.rFStatus == statusId)
                            .toList();

                        // Navigate to detailed page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailedTasksPage(
                              userId: auth.userID!,
                              statusFilter: item['desc'] ?? "Tasks",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Icon
                            Icon(
                              item['icon'] is IconData
                                  ? item['icon'] as IconData
                                  : Icons.task,
                              size: 28,
                              color: item['color'] is Color
                                  ? item['color'] as Color
                                  : Colors.grey,
                            ),

                            // Description
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                item['desc']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: item['color'] is Color
                                      ? item['color'] as Color
                                      : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Count
                            Row(
                              children: [
                                Text(
                                  item['count']?.toString() ?? '0',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: item['color'] is Color
                                        ? item['color'] as Color
                                        : Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // FloatingActionButton(
        //   onPressed: () => {taskProvider.getColorWithStatus()},
        //   child: Text('Get user approved tasks'),
        // ),
      ],
    );
  }
}
