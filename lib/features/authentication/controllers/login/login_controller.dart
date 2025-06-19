import 'package:audio_to_sign_language/data/repositories/authentication/authentication_repository.dart';
import 'package:audio_to_sign_language/features/personalization/controllers/user_controller.dart';
import 'package:audio_to_sign_language/utils/constants/image_strings.dart';
import 'package:audio_to_sign_language/utils/helpers/network_manager.dart';
import 'package:audio_to_sign_language/utils/popups/full_screen_loader.dart';
import 'package:audio_to_sign_language/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  //variables
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final userController = Get.put(UserController());

  @override
  void onInit() {
    email.text = localStorage.read('Remember_me_email') ?? '';
    password.text = localStorage.read('Remember_me_password') ?? '';
    super.onInit();
  }

  Future<void> emailAndPasswordSignIn() async {
    try {
      //Start Loading
      TFullScreenLoader.openLoadingDialog(
        'جاري تسجيل دخولك ...',
        TImages.dockerAnimation,
      );

      //Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      //Form Validation
      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      //Save data if remember me true
      if (rememberMe.value) {
        localStorage.write('Remember_me_email', email.text.trim());
        localStorage.write('Remember_me_password', password.text.trim());
      }

      // Login user using email & password authentication
      final _ = await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      TFullScreenLoader.stopLoading();

      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "حصل خطأ !", message: e.toString());
    }
  }
  Future<void> googleSignIn() async {
      try {
        TFullScreenLoader.openLoadingDialog(
          'جاري تسجيل دخولك ...',
          TImages.dockerAnimation,
        );
        final isConnected = await NetworkManager.instance.isConnected();
        if (!isConnected) {
          TFullScreenLoader.stopLoading();
          return;
        }
        final userCredentials = await AuthenticationRepository.instance.signinWithGoogle();
        await userController.saveUserRecord(userCredentials);
        TFullScreenLoader.stopLoading();
        AuthenticationRepository.instance.screenRedirect();
      } catch (e) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: "حصل خطأ !", message: e.toString());
      }
    }
}
