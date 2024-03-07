import 'dart:io';

import 'package:flutter/material.dart';
import 'package:prime_web/constants/icons.dart';
import 'package:prime_web/constants/strings.dart';

export 'colors.dart';
export 'icons.dart';
export 'strings.dart';

const appName = 'Jadu Sms';

const String androidPackageName = 'com.imtiaj.jadusms';

//change this url to set your URL in app
const String webInitialUrl =
    'https://portal.jadusms.com/admin/dashboard';
const String firstTabUrl = 'https://portal.jadusms.com/';

// keep local content of pages of setting screen
const String aboutPageURL = 'https://jadukor.com/about_jadukor_it.php';
const String privacyPageURL = 'https://sites.google.com/view/jadusms/home';
const String termsPageURL = '';

final shareAppMessage = 'Download $appName App from this link : $storeUrl';

final storeUrl = Platform.isAndroid
    ? 'https://play.google.com/store/apps/details?id=$androidPackageName'
    : 'https://testflight.apple.com/join/l6t5kD1G';

//To turn on/off ads
const bool showInterstitialAds = false;
const bool showBannerAds = false;
const bool showOpenAds = false;

//To turn on/off display of bottom navigation bar
const bool showBottomNavigationBar = false;

//To show/remove splash screen
const bool showSplashScreen = true;

//To show/remove onboarding screen
const bool showOnboardingScreen = false;

//To remove/display header/footer of website
const bool hideHeader = false;
const bool hideFooter = false;

/// Ad Ids
final interstitialAdId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/1033173712'
    : 'ca-app-pub-3940256099942544/4411468910';
final bannerAdId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/6300978111'
    : 'ca-app-pub-3940256099942544/2934735716';
final openAdId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/3419835294'
    : 'ca-app-pub-3940256099942544/5662855259';

//icon to set when get firebase messages
const String notificationIcon = '@mipmap/ic_launcher_round';

//turn on/off enable storage permission
const bool isStoragePermissionEnabled = false;

//add / remove tabs here
List<Map<String, String>> navigationTabs(BuildContext context) => [
      {
        'url': firstTabUrl,
        'label': CustomStrings.demo,
        'icon': CustomIcons.demoIcon(Theme.of(context).brightness),
      },
      {
        'url': webInitialUrl,
        'label': CustomStrings.home,
        'icon': CustomIcons.homeIcon(Theme.of(context).brightness),
      },
    ];
