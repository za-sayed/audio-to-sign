import 'package:audio_to_sign_language/features/authentication/controllers/onboarding/onboarding_controllers.dart' show OnBoardingController;
import 'package:audio_to_sign_language/utils/constants/colors.dart' show TColors;
import 'package:audio_to_sign_language/utils/constants/sizes.dart';
import 'package:audio_to_sign_language/utils/device/device_utility.dart';
import 'package:audio_to_sign_language/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Positioned(
      left: TSizes.defaultSpace,
      bottom: TDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: dark? TColors.primary: Colors.black,
        ), 
        child: Icon(Iconsax.arrow_left_2),
      ),
    );
  }
}
