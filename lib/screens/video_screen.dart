import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../widgets/app_top_bar.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final TextEditingController scriptController = TextEditingController(
    text:
    'A young woman holds a product close to the camera, then slowly turns to the side while studio lighting highlights the details of the product. Ultra realistic, cinematic, natural movement.',
  );

  String selectedToolTab = 'Tạo Video';
  String selectedModeTab = 'Khung hình';
  String selectedModel = 'Veo3.1 Quality';
  String selectedServer = 'VIP 01';
  String selectedResolution = '4K';
  String selectedRatio = '9:16';
  String selectedDuration = '10s';
  String selectedVoice = 'Không dùng voice';

  Uint8List? startFrameBytes;
  String? startFrameName;

  Uint8List? endFrameBytes;
  String? endFrameName;

  bool isGenerating = false;
  int previewPercent = 0;

  final List<_VideoJob> jobs = [
    _VideoJob(
      title: 'Motion Control',
      prompt:
      'Ultra-realistic cinematic video of a person based on the provided frame. Preserve facial identity and smooth movement.',
      duration: '19s',
      resolution: '1080p',
      date: '11/04/2026',
      status: 'done',
    ),
    _VideoJob(
      title: 'Product Review',
      prompt:
      'Natural product presentation with clean lighting and subtle camera motion for social content.',
      duration: '12s',
      resolution: '4K',
      date: '12/04/2026',
      status: 'done',
    ),
  ];

  @override
  void dispose() {
    scriptController.dispose();
    super.dispose();
  }

  Future<void> _pickStartFrame() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          startFrameBytes = file.bytes;
          startFrameName = file.name;
        });
      }
    }
  }

  Future<void> _pickEndFrame() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          endFrameBytes = file.bytes;
          endFrameName = file.name;
        });
      }
    }
  }

  void _removeStartFrame() {
    setState(() {
      startFrameBytes = null;
      startFrameName = null;
    });
  }

  void _removeEndFrame() {
    setState(() {
      endFrameBytes = null;
      endFrameName = null;
    });
  }

  Future<void> _generateFakeVideo() async {
    if (startFrameBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần chọn khung bắt đầu trước')),
      );
      return;
    }

    if (scriptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần nhập mô tả video trước')),
      );
      return;
    }

    setState(() {
      isGenerating = true;
      previewPercent = 0;
      jobs.insert(
        0,
        _VideoJob(
          title: selectedModel,
          prompt: scriptController.text.trim(),
          duration: selectedDuration,
          resolution: selectedResolution,
          date: 'Đang xử lý...',
          status: 'rendering',
        ),
      );
    });

    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() {
        previewPercent = i * 20;
      });
    }

    if (!mounted) return;
    setState(() {
      isGenerating = false;
      previewPercent = 100;
      jobs[0] = _VideoJob(
        title: selectedModel,
        prompt: scriptController.text.trim(),
        duration: selectedDuration,
        resolution: selectedResolution,
        date: 'Hôm nay',
        status: 'done',
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo job video demo thành công')),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _topMiniTab(String text, {bool active = false, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF8B5CF6) : const Color(0xFF111E36),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111E36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF22304A)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF111E36),
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

  Widget _uploadFrameBox({
    required String title,
    required String subtitle,
    required Uint8List? imageBytes,
    required String? fileName,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    bool requiredBox = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
            requiredBox ? const Color(0xFFEF4444) : const Color(0xFF33445F),
          ),
          color: const Color(0xFF101A2E),
        ),
        child: imageBytes != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  imageBytes,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              fileName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side:
                      const BorderSide(color: Color(0xFF33445F)),
                    ),
                    child: const Text('Xoá'),
                  ),
                ),
              ],
            )
          ],
        )
            : InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                color: requiredBox
                    ? const Color(0xFFFF7A7A)
                    : Colors.white54,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: requiredBox
                      ? const Color(0xFFFF7A7A)
                      : Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2740),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Chọn ảnh',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftPanel() {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F182B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF22304A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _topMiniTab(
                'Tạo Video',
                active: selectedToolTab == 'Tạo Video',
                onTap: () => setState(() => selectedToolTab = 'Tạo Video'),
              ),
              const SizedBox(width: 8),
              _topMiniTab(
                'Edit Video',
                active: selectedToolTab == 'Edit Video',
                onTap: () => setState(() => selectedToolTab = 'Edit Video'),
              ),
              const SizedBox(width: 8),
              _topMiniTab(
                'Motion',
                active: selectedToolTab == 'Motion',
                onTap: () => setState(() => selectedToolTab = 'Motion'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF111E36),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _topMiniTab(
                    'Khung hình',
                    active: selectedModeTab == 'Khung hình',
                    onTap: () => setState(() => selectedModeTab = 'Khung hình'),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _topMiniTab(
                    'Thành phần',
                    active: selectedModeTab == 'Thành phần',
                    onTap: () => setState(() => selectedModeTab = 'Thành phần'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _uploadFrameBox(
                title: 'Khung bắt đầu',
                subtitle: 'Bắt buộc',
                imageBytes: startFrameBytes,
                fileName: startFrameName,
                onPick: _pickStartFrame,
                onRemove: _removeStartFrame,
                requiredBox: true,
              ),
              const SizedBox(width: 12),
              _uploadFrameBox(
                title: 'Khung kết thúc',
                subtitle: 'Tuỳ chọn',
                imageBytes: endFrameBytes,
                fileName: endFrameName,
                onPick: _pickEndFrame,
                onRemove: _removeEndFrame,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionTitle('Mô tả video'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111E36),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF22304A)),
            ),
            child: TextField(
              controller: scriptController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Nhập mô tả video...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Thiết lập nhanh'),
          const SizedBox(height: 10),
          _dropdownField(
            value: selectedModel,
            items: const [
              'Veo3.1 Quality',
              'Kling 3.0 Pro',
              'Kling Motion Control',
            ],
            onChanged: (v) => setState(() => selectedModel = v!),
          ),
          const SizedBox(height: 12),
          _dropdownField(
            value: selectedServer,
            items: const ['VIP 01', 'VIP 02', 'Free'],
            onChanged: (v) => setState(() => selectedServer = v!),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dropdownField(
                  value: selectedResolution,
                  items: const ['HD', '1080p', '4K'],
                  onChanged: (v) => setState(() => selectedResolution = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdownField(
                  value: selectedRatio,
                  items: const ['9:16', '16:9', '1:1'],
                  onChanged: (v) => setState(() => selectedRatio = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dropdownField(
                  value: selectedDuration,
                  items: const ['5s', '10s', '15s', '20s'],
                  onChanged: (v) => setState(() => selectedDuration = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdownField(
                  value: selectedVoice,
                  items: const [
                    'Không dùng voice',
                    'Voice nữ',
                    'Voice nam',
                  ],
                  onChanged: (v) => setState(() => selectedVoice = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isGenerating ? null : _generateFakeVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isGenerating
                    ? 'Đang tạo... $previewPercent%'
                    : 'Tạo video  ✨ 30',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewBox({
    required String title,
    required Uint8List? bytes,
    required String emptyText,
  }) {
    return Expanded(
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: const Color(0xFF0F182B),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF22304A)),
        ),
        child: bytes != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(bytes, fit: BoxFit.cover),
              Positioned(
                left: 14,
                top: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white54,
                size: 52,
              ),
              const SizedBox(height: 10),
              Text(
                emptyText,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerPreview() {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              _previewBox(
                title: 'Khung bắt đầu',
                bytes: startFrameBytes,
                emptyText: 'Chưa có frame bắt đầu',
              ),
              const SizedBox(width: 16),
              _previewBox(
                title: 'Khung kết thúc',
                bytes: endFrameBytes,
                emptyText: 'Chưa có frame kết thúc',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0F182B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF22304A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preview video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  height: 360,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF22304A)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 280,
                          height: 300,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1F2937), Color(0xFF374151)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              size: 96,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      if (isGenerating)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.45),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F182B),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Đang render video... $previewPercent%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
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
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111E36),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.movie_creation_outlined,
                          color: Colors.white70),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          scriptController.text.trim().isEmpty
                              ? 'Chưa có mô tả'
                              : scriptController.text.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _historyCard(_VideoJob job) {
    final isDone = job.status == 'done';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F182B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF22304A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor:
                isDone ? const Color(0xFFF97316) : const Color(0xFF8B5CF6),
                child: Text(
                  isDone ? 'K' : 'R',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _statusChip(
                isDone ? 'Hoàn thành' : 'Đang render',
                isDone ? const Color(0xFF22C55E) : const Color(0xFF8B5CF6),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            job.prompt,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDone
                    ? const [Color(0xFF8B5CF6), Color(0xFF4F46E5)]
                    : const [Color(0xFF334155), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white70,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statusChip(job.duration, Colors.white70),
              const SizedBox(width: 8),
              _statusChip(job.resolution, Colors.white70),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            job.date,
            style: const TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(
              activeMenu: 'video',
              isLoggedIn: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 1250;

                    if (isWide) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text(
                                'Video Studio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.view_list_rounded,
                                  color: Colors.white),
                              SizedBox(width: 10),
                              Icon(Icons.grid_view_rounded,
                                  color: Colors.white),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 340, child: SizedBox()),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _leftPanel(),
                              const SizedBox(width: 18),
                              _centerPreview(),
                              const SizedBox(width: 18),
                              SizedBox(
                                width: 300,
                                child: Column(
                                  children: jobs
                                      .map((job) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 16),
                                    child: _historyCard(job),
                                  ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Video Studio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _leftPanel(),
                        const SizedBox(height: 18),
                        _centerPreview(),
                        const SizedBox(height: 18),
                        ...jobs.map(
                              (job) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _historyCard(job),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoJob {
  final String title;
  final String prompt;
  final String duration;
  final String resolution;
  final String date;
  final String status;

  _VideoJob({
    required this.title,
    required this.prompt,
    required this.duration,
    required this.resolution,
    required this.date,
    required this.status,
  });
}