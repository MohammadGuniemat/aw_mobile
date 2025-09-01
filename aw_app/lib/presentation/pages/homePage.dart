import 'package:aw_app/core/constants/translate.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/presentation/pages/loginPage.dart';
import 'package:aw_app/presentation/pages/user_info.dart';
import 'package:aw_app/provider/lang_prvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LangPrvider>(context);
    String currentLang = langProvider.lang;

    return Scaffold(
      backgroundColor: AWColors.colorLight,
      body: SafeArea(
        child: Container(
          color: AWColors.primary, // 👈 safe area background

          child: Center(
            child: Column(
              children: [
                Spacer(),
                Text(
                  "WELCOME TO LIMS APP",
                  style: TextStyle(color: AWColors.colorLight, fontSize: 25),
                ),
                Spacer(),
                Image.asset('assets/images/aw.jpg'),
                Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black54,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    Translate.get('GoTo', lang: currentLang) +
                        Translate.get('Login', lang: currentLang),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
