import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/provider/auth_provider.dart';
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
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final username = auth.username ?? "User";
    final role = auth.role ?? "N/A";
    final profilePictureURL = auth.profilePictureURL ?? "N/A";
    final userID = auth.userID ?? "N/A";

    final stats = [
      {
        "title": "TOTAL TASKS",
        "icon": Icons.list,
        "count": 1,
        "color": Colors.blue,
      },
      {
        "title": "PENDING",
        "icon": Icons.pending,
        "count": 0,
        "color": Colors.purple,
      },
      {
        "title": "RECEIVED",
        "icon": Icons.inbox,
        "count": 0,
        "color": Colors.orange,
      },
      {
        "title": "SUBMITTED",
        "icon": Icons.send,
        "count": 0,
        "color": Colors.green,
      },
      {
        "title": "APPROVED",
        "icon": Icons.check_circle,
        "count": 1,
        "color": Colors.teal,
      },
      {
        "title": "BLOCKED",
        "icon": Icons.block,
        "count": 0,
        "color": Colors.red,
      },
      {
        "title": "HOLD",
        "icon": Icons.autorenew,
        "count": 0,
        "color": Colors.indigo,
      },
    ];

    Widget _getPageContent() {
      switch (_selectedPage) {
        case "Dashboard":
          return (SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Profile Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: auth.profilePictureURL != null
                          ? NetworkImage(auth.profilePictureURL!)
                          : AssetImage('assets/images/aw.jpg'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Welcome, $role $username!\nHere are your statistics:",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ✅ Stats Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // change to 3 for wider screens
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final item = stats[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item["icon"] as IconData,
                              size: 32,
                              color: item["color"] as Color,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item["title"] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${item["count"]}",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: item["color"] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ));

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
      body: Center(child: _getPageContent()),
    );
  }
}
