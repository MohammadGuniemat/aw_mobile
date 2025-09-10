import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/presentation/pages/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:intl/intl.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text(
            "Are you sure you want to log out? This will end your current session.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop(); // Close the dialog
                await authProvider.logout(); // Clear auth info

                // Navigate to login or initial page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AWColors.primary,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    String formattedExpiry = authProvider.tokenExpiryDate != null
        ? DateFormat(
            'dd MMM yyyy, hh:mm a',
          ).format(authProvider.tokenExpiryDate!)
        : "No token";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Banner Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AWColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/aw.jpg', fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 20),

          // Username
          Text(
            authProvider.username ?? "Guest User",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),
          Divider(color: AWColors.primary.withOpacity(0.5), thickness: 1),
          const SizedBox(height: 10),

          // Role
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Role",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                authProvider.role ?? "No role assigned",
                style: const TextStyle(
                  fontSize: 18,
                  color: AWColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: AWColors.primary.withOpacity(0.5), thickness: 1),
          const SizedBox(height: 10),

          // Token Expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Token Expiry",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                formattedExpiry,
                style: const TextStyle(fontSize: 16, color: AWColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: AWColors.primary.withOpacity(0.5), thickness: 1),
          const SizedBox(height: 20),

          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AWColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'You are about to log out of your account. Logging out will invalidate your current session and require you to log in again to access your profile and data.',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 30),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmLogout(context, authProvider),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AWColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
