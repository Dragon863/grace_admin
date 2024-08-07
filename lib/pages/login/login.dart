import 'package:flutter/material.dart';
import 'package:grace_admin/pages/login/login_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      showModalBottomSheet(
        barrierColor: const Color.fromARGB(50, 0, 0, 0),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(42),
          ),
        ),
        builder: (_) => const LoginView(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: Image.asset(
        "assets/images/bg.jpg",
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
