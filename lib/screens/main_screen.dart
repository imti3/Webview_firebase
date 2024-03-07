import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:prime_web/constants/constants.dart';
import 'package:prime_web/dynamic_link_service.dart';
import 'package:prime_web/provider/navigation_bar_provider.dart';
import 'package:prime_web/screens/demo_screen.dart';
import 'package:prime_web/screens/home_screen.dart';
import 'package:prime_web/screens/settings_screen.dart';
import 'package:prime_web/widgets/widgets.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.webUrl, super.key});

  final String webUrl;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _selectedIndex = showBottomNavigationBar ? 1 : 0;
  int _previousIndex = showBottomNavigationBar ? 1 : 0;

  late AnimationController idleAnimation;
  late AnimationController onSelectedAnimation;
  late AnimationController onChangedAnimation;
  Duration animationDuration = const Duration(milliseconds: 700);
  late AppLifecycleReactor? _appLifecycleReactor;
  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];

  late final List<Widget> _tabs = [];
  var _navigationTabs = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    demoInitializeTabs();

    idleAnimation = AnimationController(vsync: this);
    onSelectedAnimation =
        AnimationController(vsync: this, duration: animationDuration);
    onChangedAnimation =
        AnimationController(vsync: this, duration: animationDuration);
    Future.delayed(Duration.zero, () {
      context
          .read<NavigationBarProvider>()
          .setAnimationController(navigationContainerAnimationController);
    });
    FirebaseInitialize().initFirebaseState(context);

    DynamicService.initDynamicLinks(context);

    if (showOpenAds == true) {
      final appOpenAdManager = AdMobService()..loadOpenAd();
      _appLifecycleReactor =
          AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
      _appLifecycleReactor!.listenToAppStateChanges();
    }
  }

  /// FIXME: it is for Demo APK. remove when publishing.
  void demoInitializeTabs() {
    if (showBottomNavigationBar) {
      Future.delayed(Duration.zero, () {
        for (int i = 0; i < _navigationTabs.length; i++) {
          _navigatorKeys.add(GlobalKey<NavigatorState>());

          _tabs.add(
            Navigator(
              key: _navigatorKeys[i],
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (_) => HomeScreen(
                    _navigationTabs[i]['url']!,
                  ),
                );
              },
            ),
          );
        }
        _navigatorKeys.add(GlobalKey<NavigatorState>());
        _tabs.add(
          Navigator(
            key: _navigatorKeys[_navigationTabs.length],
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            },
          ),
        );

        setState(() {});
      });

      // Future.delayed(Duration.zero, () {
      //   _navigatorKeys
      //     ..add(GlobalKey<NavigatorState>())
      //     ..add(GlobalKey<NavigatorState>())
      //     ..add(GlobalKey<NavigatorState>());

      //   _tabs
      //     ..add(
      //       Navigator(
      //         key: _navigatorKeys[0],
      //         onGenerateRoute: (_) => MaterialPageRoute(
      //           builder: (_) => const DemoScreen(),
      //         ),
      //       ),
      //     )
      //     ..add(
      //       Navigator(
      //         key: _navigatorKeys[1],
      //         onGenerateRoute: (_) => MaterialPageRoute(
      //           builder: (_) => HomeScreen(_navigationTabs[1]['url']!),
      //         ),
      //       ),
      //     )
      //     ..add(
      //       Navigator(
      //         key: _navigatorKeys[2],
      //         onGenerateRoute: (_) => MaterialPageRoute(
      //           builder: (_) => const SettingsScreen(),
      //         ),
      //       ),
      //     );

      //   setState(() {});
      // });
    } else {
      _navigatorKeys.add(GlobalKey<NavigatorState>());
      setState(() {});
    }
  }

  void initializeTabs() {
    if (showBottomNavigationBar) {
      Future.delayed(Duration.zero, () {
        for (var i = 0; i < _navigationTabs.length; i++) {
          _navigatorKeys.add(GlobalKey<NavigatorState>());
          _tabs.add(
            Navigator(
              key: _navigatorKeys[i],
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => HomeScreen(_navigationTabs[i]['url']!),
              ),
            ),
          );
        }

        ///
        _navigatorKeys.add(GlobalKey<NavigatorState>());
        _tabs.add(
          Navigator(
            key: _navigatorKeys[2],
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            ),
          ),
        );

        setState(() {});
      });
    } else {
      _navigatorKeys.add(GlobalKey<NavigatorState>());
      setState(() {});
    }
  }

  @override
  void dispose() {
    idleAnimation.dispose();
    onSelectedAnimation.dispose();
    onChangedAnimation.dispose();
    navigationContainerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _navigationTabs = navigationTabs(context);

    return WillPopScope(
      onWillPop: () => _navigateBack(context),
      child: GestureDetector(
        onTap: () =>
            context.read<NavigationBarProvider>().animationController.reverse(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          bottomNavigationBar: showBottomNavigationBar
              ? FadeTransition(
                  opacity: Tween<double>(begin: 1, end: 0).animate(
                    CurvedAnimation(
                      parent: navigationContainerAnimationController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: const Offset(0, 1),
                    ).animate(
                      CurvedAnimation(
                        parent: navigationContainerAnimationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: _bottomNavigationBar,
                  ),
                )
              : null,
          body: showBottomNavigationBar
              ? IndexedStack(
                  index: _selectedIndex,
                  children: _tabs,
                )
              : Navigator(
                  key: _navigatorKeys[0],
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(
                      builder: (_) => HomeScreen(
                        widget.webUrl,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget get _bottomNavigationBar {
    return Container(
      height: 75,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: GlassBoxCurve(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width / 10,
        child: Padding(
          padding: const EdgeInsets.only(left: 2, right: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_navigationTabs.length + 1, (i) {
              if (i == _navigationTabs.length) {
                return _buildNavItem(
                  _navigationTabs.length,
                  CustomStrings.settings,
                  CustomIcons.settingsIcon(Theme.of(context).brightness),
                );
              }
              return _buildNavItem(
                i,
                _navigationTabs[i]['label']!,
                _navigationTabs[i]['icon']!,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, String icon) {
    return InkWell(
      onTap: () => onButtonPressed(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          Lottie.asset(
            icon,
            height: 30,
            repeat: true,
            controller: _selectedIndex == index
                ? onSelectedAnimation
                : _previousIndex == index
                    ? onChangedAnimation
                    : idleAnimation,
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: _selectedIndex == index
                  ? Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.normal,
                      )
                  : Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 35,
              height: 3,
              decoration: BoxDecoration(
                color: _selectedIndex == index
                    ? Theme.of(context).indicatorColor
                    : Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                boxShadow: _selectedIndex == index
                    ? [
                        BoxShadow(
                          color:
                              Theme.of(context).indicatorColor.withOpacity(0.5),
                          blurRadius: 50, // soften the shadow
                          spreadRadius: 20,
                          //extend the shadow
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onButtonPressed(int index) {
    if (!context
        .read<NavigationBarProvider>()
        .animationController
        .isAnimating) {
      context.read<NavigationBarProvider>().animationController.reverse();
    }
    // pageController.jumpToPage(index);
    onSelectedAnimation
      ..reset()
      ..forward();

    onChangedAnimation
      ..value = 1
      ..reverse();

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  Future<bool> _navigateBack(BuildContext context) async {
    if (Platform.isIOS && Navigator.of(context).userGestureInProgress) {
      return Future.value(true);
    }
    final isFirstRouteInCurrentTab =
    !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
    if (!context
        .read<NavigationBarProvider>()
        .animationController
        .isAnimating) {
      await context.read<NavigationBarProvider>().animationController.reverse();
    }
    if (!isFirstRouteInCurrentTab) {
      return Future.value(false);
    } else {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Do you want to exit app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Pass false
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Pass true
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      // If the dialog is dismissed by tapping outside of it, ensure we don't exit.
      return shouldExit ?? false;
    }
  }

}
