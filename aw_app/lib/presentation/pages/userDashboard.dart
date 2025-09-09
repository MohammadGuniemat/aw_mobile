import 'dart:developer';

import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/presentation/widgets/userWidgets/userDashboardWidget.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:aw_app/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String _selectedPage = "Dashboard"; // default

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final taskProvider = context.watch<TaskProvider>();
    // final tasksCounts = taskProvider.tasksCounts;
    final username = auth.username ?? "User";
    final role = auth.role ?? "N/A";
    // final profilePictureURL = auth.profilePictureURL ?? "N/A";
    final userID = auth.userID ?? "N/A";

    Widget _getPageContent() {
      switch (_selectedPage) {
        case "Dashboard":
          return DashboardContent(
            username: auth.username ?? "User",
            role: auth.role ?? "N/A",
            profilePictureURL: auth.profilePictureURL ?? "",
          );
        case "My Tasks":
          return const Center(
            child: Text(
              "Here are your tasks 📋",
              style: TextStyle(fontSize: 20),
            ),
          );
        case "Profile":
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 80, color: AWColors.primary),
                const SizedBox(height: 10),
                Text("Name: $username", style: const TextStyle(fontSize: 18)),
                Text("Role: $role", style: const TextStyle(fontSize: 18)),
                Text("ID: $userID", style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
        case "Logout":
          return const Center(
            child: Text(
              "You have logged out 🚪",
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          );
        default:
          return const Center(child: Text("Page not found"));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AWColors.colorDark,
        foregroundColor: AWColors.colorLight,
        title: Text(_selectedPage),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
              icon: const Icon(Icons.replay_outlined),
              onPressed: () {
                auth.getUserInfo();
                auth.savProfilePicture(auth.profilePictureURL!);
                taskProvider.reloadTasks(auth.token!, auth.userID!);
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AWColors.colorDark),
              child: Text(
                'Menu',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                setState(() => _selectedPage = "Dashboard");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('My Tasks'),
              onTap: () {
                setState(() => _selectedPage = "My Tasks");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                setState(() => _selectedPage = "Profile");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                setState(() => _selectedPage = "Logout");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _getPageContent(),
    );
  }
}
