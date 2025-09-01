import 'package:aw_app/presentation/pages/landingpage.dart';
import 'package:aw_app/presentation/pages/loginPage.dart';
import 'package:aw_app/provider/lang_prvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LangPrvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your....2025 application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AW APP',
      home: const LoginPage(),
    );
  }
}