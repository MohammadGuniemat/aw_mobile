import 'package:aw_app/core/constants/translate.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/presentation/pages/loginPage.dart';
import 'package:aw_app/provider/data_provider.dart';
import 'package:aw_app/provider/lang_prvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      _isInit = true;
      // fetchAllData once when page comes up
      final dataProvider = context.read<DataProvider>();
      dataProvider.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LangPrvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    String currentLang = langProvider.lang;

    // show loading while fetching
    if (dataProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // show error if fetching failed
    if (dataProvider.error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            "❌ Error: ${dataProvider.error}",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // show the actual UI when data is ready
    return Scaffold(
      backgroundColor: AWColors.colorLight,
      body: SafeArea(
        child: Container(
          color: AWColors.primary,
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                const Text(
                  "WELCOME TO LIMS APP",
                  style: TextStyle(color: AWColors.colorLight, fontSize: 25),
                ),
                const Spacer(),
                Image.asset('assets/images/aw.jpg'),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    Translate.get('GoTo', lang: currentLang) +
                        Translate.get('Login', lang: currentLang),
                  ),
                ),
                const Spacer(),
                // FloatingActionButton(
                //   onPressed: dataProvider.fetchAllData,
                //   child: const Icon(Icons.refresh),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
