import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LearningController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Observable list of words
  final videos = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final snapshot = await _db.collection('signVideos').get();
      final words = snapshot.docs.map((d) => d['word'] as String).toList();
      videos.assignAll(words);
    } catch (e) {
      // optional: error handling
      videos.clear();
      if (kDebugMode) {
        print('Error loading videos: $e');
      }
    }
  }
}
