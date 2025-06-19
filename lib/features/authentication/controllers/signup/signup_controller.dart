import 'package:audio_to_sign_language/data/repositories/authentication/authentication_repository.dart';
import 'package:audio_to_sign_language/data/repositories/user/user_repository.dart';
import 'package:audio_to_sign_language/features/authentication/screens/signup/verifyEmail.dart';
import 'package:audio_to_sign_language/features/personalization/models/user_model.dart';
import 'package:audio_to_sign_language/utils/constants/image_strings.dart';
import 'package:audio_to_sign_language/utils/helpers/network_manager.dart';
import 'package:audio_to_sign_language/utils/popups/full_screen_loader.dart';
import 'package:audio_to_sign_language/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  //Variables
  final privacyPolicy = true.obs;
  final hidePassword = true.obs;
  final email = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final password = TextEditingController();
  final username = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // Signup
  Future<void> signup() async {
    try {
      //Start Loading
      TFullScreenLoader.openLoadingDialog(
        'جاري معالجة بياناتك ... ',
        TImages.dockerAnimation,
      );

      //Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      //Form Validation
      if (!signupFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      //Privacy Policy Check
      if (!privacyPolicy.value) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'الموافقة على سياسة الخصوصية',
          message:
              'لإنشاء حساب، يجب عليك قراءة سياسة الخصوصية وشروط الاستخدام والموافقة عليهما.',
        );
        return;
      }

      // Register user in Firebase Authentication & Save user data in the Firebase
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
            email.text.trim(),
            password.text.trim(),
          );
      // Save authenticated user data in firebase firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        username: username.text.trim(),
        email: email.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        profilePicture: '',
      );

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
        title: 'تهانينا',
        message: 'تم إنشاء حسابك بنجاح! يرجى تأكيد بريدك الإلكتروني للمتابعة.',
      );

      Get.to(() => VerifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "حصل خطأ !", message: e.toString());
    } 
  }
}
