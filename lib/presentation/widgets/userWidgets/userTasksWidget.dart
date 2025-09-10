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
                auth.username ?? "Guest",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                auth.role ?? "No role",
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
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
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
                              tasks: selectedTasks,
                              statusTitle: item['desc'] ?? "Tasks",
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item['icon'] is IconData
                                    ? item['icon'] as IconData
                                    : Icons.task,
                                size: 28,
                                color: item['color'] is Color
                                    ? item['color'] as Color
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['desc']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: item['color'] is Color
                                      ? item['color'] as Color
                                      : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['count']?.toString() ?? '0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: item['color'] is Color
                                      ? item['color'] as Color
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
