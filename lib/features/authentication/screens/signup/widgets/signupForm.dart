// ignore_for_file: file_names

import 'package:audio_to_sign_language/features/authentication/controllers/signup/signup_controller.dart';
import 'package:audio_to_sign_language/features/authentication/screens/signup/widgets/termsAndConditions.dart';
import 'package:audio_to_sign_language/utils/constants/sizes.dart';
import 'package:audio_to_sign_language/utils/constants/text_strings.dart';
import 'package:audio_to_sign_language/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: controller.firstName,
                    validator: (value) => TValidator.validateFirstName(value),
                    expands: false,
                    decoration: const InputDecoration(
                      labelText: TTexts.firstName,
                      prefixIcon: Icon(Iconsax.user),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: controller.lastName,
                    validator: (value) => TValidator.validateLastName(value),
                    expands: false,
                    decoration: const InputDecoration(
                      labelText: TTexts.lastName,
                      prefixIcon: Icon(Iconsax.user),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextFormField(
              controller: controller.username,
              validator: (value) => TValidator.validateUserName(value),
              expands: false,
              decoration: const InputDecoration(
                labelText: TTexts.username,
                prefixIcon: Icon(Iconsax.user_edit),
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextFormField(
              controller: controller.email,
              validator: (value) => TValidator.validateEmail(value),
              expands: false,
              decoration: const InputDecoration(
                labelText: TTexts.email,
                prefixIcon: Icon(Iconsax.direct),
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          Obx(
            () => Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                controller: controller.password,
                validator: (value) => TValidator.validatePassword(value),
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
          const SizedBox(height: TSizes.spaceBtwSections),
          const TermsAndConditions(),
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.signup(),
              child: Text(TTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
