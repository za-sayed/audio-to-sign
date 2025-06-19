import 'package:audio_to_sign_language/features/authentication/controllers/onboarding/onboarding_controllers.dart';
import 'package:audio_to_sign_language/utils/constants/colors.dart';
import 'package:audio_to_sign_language/utils/constants/sizes.dart';
import 'package:audio_to_sign_language/utils/device/device_utility.dart';
import 'package:audio_to_sign_language/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Positioned(
        bottom: TDeviceUtils.getBottomNavigationBarHeight() + 22,
        right: TSizes.defaultSpace,
        child: SmoothPageIndicator(
          controller: controller.pageController,
          onDotClicked: controller.dotNavigationClick, 
          count: 3, 
          effect: ExpandingDotsEffect(activeDotColor: dark? TColors.light: TColors.dark, dotHeight: 6)
        )
      ),
    );
  }
}