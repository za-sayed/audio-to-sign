import 'package:audio_to_sign_language/data/repositories/authentication/authentication_repository.dart';
import 'package:audio_to_sign_language/features/authentication/screens/password_config/reset_password.dart';
import 'package:audio_to_sign_language/utils/constants/image_strings.dart';
import 'package:audio_to_sign_language/utils/helpers/network_manager.dart';
import 'package:audio_to_sign_language/utils/popups/full_screen_loader.dart';
import 'package:audio_to_sign_language/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  static ForgotPasswordController get instance => Get.find();
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();
  sendPasswordResetEmail() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جاري معالجة طلبك ...",
        TImages.dockerAnimation,
      );
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      if (!forgetPasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      await AuthenticationRepository.instance.sendPasswordResetEmail(
        email.text.trim(),
      );
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: 'تم إرسال البريد الإلكتروني',
        message: 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      );
      Get.to(() => ResetPassword(email: email.text.trim()));
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "حصل خطأ !", message: e.toString());
    }
  }

  resendPasswordResetEmail(String email) async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "جاري معالجة طلبك ...",
        TImages.dockerAnimation,
      );
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      await AuthenticationRepository.instance.sendPasswordResetEmail(
        email.trim(),
      );
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: 'تم إرسال البريد الإلكتروني',
        message: 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "حصل خطأ !", message: e.toString());
    }
  }
}
