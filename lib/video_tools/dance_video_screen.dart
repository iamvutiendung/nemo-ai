import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/app_top_bar.dart';
import '../widgets/video_history_panel.dart';
import '../widgets/ai_loading_overlay.dart';
import '../models/video_job.dart';
import '../services/video_service.dart';
import '../services/ai_service.dart';
import '../services/user_credit_service.dart';

class DanceVideoScreen extends StatefulWidget {
  const DanceVideoScreen({super.key});

  @override
  State<DanceVideoScreen> createState() => _DanceVideoScreenState();
}

class _DanceVideoScreenState extends State<DanceVideoScreen> {
  final GlobalKey<VideoHistoryPanelState> historyKey = GlobalKey();

  final TextEditingController promptController = TextEditingController(
    text:
    'Tạo video dance chân thực từ ảnh nhân vật. Giữ nguyên khuôn mặt, dáng người, trang phục. Chuyển động mượt, ánh sáng đẹp, camera cinematic, không bị méo mặt, không lỗi tay chân.',
  );

  Uint8List? characterImageBytes;
  String? characterImageName;

  String? motionVideoName;

  Uint8List? generatedPreviewBytes;

  bool isGenerating = false;
  int progress = 0;

  String selectedRatio = '9:16';
  String selectedResolution = '1080p';
  String selectedDuration = '20s';
  String selectedServer = 'VIP 01';
  String selectedMode = 'Motion Control';

  String? generatedVideoUrl;
  VideoPlayerController? generatedVideoController;

  Future<void> _pickCharacterImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() {
      characterImageBytes = result.files.single.bytes;
      characterImageName = result.files.single.name;
    });
  }

  Future<void> _pickMotionVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null) return;

    setState(() {
      motionVideoName = result.files.single.name;
    });
  }

  void _removeCharacterImage() {
    setState(() {
      characterImageBytes = null;
      characterImageName = null;
    });
  }

  void _removeMotionVideo() {
    setState(() {
      motionVideoName = null;
    });
  }

  Future<void> _loadGeneratedVideo(String url) async {
    await generatedVideoController?.dispose();

    generatedVideoController = VideoPlayerController.networkUrl(
      Uri.parse(url),
    );

    await generatedVideoController!.initialize();

    generatedVideoController!
      ..setVolume(1.0)
      ..setLooping(true)
      ..play();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _downloadGeneratedVideo() async {
    if (generatedVideoUrl == null || generatedVideoUrl!.isEmpty) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/dance_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await Dio().download(
        generatedVideoUrl!,
        filePath,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tải video về: $filePath')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải video: $e')),
      );
    }
  }

  Future<void> _generateDanceVideo() async {
    if (promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập prompt đã bro')),
      );
      return;
    }

    final success = await UserCreditService.spendCredits(35);

    if (!success) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Không đủ Credits'),
        ),
      );

      return;
    }

    setState(() {
      isGenerating = true;
      progress = 10;
    });

    try {
      final result = await AiService.generateVideo(
        prompt: promptController.text.trim(),
      );

      generatedVideoUrl = result;

      for (int i = 10; i <= 100; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        if (!mounted) return;

        setState(() {
          progress = i;
        });
      }

      await _loadGeneratedVideo(result);

      if (!mounted) return;

      setState(() {
        isGenerating = false;
        progress = 100;
        generatedPreviewBytes = characterImageBytes;
        generatedVideoUrl = result;
      });

      await VideoService.addJob(
        VideoJob(
          title: 'AI Dance Video',
          prompt: promptController.text,
          duration: selectedDuration,
          resolution: selectedResolution,
          date: DateTime.now().toString(),
          status: 'Done',
          videoUrl: result,
        ),
      );

      await historyKey.currentState?.refresh();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI trả về: $result')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isGenerating = false;
        progress = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gọi AI: $e')),
      );
    }
  }

  Widget _uploadImageBox() {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8B5CF6)),
      ),
      child: characterImageBytes != null
          ? Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(
                characterImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: InkWell(
              onTap: _removeCharacterImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                characterImageName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      )
          : InkWell(
        onTap: _pickCharacterImage,
        borderRadius: BorderRadius.circular(18),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              color: Color(0xFFA78BFA),
              size: 48,
            ),
            SizedBox(height: 14),
            Text(
              'Upload ảnh nhân vật',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Bắt buộc: ảnh người cần tạo video nhảy',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadVideoBox() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: motionVideoName != null
          ? Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.video_library_outlined,
                  color: Colors.white70,
                  size: 42,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Video chuyển động đã chọn',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    motionVideoName!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: InkWell(
              onTap: _removeMotionVideo,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      )
          : InkWell(
        onTap: _pickMotionVideo,
        borderRadius: BorderRadius.circular(18),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_outlined,
              color: Color(0xFFFF7A1A),
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'Upload video chuyển động',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Bắt buộc: video mẫu nhảy / chuyển động',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF111827),
          iconEnabledColor: Colors.white70,
          style: const TextStyle(color: Colors.white),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _chip(String text, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF8B5CF6) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xFF8B5CF6) : Colors.white12,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _settingPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thiết lập dance video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chế độ tạo',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(
                'Motion Control',
                selectedMode == 'Motion Control',
                    () => setState(() => selectedMode = 'Motion Control'),
              ),
              _chip(
                'Dance Template',
                selectedMode == 'Dance Template',
                    () => setState(() => selectedMode = 'Dance Template'),
              ),
              _chip(
                'Body Sync',
                selectedMode == 'Body Sync',
                    () => setState(() => selectedMode = 'Body Sync'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  value: selectedRatio,
                  items: const ['9:16', '16:9', '1:1'],
                  onChanged: (v) => setState(() => selectedRatio = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdown(
                  value: selectedResolution,
                  items: const ['720p', '1080p', '2K', '4K'],
                  onChanged: (v) => setState(() => selectedResolution = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  value: selectedDuration,
                  items: const ['10s', '20s', '30s', '60s'],
                  onChanged: (v) => setState(() => selectedDuration = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdown(
                  value: selectedServer,
                  items: const ['VIP 01', 'VIP 02', 'Free'],
                  onChanged: (v) => setState(() => selectedServer = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewBox(String title, {Uint8List? imageBytes}) {
    return Expanded(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: imageBytes != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.memory(imageBytes, fit: BoxFit.cover),
        )
            : Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_outline,
                color: Colors.white.withValues(alpha: 0.35),
                size: 64,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _videoPlayerBox() {
    if (generatedVideoController == null ||
        !generatedVideoController!.value.isInitialized) {
      return _previewBox('Dance video preview');
    }

    return Expanded(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: generatedVideoController!.value.aspectRatio,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      generatedVideoController!.value.isPlaying
                          ? generatedVideoController!.pause()
                          : generatedVideoController!.play();
                    });
                  },
                  child: VideoPlayer(generatedVideoController!),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      generatedVideoController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFF8B5CF6),
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              generatedVideoController!.value.isPlaying
                                  ? generatedVideoController!.pause()
                                  : generatedVideoController!.play();
                            });
                          },
                          icon: Icon(
                            generatedVideoController!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: _downloadGeneratedVideo,
                          icon: const Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  backgroundColor: Colors.black,
                                  body: Center(
                                    child: AspectRatio(
                                      aspectRatio: generatedVideoController!
                                          .value.aspectRatio,
                                      child: VideoPlayer(
                                        generatedVideoController!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
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

  Widget _mainContentWide() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 430,
          child: Column(
            children: [
              _uploadImageBox(),
              const SizedBox(height: 16),
              _uploadVideoBox(),
              const SizedBox(height: 16),
              _settingPanel(),
            ],
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: promptController,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập prompt dance video...',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _previewBox(
                    'Preview sẽ hiện sau khi tạo',
                    imageBytes: generatedPreviewBytes,
                  ),
                  const SizedBox(width: 16),
                  _videoPlayerBox(),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: isGenerating ? null : _generateDanceVideo,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    isGenerating
                        ? 'Đang tạo dance video... $progress%'
                        : 'Tạo Dance Video AI  ✨ 35',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mainContentMobile() {
    return Column(
      children: [
        _uploadImageBox(),
        const SizedBox(height: 16),
        _uploadVideoBox(),
        const SizedBox(height: 16),
        _settingPanel(),
        const SizedBox(height: 16),
        TextField(
          controller: promptController,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFF0F172A),
            hintText: 'Nhập prompt dance video...',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 18),
        _videoPlayerBox(),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isGenerating ? null : _generateDanceVideo,
            child: Text(
              isGenerating
                  ? 'Đang tạo... $progress%'
                  : 'Tạo Dance Video AI  ✨ 35',
            ),
          ),
        ),
        const SizedBox(height: 20),
        VideoHistoryPanel(
          key: historyKey,
          onTapJob: (job) async {
            setState(() {
              generatedVideoUrl = job.videoUrl;
              promptController.text = job.prompt;
            });

            if (job.videoUrl.isNotEmpty) {
              await _loadGeneratedVideo(job.videoUrl);
              generatedVideoController?.play();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    promptController.dispose();
    generatedVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050914),
      body: Stack(
        children: [
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const AppTopBar(
                        activeMenu: 'video',
                        isLoggedIn: true,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 22, 28, 40),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1500),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF1A102E),
                                          Color(0xFF111827),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: const Color(0xFF3E2C73),
                                      ),
                                    ),
                                    child: const Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AI Dance Video',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tải ảnh nhân vật và video chuyển động mẫu. Nemo AI tạo video nhảy tự nhiên theo motion.',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (constraints.maxWidth > 950) {
                                        return _mainContentWide();
                                      }
                                      return _mainContentMobile();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                VideoHistoryPanel(
                  key: historyKey,
                  onTapJob: (job) async {
                    setState(() {
                      generatedVideoUrl = job.videoUrl;
                      promptController.text = job.prompt;
                    });

                    if (job.videoUrl.isNotEmpty) {
                      await _loadGeneratedVideo(job.videoUrl);
                      generatedVideoController?.play();
                    }
                  },
                ),
              ],
            ),
          ),
          AiLoadingOverlay(
            visible: isGenerating,
            title: 'AI đang tạo dance video...',
            subtitle:
            'Nemo đang xử lý ảnh nhân vật, video mẫu, chuyển động và preview.',
            progress: progress,
          ),
        ],
      ),
    );
  }
}