import 'package:audio_to_sign_language/utils/constants/sizes.dart';
import 'package:audio_to_sign_language/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key, required this.image, required this.title, required this.subTitle,
  });

  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace + 25),
      child: Column(
        children: [
          Image(
            width: THelperFunctions.screenWidth() * 0.8,
            height: THelperFunctions.screenHeight() * 0.6,
            image: AssetImage(image)
          ),
          Text(
          title, 
          style: Theme.of(context).textTheme.headlineMedium, 
          textAlign: TextAlign.center),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
          subTitle, 
          style: Theme.of(context).textTheme.bodyMedium, 
          textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }
}