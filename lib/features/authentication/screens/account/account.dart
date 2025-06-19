// lib/features/authentication/screens/account_details_view.dart

import 'package:audio_to_sign_language/features/authentication/controllers/account/account_controller.dart';
import 'package:audio_to_sign_language/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_to_sign_language/utils/constants/image_strings.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AccountController());
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('إعدادات الحساب'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            Obx(() {
              final img = ctrl.imageData.value;
              return CircleAvatar(
                radius: 80,
                backgroundImage:
                    img != null
                        ? MemoryImage(img)
                        : const AssetImage(TImages.user) as ImageProvider,
              );
            }),
            TextButton.icon(
              icon: const Icon(Icons.add_a_photo),
              label: const Text('تغيير الصورة'),
              onPressed: ctrl.pickImage,
            ),
            const SizedBox(height: 32),
            Obx(
              () => _buildField(
                hint: 'الاسم الأول',
                controller: ctrl.firstNameController,
                obscure: false,
                readOnly: ctrl.isFirstReadOnly.value,
                onEdit: () => ctrl.isFirstReadOnly.toggle(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildField(
                hint: 'الاسم الأخير',
                controller: ctrl.lastNameController,
                obscure: false,
                readOnly: ctrl.isLastReadOnly.value,
                onEdit: () => ctrl.isLastReadOnly.toggle(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildField(
                hint: 'اسم المستخدم',
                controller: ctrl.usernameController,
                obscure: false,
                readOnly: ctrl.isUserNameReadOnly.value,
                onEdit: () => ctrl.isUserNameReadOnly.toggle(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildField(
                hint: 'البريد الإلكتروني',
                controller: ctrl.emailController,
                obscure: false,
                readOnly: ctrl.isEmailReadOnly.value || ctrl.isGoogleUser.value,
                onEdit:
                    ctrl.isGoogleUser.value
                        ? null
                        : () async {
                          final confirmEdit = await Get.dialog<bool>(
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                title: const Text('تنبيه'),
                                content: const Text(
                                  'عند تعديل البريد الإلكتروني، سيتم تسجيل خروجك بعد الحفظ لإعادة التحقق.\nهل ترغب في المتابعة؟',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.back(result: true),
                                    child: const Text('متابعة'),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (confirmEdit == true) {
                            ctrl.isEmailReadOnly.toggle();
                          }
                        },
              ),
            ),

            const SizedBox(height: 16),
            Obx(
              () => _buildField(
                hint: 'كلمة المرور',
                controller: ctrl.passwordController,
                obscure: true,
                readOnly: ctrl.isPassReadOnly.value || ctrl.isGoogleUser.value,
                onEdit:
                    ctrl.isGoogleUser.value
                        ? null
                        : () => ctrl.isPassReadOnly.toggle(),
              ),
            ),
            const SizedBox(height: 32),
            _buildButton('حفظ', ctrl.save),
            const SizedBox(height: 16),
            _buildButton('تسجيل الخروج', ctrl.signOut),
            const SizedBox(height: 16),
            _buildButton('حذف الحساب', ctrl.deleteAccount),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required bool readOnly,
    VoidCallback? onEdit,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscure,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
        if (onEdit != null)
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}
