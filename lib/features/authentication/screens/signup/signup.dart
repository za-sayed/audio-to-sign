import 'package:audio_to_sign_language/common/widgets/login_signup/formDivider.dart';
import 'package:audio_to_sign_language/common/widgets/login_signup/socialButtons.dart';
import 'package:audio_to_sign_language/features/authentication/screens/signup/widgets/signupForm.dart';
import 'package:audio_to_sign_language/utils/constants/sizes.dart';
import 'package:audio_to_sign_language/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child:Text("إنشاء حساب"))),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  TTexts.signupTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Form
                const SignupForm(),
                const SizedBox(height: TSizes.spaceBtwSections),
                //Divider
                FormDivider(dividerText: TTexts.orSignUpWith),
                const SizedBox(height: TSizes.spaceBtwSections),
                //Social buttons
                const SocialButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

