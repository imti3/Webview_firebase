import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prime_web/constants/constants.dart';
import 'package:prime_web/provider/navigation_bar_provider.dart';
import 'package:prime_web/provider/theme_provider.dart';
import 'package:prime_web/screens/home_screen.dart';
import 'package:prime_web/screens/main_screen.dart';
import 'package:prime_web/screens/settings_screen.dart';
import 'package:prime_web/screens/splash_screen.dart';
import 'package:prime_web/widgets/admob_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences pref;
// Create a global instance of FirebaseMessaging
final _firebaseMessaging = FirebaseMessaging.instance;

Future<bool> enableStoragePermission() async {
  if (Platform.isIOS) {
    if (await Permission.storage.isGranted) {
      return true;
    } else {
      return (await Permission.storage.request()).isGranted;
    }
  } else {
    final androidDeviceInfo = await DeviceInfoPlugin().androidInfo;

    if (androidDeviceInfo.version.sdkInt < 33) {
      if (await Permission.storage.isGranted) {
        return true;
      } else {
        return (await Permission.storage.request()).isGranted;
      }
    } else {
      if (await Permission.photos.isGranted) {
        return true;
      } else {
        return (await Permission.photos.request()).isGranted;
      }
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pref = await SharedPreferences.getInstance();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,

    /// NOTE: Uncomment below 2 lines to enable landscape mode
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  await Firebase.initializeApp();
  AdMobService.initialize();

  await requestNotificationPermissions();
  FirebaseMessaging.onBackgroundMessage((_) async {});

  const counter = 0;

  if (isStoragePermissionEnabled) {
    await enableStoragePermission();
  }

  await SharedPreferences.getInstance().then((prefs) {
    prefs.setInt('counter', counter);
    final bool isDarkTheme;
    if (prefs.getBool('isDarkTheme') ?? ThemeMode.system == ThemeMode.dark) {
      isDarkTheme = true;
    } else {
      isDarkTheme = false;
    }

    return runApp(
      ChangeNotifierProvider<ThemeProvider>(
        child: const MyApp(),
        create: (BuildContext context) {
          return ThemeProvider(isDarkTheme: isDarkTheme);
        },
      ),
    );
  });
}

Future<void> requestNotificationPermissions() async {
  // Request permission for iOS
  await _firebaseMessaging.requestPermission();

  // Request permission for Android
  await _firebaseMessaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<NavigationBarProvider>(
            create: (_) => NavigationBarProvider(),
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, value, child) {
            return MaterialApp(
              title: appName,
              debugShowCheckedModeBanner: false,
              themeMode: value.getTheme(),
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              navigatorKey: navigatorKey,
              onGenerateRoute: (RouteSettings settings) {
                return switch (settings.name) {
                  'settings' => CupertinoPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  _ => null,
                };
              },
              home: showSplashScreen
                  ? const SplashScreen()
                  : const MyHomePage(webUrl: webInitialUrl),
            );
          },
        ),
      ),
    );
  }
}
