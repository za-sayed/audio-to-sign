// lib/features/authentication/controllers/account_controller.dart

// ignore_for_file: use_build_context_synchronously, unused_field

import 'dart:typed_data';
import 'dart:convert';
import 'package:audio_to_sign_language/features/authentication/screens/login/login.dart';
import 'package:audio_to_sign_language/utils/constants/image_strings.dart';
import 'package:audio_to_sign_language/utils/popups/full_screen_loader.dart';
import 'package:audio_to_sign_language/utils/popups/loaders.dart';
import 'package:audio_to_sign_language/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class AccountController extends GetxController {
  static AccountController get instance => Get.find();

  final imageData = Rx<Uint8List?>(null);
  final isEmailReadOnly = true.obs;
  final isPassReadOnly = true.obs;
  final isUserNameReadOnly = true.obs;
  final isFirstReadOnly = true.obs;
  final isLastReadOnly = true.obs;
  final isNewImage = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final RxBool isGoogleUser = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    TFullScreenLoader.openLoadingDialog(
      'جاري تحميل البيانات...',
      TImages.dockerAnimation,
    );
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final methods = user.providerData;
      isGoogleUser.value = methods.any((p) => p.providerId == 'google.com');
      final doc = await _db.collection('Users').doc(user.uid).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      if (user.email != data['Email']) {
        FirestoreServicesAcc().updateUserEmail(newEmail: user.email!);
      }
      emailController.text = user.email ?? '';
      usernameController.text = data['Username'] ?? '';
      firstNameController.text = data['FirstName'] ?? '';
      lastNameController.text = data['LastName'] ?? '';
      passwordController.clear();
      final pic = data['ProfilePicture'] as String? ?? '';
      if (pic.isNotEmpty) {
        try {
          imageData.value = base64Decode(pic);
        } catch (e) {
          debugPrint('⚠️ Invalid base64 format for profile picture: $e');
          imageData.value = null;
        }
      } else {
        imageData.value = null;
      }
      isNewImage.value = false;
      isEmailReadOnly.value = true;
      isPassReadOnly.value = true;
      isUserNameReadOnly.value = true;
      isFirstReadOnly.value = true;
      isLastReadOnly.value = true;
      TFullScreenLoader.stopLoading();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: "حصل خطأ !", message: e.toString());
    }
  }

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    imageData.value = await img.readAsBytes();
    isNewImage.value = true;
  }

  Future<bool> confirm(String title, String msg) async {
    return (await Get.dialog<bool>(
          Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(title),
              content: Text(msg),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('تأكيد'),
                ),
              ],
            ),
          ),
        )) ??
        false;
  }

  Future<void> save() async {
    final ctx = Get.context!;
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _db.collection('Users').doc(user.uid).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final currentUsername = data['Username'];
    final currentFirstName = data['FirstName'];
    final currentLastName = data['LastName'];
    final newEmail = emailController.text.trim();
    final newPass = passwordController.text.trim();
    final newUsername = usernameController.text.trim();
    final newFirst = firstNameController.text.trim();
    final newLast = lastNameController.text.trim();

    // nothing changed?
    if (newEmail == user.email &&
        newPass.isEmpty &&
        !isNewImage.value &&
        newUsername == currentUsername &&
        newFirst == currentFirstName &&
        newLast == currentLastName) {
      TLoaders.warningSnackBar(
        title: 'تنبيه',
        message: 'يرجى تغيير شيء على الأقل',
      );
      return;
    }

    if (isGoogleUser.value && (newEmail != user.email || newPass.isNotEmpty)) {
      TLoaders.warningSnackBar(
        title: 'غير مسموح',
        message: 'لا يمكن تعديل البريد أو كلمة المرور لحساب Google',
      );
      return;
    }

    if (!await confirm(
      'تأكيد حفظ التغييرات',
      'هل أنت متأكد أنك تريد حفظ التغييرات؟',
    )) {
      await loadUser();
      return;
    }

    if (newEmail != user.email) {
      final v = TValidator.validateEmail(newEmail);
      if (v != null) {
        TLoaders.warningSnackBar(title: 'تنبيه', message: v);
        return;
      }
    }

    if (newPass.isNotEmpty) {
      final v = TValidator.validatePassword(newPass);
      if (v != null) {
        TLoaders.warningSnackBar(title: 'تنبيه', message: v);
        return;
      }
    }

    if (newUsername != currentUsername) {
      final v = TValidator.validateUserName(newUsername);
      if (v != null) {
        TLoaders.warningSnackBar(title: 'تنبيه', message: v);
        return;
      }
    }

    if (newFirst != currentFirstName) {
      final v = TValidator.validateFirstName(newFirst);
      if (v != null) {
        TLoaders.warningSnackBar(title: 'تنبيه', message: v);
        return;
      }
    }

    if (newLast != currentLastName) {
      final v = TValidator.validateLastName(newLast);
      if (v != null) {
        TLoaders.warningSnackBar(title: 'تنبيه', message: v);
        return;
      }
    }

    // reauthenticate if email or password changed
    if (newEmail != user.email || newPass.isNotEmpty) {
      final currentPwd = await promptForPassword(ctx);
      if (currentPwd == null) return;
      try {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPwd,
        );
        await user.reauthenticateWithCredential(cred);
      } catch (e) {
        TLoaders.errorSnackBar(
          title: 'فشل التحقق من الهوية',
          message: e.toString(),
        );
        return;
      }
    }

    // prepare image
    String? base64Image;
    if (isNewImage.value && imageData.value != null) {
      base64Image = base64Encode(imageData.value!);
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      bool emailChanged = newEmail != user?.email;
      bool otherFieldsChanged =
          newPass.isNotEmpty ||
          isNewImage.value ||
          newUsername != currentUsername ||
          newFirst != currentFirstName ||
          newLast != currentLastName;

      if (emailChanged) {
        await FirestoreServicesAcc().updateUserEmail(newEmail: newEmail);
        TLoaders.warningSnackBar(
          title: 'تحديث البريد الإلكتروني',
          message:
              'تم إرسال رابط تأكيد إلى بريدك الجديد. الرجاء تأكيده لتفعيل التحديث.',
        );
        await _auth.signOut();
        Get.offAll(() => const LoginScreen());
        return;
      }
      if (otherFieldsChanged) {
        await FirestoreServicesAcc().updateUserData(
          context: ctx,
          newPassword: newPass.isNotEmpty ? newPass : null,
          imageBase64: base64Image,
          newUsername: newUsername,
          newFirstName: newFirst,
          newLastName: newLast,
        );

        TLoaders.successSnackBar(
          title: 'تهانينا',
          message: 'تم تحديث البيانات بنجاح.',
        );
      }
      await loadUser();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'فشل تحديث البيانات',
        message: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    if (!await confirm(
      'تأكيد تسجيل الخروج',
      'هل أنت متأكد أنك تريد تسجيل الخروج؟',
    )) {
      return;
    }
    await _auth.signOut();
    Get.offAll(() => const LoginScreen());
  }

  Future<void> deleteAccount() async {
    final ctx = Get.context!;
    if (!await confirm(
      'تأكيد حذف الحساب',
      'هل أنت متأكد أنك تريد حذف الحساب نهائيًا؟',
    )) {
      return;
    }
    final user = _auth.currentUser;
    if (user == null) return;
    final currentPwd = await promptForPassword(ctx);
    if (currentPwd == null) return;
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPwd,
      );
      await user.reauthenticateWithCredential(cred);
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'فشل التحقق من الهوية',
        message: e.toString(),
      );
      return;
    }
    await _db.collection('Users').doc(user.uid).delete();
    await user.delete();
    TLoaders.successSnackBar(title: 'تهانينا', message: 'تم حذف الحساب بنجاح');
    Get.offAll(() => const LoginScreen());
  }
}

Future<String?> promptForPassword(BuildContext context) async {
  final passwordController = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      bool obscure = true;
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('أدخل كلمة المرور الحالية'),
              content: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Iconsax.eye_slash : Iconsax.eye),
                      onPressed: () {
                        setState(() => obscure = !obscure);
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, passwordController.text),
                  child: const Text('تأكيد'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class FirestoreServicesAcc {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('Users');

  Future<void> updateUserEmail({required String newEmail}) async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      if (newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.reload();
      }
      final updateData = <String, dynamic>{};
      if (newEmail != user.email) {
        updateData['Email'] = newEmail;
      }
      if (updateData.isNotEmpty) {
        await _usersCollection
            .doc(uid)
            .set(updateData, SetOptions(merge: true));
      }
    } else {
      TLoaders.errorSnackBar(
        title: 'فشل تحديث البريد الإلكتروني',
        message: 'المستخدم غير موجود',
      );
      throw Exception('No user is currently logged in');
    }
  }

  Future<void> updateUserData({
    required BuildContext context,
    String? newPassword,
    String? imageBase64,
    String? newUsername,
    String? newFirstName,
    String? newLastName,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      // Update password if provided
      if (newPassword != null) {
        await user.updatePassword(newPassword);
      }
      // Build Firestore update
      final updateData = <String, dynamic>{};
      if (imageBase64 != null) {
        updateData['ProfilePicture'] = imageBase64;
      }
      if (newUsername != null) {
        updateData['Username'] = newUsername;
      }
      if (newFirstName != null) {
        updateData['FirstName'] = newFirstName;
      }
      if (newLastName != null) {
        updateData['LastName'] = newLastName;
      }
      if (updateData.isNotEmpty) {
        await _usersCollection
            .doc(uid)
            .set(updateData, SetOptions(merge: true));
      }
    } else {
      TLoaders.errorSnackBar(
        title: 'فشل تحديث البيانات',
        message: 'المستخدم غير موجود',
      );
      throw Exception('No user is currently logged in');
    }
  }
}
