import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:prime_web/constants/constants.dart';
import 'package:prime_web/main.dart';
import 'package:prime_web/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _selectedIndex = 0;
  late int totalPages;
  TextStyle headline = const TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );
  TextStyle desc = const TextStyle(color: primaryColor, fontSize: 16);
  static const slidersList = <Map<String, String>>[
    {
      'title': CustomStrings.onboardingTitle1,
      'image': CustomIcons.onboardingImage1,
      'desc': CustomStrings.onboardingDesc1,
    },
    {
      'title': CustomStrings.onboardingTitle2,
      'image': CustomIcons.onboardingImage2,
      'desc': CustomStrings.onboardingDesc2,
    },
    {
      'title': CustomStrings.onboardingTitle3,
      'image': CustomIcons.onboardingImage3,
      'desc': CustomStrings.onboardingDesc3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    totalPages = slidersList.length;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: ColoredBox(
        color: onboardingBGColor,
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.7,
              child: ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: PageView.builder(
                  controller: pageController,
                  itemCount: totalPages,
                  onPageChanged: (index) => setState(() {
                    _selectedIndex = index;
                  }),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      child: Column(
                        children: <Widget>[
                          const Spacer(flex: 2),
                          Text(
                            slidersList[index]['title']!,
                            style: headline,
                          ),
                          const Spacer(flex: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: SvgPicture.asset(
                              slidersList[index]['image']!,
                            ),
                          ),
                          const Spacer(flex: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 60,
                            ),
                            child: Text(
                              slidersList[index]['desc']!,
                              style: desc,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            PageIndicator(
              index: _selectedIndex,
              length: slidersList.length,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                if (_selectedIndex < totalPages - 1) {
                  await pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else if (_selectedIndex == totalPages - 1) {
                  await jumpToMainPage();
                }
              },
              child: Container(
                width: _selectedIndex == totalPages - 1 ? 213 : 65,
                height: _selectedIndex == totalPages - 1 ? 50 : 65,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x29000000),
                      offset: Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      onboardingButtonColor1,
                      onboardingButtonColor2,
                    ],
                  ),
                ),
                child: _selectedIndex == totalPages - 1
                    ? Text(
                        CustomStrings.done,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: whiteColor),
                      )
                    : const Icon(
                        Icons.arrow_forward,
                        color: whiteColor,
                      ),
              ),
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                const Spacer(),
                TextButton(
                  onPressed: jumpToMainPage,
                  child: Text('Skip', style: headline),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> jumpToMainPage() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('isFirstTimeUser', false);
    await navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute<MyHomePage>(
        builder: (_) => const MyHomePage(webUrl: webInitialUrl),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    required this.index,
    required this.length,
    super.key,
  });

  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (indexDots) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: index == indexDots ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == indexDots
                ? onboardingButtonColor1
                : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(40)),
            border: Border.all(color: onboardingButtonColor1),
          ),
        );
      }),
    );
  }
}
