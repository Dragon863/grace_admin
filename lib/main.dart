import 'package:flutter/material.dart';
import 'package:grace_admin/pages/duty_library/duty_library.dart';
import 'package:grace_admin/pages/rota_edit/rota_edit_panels.dart';
import 'package:grace_admin/pages/splash/splash.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: ((context) => AuthAPI()), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grace Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, //const Color.fromARGB(255, 32, 109, 156),
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        '/splash': (context) => const SplashPage(),
        '/home': (context) => const PanelledRotaEditPage(),
        '/duty_library': (context) => const DutyLibraryPage(),
      },
    );
  }
}
