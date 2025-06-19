// lib/features/authentication/screens/home/home_screen.dart

import 'dart:io';

import 'package:audio_to_sign_language/features/authentication/controllers/home/home_controller.dart';
import 'package:audio_to_sign_language/utils/constants/image_strings.dart';
import 'package:audio_to_sign_language/utils/constants/sizes.dart';
import 'package:audio_to_sign_language/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  late final TextEditingController _textController;

  late final Worker _textWorker;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textWorker = ever(controller.statusText, (String newText) {
      if (!mounted) return;
      _textController.text = newText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    });
  }

  @override
  void dispose() {
    _textWorker.dispose(); // Cancel the reactive listener
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Center(child: Text("الصفحة الرئيسية"))),
        body: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Video / Placeholder area
              Expanded(
                flex: 3,
                child: Obx(() {
                  final text = controller.statusText.value;
                  final fetched = controller.hasFetchedSegments.value;
                  final videos = controller.segmentVideos;
                  if (text.isEmpty) {
                    return Center(
                      child: FractionallySizedBox(
                        heightFactor: 0.9,
                        widthFactor: 0.9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image(image: AssetImage(TImages.video)),
                        ),
                      ),
                    );
                  }
                  if (!fetched) {
                    return Center(
                      child: Text(
                        'اضغط على السهم لتحميل الفيديوهات',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }
                  if (videos.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد فيديوات لعرضها لاحتواء النص على جزء غير مدعوم',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }
                  return _VideoPlaylist(videos: videos);
                }),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Mic / Arrow + editable field
              SafeArea(
                top: false,
                child: Row(
                  children: [
                    Obx(() {
                      final hasText = controller.statusText.value.isNotEmpty;
                      final isPlaying = controller.isPlaying.value;
                      final isRecording = controller.isRecording.value;

                      if (isPlaying) {
                        return IconButton(
                          iconSize: 32,
                          color: theme.colorScheme.primary,
                          onPressed: null,
                          icon: const Icon(Icons.mic_outlined),
                        );
                      }

                      if (!hasText) {
                        return IconButton(
                          iconSize: 32,
                          color:
                              isRecording
                                  ? theme.colorScheme.primary
                                  : theme.iconTheme.color,
                          onPressed:
                              isRecording
                                  ? controller.stopRecording
                                  : controller.startRecording,
                          icon: Icon(
                            isRecording ? Icons.mic_off : Icons.mic_outlined,
                          ),
                        );
                      }

                      // Text exists → show arrow to update segments
                      return IconButton(
                        iconSize: 32,
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          final text = _textController.text;
                          final isArabicOnly = RegExp(
                            r'^[\u0600-\u06FF\s]+$',
                          ).hasMatch(text);
                          if (!isArabicOnly) {
                            TLoaders.warningSnackBar(
                              title: 'تنبيه',
                              message: 'يرجى إدخال نص عربي فقط.',
                            );
                            return;
                          }
                          controller.updateSegmentsFromText(text);
                        },
                        icon: const Icon(Icons.arrow_back),
                      );
                    }),
                    const SizedBox(width: TSizes.spaceBtwItems / 2),
                    Expanded(
                      child: Obx(() {
                        final readOnly = controller.statusText.value.isEmpty;
                        final isDisabled = controller.isPlaying.value;
                        return TextField(
                          controller: _textController,
                          readOnly: readOnly,
                          enabled: !isDisabled,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                            suffixIcon:
                                controller.statusText.value.isNotEmpty &&
                                        !controller.isPlaying.value
                                    ? IconButton(
                                      icon: const Icon(Icons.close),
                                      color: theme.colorScheme.primary,
                                      onPressed: () {
                                        _textController.clear();
                                        controller.resetAll();
                                      },
                                    )
                                    : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPlaylist extends StatefulWidget {
  final List<String> videos;
  const _VideoPlaylist({required this.videos});

  @override
  State<_VideoPlaylist> createState() => _VideoPlaylistState();
}

class _VideoPlaylistState extends State<_VideoPlaylist> {
  VideoPlayerController? _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAndPlay(_currentIndex);
  }

  Future<void> _loadAndPlay(int index) async {
    final url = widget.videos[index];
    debugPrint('loading video: $url');

    if (_controller != null) {
      _controller!
        ..removeListener(_onVideoUpdate)
        ..pause();
      await _controller!.dispose();
    }

    final data = await rootBundle.load(url);
    final bytes = data.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${url.split('/').last}');
    if (!await file.exists()) {
      await file.writeAsBytes(bytes, flush: true);
    }

    final newCtrl =
        VideoPlayerController.file(file)
          ..setLooping(false)
          ..addListener(_onVideoUpdate);

    _controller = newCtrl;
    try {
      await newCtrl.initialize();
      HomeController.instance.isPlaying.value = true;
      if (!mounted || _controller != newCtrl) return;
      setState(() {});
      newCtrl.play();
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _onVideoUpdate() {
    final c = _controller;
    if (c == null) return;
    final pos = c.value.position;
    final dur = c.value.duration;
    if (pos >= dur && !c.value.isPlaying) {
      _playNext();
    }
  }

  void _playNext() async {
    if (_controller != null) {
      _controller!
        ..removeListener(_onVideoUpdate)
        ..pause();
      await _controller!.dispose();
    }
    if (_currentIndex + 1 < widget.videos.length) {
      _currentIndex++;
      await _loadAndPlay(_currentIndex);
    } else {
      // last video done → reset everything
      Get.find<HomeController>().resetAll();
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!
        ..removeListener(_onVideoUpdate)
        ..pause()
        ..dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final currentWord =
        widget.videos[_currentIndex].split('/').last.split('.').first;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c)),
        SizedBox(height: 10),
        Text(
          currentWord,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
