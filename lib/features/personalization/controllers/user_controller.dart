import 'package:audio_to_sign_language/data/repositories/user/user_repository.dart';
import 'package:audio_to_sign_language/features/personalization/models/user_model.dart';
import 'package:audio_to_sign_language/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  final userRepository = Get.put(UserRepository());
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      if (userCredentials != null) {
        final nameParts = UserModel.nameParts(
          userCredentials.user!.displayName ?? '',
        );
        final username = UserModel.generateUsername(
          userCredentials.user!.displayName ?? '',
        );
        final user = UserModel(
          id: userCredentials.user!.uid,
          username: username,
          email: userCredentials.user!.email ?? '',
          firstName: nameParts[0],
          lastName: nameParts.length > 1? nameParts.sublist(1).join(' '): '',
          profilePicture: userCredentials.user!.photoURL ?? '',
        );
        await userRepository.saveUserRecord(user);
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: "تعذر حفظ البيانات",
        message:
            'حدث خطأ أثناء حفظ معلوماتك. يمكنك إعادة محاولة الحفظ عبر ملفك الشخصي.',
      );
    }
  }
}
