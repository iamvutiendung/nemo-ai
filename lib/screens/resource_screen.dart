import 'package:flutter/material.dart';
import '../models/resource_item.dart';
import '../services/resource_service.dart';
import '../widgets/app_top_bar.dart';

class ResourceScreen extends StatefulWidget {
  const ResourceScreen({super.key});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  String selectedMenu = 'Video';
  List<ResourceItem> get currentItems {
    final items = ResourceService.getItems();

    if (selectedMenu == 'Tất cả') return items;

    if (selectedMenu == 'Video') {
      return items.where((e) => e.type == ResourceType.video).toList();
    }

    if (selectedMenu == 'Ảnh') {
      return items.where((e) => e.type == ResourceType.image).toList();
    }

    if (selectedMenu == 'Upscale') {
      return items.where((e) => e.type == ResourceType.upscale).toList();
    }

    if (selectedMenu == 'Đã tải lên') {
      return items.where((e) => e.type == ResourceType.upload).toList();
    }

    if (selectedMenu == 'Giọng nói') {
      return items.where((e) => e.type == ResourceType.voice).toList();
    }

    if (selectedMenu == 'Yêu thích') {
      return items.where((e) => e.isFavorite).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101826),
        body: Column(
            children: [
          AppTopBar(
          activeMenu: 'Tài nguyên',
          isLoggedIn: true,
        ),
        Expanded(
          child: Row(
        children: [
          // LEFT MENU
          Container(
            width: 240,
            color: const Color(0xFF1B2636),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _searchBox(),
                const SizedBox(height: 20),
                _menuItem(Icons.folder_open, 'Tất cả', '0'),
                _menuItem(Icons.favorite_border, 'Yêu thích', '0'),
                _menuItem(Icons.image_outlined, 'Ảnh', '0'),
                _menuItem(Icons.videocam_outlined, 'Video', '50'),
                _menuItem(Icons.auto_fix_high, 'Upscale', '0'),
                _menuItem(Icons.upload_file, 'Đã tải lên', '0'),
                _menuItem(Icons.mic_none, 'Giọng nói', '0'),
                const Divider(color: Colors.white24, height: 32),
                _folderItem('Personal projects'),
                _folderItem('Team projects'),

              ],
            ),
          ),

          // MAIN CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topTitle(),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildContentByMenu(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
          ),
        ),
            ],
        ),
    );
  }

  Widget _topTitle() {
    return Row(
      children: [
        const Text(
          'Video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${currentItems.length} items',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const Spacer(),
        Container(
          width: 190,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF2B3748),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              SizedBox(width: 12),
              Icon(Icons.search, color: Colors.white54, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tìm kiếm...',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchBox() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.white54, size: 18),
          SizedBox(width: 8),
          Text('Tìm kiếm...', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _menuItem(
      IconData icon,
      String title,
      String count, {
        bool active = false,
      }) {
    final bool isActive = selectedMenu == title || active;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() {
          selectedMenu = title;
        });
      },
      child: Container(
        height: 42,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4C3575) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFC084FC) : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? const Color(0xFFC084FC) : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(count, style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _folderItem(String title) {
    return Container(
      height: 38,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Icon(Icons.keyboard_arrow_right, color: Colors.white54),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }
  List<Widget> _buildContentByMenu() {
    final items = currentItems;

    if (items.isEmpty) {
      return [
        _emptyBox('Chưa có dữ liệu trong mục $selectedMenu'),
      ];
    }

    final Map<String, List<ResourceItem>> grouped = {};

    for (final item in items) {
      final dateKey = _formatDate(item.createdAt);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(item);
    }

    return grouped.entries.map((entry) {
      return _resourceGroup(entry.key, entry.value);
    }).toList();
  }
  String _formatDate(DateTime date) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];

    final weekday = weekdays[date.weekday - 1];

    return '$weekday, ${date.day} tháng ${date.month}, ${date.year}';
  }
  Widget _resourceGroup(String date, List<ResourceItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (_) {},
              side: const BorderSide(color: Colors.white54),
            ),
            Text(
              date,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            if (item.type == ResourceType.video) {
              return _videoCard(item.path, item.duration ?? '8s');
            }

            return _imageCard(item.path);
          }).toList(),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
  Widget _imageGroup(String title, int count, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (_) {},
              side: const BorderSide(color: Colors.white54),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            count,
                (index) => _imageCard(imagePath),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _emptyBox(String text) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
      ),
    );
  }
  Widget _imageCard(String imagePath) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPreview(imagePath, 'Ảnh', false),
      child: Container(
        width: 150,
        height: 190,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  Widget _dateGroup(String date, int count, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (_) {},
              side: const BorderSide(color: Colors.white54),
            ),
            Text(
              date,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            count,
                (index) => _videoCard(imagePath, index == 0 ? '19s' : '8s'),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
  void _openPreview(String imagePath, String time, bool isVideo) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: SizedBox(
            width: 520,
            height: 620,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Text(
                        'Xem tài nguyên',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: 420,
                          height: 500,
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                      Positioned(
                        right: 55,
                        bottom: 50,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            time,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng tải về sẽ nối file thật ở bước sau'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: Text(isVideo ? 'Tải video về' : 'Tải ảnh về'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _videoCard(String imagePath, String time) {
    return InkWell(
        borderRadius: BorderRadius.circular(12),
      onTap: () => _openPreview(imagePath, time, true),
        child: Container(
      width: 150,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                time,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
        ),
    );
  }
}