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

class ReviewProductVideoScreen extends StatefulWidget {
  const ReviewProductVideoScreen({super.key});

  @override
  State<ReviewProductVideoScreen> createState() =>
      _ReviewProductVideoScreenState();
}

class _ReviewProductVideoScreenState extends State<ReviewProductVideoScreen> {
  final GlobalKey<VideoHistoryPanelState> historyKey = GlobalKey();

  final TextEditingController promptController = TextEditingController(
    text:
    'Tạo video review sản phẩm chân thực như quay bằng điện thoại 4K. Người mẫu cầm sản phẩm, giới thiệu tự nhiên, ánh sáng đẹp, chuyển động mượt, không bị nhựa.',
  );

  Uint8List? modelImageBytes;
  String? modelImageName;

  Uint8List? productImageBytes;
  String? productImageName;

  Uint8List? backgroundImageBytes;
  String? backgroundImageName;

  Uint8List? generatedPreviewBytes;

  bool isGenerating = false;
  int progress = 0;

  String selectedRatio = '9:16';
  String selectedResolution = '1080p';
  String selectedDuration = '20s';
  String selectedServer = 'VIP 01';
  String selectedVoice = 'Nữ trẻ';
  String selectedLanguage = 'VN';

  String? generatedVideoUrl;
  VideoPlayerController? generatedVideoController;

  Future<void> _pickImage(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() {
      if (type == 'model') {
        modelImageBytes = result.files.single.bytes;
        modelImageName = result.files.single.name;
      } else if (type == 'product') {
        productImageBytes = result.files.single.bytes;
        productImageName = result.files.single.name;
      } else {
        backgroundImageBytes = result.files.single.bytes;
        backgroundImageName = result.files.single.name;
      }
    });
  }

  void _removeImage(String type) {
    setState(() {
      if (type == 'model') {
        modelImageBytes = null;
        modelImageName = null;
      } else if (type == 'product') {
        productImageBytes = null;
        productImageName = null;
      } else {
        backgroundImageBytes = null;
        backgroundImageName = null;
      }
    });
  }

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

  Future<void> _generateReviewVideo() async {
    if (productImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần tải ảnh sản phẩm trước')),
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
      progress = 0;
    });

    try {
      for (int i = 1; i <= 100; i++) {
        await Future.delayed(const Duration(milliseconds: 25));
        if (!mounted) return;

        setState(() {
          progress = i;
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
      });

      await VideoService.addJob(
        VideoJob(
          title: 'AI Review Sản phẩm',
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
        const SnackBar(content: Text('Đã tạo video review sản phẩm demo')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isGenerating = false;
        progress = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo video review: $e')),
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
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: requiredBox ? const Color(0xFFFF7A1A) : Colors.white24,
        ),
      ),
      child: imageBytes != null
          ? Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(imageBytes, fit: BoxFit.cover),
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
              Icons.add_photo_alternate_outlined,
              color: Color(0xFFFF7A1A),
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
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
                  fontSize: 12,
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

  Widget _chip(String text, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF7A1A) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xFFFF7A1A) : Colors.white12,
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

  Widget _previewBox(String title, {Uint8List? imageBytes}) {
    return Expanded(
      child: Container(
        height: 230,
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
                Icons.movie_creation_outlined,
                color: Colors.white.withValues(alpha: 0.35),
                size: 58,
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
      return _previewBox('Video Preview');
    }

    return Expanded(
      child: Container(
        height: 230,
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
                child: IconButton(
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
            'Thiết lập kịch bản review',
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
          const SizedBox(height: 16),
          const Text(
            'Ngôn ngữ thoại',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(
                'VN',
                selectedLanguage == 'VN',
                    () => setState(() => selectedLanguage = 'VN'),
              ),
              _chip(
                'EN',
                selectedLanguage == 'EN',
                    () => setState(() => selectedLanguage = 'EN'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Giọng đọc',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(
                'Nữ trẻ',
                selectedVoice == 'Nữ trẻ',
                    () => setState(() => selectedVoice = 'Nữ trẻ'),
              ),
              _chip(
                'Nam trẻ',
                selectedVoice == 'Nam trẻ',
                    () => setState(() => selectedVoice = 'Nam trẻ'),
              ),
              _chip(
                'Bán hàng',
                selectedVoice == 'Bán hàng',
                    () => setState(() => selectedVoice = 'Bán hàng'),
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
            children: [
              _uploadBox(
                title: 'Upload ảnh người mẫu',
                subtitle: 'Có thể bỏ trống, AI tự chọn người mẫu phù hợp',
                imageBytes: modelImageBytes,
                fileName: modelImageName,
                onPick: () => _pickImage('model'),
                onRemove: () => _removeImage('model'),
              ),
              const SizedBox(height: 16),
              _uploadBox(
                title: 'Upload ảnh sản phẩm',
                subtitle: 'Bắt buộc: ảnh sản phẩm cần review',
                imageBytes: productImageBytes,
                fileName: productImageName,
                onPick: () => _pickImage('product'),
                onRemove: () => _removeImage('product'),
                requiredBox: true,
              ),
              const SizedBox(height: 16),
              _uploadBox(
                title: 'Upload ảnh bối cảnh',
                subtitle: 'Có thể bỏ trống, AI tự chọn background',
                imageBytes: backgroundImageBytes,
                fileName: backgroundImageName,
                onPick: () => _pickImage('background'),
                onRemove: () => _removeImage('background'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _settingPanel(),
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
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập nội dung review sản phẩm...',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _previewBox(
                    'Image will appear after generate',
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
                  onPressed: isGenerating ? null : _generateReviewVideo,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    isGenerating
                        ? 'Đang tạo video... $progress%'
                        : 'Tạo Video Review AI  ✨ 35',
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
          onPick: () => _pickImage('product'),
          onRemove: () => _removeImage('product'),
          requiredBox: true,
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
            hintText: 'Nhập nội dung review sản phẩm...',
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
            onPressed: isGenerating ? null : _generateReviewVideo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A1A),
              foregroundColor: Colors.white,
            ),
            child: Text(
              isGenerating
                  ? 'Đang tạo... $progress%'
                  : 'Tạo Video Review AI  ✨ 35',
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
                                          'AI Review Sản Phẩm',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tải ảnh người mẫu, ảnh sản phẩm và bối cảnh. Nemo AI tạo video review bán hàng chuyên nghiệp.',
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
            title: 'AI đang tạo video review...',
            subtitle:
            'Nemo đang xử lý người mẫu, sản phẩm, bối cảnh, giọng đọc và preview.',
            progress: progress,
          ),
        ],
      ),
    );
  }
}