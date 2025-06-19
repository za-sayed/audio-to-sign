// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:audio_to_sign_language/features/authentication/controllers/learning_section/learning_section_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_to_sign_language/utils/constants/image_strings.dart';


class LearningSection extends StatelessWidget {
  const LearningSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LearningController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('قسم التعلم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: _CustomSearch(controller.videos),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final items = controller.videos;
        if (items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8
            ),
            itemBuilder: (ctx, i) {
              final word = items[i];
              final assetPath = word.length == 1
                  ? 'assets/videos/letters/$word.mp4'
                  : 'assets/videos/$word.mp4';
              return _VideoTile(word: word, assetPath: assetPath);
            },
          ),
        );
      }),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final String word;
  final String assetPath;
  const _VideoTile({required this.word, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showVideoDialog(context, word, assetPath),
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(TImages.video),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(Icons.play_circle_fill, size: 50, color: Colors.white.withOpacity(0.9)),
            ),
          ),
          const SizedBox(height: 8),
          Text(word, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _CustomSearch extends SearchDelegate {
  final RxList<String> items;
  _CustomSearch(this.items);

  @override List<Widget>? buildActions(BuildContext c) => [ IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '' ) ];
  @override Widget? buildLeading(BuildContext c) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(c, null));
  @override Widget buildResults(BuildContext c) => _buildGrid(c);
  @override Widget buildSuggestions(BuildContext c) => _buildGrid(c);

  Widget _buildGrid(BuildContext c) {
    final filtered = items.where((w) => w.toLowerCase().contains(query.toLowerCase())).toList();
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8
      ),
      itemBuilder: (ctx, i) {
        final word = filtered[i];
        final assetPath = word.length == 1
            ? 'assets/videos/letters/$word.mp4'
            : 'assets/videos/$word.mp4';
        return _VideoTile(word: word, assetPath: assetPath);
      },
    );
  }
}

class _VideoPlayerPopup extends StatefulWidget {
  final String assestpath, title;
  const _VideoPlayerPopup({required this.assestpath, required this.title});

  @override State<_VideoPlayerPopup> createState() => _VideoPlayerPopupState();
}

class _VideoPlayerPopupState extends State<_VideoPlayerPopup> {
  late VideoPlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.file(File(widget.assestpath))
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _ctrl.play();
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    return SizedBox(
      width: 300, height: 300,
      child: Column(
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _ctrl.value.isInitialized
            ? AspectRatio(aspectRatio: _ctrl.value.aspectRatio, child: VideoPlayer(_ctrl))
            : const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

void _showVideoDialog(BuildContext context, String title, String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List();
  final dir = await getTemporaryDirectory();
  final tempFile = File('${dir.path}/${assetPath.split('/').last}');
  if (!await tempFile.exists()) {
    await tempFile.writeAsBytes(bytes, flush: true);
  }

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: _VideoPlayerPopup(assestpath: tempFile.path, title: title),
    ),
  );
}