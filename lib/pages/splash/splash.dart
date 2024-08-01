import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grace_admin/pages/login/login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initialize(context);
  }

  Future<void> _initialize(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    const targetPage = LoginPage();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.aspectRatio;
    precacheImage(const AssetImage("assets/images/bg.jpg"), context);
    precacheImage(const AssetImage("assets/images/grace.png"), context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(children: [
              const Spacer(),
              SvgPicture.asset(
                'assets/images/blob1.svg',
                width: aspectRatio < 0.8 ? size.width * 0.3 : size.width * 0.1,
              ),
            ]),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: const AssetImage('assets/images/grace.png'),
              radius: size.height / 6,
            ),
            SizedBox(height: size.height / 10),
            const CircularProgressIndicator(),
            const Spacer(),
            Row(children: [
              SvgPicture.asset(
                'assets/images/blob2.svg',
                width: aspectRatio < 0.7 ? size.width * 0.4 : size.width * 0.1,
              ),
              const Spacer(),
            ]),
          ],
        ),
      ),
    );
  }
}
