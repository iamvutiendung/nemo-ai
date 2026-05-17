import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../widgets/app_top_bar.dart';

class FaceSwapImageScreen extends StatefulWidget {
  const FaceSwapImageScreen({super.key});

  @override
  State<FaceSwapImageScreen> createState() => _FaceSwapImageScreenState();
}

class _FaceSwapImageScreenState extends State<FaceSwapImageScreen> {
  Uint8List? characterImageBytes;
  String? characterImageName;

  Uint8List? faceImageBytes;
  String? faceImageName;

  Uint8List? generatedPreviewBytes;

  bool isGenerating = false;
  int progress = 0;

  Future<void> _pickImage(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() {
      if (type == 'character') {
        characterImageBytes = result.files.single.bytes;
        characterImageName = result.files.single.name;
      } else {
        faceImageBytes = result.files.single.bytes;
        faceImageName = result.files.single.name;
      }
    });
  }

  void _removeImage(String type) {
    setState(() {
      if (type == 'character') {
        characterImageBytes = null;
        characterImageName = null;
      } else {
        faceImageBytes = null;
        faceImageName = null;
      }
    });
  }

  Future<void> _generateImage() async {
    if (characterImageBytes == null || faceImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần tải đủ ảnh nhân vật và ảnh gương mặt mới'),
        ),
      );
      return;
    }

    setState(() {
      isGenerating = true;
      progress = 0;
    });

    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (!mounted) return;
      setState(() => progress = i);
    }

    setState(() {
      isGenerating = false;
      generatedPreviewBytes = characterImageBytes;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo ảnh hoán đổi gương mặt demo')),
    );
  }

  Widget _demoImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        'assets/images/face_swap.jpg',
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
    required Uint8List? imageBytes,
    required String? fileName,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
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
                icon: const Icon(Icons.upload, size: 16),
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
                  fileName ?? 'Chưa chọn file nào hết á',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              if (imageBytes != null)
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
                'Ảnh sẽ hiện sau khi bấm Tạo Ảnh AI',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
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
            color: const Color(0xFF8B5CF6).withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'AI Hoán Đổi Gương Mặt + Giữ Nguyên Thần Thái',
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
            'Người dùng chỉ cần tải lên ảnh nhân vật và ảnh gương mặt thay thế. AI sẽ xử lý tự động và tạo ra phiên bản nhân vật với gương mặt mới một cách tự nhiên và chân thực.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 26),
          _uploadRow(
            label: 'Ảnh nhân vật',
            buttonText: 'Tải ảnh nhân vật',
            imageBytes: characterImageBytes,
            fileName: characterImageName,
            onPick: () => _pickImage('character'),
            onRemove: () => _removeImage('character'),
          ),
          const SizedBox(height: 22),
          _uploadRow(
            label: 'Ảnh Gương Mặt Mới',
            buttonText: 'Ảnh gương mặt mới',
            imageBytes: faceImageBytes,
            fileName: faceImageName,
            onPick: () => _pickImage('face'),
            onRemove: () => _removeImage('face'),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : _generateImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(
                isGenerating
                    ? 'AI đang tạo ảnh... $progress%'
                    : 'Tạo Ảnh AI    0.5 🔥',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120A2A),
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(
              activeMenu: 'image',
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
    );
  }
}