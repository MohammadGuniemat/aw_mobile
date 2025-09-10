import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/presentation/pages/logoutPage.dart';
import 'package:aw_app/presentation/pages/profilePage.dart';
import 'package:aw_app/presentation/widgets/userWidgets/userDashboardWidget.dart';
import 'package:aw_app/presentation/widgets/userWidgets/userTasksWidget.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:aw_app/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String _selectedPage = "Dashboard"; // default

  final List<String> _pages = ["Dashboard", "My Tasks", "Profile", "Logout"];
  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.task,
    Icons.person,
    Icons.logout,
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final taskProvider = context.watch<TaskProvider>();

    Widget _getPageContent() {
      switch (_selectedPage) {
        case "Dashboard":
          return DashboardContent(
            username: auth.username ?? "User",
            role: auth.role ?? "N/A",
            profilePictureURL: auth.profilePictureURL ?? "",
          );
        case "My Tasks":
          return const UserTasks();
        case "Profile":
          return const ProfilePage();
        case "Logout":
          return const LogoutPage();
        default:
          return const Center(child: Text("Page not found"));
      }
    }

    int _currentIndex = _pages.indexOf(_selectedPage);

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
                auth.refreshSingleUserInfo();
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
            ...List.generate(_pages.length, (index) {
              return ListTile(
                leading: Icon(_icons[index]),
                title: Text(_pages[index]),
                onTap: () {
                  setState(() => _selectedPage = _pages[index]);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
      body: _getPageContent(),
      bottomNavigationBar: ConvexAppBar(
        key: ValueKey(_selectedPage), // force rebuild when page changes
        style: TabStyle.react,
        backgroundColor: Colors.white,
        activeColor: AWColors.primary,
        color: Colors.grey,
        elevation: 8,
        curveSize: 75,
        initialActiveIndex: _currentIndex, // still used
        items: List.generate(_pages.length, (index) {
          return TabItem(icon: _icons[index], title: _pages[index]);
        }),
        onTap: (index) {
          setState(() {
            _selectedPage = _pages[index]; // updates current page
          });
        },
      ),
    );
  }
}
