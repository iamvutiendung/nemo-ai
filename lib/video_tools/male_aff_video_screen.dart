import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../widgets/app_top_bar.dart';
import '../models/video_job.dart';
import '../services/video_service.dart';
import '../widgets/video_history_panel.dart';
import '../widgets/ai_loading_overlay.dart';
import '../widgets/real_hover_video_card.dart';
import '../services/ai_service.dart';
import '../services/user_credit_service.dart';

class MaleAffVideoScreen extends StatefulWidget {
  const MaleAffVideoScreen({super.key});

  @override
  State<MaleAffVideoScreen> createState() => _MaleAffVideoScreenState();
}

class _MaleAffVideoScreenState extends State<MaleAffVideoScreen> {
  final GlobalKey<VideoHistoryPanelState> historyKey = GlobalKey();

  final TextEditingController promptController = TextEditingController(
    text:
    'Create a realistic male fashion affiliate video. A male model presents the outfit naturally, phone camera style, vertical 9:16, smooth movement, realistic lighting, TikTok Shop style.',
  );

  Uint8List? outfitImageBytes;
  String? outfitImageName;

  Uint8List? modelImageBytes;
  String? modelImageName;

  bool isGenerating = false;
  int progress = 0;

  String selectedRatio = '9:16';
  String selectedResolution = '1080p';
  String selectedDuration = '10s';
  String selectedServer = 'VIP 01';
  String selectedStyle = 'TikTok Shop';

  Future<void> _pickOutfitImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() {
      outfitImageBytes = result.files.single.bytes;
      outfitImageName = result.files.single.name;
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

  void _removeOutfitImage() {
    setState(() {
      outfitImageBytes = null;
      outfitImageName = null;
    });
  }

  void _removeModelImage() {
    setState(() {
      modelImageBytes = null;
      modelImageName = null;
    });
  }

  Future<void> _generateVideo() async {
    if (outfitImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần tải ảnh trang phục trước'),
        ),
      );
      return;
    }

    final success = await UserCreditService.spendCredits(30);

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

      final job = VideoJob(
        videoUrl: result,
        title: 'Affiliate Nam',
        prompt: promptController.text,
        duration: selectedDuration,
        resolution: selectedResolution,
        date: DateTime.now().toString(),
        status: 'Done',
      );

      await VideoService.addJob(job);

      await historyKey.currentState?.refresh();

      if (!mounted) return;

      setState(() {
        isGenerating = false;
        progress = 100;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo video affiliate thời trang nam demo'),
        ),
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
      height: 240,
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
            Icon(
              requiredBox ? Icons.checkroom_outlined : Icons.person_outline,
              color: const Color(0xFFA78BFA),
              size: 48,
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
              padding: const EdgeInsets.symmetric(horizontal: 18),
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

  Widget _chip(String text, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF7A1A) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
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

  Widget _previewCard({
    required String title,
    required IconData icon,
    Uint8List? imageBytes,
  }) {
    return Expanded(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Stack(
          children: [
            if (imageBytes != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Center(
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.35),
                  size: 58,
                ),
              ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
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
            'Thiết lập video affiliate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Phong cách',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(
                'TikTok Shop',
                selectedStyle == 'TikTok Shop',
                    () => setState(() => selectedStyle = 'TikTok Shop'),
              ),
              _chip(
                'Lookbook',
                selectedStyle == 'Lookbook',
                    () => setState(() => selectedStyle = 'Lookbook'),
              ),
              _chip(
                'Review nam',
                selectedStyle == 'Review nam',
                    () => setState(() => selectedStyle = 'Review nam'),
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
                title: 'Upload ảnh trang phục',
                subtitle: 'Bắt buộc: áo, quần, phụ kiện hoặc outfit nam',
                imageBytes: outfitImageBytes,
                fileName: outfitImageName,
                onPick: _pickOutfitImage,
                onRemove: _removeOutfitImage,
                requiredBox: true,
              ),
              const SizedBox(height: 16),
              _uploadBox(
                title: 'Upload ảnh mẫu nam',
                subtitle: 'Có thể bỏ trống, AI sẽ tự chọn mẫu nam phù hợp',
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
              Row(
                children: [
                  _previewCard(
                    title: 'Preview ảnh outfit',
                    icon: Icons.image_outlined,
                    imageBytes: outfitImageBytes,
                  ),
                  const SizedBox(width: 16),
                  _previewCard(
                    title: 'Preview mẫu nam',
                    icon: Icons.person_outline,
                    imageBytes: modelImageBytes,
                  ),
                ],
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
                    hintText: 'Nhập prompt video affiliate...',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(
                    child: RealHoverVideoCard(
                      videoAsset: 'assets/videos/fashion_preview.mp4',
                      title: 'Video Preview 01',
                      subtitle: 'Rê chuột để phát video',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: RealHoverVideoCard(
                      videoAsset: 'assets/videos/fashion_preview.mp4',
                      title: 'Video Preview 02',
                      subtitle: 'Affiliate video preview',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: isGenerating ? null : _generateVideo,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    isGenerating
                        ? 'Đang tạo video... $progress%'
                        : 'Tạo Video Affiliate Nam  ✨ 30',
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
          title: 'Upload ảnh trang phục',
          subtitle: 'Bắt buộc',
          imageBytes: outfitImageBytes,
          fileName: outfitImageName,
          onPick: _pickOutfitImage,
          onRemove: _removeOutfitImage,
          requiredBox: true,
        ),
        const SizedBox(height: 16),
        _uploadBox(
          title: 'Upload ảnh mẫu nam',
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
            hintText: 'Nhập prompt video affiliate...',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
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
                  : 'Tạo Video Affiliate Nam  ✨ 30',
            ),
          ),
        ),
        const SizedBox(height: 20),
        VideoHistoryPanel(
          key: historyKey,
          onTapJob: (job) {
            promptController.text = job.prompt;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã chọn: ${job.title}')),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    promptController.dispose();
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
                          padding: const EdgeInsets.all(20),
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
                                          'AI Affiliate Thời Trang Nam',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tải ảnh outfit nam hoặc sản phẩm affiliate. AI tạo video review/lookbook bán hàng dạng TikTok Shop.',
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
                  onTapJob: (job) {
                    promptController.text = job.prompt;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã chọn: ${job.title}')),
                    );
                  },
                ),
              ],
            ),
          ),
          AiLoadingOverlay(
            visible: isGenerating,
            title: 'AI đang tạo video...',
            subtitle: 'Nemo đang xử lý outfit, prompt, chuyển động và preview.',
            progress: progress,
          ),
        ],
      ),
    );
  }
}