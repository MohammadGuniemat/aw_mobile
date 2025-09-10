import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/utils/profileUtils.dart'; // contains changeProfile
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Banner Image
          Container(
            height: 230,
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
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  authProvider.profilePictureURL ??
                      'https://aw.jo/web/assets/uploads/media-uploader/aw21661878799.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Username
          Text(
            "Welcome ${authProvider.username ?? "Guest User"}",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AWColors.colorDark,
            ),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AWColors.colorDark,
                ),
              ),
              Text(
                authProvider.role ?? "No role assigned",
                style: const TextStyle(
                  fontSize: 18,
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AWColors.colorDark,
                ),
              ),
              Text(
                authProvider.tokenExpiryDate != null
                    ? DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(authProvider.tokenExpiryDate!)
                    : "No token",
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
              'The Profile Page serves as a central hub for personal account management. Users can view and update their profile picture, username, and role. Real-time status feedback and persistent authentication ensure a smooth user experience.',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 30),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => changeProfile(context),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                "Edit Profile",
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
