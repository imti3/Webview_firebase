import 'dart:developer';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:prime_web/screens/main_screen.dart';

class DynamicService {
  static final _dynamicLinks = FirebaseDynamicLinks.instance;

  static Future<void> initDynamicLinks(BuildContext context) async {
    if (!context.mounted) return;

    _dynamicLinks.onLink.listen((dynamicLinkData) {
      final deepLinkUrl = dynamicLinkData.link.toString();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<MyHomePage>(
          builder: (_) => MyHomePage(webUrl: deepLinkUrl),
        ),
        (route) => false,
      );
    }).onError(
      (Object e) => log(e.toString(), name: '[DynamicService]'),
    );
  }
}
