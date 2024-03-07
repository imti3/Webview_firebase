import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prime_web/constants/constants.dart';
import 'package:prime_web/main.dart';
import 'package:prime_web/screens/main_screen.dart';
import 'package:prime_web/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  Future<Timer> startTimer() async {
    const duration = Duration(seconds: 2);
    return Timer(duration, () async {
      final pref = await SharedPreferences.getInstance();
      if (showOnboardingScreen && (pref.getBool('isFirstTimeUser') ?? true)) {
        await navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute<OnboardingScreen>(
            builder: (_) => const OnboardingScreen(),
          ),
        );
      } else {
        await navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute<MyHomePage>(
            builder: (_) => const MyHomePage(webUrl: webInitialUrl),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [splashBackColor1, splashBackColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              CustomIcons.splashLogo,
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
