import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/app_top_bar.dart';
import '../widgets/video_history_panel.dart';
import '../widgets/ai_loading_overlay.dart';
import '../models/video_job.dart';
import '../services/video_service.dart';
import '../services/ai_service.dart';
import '../services/user_credit_service.dart';

class FashionSelfieVideoScreen extends StatefulWidget {
  const FashionSelfieVideoScreen({super.key});

  @override
  State<FashionSelfieVideoScreen> createState() =>
      _FashionSelfieVideoScreenState();
}

class _FashionSelfieVideoScreenState extends State<FashionSelfieVideoScreen> {
  final GlobalKey<VideoHistoryPanelState> historyKey = GlobalKey();

  final TextEditingController promptController = TextEditingController(
    text:
    'Create a realistic selfie fashion video. The model naturally holds and presents the clothing product, smooth hand movement, phone camera style, realistic lighting, vertical 9:16 video.',
  );

  Uint8List? productImageBytes;
  String? productImageName;

  Uint8List? modelImageBytes;
  String? modelImageName;

  Uint8List? generatedPreviewBytes;

  bool isGenerating = false;
  int progress = 0;

  String selectedRatio = '9:16';
  String selectedResolution = '1080p';
  String selectedDuration = '10s';
  String selectedServer = 'VIP 01';

  String? generatedVideoUrl;
  VideoPlayerController? generatedVideoController;

  Future<void> _loadGeneratedVideo(String url) async {
    await generatedVideoController?.dispose();

    generatedVideoController = VideoPlayerController.networkUrl(
      Uri.parse(url),
    );

    await generatedVideoController!.initialize();

    generatedVideoController!
      ..setLooping(true)
      ..play();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _downloadGeneratedVideo() async {
    if (generatedVideoUrl == null || generatedVideoUrl!.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng tải video sẽ làm ở bước sau'),
      ),
    );
  }

  Future<void> _pickProductImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() {
      productImageBytes = result.files.single.bytes;
      productImageName = result.files.single.name;
    });
  }

  Future<void> _pickModelImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() {
      modelImageBytes = result.files.single.bytes;
      modelImageName = result.files.single.name;
    });
  }

  void _removeProductImage() {
    setState(() {
      productImageBytes = null;
      productImageName = null;
    });
  }

  void _removeModelImage() {
    setState(() {
      modelImageBytes = null;
      modelImageName = null;
    });
  }

  Future<void> _generateVideo() async {
    if (productImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần tải ảnh sản phẩm trước')),
      );
      return;
    }

    final success = await UserCreditService.spendCredits(25);

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
      progress = 0;
    });

    try {
      for (int i = 1; i <= 5; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        setState(() {
          progress = i * 20;
        });
      }

      final result = await AiService.generateVideo(
        prompt: promptController.text.trim(),
      );

      generatedVideoUrl = result;

      await _loadGeneratedVideo(result);

      if (!mounted) return;

      setState(() {
        isGenerating = false;
        progress = 100;
        generatedPreviewBytes = productImageBytes;
        generatedVideoUrl = result;
      });

      await VideoService.addJob(
        VideoJob(
          title: 'Fashion Selfie',
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
        const SnackBar(content: Text('Đã tạo video selfie demo')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isGenerating = false;
        progress = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo video: $e')),
      );
    }
  }

  Widget _uploadBox({
    required String title,
    required String subtitle,
    required Uint8List? imageBytes,
    required String? fileName,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    bool requiredBox = false,
  }) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: requiredBox ? const Color(0xFF8B5CF6) : Colors.white24,
        ),
      ),
      child: imageBytes != null
          ? Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: InkWell(
              onTap: onRemove,
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
                fileName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      )
          : InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_rounded,
              color: Color(0xFFA78BFA),
              size: 46,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
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

  Widget _videoPreviewBox(String title) {
    return Expanded(
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.movie_creation_outlined,
                color: Colors.white.withValues(alpha: 0.35),
                size: 58,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 86),
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
            if (isGenerating)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 14),
                        Text(
                          'Đang tạo... $progress%',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _videoPlayerBox() {
    if (generatedVideoController == null ||
        !generatedVideoController!.value.isInitialized) {
      return _videoPreviewBox('Video Preview');
    }

    return Expanded(
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                child: Row(
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
                      ),
                    ),
                    IconButton(
                      onPressed: _downloadGeneratedVideo,
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                      ),
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
            'Thiết lập video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
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
                  items: const ['5s', '10s', '15s', '20s'],
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

  Widget _mainContentWide() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 430,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _uploadBox(
                title: 'Upload ảnh sản phẩm',
                subtitle: 'Bắt buộc: ảnh quần áo / phụ kiện / sản phẩm',
                imageBytes: productImageBytes,
                fileName: productImageName,
                onPick: _pickProductImage,
                onRemove: _removeProductImage,
                requiredBox: true,
              ),
              const SizedBox(height: 16),
              _uploadBox(
                title: 'Upload ảnh mẫu',
                subtitle: 'Có thể bỏ trống, AI sẽ tự chọn mẫu phù hợp',
                imageBytes: modelImageBytes,
                fileName: modelImageName,
                onPick: _pickModelImage,
                onRemove: _removeModelImage,
              ),
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
                height: 230,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: generatedPreviewBytes != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    generatedPreviewBytes!,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Center(
                  child: Text(
                    'Image will appear here',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: promptController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập prompt video...',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _videoPlayerBox(),
                  const SizedBox(width: 16),
                  _videoPreviewBox('Video Preview 02'),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isGenerating ? null : _generateVideo,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    isGenerating
                        ? 'Đang tạo video... $progress%'
                        : 'Tạo Video Selfie AI  ✨ 25',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A1A),
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
        _uploadBox(
          title: 'Upload ảnh sản phẩm',
          subtitle: 'Bắt buộc',
          imageBytes: productImageBytes,
          fileName: productImageName,
          onPick: _pickProductImage,
          onRemove: _removeProductImage,
          requiredBox: true,
        ),
        const SizedBox(height: 16),
        _uploadBox(
          title: 'Upload ảnh mẫu',
          subtitle: 'Có thể bỏ trống',
          imageBytes: modelImageBytes,
          fileName: modelImageName,
          onPick: _pickModelImage,
          onRemove: _removeModelImage,
        ),
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
            hintText: 'Nhập prompt video...',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _videoPlayerBox(),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isGenerating ? null : _generateVideo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A1A),
              foregroundColor: Colors.white,
            ),
            child: Text(
              isGenerating
                  ? 'Đang tạo... $progress%'
                  : 'Tạo Video Selfie AI  ✨ 25',
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
                                          'AI Video Thời Trang Selfie',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tải ảnh sản phẩm, có thể thêm ảnh mẫu. AI tạo video selfie thời trang dạng TikTok/Reels.',
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
            title: 'AI đang tạo video...',
            subtitle:
            'Nemo đang xử lý ảnh sản phẩm, ảnh mẫu, prompt và preview.',
            progress: progress,
          ),
        ],
      ),
    );
  }
}