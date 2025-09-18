import 'package:aw_app/models/formSampleUpdate.dart';
import 'package:aw_app/presentation/pages/homePage.dart';
import 'package:aw_app/presentation/pages/userDashboard.dart';
import 'package:aw_app/provider/auth_provider.dart';
import 'package:aw_app/provider/lang_prvider.dart';
import 'package:aw_app/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aw_app/presentation/pages/formMoreDetails.dart';

final simulatedSample = FormSampleUpdate.fromJson({
  "BatchNo": "Brr1",
  "DepartmentID": 8,
  "Notes": "",
  "RFID": 14635,
  "SampleStatus": "COLLECTED",
  "SampleStatusOwner": 1038,
  "SectorID": 0,
  "StatusID": 0,
  "WeatherID": 0,
  "analysisTypeIDs": {},
  "location": "محطة تحلية قطر",
  "sample_WaterSourceTypeID": 5,
  "sub_location": "Product",
});

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LangPrvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
        ChangeNotifierProvider(
          create: (_) => TaskProvider()..getColorWithStatus(),
        ),
      ],
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
      // home: const HomePage(),
      home: FormMoreDetails(
        prefillData: simulatedSample,
      ), // pass simulated data here
      // home: const UserDashboard(),
    );
  }
}
