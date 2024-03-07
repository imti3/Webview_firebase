import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prime_web/constants/constants.dart';
import 'package:prime_web/screens/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessageLocal(NotificationResponse message) async {
  await Firebase.initializeApp();
}

class FirebaseInitialize {
  final _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;
  Future<void> initFirebaseState(BuildContext context) async {
    channel = const AndroidNotificationChannel(
      androidPackageName,
      appName,
      description: appName,
      importance: Importance.high,

    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestBadgePermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
      notificationCategories: [],
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // TODO(J): is it incomplete: onSelectNotification
    Future<void> onSelectNotification(String? payload) async {}

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            onSelectNotification(notificationResponse.payload);

          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundMessageLocal,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    Future<void> generateSimpleNotification(String title, String msg) async {
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: notificationIcon,
      );

      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails(),
      );
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        msg,
        platformChannelSpecifics,
      );
    }

    Future<void> generateImageNotification(
      String title,
      String msg,
      String image,
    ) async {
      final bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(image),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: msg,
        htmlFormatSummaryText: true,
      );
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: notificationIcon,
        largeIcon: FilePathAndroidBitmap(image),
        styleInformation: bigPictureStyleInformation,
      );

      final platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        msg,
        platformChannelSpecifics,
      );
    }

    await _firebaseMessaging.getInitialMessage().then((message) async {
      if (message != null) {

        final url = message.data['url']?.toString();
        if (url != null && await canLaunch(url)) {
      await launch(url);
      }
    }


    });



    await _firebaseMessaging.getToken().then((value) {
      log('token==$value');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification!;
      final title = notification.title ?? '';
      final body = notification.body ?? '';
      final data = message.data;
      final url = data['url']?.toString();

      var image = '';
      print('Notification payload: $message');
      if (data['url'] != null) {
        // Handle the URL data here
        final url = data['url'];
        // Navigate to the appropriate screen or perform any other action with the URL
        print('Received URL: $url');
      }

      image = defaultTargetPlatform == TargetPlatform.android
          ? notification.android!.imageUrl ?? ''
          : notification.apple!.imageUrl ?? '';

      if (image != '') {
        generateImageNotification(title, body, image);
      } else {
        generateSimpleNotification(title, body);
      }
      /*if (url != null) {
        print('Received URL1: $url');
        if (await canLaunch(url)) {
      await launch(url); // Launch the URL in the default browser
      } else {
      print('Could not launch $url');
      }*/

    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final notification = message.notification!;
      final body = notification.body ?? '';
      final data = message.data;
      final url = data['url']?.toString();
      //print('Notification payload: $message');

      if (url != null) {
        print('Received URL1: $url');
        if (await canLaunch(url)) {
          await launch(url); // Launch the URL in the default browser
        } else {
          print('Could not launch $url');
        }
      } else {
        // Handle dynamic link data if URL is not present
        PendingDynamicLinkData? dynamicLinkData;
        if (Uri.parse(body).host != '') {
          dynamicLinkData = await FirebaseDynamicLinks.instance.getDynamicLink(Uri.parse(body));
        }
      if (dynamicLinkData != null) {

        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<MyHomePage>(
            builder: (_) => MyHomePage(
              webUrl: dynamicLinkData!.link.toString(),
            ),
          ),
          (route) => false,
        );
      }
    }});




    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      final url = message.data['url']?.toString();
      if (url != null && await canLaunch(url)) {
        await launch(url);
      }
    });









    await subscribeToTopic('Imtiaj');





  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic).then((_) {
      print('Subscription to $topic successful');
    }).catchError((error) {
      print('Failed to subscribe to $topic: $error');
    });
  }


}

