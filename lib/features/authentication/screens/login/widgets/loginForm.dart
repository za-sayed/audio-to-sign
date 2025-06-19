// ignore_for_file: file_names

import 'package:audio_to_sign_language/features/authentication/controllers/login/login_controller.dart';
import 'package:audio_to_sign_language/features/authentication/screens/password_config/forget_password.dart';
import 'package:audio_to_sign_language/features/authentication/screens/signup/signup.dart';
import 'package:audio_to_sign_language/utils/constants/sizes.dart';
import 'package:audio_to_sign_language/utils/constants/text_strings.dart';
import 'package:audio_to_sign_language/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            // Email
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                controller: controller.email,
                validator:
                    (value) =>
                        TValidator.validateEmptyText(TTexts.email, value),
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.direct_right),
                  labelText: TTexts.email,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Password
            Obx(
              () => Directionality(
                textDirection: TextDirection.ltr,
                child: TextFormField(
                  controller: controller.password,
                  validator:
                      (value) =>
                          TValidator.validateEmptyText(TTexts.password, value),
                  expands: false,
                  obscureText: controller.hidePassword.value,
                  decoration: InputDecoration(
                    labelText: TTexts.password,
                    prefixIcon: const Icon(Iconsax.password_check),
                    suffixIcon: IconButton(
                      onPressed:
                          () =>
                              controller.hidePassword.value =
                                  !controller.hidePassword.value,
                      icon: Icon(
                        controller.hidePassword.value == true
                            ? Iconsax.eye_slash
                            : Iconsax.eye,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),

            //Remember me and forget password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Remember me
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.rememberMe.value,
                        onChanged:
                            (value) =>
                                controller.rememberMe.value = value ?? false,
                      ),
                    ),
                    Text(TTexts.rememberMe),
                  ],
                ),

                // Forgot password
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPassword()),
                  child: const Text(TTexts.forgetPassword),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            //SignIn button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.emailAndPasswordSignIn(),
                child: Text(TTexts.signIn),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),
            //Signup button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignupScreen()),
                child: Text(TTexts.createAccount),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}
