import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:grace_admin/pages/dashboard/dashboard.dart';
import 'package:grace_admin/pages/duty_library/duty_library.dart';
import 'package:grace_admin/pages/print_page/print_page.dart';
import 'package:grace_admin/pages/rota_edit/rota_edit_panels.dart';
import 'package:grace_admin/pages/splash/splash.dart';
import 'package:grace_admin/pages/feed_page/feed_page.dart';
import 'package:grace_admin/pages/translate_page/translate_page.dart';
import 'package:grace_admin/pages/users_page/users_page.dart';
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
        '/splash':       (context) => const SplashPage(),
        '/home':         (context) => const DashboardPage(),
        '/duty_library': (context) => const DutyLibraryPage(),
        '/rota_edit':    (context) => const PanelledRotaEditPage(),
        '/users':        (context) => const UsersPage(),
        '/feed':         (context) => const FeedPage(),
        '/translate':    (context) => const TranslatePage(),
        '/print':        (context) => const PrintPage(),
      },
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
          PointerDeviceKind.trackpad,
        },
      ),
    );
  }
}
