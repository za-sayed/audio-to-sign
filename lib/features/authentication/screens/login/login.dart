import 'package:audio_to_sign_language/common/widgets/login_signup/formDivider.dart';
import 'package:audio_to_sign_language/common/widgets/login_signup/socialButtons.dart';
import 'package:audio_to_sign_language/features/authentication/screens/login/widgets/loginForm.dart';
import 'package:audio_to_sign_language/features/authentication/screens/login/widgets/loginHeader.dart';
import 'package:audio_to_sign_language/utils/constants/sizes.dart';
import 'package:audio_to_sign_language/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Center(child:Text("تسجيل الدخول"))),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                const LoginHeader(),

                const LoginForm(),

                FormDivider(dividerText: TTexts.orSignInWith),

                const SizedBox(height: TSizes.spaceBtwSections),

                const SocialButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

