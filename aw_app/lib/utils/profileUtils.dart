import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// ✅ Bottom sheet for updating profile info
void changeProfile(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  final usernameController = TextEditingController(
    text: authProvider.username ?? "",
  );
  final passwordController = TextEditingController();

  Map<String, dynamic> requestBody = {};

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: Icon(Icons.arrow_downward_rounded),
              ),
              // ✅ Drag handle
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const Text(
                "Manage Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // ✅ Profile picture
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      authProvider.profilePictureURL?.isNotEmpty == true
                          ? authProvider.profilePictureURL!
                          : 'https://aw.jo/web/assets/uploads/media-uploader/aw21661878799.png',
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      try {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 800,
                          maxHeight: 800,
                          imageQuality: 80,
                        );

                        if (image != null) {
                          // Optional: show temporary preview
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("📷 Profile picture selected"),
                            ),
                          );

                          // Update profile picture in provider
                          authProvider.savProfilePicture(image.path);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("❌ No image selected"),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("⚠️ Failed to pick image: $e"),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ✅ Username field
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ✅ Reset password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Example actions (replace with your API calls)
                    // authProvider.authStatus = '⏳ Waiting for your a2ctions ...';

                    requestBody.addEntries([
                      MapEntry('userName', usernameController.text),
                    ]);
                    if (passwordController.text.isNotEmpty) {
                      requestBody.addEntries([
                        MapEntry('passWord', passwordController.text),
                      ]);
                    }

                    authProvider.setUserinfo(requestBody); //
                    // Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Editing Profile Closed',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AWColors.primary),
                        ),
                        backgroundColor: AWColors.colorDisabled,
                        duration: Duration(seconds: 10),
                      ),
                    );
                  },
                ),
              ),

              Builder(
                builder: (context) {
                  return Selector<AuthProvider, String?>(
                    selector: (_, provider) => provider.authStatus,
                    builder: (context, authStatus, child) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              authStatus ?? 'Nothing yet initialized',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AWColors
                                    .primary, // Set your desired color here
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // IconButton(
                            //   onPressed: () => {Navigator.pop(context)},
                            //   icon: Icon(Icons.arrow_downward_rounded),
                            // ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  ).then((_) {
    usernameController.dispose();
    passwordController.dispose();
    // ✅ This runs after the bottom sheet is popped
    print("Bottom sheet closed");
    // You can trigger any action here, like resetting authStatus
    if (!authProvider.is_loading) {
      authProvider.authStatus = '⏳ Waiting for your actions ...';
    }
  });
}
