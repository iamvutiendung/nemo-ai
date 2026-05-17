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

class BrandAdsVideoScreen extends StatefulWidget {
  const BrandAdsVideoScreen({super.key});

  @override
  State<BrandAdsVideoScreen> createState() => _BrandAdsVideoScreenState();
}

class _BrandAdsVideoScreenState extends State<BrandAdsVideoScreen> {
  final GlobalKey<VideoHistoryPanelState> historyKey = GlobalKey();

  final TextEditingController promptController = TextEditingController(
    text:
    'Tạo video quảng cáo thương hiệu chuyên nghiệp, người đại diện giới thiệu dịch vụ tự nhiên, ánh sáng đẹp, chuyển động mượt, phong cách TikTok/Reels, nhìn như quay bằng điện thoại 4K.',
  );

  Uint8List? actorImageBytes;
  String? actorImageName;

  Uint8List? productImageBytes;
  String? productImageName;

  Uint8List? backgroundImageBytes;
  String? backgroundImageName;

  Uint8List? generatedPreviewBytes;

  bool isGenerating = false;
  int progress = 0;

  String? generatedVideoUrl;
  VideoPlayerController? generatedVideoController;

  String selectedRatio = '9:16';
  String selectedResolution = '1080p';
  String selectedDuration = '20s';
  String selectedServer = 'VIP 01';
  String selectedVoice = 'Nữ trẻ';
  String selectedTone = 'Chuyên nghiệp';

  Future<void> _pickImage(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() {
      if (type == 'actor') {
        actorImageBytes = result.files.single.bytes;
        actorImageName = result.files.single.name;
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
      if (type == 'actor') {
        actorImageBytes = null;
        actorImageName = null;
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

  Future<void> _generateBrandAdsVideo() async {
    if (productImageBytes == null && actorImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần tải ít nhất ảnh nhân vật hoặc ảnh sản phẩm'),
        ),
      );
      return;
    }

    final success = await UserCreditService.spendCredits(20);

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
      generatedPreviewBytes = productImageBytes ?? actorImageBytes;
    });

    await VideoService.addJob(
      VideoJob(
        title: 'AI Quảng Cáo Thương Hiệu',
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
      const SnackBar(content: Text('Đã tạo video quảng cáo demo')),
    );
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
              Icons.campaign_outlined,
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
            'Thiết lập quảng cáo',
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
          const Text('Tone quảng cáo', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(
                'Chuyên nghiệp',
                selectedTone == 'Chuyên nghiệp',
                    () => setState(() => selectedTone = 'Chuyên nghiệp'),
              ),
              _chip(
                'Cao cấp',
                selectedTone == 'Cao cấp',
                    () => setState(() => selectedTone = 'Cao cấp'),
              ),
              _chip(
                'Bán hàng mạnh',
                selectedTone == 'Bán hàng mạnh',
                    () => setState(() => selectedTone = 'Bán hàng mạnh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Giọng đọc', style: TextStyle(color: Colors.white70)),
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
                'MC quảng cáo',
                selectedVoice == 'MC quảng cáo',
                    () => setState(() => selectedVoice = 'MC quảng cáo'),
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
                Icons.play_circle_outline,
                color: Colors.white.withValues(alpha: 0.55),
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
      return _previewBox('Video quảng cáo preview');
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
          child: AspectRatio(
            aspectRatio: generatedVideoController!.value.aspectRatio,
            child: VideoPlayer(generatedVideoController!),
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
              _uploadBox(
                title: 'Upload ảnh nhân vật',
                subtitle: 'Người đại diện, mascot, KOL hoặc avatar thương hiệu',
                imageBytes: actorImageBytes,
                fileName: actorImageName,
                onPick: () => _pickImage('actor'),
                onRemove: () => _removeImage('actor'),
              ),
              const SizedBox(height: 16),
              _uploadBox(
                title: 'Upload ảnh sản phẩm / dịch vụ',
                subtitle: 'Ảnh sản phẩm, logo, dịch vụ hoặc banner thương hiệu',
                imageBytes: productImageBytes,
                fileName: productImageName,
                onPick: () => _pickImage('product'),
                onRemove: () => _removeImage('product'),
                requiredBox: true,
              ),
              const SizedBox(height: 16),
              _uploadBox(
                title: 'Upload ảnh bối cảnh',
                subtitle: 'Có thể bỏ trống, AI tự chọn background quảng cáo',
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
                    hintText: 'Nhập nội dung quảng cáo thương hiệu...',
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
                  onPressed: isGenerating ? null : _generateBrandAdsVideo,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    isGenerating
                        ? 'Đang tạo video... $progress%'
                        : 'Tạo Video Quảng Cáo AI  ✨ 20',
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
          title: 'Upload ảnh sản phẩm / dịch vụ',
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
            hintText: 'Nhập nội dung quảng cáo...',
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
            onPressed: isGenerating ? null : _generateBrandAdsVideo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A1A),
              foregroundColor: Colors.white,
            ),
            child: Text(
              isGenerating
                  ? 'Đang tạo... $progress%'
                  : 'Tạo Video Quảng Cáo AI  ✨ 20',
            ),
          ),
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
                                          'AI Quảng Cáo Dịch Vụ / Thương Hiệu',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tải ảnh nhân vật, sản phẩm và bối cảnh. Nemo AI tạo video quảng cáo thương hiệu chuyên nghiệp.',
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
                    }
                  },
                ),
              ],
            ),
          ),
          AiLoadingOverlay(
            visible: isGenerating,
            title: 'AI đang tạo video quảng cáo...',
            subtitle:
            'Nemo đang xử lý nhân vật, sản phẩm, bối cảnh, nội dung và preview.',
            progress: progress,
          ),
        ],
      ),
    );
  }
}