import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';
import 'package:prime_web/constants/constants.dart';
import 'package:prime_web/main.dart';
import 'package:prime_web/screens/app_content_screen.dart';
import 'package:prime_web/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin<SettingsScreen> {
  @override
  bool get wantKeepAlive => true;
  final _inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();

    if (showInterstitialAds) {
      AdMobService.createInterstitialAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text(CustomStrings.settings), elevation: 2),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _homeFloatingAction,
      body: SafeArea(
        top: !Platform.isIOS,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              /// Dark Mode
              const SettingTile(
                leadingIcon: CustomIcons.darkModeIcon,
                title: CustomStrings.darkMode,
                trailing: ChangeThemeButtonWidget(),
              ),

              /// About Us
              SettingTile(
                leadingIcon: CustomIcons.aboutUsIcon,
                title: CustomStrings.aboutUs,
                onTap: () => _onPressed(
                  const AppContentScreen(
                    title: CustomStrings.aboutUs,
                    content: CustomStrings.aboutPageContent,
                    url: aboutPageURL,
                  ),
                ),
              ),

              /// Privacy Policy
              SettingTile(
                leadingIcon: CustomIcons.privacyIcon,
                title: CustomStrings.privacyPolicy,
                onTap: () => _onPressed(
                  const AppContentScreen(
                    title: CustomStrings.privacyPolicy,
                    content: CustomStrings.privacyPageContent,
                    url: privacyPageURL,
                  ),
                ),
              ),

              /// Terms & Condition
              /*SettingTile(
                leadingIcon: CustomIcons.termsIcon,
                title: CustomStrings.terms,
                onTap: () => _onPressed(
                  const AppContentScreen(
                    title: CustomStrings.terms,
                    content: CustomStrings.termsPageContent,
                    url: termsPageURL,
                  ),
                ),
              ),*/

              /// Share
              SettingTile(
                leadingIcon: CustomIcons.shareIcon,
                title: CustomStrings.share,
                onTap: () => Share.share(
                  shareAppMessage,
                  subject: shareAppMessage,
                ),
              ),

              /// Rate Us
              SettingTile(
                leadingIcon: CustomIcons.rateUsIcon,
                title: CustomStrings.rateUs,
                onTap: () async {
                  if (await _inAppReview.isAvailable()) {
                    await _inAppReview
                        .requestReview()
                        .then((value) => _rateApp(context))
                        .onError(
                          (error, stackTrace) => log('[RateUs] : $error'),
                        );
                  }
                },
              ),

              /// Debug SHA keys
              /*SettingTile(
                leadingIcon: CustomIcons.shareIcon,
                title: 'FCM Token',
                onTap: () async {
                  final fcmToken = await FirebaseMessaging.instance.getToken();
                  await Share.share(fcmToken!, subject: fcmToken);
                },
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget get _homeFloatingAction => !showBottomNavigationBar
      ? FloatingActionButton(
          onPressed: Navigator.of(context).pop,
          child: Lottie.asset(
            CustomIcons.homeIcon(Theme.of(context).brightness),
            height: 30,
            repeat: true,
          ),
        )
      : const SizedBox.shrink();

  Future<void> _rateApp(BuildContext context) async {
    if (await canLaunchUrl(Uri.parse(storeUrl))) {
      await launchUrl(Uri.parse(storeUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again'),
        ),
      );
    }
  }

  void _onPressed(Widget routeName) {
    if (showInterstitialAds) {
      AdMobService.showInterstitialAd();
    }

    navigatorKey.currentState!.push(
      CupertinoPageRoute<dynamic>(builder: (_) => routeName),
    );
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    required this.leadingIcon,
    required this.title,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String leadingIcon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        leadingIcon,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          Theme.of(context).iconTheme.color!,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
      onTap: onTap,
    );
  }
}
