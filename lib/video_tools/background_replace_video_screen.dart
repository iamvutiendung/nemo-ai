import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../widgets/app_top_bar.dart';
import '../widgets/video_history_panel.dart';
import '../widgets/ai_loading_overlay.dart';
import '../models/video_job.dart';
import '../services/video_service.dart';
import '../services/user_credit_service.dart';

class BackgroundReplaceVideoScreen extends StatefulWidget {
  const BackgroundReplaceVideoScreen({super.key});

  @override
  State<BackgroundReplaceVideoScreen> createState() =>
      _BackgroundReplaceVideoScreenState();
}

class _BackgroundReplaceVideoScreenState
    extends State<BackgroundReplaceVideoScreen> {
  final GlobalKey<VideoHistoryPanelState> historyKey = GlobalKey();

  Uint8List? backgroundImageBytes;
  String? backgroundImageName;

  String? videoName;

  Uint8List? generatedPreviewBytes;

  bool isGenerating = false;
  int progress = 0;

  String selectedRatio = '9:16';
  String selectedResolution = '1080p';
  String selectedDuration = '20s';
  String selectedServer = 'VIP 01';

  Future<void> _pickBackgroundImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() {
      backgroundImageBytes = result.files.single.bytes;
      backgroundImageName = result.files.single.name;
    });
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null) return;

    setState(() {
      videoName = result.files.single.name;
    });
  }

  void _removeBackground() {
    setState(() {
      backgroundImageBytes = null;
      backgroundImageName = null;
    });
  }

  void _removeVideo() {
    setState(() {
      videoName = null;
    });
  }

  Future<void> _generateVideo() async {
    if (backgroundImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần tải ảnh phông nền mới trước')),
      );
      return;
    }

    if (videoName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần tải video mẫu trước')),
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
      setState(() => progress = i);
    }

    if (!mounted) return;

    setState(() {
      isGenerating = false;
      progress = 100;
      generatedPreviewBytes = backgroundImageBytes;
    });

    await VideoService.addJob(
      VideoJob(
        title: 'AI Thay Đổi Nền Video',
        prompt: 'Thay nền video, giữ nguyên nhân vật/sản phẩm',
        duration: selectedDuration,
        resolution: selectedResolution,
        date: DateTime.now().toString(),
        status: 'Done',
        videoUrl: '',
      ),
    );

    await historyKey.currentState?.refresh();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo video thay nền demo')),
    );
  }

  Widget _demoImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        'assets/images/background_replace.jpg',
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            height: 260,
            color: const Color(0xFF111827),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                color: Colors.white54,
                size: 52,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _uploadRow({
    required String label,
    required String buttonText,
    required String emptyText,
    required IconData icon,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    required bool hasFile,
    required String? fileName,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0618),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: onPick,
                icon: Icon(icon, size: 16),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName ?? emptyText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              if (hasFile)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ratioCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2B185D) : const Color(0xFF211548),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? const Color(0xFF8B5CF6) : Colors.white24,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
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
        color: const Color(0xFF0B0618),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
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

  Widget _mainToolCard() {
    return Container(
      width: 560,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF211548),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3E2C73)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'AI Thay Đổi Nền Cho Video - Vượt Kiểm Duyệt Nền TikTok Aff',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _demoImage(),
          const SizedBox(height: 20),
          const Text(
            'Model thay thế nền cho video, giữ nguyên nhân vật và sản phẩm. Phù hợp làm video affiliate, review sản phẩm và tránh trùng nền.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 26),
          _uploadRow(
            label: 'Phông Nền Mới Cho Video',
            buttonText: 'Phông Nền Mới Cho Video',
            emptyText: 'Chưa chọn file nào hết á',
            icon: Icons.person_outline,
            onPick: _pickBackgroundImage,
            onRemove: _removeBackground,
            hasFile: backgroundImageBytes != null,
            fileName: backgroundImageName,
          ),
          const SizedBox(height: 22),
          _uploadRow(
            label: 'Video mẫu (Video)',
            buttonText: 'Tải lên video',
            emptyText: 'Chưa chọn file nào hết á',
            icon: Icons.videocam_outlined,
            onPick: _pickVideo,
            onRemove: _removeVideo,
            hasFile: videoName != null,
            fileName: videoName,
          ),
          const SizedBox(height: 26),
          const Text(
            'Chọn tỷ lệ khung hình:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ratioCard(
                title: '9:16 (Dọc)',
                subtitle: 'TikTok / Reels',
                icon: Icons.phone_iphone,
                active: selectedRatio == '9:16',
                onTap: () => setState(() => selectedRatio = '9:16'),
              ),
              const SizedBox(width: 12),
              _ratioCard(
                title: '16:9 (Ngang)',
                subtitle: 'YouTube',
                icon: Icons.desktop_windows_outlined,
                active: selectedRatio == '16:9',
                onTap: () => setState(() => selectedRatio = '16:9'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  value: selectedResolution,
                  items: const ['720p', '1080p', '2K', '4K'],
                  onChanged: (v) => setState(() => selectedResolution = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdown(
                  value: selectedDuration,
                  items: const ['10s', '20s', '30s', '60s'],
                  onChanged: (v) => setState(() => selectedDuration = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _dropdown(
            value: selectedServer,
            items: const ['VIP 01', 'VIP 02', 'Free'],
            onChanged: (v) => setState(() => selectedServer = v!),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : _generateVideo,
              icon: const Icon(Icons.flash_on),
              label: Text(
                isGenerating
                    ? 'Đang tạo video... $progress%'
                    : 'Tạo Video Nhanh • 20 Credits 🔥',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewResult() {
    return Container(
      width: 430,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF221848),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF3E2C73)),
      ),
      child: Column(
        children: [
          const Text(
            'Kết quả sau khi tạo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 360,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0B0618),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: generatedPreviewBytes != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(
                generatedPreviewBytes!,
                fit: BoxFit.cover,
              ),
            )
                : const Center(
              child: Text(
                'Video sẽ hiện sau khi bấm Tạo Video Nhanh',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'History bên phải sẽ lưu job sau khi tạo video.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120A2A),
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
                          padding: const EdgeInsets.fromLTRB(28, 40, 28, 60),
                          child: Center(
                            child: Wrap(
                              spacing: 28,
                              runSpacing: 28,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                _mainToolCard(),
                                _previewResult(),
                              ],
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã chọn: ${job.title}'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          AiLoadingOverlay(
            visible: isGenerating,
            title: 'AI đang thay nền video...',
            subtitle:
            'Nemo đang xử lý video mẫu, phông nền mới, tách nhân vật và tạo preview.',
            progress: progress,
          ),
        ],
      ),
    );
  }
}