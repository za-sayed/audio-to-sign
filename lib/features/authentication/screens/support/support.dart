import 'package:audio_to_sign_language/features/authentication/controllers/support/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SupportController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم والمساعدة'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(':تواصل معنا عبر', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // contact rows
              _contactRow(Icons.camera_alt_outlined, 'xxxxxxx'),
              const SizedBox(height: 15),
              _contactRow(Icons.email_outlined, 'xxxx@example.com'),
              const SizedBox(height: 15),
              _contactRow(Icons.phone_outlined, '+12345678'),
              const SizedBox(height: 30),

              // FAQs
              const Text(':الأسئلة المتكررة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Column(
                children: ctrl.faqs.map((faq) {
                  return Column(
                    children: [
                      ExpansionTile(
                        title: Text(faq['q']!, textAlign: TextAlign.right),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(faq['a']!, textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                      //const Divider(),
                    ],
                  );
                }).toList(),
              )),
              
              const SizedBox(height: 30),
              const Text(':اترك لنا تعليقًا', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // comment box
              TextField(
                maxLines: 4,
                controller: ctrl.commentController,
                decoration: InputDecoration(
                  hintText: '...أكتب تعليقك هنا',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 20),

              // submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ctrl.postComment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('إرسال', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(text, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Icon(icon),
      ],
    );
  }
}
