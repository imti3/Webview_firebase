import 'dart:io';

import 'package:flutter/material.dart';
import 'package:prime_web/widgets/load_web_view.dart';

class AppContentScreen extends StatefulWidget {
  const AppContentScreen({
    required this.title,
    required this.content,
    required this.url,
    super.key,
  });

  final String title;
  final String content;
  final String url;

  @override
  State<AppContentScreen> createState() => _AppContentScreenState();
}

class _AppContentScreenState extends State<AppContentScreen> {
  @override
  Widget build(BuildContext context) {
    late final message =
        "<span style='color: ${Theme.of(context).brightness == Brightness.dark ? 'white' : 'black'};'>"
        '${widget.content}'
        '</span>';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: SafeArea(
        top: !Platform.isIOS,
        child: widget.url == ''
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: LoadWebView(url: message, webUrl: false),
              )
            : LoadWebView(url: widget.url),
      ),
    );
  }
}
