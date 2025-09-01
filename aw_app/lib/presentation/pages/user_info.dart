import 'package:aw_app/core/constants/translate.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/presentation/widgets/customerInfo.dart';
import 'package:aw_app/provider/lang_prvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LangPrvider>(context);
    String currentLang = langProvider.lang;

    return Directionality(
      textDirection: currentLang == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: AWColors.colorLight,
          title: Text(Translate.get('LandTitle', lang: currentLang)),
          centerTitle: true,
          leading: const Icon(Icons.person_3_outlined),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                child: Center(
                  child: Text(currentLang == 'eng' ? ("عربي") : ("EN")),
                ),
                onTap: () {
                  currentLang == 'eng'
                      ? langProvider.setLang('ar')
                      : langProvider.setLang("eng");
                },
              ),
            ),
          ],
          backgroundColor: AWColors.primary,
        ),
        body: const CustomerInfo(),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: AWColors.colorDark,
          unselectedItemColor: AWColors.colorDisabled,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: Translate.get('Home', lang: currentLang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: Translate.get('Settings', lang: currentLang),
            ),
          ],
        ),
      ),
    );
  }
}
