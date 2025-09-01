import 'dart:convert';

import 'package:aw_app/presentation/pages/pageWrapper.dart';
import 'package:flutter/material.dart';
import 'package:aw_app/core/constants/translate.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/provider/lang_prvider.dart';
import 'package:provider/provider.dart';
import 'package:aw_app/server/apis.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login(BuildContext context, String lang) async {
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await Api.post.login(username, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle successful login (e.g., save token, navigate)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Translate.get('LoginSuccess', lang: lang))),
        );
      } else {
        print(response.body);

        final error = jsonDecode(response.body)['error'] ?? 'Error';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      print(e);
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
                SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: Translate.get('Email', lang: currentLang),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: Translate.get('Password', lang: currentLang),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AWColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _login(context, currentLang),
                    child: _isLoading
                        ? CircularProgressIndicator(color: AWColors.colorLight)
                        : Text(
                            Translate.get('Submit', lang: currentLang),
                            style: TextStyle(
                              fontSize: 18,
                              color: AWColors.colorLight,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Translate.get('NoAccount', lang: currentLang) + " ",
                      style: TextStyle(color: AWColors.colorDark),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to Register
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
    );
  }
}
