import 'dart:convert';
import 'package:aw_app/presentation/pages/pageWrapper.dart';
import 'package:aw_app/presentation/pages/userDashboard.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/core/constants/translate.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/provider/lang_prvider.dart';
import 'package:provider/provider.dart';
import 'package:aw_app/server/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login(BuildContext context, String lang) async {
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await Api.post.login(username, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);

        // ✅ Save token locally
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('token', data['token']);
        auth.saveToken(data['token']);
        auth.savProfilePicture(data['results'][0]['profilePictureURL']);
        // ✅ Success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translate.get('LoginSuccess', lang: lang)),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Navigate to user info page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserDashboard()),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Translate.get('NetworkError', lang: lang))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LangPrvider>(context);
    String currentLang = langProvider.lang;

    return PageWrapper(
      titleKey: "Login",
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    Translate.get('EnterCredentials', lang: currentLang),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AWColors.colorDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // ✅ Username
                  TextFormField(
                    controller: _usernameController,
                    validator: (value) => value == null || value.isEmpty
                        ? Translate.get('EnterEmail', lang: currentLang)
                        : null,
                    decoration: InputDecoration(
                      labelText: Translate.get('Email', lang: currentLang),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) => value == null || value.isEmpty
                        ? Translate.get('EnterPassword', lang: currentLang)
                        : null,
                    decoration: InputDecoration(
                      labelText: Translate.get('Password', lang: currentLang),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AWColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _login(context, currentLang);
                              }
                            },
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: AWColors.colorLight,
                            )
                          : Text(
                              Translate.get('Submit', lang: currentLang),
                              style: TextStyle(
                                fontSize: 18,
                                color: AWColors.colorLight,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Translate.get('NoAccount', lang: currentLang) + " ",
                        style: TextStyle(color: AWColors.colorDark),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to RegisterPage
                        },
                        child: Text(
                          Translate.get('Register', lang: currentLang),
                          style: TextStyle(
                            color: AWColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
