import 'package:audio_to_sign_language/utils/constants/image_strings.dart';
import 'package:audio_to_sign_language/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audio_to_sign_language/utils/popups/loaders.dart';

class SupportController extends GetxController {
  static SuperController get instance => Get.find();
  
  final commentController = TextEditingController();

  // Frequently Asked Questions
  final faqs = <Map<String,String>>[
    {
      'q': 'كيف يمكنني إنشاء حساب؟',
      'a': 'يمكنك إنشاء حساب بالضغط على زر "إنشاء حساب" وإدخال معلوماتك الشخصية مثل البريد الإلكتروني وكلمة المرور.'
    },
    {
      'q': 'كيف يمكنني استرجاع كلمة المرور؟',
      'a': 'في صفحة تسجيل الدخول، اضغط على "نسيت كلمة المرور" واتبع التعليمات لاستعادة حسابك.'
    },
    {
      'q': 'كيف يمكنني التواصل مع فريق الدعم؟',
      'a': 'يمكنك التواصل معنا عبر إنستغرام أو البريد الإلكتروني أو رقم الهاتف الموضحين في صفحة الدعم.'
    },
  ].obs;

  Future<void> postComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) {
      TLoaders.warningSnackBar(title: 'تحذير', message: 'يرجى كتابة تعليق قبل الإرسال');
      return;
    }

    try {
      TFullScreenLoader.openLoadingDialog('جاري إرسال تعليقك ...', TImages.dockerAnimation);
      final user = FirebaseAuth.instance.currentUser;
      final username = user?.email ?? 'guest';

      await FirebaseFirestore.instance.collection('comments').add({
        'user': username,
        'comment': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      commentController.clear();
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(title: 'تهانينا', message: 'تم إرسال التعليق بنجاح!');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title:  'حدث خطأ أثناء الإرسال', message: e.toString());
    } 
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
