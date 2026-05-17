import '../widgets/app_top_bar.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/user_credit_service.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final TextEditingController promptController = TextEditingController();
  final TextEditingController negativePromptController =
      TextEditingController();

  String selectedMode = 'Text to Image';
  String selectedModel = 'Nano Banana Pro';
  String selectedRatio = '9:16';
  String selectedResolution = '2K';
  String selectedCount = '4';
  String selectedQuality = 'VIP 01';

  bool isGenerating = false;
  int loadingCardCount = 0;
  Uint8List? selectedImageBytes;
  String? selectedImageName;

  final List<_GeneratedImageItem> generatedImages = [];

  final List<Color> demoColors = const [
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFF3B82F6),
    Color(0xFFEF4444),
    Color(0xFFA855F7),
  ];

  @override
  void dispose() {
    promptController.dispose();
    negativePromptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes != null) {
          setState(() {
            selectedImageBytes = file.bytes;
            selectedImageName = file.name;
            selectedMode = 'Image to Image';
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã chọn ảnh: ${file.name}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: $e')),
      );
    }
  }

  void _removeSelectedImage() {
    setState(() {
      selectedImageBytes = null;
      selectedImageName = null;
      selectedMode = 'Text to Image';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xoá ảnh đã chọn')),
    );
  }

  Future<void> _generateFakeImages() async {
    final prompt = promptController.text.trim();

    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần nhập prompt trước')),
      );
      return;
    }

    if (selectedMode == 'Image to Image' && selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần chọn ảnh trước')),
      );
      return;
    }

    final int count = int.tryParse(selectedCount) ?? 4;

    final success =
    await UserCreditService.spendCredits(5);

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
      loadingCardCount = count;
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    final List<_GeneratedImageItem> newItems = List.generate(count, (index) {
      return _GeneratedImageItem(
        title: selectedMode == 'Text to Image'
            ? 'Text AI ${generatedImages.length + index + 1}'
            : 'Image AI ${generatedImages.length + index + 1}',
        prompt: prompt,
        color: demoColors[(DateTime.now().millisecondsSinceEpoch + index) %
            demoColors.length],
        ratio: selectedRatio,
        model: selectedModel,
      );
    });

    setState(() {
      generatedImages.insertAll(0, newItems);
      isGenerating = false;
      loadingCardCount = 0;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedMode == 'Text to Image'
              ? 'Đã tạo ảnh Text to Image'
              : 'Đã tạo ảnh Image to Image',
        ),
      ),
    );
  }

  Widget _topMenuItem(String text, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _topButton(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101C31),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF21304A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _creditBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF071F35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0EA5E9)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_outlined, color: Color(0xFF22D3EE), size: 18),
          SizedBox(width: 8),
          Text(
            '473',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionSwitch() {
    Widget buildTab(String title, bool active, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                  )
                : null,
            color: active ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF18263D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A3A58)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTab(
            'Text to Image',
            selectedMode == 'Text to Image',
            () {
              setState(() {
                selectedMode = 'Text to Image';
                selectedImageBytes = null;
                selectedImageName = null;
              });
            },
          ),
          buildTab(
            'Image to Image',
            selectedMode == 'Image to Image',
            () {
              setState(() {
                selectedMode = 'Image to Image';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _dropdownBox({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF101C31),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF22304A)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF101C31),
            isExpanded: true,
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white70,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildPromptPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1830),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF22304A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thiết lập tạo ảnh',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          _sectionSwitch(),
          const SizedBox(height: 18),
          Row(
            children: [
              _dropdownBox(
                value: selectedModel,
                items: const [
                  'Nano Banana Pro',
                  'Nano Banana 2',
                  'Grok Imagine',
                  'Kling 01 Image',
                ],
                onChanged: (v) => setState(() => selectedModel = v!),
              ),
              const SizedBox(width: 12),
              _dropdownBox(
                value: selectedRatio,
                items: const ['1:1', '4:5', '9:16', '16:9'],
                onChanged: (v) => setState(() => selectedRatio = v!),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _dropdownBox(
                value: selectedResolution,
                items: const ['HD', '2K', '4K'],
                onChanged: (v) => setState(() => selectedResolution = v!),
              ),
              const SizedBox(width: 12),
              _dropdownBox(
                value: selectedCount,
                items: const ['1', '2', '4', '6'],
                onChanged: (v) => setState(() => selectedCount = v!),
              ),
              const SizedBox(width: 12),
              _dropdownBox(
                value: selectedQuality,
                items: const ['VIP 01', 'VIP 02', 'Free'],
                onChanged: (v) => setState(() => selectedQuality = v!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Prompt',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: promptController,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Ví dụ: luxury cosmetic product on marble table, studio lighting, ultra detailed...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF101C31),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Negative Prompt',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: negativePromptController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'blur, watermark, low quality, deformed, ugly, duplicate...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF101C31),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (selectedMode == 'Image to Image') ...[
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Chọn ảnh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24344E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed:
                      selectedImageBytes != null ? _removeSelectedImage : null,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Xoá ảnh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Color(0xFF33445F)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton.icon(
                onPressed: isGenerating ? null : _generateFakeImages,
                icon: isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(isGenerating ? 'Đang tạo...' : 'Tạo ảnh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1830),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF22304A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ảnh tham chiếu / preview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 360,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF101C31),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF22304A)),
            ),
            child: selectedImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      selectedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            color: Colors.white54, size: 54),
                        SizedBox(height: 12),
                        Text(
                          'Chưa có ảnh nào được chọn',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            selectedImageName ?? 'Bạn có thể dùng ảnh này làm image-to-image',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  double _ratioToAspect(String ratio) {
    switch (ratio) {
      case '16:9':
        return 1.55;
      case '9:16':
        return 0.60;
      case '4:5':
        return 0.80;
      case '1:1':
      default:
        return 1.0;
    }
  }

  Widget _buildGeneratedGallery() {
    final totalItems = generatedImages.length + loadingCardCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1830),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF22304A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kết quả tạo ảnh',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          if (totalItems == 0)
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF101C31),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF22304A)),
              ),
              child: const Center(
                child: Text(
                  'Chưa có ảnh nào được tạo',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              itemCount: totalItems,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: generatedImages.isNotEmpty
                    ? _ratioToAspect(generatedImages.first.ratio)
                    : 1,
              ),
              itemBuilder: (context, index) {
                final bool isLoadingCard = index < loadingCardCount;

                if (isLoadingCard) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF101C31),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF22304A)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'AI đang tạo ảnh...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Đang xử lý từng ảnh',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final item = generatedImages[index - loadingCardCount];

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.color.withOpacity(0.95),
                          item.color.withOpacity(0.55),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.prompt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.model,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: Column(
        children: [
          // 🔥 TOP BAR
          const AppTopBar(
            activeMenu: 'image',
            isLoggedIn: false,
          ),

          // 🔽 NỘI DUNG
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Image Studio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload ảnh, nhập prompt và tạo kết quả demo giống luồng AI thật.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: selectedMode == 'Image to Image' ? 3 : 1,
                              child: _buildPromptPanel(),
                            ),
                            if (selectedMode == 'Image to Image') ...[
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: _buildPreviewPanel(),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildGeneratedGallery(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedImageItem {
  final String title;
  final String prompt;
  final Color color;
  final String ratio;
  final String model;

  const _GeneratedImageItem({
    required this.title,
    required this.prompt,
    required this.color,
    required this.ratio,
    required this.model,
  });
}
