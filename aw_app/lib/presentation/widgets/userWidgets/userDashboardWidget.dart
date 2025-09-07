import 'package:aw_app/utils/profileUtils.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:aw_app/provider/task_provider.dart';
import 'package:provider/provider.dart';

class DashboardContent extends StatelessWidget {
  final String username;
  final String role;
  final String profilePictureURL;

  const DashboardContent({
    Key? key,
    required this.username,
    required this.role,
    required this.profilePictureURL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final tasksCounts = taskProvider.tasksCounts;
    int total = 0;
    for (var element in tasksCounts.values) {
      total += (element['count'] as num?)?.toInt() ?? 0;
    }

    return Column(
      children: [
        // ✅ Profile row fixed at top
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: profilePictureURL.isNotEmpty
                    ? NetworkImage(profilePictureURL)
                    : const AssetImage('assets/images/aw.jpg') as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, ${role.trim()} ${username.trim()}!",
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: AWColors.colorDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Here are your statistics:",
                      style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () {
                  changeProfile(context);
                },
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,

          // color: AWColors.colorLight,
          child: Center(
            child: Text(
              "TOTAL Number Of Tasks is: $total",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AWColors.colorDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ✅ Task section takes remaining space
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

                    return Card(
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
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: item['color'] is Color
                                    ? item['color'] as Color
                                    : Colors.grey,
                              ),
                            ),
                          ],
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
