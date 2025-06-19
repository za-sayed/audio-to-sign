// lib/features/authentication/controllers/home/home_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_to_sign_language/utils/constants/image_strings.dart';
import 'package:audio_to_sign_language/utils/popups/full_screen_loader.dart';
import 'package:audio_to_sign_language/utils/popups/loaders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class TrieNode {
  final Map<String, TrieNode> children = {};
  bool isEnd = false;
}

class PhraseTrie {
  final TrieNode _root = TrieNode();

  void insert(String phrase) {
    var node = _root;
    for (var ch in phrase.runes.map((r) => String.fromCharCode(r))) {
      node = node.children.putIfAbsent(ch, () => TrieNode());
    }
    node.isEnd = true;
  }

  int? longestMatch(String text, int start) {
    var node = _root;
    int? lastMatch;
    for (int j = start; j < text.length; j++) {
      final ch = text[j];
      if (!node.children.containsKey(ch)) break;
      node = node.children[ch]!;
      if (node.isEnd) lastMatch = j + 1;
    }
    return lastMatch;
  }
}

List<String> segmentText(String text, PhraseTrie trie) {
  final segments = <String>[];
  int i = 0;
  while (i < text.length) {
    if (text[i] == ' ') {
      i++;
      continue;
    }
    final matchEnd = trie.longestMatch(text, i);
    if (matchEnd != null) {
      segments.add(text.substring(i, matchEnd));
      i = matchEnd;
    } else {
      segments.add(text[i]);
      i++;
    }
  }
  return segments;
}

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  // Recorder state
  final isReady       = false.obs;
  final isRecording   = false.obs;
  final statusText    = ''.obs;

  // Segmentation data
  final segments           = <String>[].obs;
  final segmentVideos      = <String>[].obs;
  final hasFetchedSegments = false.obs;
  RxBool isPlaying = false.obs;

  // Internal recorder
  late final FlutterSoundRecorder _recorder;
  late String                     _filePath;

  // AssemblyAI config
  static const _apiKey        = '3f3696d6aedc4276b0dd072ffdf84341';
  static const _uploadUrl     = 'https://api.assemblyai.com/v2/upload';
  static const _transcriptUrl = 'https://api.assemblyai.com/v2/transcript';

  // Phrase trie & word set
  final PhraseTrie _trie     = PhraseTrie();
  final Set<String> _dbWords = {};
  bool _trieInitialized      = false;

  @override
  void onInit() {
    super.onInit();
    _recorder = FlutterSoundRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        'جاري تهيئة المسجل ...',
        TImages.initRecorderAnimation,
      );
      final dir = await getTemporaryDirectory();
      _filePath = p.join(dir.path, 'speech.m4a');
      if (!kIsWeb) {
        final micStatus = await Permission.microphone.request();
        if (micStatus != PermissionStatus.granted) {
          TFullScreenLoader.stopLoading();
          TLoaders.warningSnackBar(
            title: 'مطلوب الإذن',
            message: 'يرجى السماح للتطبيق بالوصول إلى الميكروفون.',
          );
          return;
        }
      }
      await _recorder.openRecorder();
      isReady.value = true;
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: 'جاهز',
        message: 'المسجل جاهز للاستخدام.',
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'خطأ في التهيئة',
        message: e.toString(),
      );
    }
  }

  Future<void> startRecording() async {
    if (!isReady.value) {
      await _initRecorder();
      if (!isReady.value) return;
    }
    try {
      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.aacMP4,
        sampleRate: 16000,
      );
      isRecording.value = true;
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'حصل خطأ!',
        message: e.toString(),
      );
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording.value) return;
    try {
      await _recorder.stopRecorder();
      isRecording.value = false;
      final file = File(_filePath);
      if (!await file.exists() || await file.length() < 500) {
        TLoaders.warningSnackBar(
          title: 'تحذير',
          message: 'التسجيل قصير جدًا أو غير موجود. حاول مرة أخرى.',
        );
        return;
      }
      await _transcribe();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'حصل خطأ!',
        message: e.toString(),
      );
    }
  }

  Future<void> _transcribe() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        'جاري تحويل الصوت إلى نص ...',
        TImages.recordingAnimation,
      );
      final bytes = await File(_filePath).readAsBytes();
      final upl = await http.post(
        Uri.parse(_uploadUrl),
        headers: {
          'authorization': _apiKey,
          'content-type':  'application/octet-stream',
        },
        body: bytes,
      );
      if (upl.statusCode != 200) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
          title: 'خطأ في الرفع',
          message: upl.body,
        );
        return;
      }
      final audioUrl = jsonDecode(upl.body)['upload_url'] as String;
      final tr = await http.post(
        Uri.parse(_transcriptUrl),
        headers: {
          'authorization': _apiKey,
          'content-type':  'application/json',
        },
        body: jsonEncode({
          'audio_url':     audioUrl,
          'speech_model':  'nano',
          'language_code': 'ar',
        }),
      );
      if (tr.statusCode != 200) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
          title: 'خطأ في التحويل',
          message: tr.body,
        );
        return;
      }
      final id = jsonDecode(tr.body)['id'] as String;
      String status, result = '';
      do {
        await Future.delayed(const Duration(seconds: 2));
        final poll = await http.get(
          Uri.parse('$_transcriptUrl/$id'),
          headers: {'authorization': _apiKey},
        );
        if (poll.statusCode != 200) {
          TFullScreenLoader.stopLoading();
          TLoaders.errorSnackBar(
            title: 'خطأ في الاستعلام',
            message: poll.body,
          );
          return;
        }
        final data = jsonDecode(poll.body);
        status = data['status'] as String;
        if (status == 'error') {
          TFullScreenLoader.stopLoading();
          TLoaders.errorSnackBar(
            title: 'فشل التحويل',
            message: data['error'] ?? 'Unknown error',
          );
          return;
        }
        if (status == 'completed') {
          result = data['text'] as String;
        }
      } while (status != 'completed');

      statusText.value = result;
      hasFetchedSegments.value = false;
      segments.value = [];
      segmentVideos.value = [];

      TFullScreenLoader.stopLoading();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'خطأ غير متوقع',
        message: e.toString(),
      );
    }
  }

  String _cleanArabicText(String text) {
    final onlyArabic = text.replaceAll(RegExp(r'[^\u0621-\u063A\u0641-\u064A\s]'), '');
    return onlyArabic.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _prepareSegmentsAndVideos(String text) async {
    final cleaned = _cleanArabicText(text);
    if (!_trieInitialized) {
      final snap = await FirebaseFirestore.instance
          .collection('signVideos')
          .get();
      for (var doc in snap.docs) {
        final word = doc['word'] as String;
        _trie.insert(word);
        _dbWords.add(word);
      }
      _trieInitialized = true;
    }
    final parts = segmentText(cleaned, _trie);
    segments.value = parts;

    final urls = <String>[];
    for (var seg in parts) {
      if (seg.length == 1 && _dbWords.contains(seg)) {
        urls.add('assets/videos/letters/$seg.mp4');
      } else if (_dbWords.contains(seg)) {
        urls.add('assets/videos/$seg.mp4');
      } else {
        segmentVideos.value = [];
        return;
      }
    }
    segmentVideos.value = urls;
  }

  /// Called by the arrow button to commit edited text and fetch videos
  Future<void> updateSegmentsFromText(String newText) async {
    statusText.value = newText;
    hasFetchedSegments.value = false;
    segments.value = [];
    segmentVideos.value = [];
    await _prepareSegmentsAndVideos(newText);
    hasFetchedSegments.value = true;
  }

  void resetAll() {
    statusText.value = '';
    hasFetchedSegments.value = false;
    segments.clear();
    segmentVideos.clear();
    isPlaying.value = false;
  }

  @override
  void onClose() {
    _recorder.closeRecorder();
    super.onClose();
  }
}
