

import 'package:audio_to_sign_language/features/authentication/controllers/onboarding/onboarding_controllers.dart';
import 'package:audio_to_sign_language/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:audio_to_sign_language/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:audio_to_sign_language/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:audio_to_sign_language/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:audio_to_sign_language/utils/constants/image_strings.dart';
import 'package:audio_to_sign_language/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      body: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatepagelndicator,
              children:  const [
                OnBoardingPage(image: TImages.onBoardingImage1, title: TTexts.onBoardingTitle1, subTitle: TTexts.onBoardingSubTitle1),
                OnBoardingPage(image: TImages.onBoardingImage2, title: TTexts.onBoardingTitle2, subTitle: TTexts.onBoardingSubTitle2),
                OnBoardingPage(image: TImages.onBoardingImage3, title: TTexts.onBoardingTitle3, subTitle: TTexts.onBoardingSubTitle3),
              ]
            ),
          ),
          //skip button
          const OnBoardingSkip(),

          //Dot Navigation SmoothPageIndicator
          const OnBoardingDotNavigation(),

          //Circular Button
          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}






