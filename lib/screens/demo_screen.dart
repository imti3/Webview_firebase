import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prime_web/constants/constants.dart';
import 'package:prime_web/screens/home_screen.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen>
    with AutomaticKeepAliveClientMixin<DemoScreen> {
  @override
  bool get wantKeepAlive => true;

  TextEditingController urlTextController =
      TextEditingController(text: 'https://');

  late final List<Map<String, dynamic>> urls;

  @override
  void initState() {
    super.initState();

    urls = [
      {
        'icon': Image.asset(
          'assets/icons/elite_web.png',
          height: 25,
          width: 25,
        ),
        'url': 'https://eliteweb.wrteam.me',
        'label': 'Elite Quiz - Web Version',
      },
      {
        'icon': Image.asset(
          'assets/icons/ecart.png',
          height: 35,
          width: 25,
        ),
        'url': 'https://ecartmultivendorweb.thewrteam.in/',
        'label': 'eCart Web - Multi Vendor',
      },
      {
        'icon': Image.asset(
          'assets/icons/envato.png',
          height: 25,
          width: 25,
        ),
        'url': 'https://codecanyon.net/',
        'label': 'Codecanyon',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        top: !Platform.isIOS,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(CustomStrings.demo),
            elevation: 2,
          ),
          backgroundColor: Colors.transparent,
          body: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTextFormField(),
                const SizedBox(height: 30),
                const Divider(height: 4, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'Check this out',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Flexible(
                  flex: 10,
                  child: ScrollConfiguration(
                    behavior: MyBehavior(),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: urls.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () => Navigator.of(context).push(
                            CupertinoPageRoute<HomeScreen>(
                              builder: (_) => HomeScreen(
                                urls[index]['url']! as String,
                                mainPage: false,
                              ),
                            ),
                          ),
                          visualDensity: const VisualDensity(horizontal: -4),
                          leading: urls[index]['icon'] as Widget,
                          title: _urlText(urls[index]['label'] as String),
                          tileColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          dense: true,
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(height: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField() => Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.centerEnd,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 35),
            child: TextFormField(
              controller: urlTextController,
              style: Theme.of(context).textTheme.titleSmall,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(5),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(5.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(5.5),
                ),
                isDense: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: SvgPicture.asset(
                    CustomIcons.webIcon,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      accentColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              cursorColor: accentColor,
            ),
          ),
          Positioned.directional(
            end: 0,
            textDirection: Directionality.of(context),
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: accentColor.withOpacity(1),
              ),
              child: IconButton(
                onPressed: _loadUrl,
                iconSize: 30,
                icon: const Icon(Icons.arrow_right_alt_sharp),
                color: Colors.white,
              ),
            ),
          ),
        ],
      );

  void _loadUrl() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (Uri.parse(urlTextController.text).host != '') {
      Navigator.of(context).push(
        CupertinoPageRoute<HomeScreen>(
          builder: (_) => HomeScreen(urlTextController.text, mainPage: false),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error! Please enter valid URL'),
        ),
      );
    }
  }

  Widget _urlText(String url) {
    return Text(
      url,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontWeight: FontWeight.normal),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
