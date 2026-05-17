import '../video_tools/male_aff_video_screen.dart';
import '../video_tools/brand_ads_video_screen.dart';
import '../video_tools/fashion_selfie_video_screen.dart';
import '../video_tools/review_product_video_screen.dart';
import '../widgets/app_top_bar.dart';
import '../video_tools/dance_video_screen.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'image_screen.dart';
import 'video_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../video_tools/background_replace_video_screen.dart';
import '../image_tools/face_swap_image_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false;
  String selectedTab = 'all';

  Future<void> _openLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );

    if (result == true && mounted) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  void _goTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showComingSoon(String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1830),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tính năng đang phát triển...',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openProfileGuarded() async {
    if (isLoggedIn) {
      _goTo(const ProfileScreen());
    } else {
      await _openLogin();
    }
  }

  Widget _menuItem(String title, VoidCallback onTap, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _topButton(String title, {IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => _showComingSoon(title),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
          color: const Color(0xFF101C31),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _creditBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF071F35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0EA5E9)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_outlined, color: Color(0xFF22D3EE), size: 18),
          SizedBox(width: 6),
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

  Widget _buildTopBar() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEC4899),
                  Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          },
          child: const Text(
            'Nemo AI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 24),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _menuItem(
                  'Image',
                      () => _goTo(const ImageScreen()),
                  active: true,
                ),
                _menuItem(
                  'Video',
                      () => _goTo(const VideoScreen()),
                ),
                _menuItem(
                  'Voices',
                      () => _showComingSoon('Voices'),
                ),
                _menuItem(
                  'Apps',
                      () => _showComingSoon('Apps'),
                ),
                _menuItem(
                  'Workflow',
                      () => _showComingSoon('Workflow'),
                ),
                _menuItem(
                  'Khám phá',
                      () => _showComingSoon('Khám phá'),
                ),
                _menuItem(
                  'Khóa Học',
                      () => _showComingSoon('Khóa Học'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),
        _topButton(
          'Tài nguyên',
          icon: Icons.folder_open_outlined,
          onTap: () => _showComingSoon('Tài nguyên'),
        ),
        const SizedBox(width: 10),
        _topButton(
          'Bảng giá',
          icon: Icons.menu,
          onTap: () => _showComingSoon('Bảng giá'),
        ),
        const SizedBox(width: 10),
        _creditBox(),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () => _showComingSoon('Thông báo'),
          icon: const Icon(Icons.notifications_none, color: Colors.white70),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _openProfileGuarded,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF101C31),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF22304A)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.purple.shade300,
                  child: Text(
                    isLoggedIn ? 'U' : 'N',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? 'User đã đăng nhập' : 'Đăng nhập',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isLoggedIn ? 'User' : 'Nhấn để đăng nhập',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionSwitch() {
    Widget buildTab(String id, String label) {
      final active = selectedTab == id;
      return InkWell(
        onTap: () {
          setState(() {
            selectedTab = id;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
              colors: [
                Color(0xFFEC4899),
                Color(0xFF8B5CF6),
              ],
            )
                : null,
            color: active ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
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
          buildTab('all', 'Tất cả'),
          buildTab('video', 'Video'),
          buildTab('image', 'Ảnh'),
        ],
      ),
    );
  }

  Widget _templateImage({
    required String assetPath,
    required double height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF16253C),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.white54,
                  size: 56,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _templateCard({
    required String title,
    required String description,
    required String assetPath,
    required String buttonText,
    required Widget targetScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        _templateImage(
          assetPath: assetPath,
          height: 260,
        ),
        const SizedBox(height: 14),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: () => _goTo(targetScreen),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEC4899),
                  Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _simpleToolCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1830),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF22304A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolShowcaseCard({
    required String title,
    required String description,
    required String assetPath,
    required String buttonText,
    required Widget targetScreen,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF24124A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF3E2C73)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              assetPath,
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 190,
                  color: const Color(0xFF101C31),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white54,
                      size: 46,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _goTo(targetScreen),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF818CF8), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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
    final allTemplates = [
      {
        'type': 'video',
        'title': '✦ AI Dance Video',
        'description':
        'Tải lên ảnh và video tỉ lệ 9:16. AI sẽ tạo video nhảy sinh động theo chuyển động mẫu.',
        'asset': 'assets/images/dance_video.jpg',
        'button': 'Tạo Video',
        'screen': const DanceVideoScreen(),
      },
      {
        'type': 'video',
        'title': '✦ AI Review Sản phẩm',
        'description':
        'Tải ảnh mẫu, sản phẩm và phông nền. AI sẽ tạo kịch bản và video giới thiệu sản phẩm.',
        'asset': 'assets/images/review_product.jpg',
        'button': 'Tạo ngay',
        'screen': const ReviewProductVideoScreen(),
      },
      {
        'type': 'video',
        'title': '✦ AI Video Thời trang Selfie',
        'description':
        'Tải ảnh sản phẩm lên, có thể tải ảnh mẫu hoặc không. AI tạo video thử đồ dạng selfie.',
        'asset': 'assets/images/fashion_selfie.jpg',
        'button': 'Tạo ngay',
        'screen': const FashionSelfieVideoScreen(),
      },
      {
        'type': 'video',
        'title': '✦ AI Quảng Cáo Dịch vụ, Thương Hiệu',
        'description':
        'Tải ảnh nhân vật, sản phẩm và phông nền. AI tạo video quảng cáo dịch vụ hoặc nhãn hàng.',
        'asset': 'assets/images/brand_ads.jpg',
        'button': 'Tạo ngay',
        'screen': const BrandAdsVideoScreen(),
      },
      {
        'type': 'video',
        'title': '✦ AI Aff Thời Trang Nam',
        'description':
        'Tải ảnh trang phục và ảnh mẫu để tạo video lookbook thời trang nam chuyên nghiệp.',
        'asset': 'assets/images/male_fashion.jpg',
        'button': 'Tạo ngay',
        'screen': const MaleAffVideoScreen(),
      },
      {
        'type': 'video',
        'title': '✨ AI Thay Đổi Nền Cho Video - Vượt Kiểm Duyệt Nền Tiktok Aff',
        'description':
        'Model thay thế nền cho video, giữ nguyên nhân vật và sản phẩm. Phù hợp làm video affiliate vượt kiểm duyệt nền.',
        'asset': 'assets/images/background_replace.jpg',
        'button': 'Tạo Video',
        'screen': const BackgroundReplaceVideoScreen(),
      },
      {
        'type': 'image',
        'title': '✨ AI Hoán Đổi Gương Mặt + Giữ Nguyên Thần Thái',
        'description':
        'Tải ảnh nhân vật và ảnh gương mặt thay thế. AI giữ thần thái, ánh sáng và phong cách tự nhiên.',
        'asset': 'assets/images/face_swap.jpg',
        'button': 'Tạo Ảnh',
        'screen': const FaceSwapImageScreen(),
      },
      {
        'type': 'image',
        'title': '✦ AI Product Image',
        'description':
        'Tạo ảnh sản phẩm đẹp, sạch, sang trọng cho Shopee, TikTok Shop và banner quảng cáo.',
        'asset': 'assets/images/review_product.jpg',
        'button': 'Tạo ảnh',
        'screen': const ImageScreen(),
      },
    ];

    final filteredTemplates = selectedTab == 'all'
        ? allTemplates
        : allTemplates.where((e) => e['type'] == selectedTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    activeMenu: 'home',
                    isLoggedIn: isLoggedIn,
                  ),
                  const SizedBox(height: 34),
                  Center(child: _sectionSwitch()),
                  const SizedBox(height: 28),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      double cardWidth = (constraints.maxWidth - 24) / 2;
                      if (constraints.maxWidth < 900) {
                        cardWidth = constraints.maxWidth;
                      }

                      return Wrap(
                        spacing: 24,
                        runSpacing: 28,
                        children: filteredTemplates.map((item) {
                          return SizedBox(
                            width: cardWidth,
                            child: _templateCard(
                              title: item['title'] as String,
                              description: item['description'] as String,
                              assetPath: item['asset'] as String,
                              buttonText: item['button'] as String,
                              targetScreen: item['screen'] as Widget,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Công cụ AI chuyên biệt',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Các công cụ tạo nội dung và xử lý ảnh/video chuyên sâu',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 4;
                      if (constraints.maxWidth < 1200) crossAxisCount = 3;
                      if (constraints.maxWidth < 850) crossAxisCount = 2;
                      if (constraints.maxWidth < 560) crossAxisCount = 1;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.18,
                        children: [
                          _simpleToolCard(
                            title: 'Chat AI',
                            description:
                            'Viết nội dung, tư vấn, hỗ trợ bán hàng',
                            icon: Icons.chat_bubble_outline,
                            color: const Color(0xFFA855F7),
                            onTap: () => _goTo(const ChatScreen()),
                          ),
                          _simpleToolCard(
                            title: 'Image Studio',
                            description: 'Tạo ảnh sản phẩm, banner, avatar',
                            icon: Icons.image_outlined,
                            color: const Color(0xFF22D3EE),
                            onTap: () => _goTo(const ImageScreen()),
                          ),
                          _simpleToolCard(
                            title: 'Video Studio',
                            description: 'Tạo video review, quảng cáo, avatar',
                            icon: Icons.videocam_outlined,
                            color: const Color(0xFFF97316),
                            onTap: () => _goTo(const VideoScreen()),
                          ),
                          _simpleToolCard(
                            title: 'Profile',
                            description: 'Quản lý tài khoản và lịch sử',
                            icon: Icons.person_outline,
                            color: const Color(0xFF22C55E),
                            onTap: _openProfileGuarded,
                          ),
                          _simpleToolCard(
                            title: 'AI Upscale',
                            description: 'Nâng độ phân giải ảnh lên sắc nét hơn',
                            icon: Icons.bolt_rounded,
                            color: const Color(0xFF38BDF8),
                          ),
                          _simpleToolCard(
                            title: 'Skin Enhancer',
                            description: 'Làm đẹp da và tối ưu ảnh chân dung',
                            icon: Icons.auto_fix_high_rounded,
                            color: const Color(0xFFEC4899),
                          ),
                          _simpleToolCard(
                            title: 'AI Product Creator',
                            description: 'Tạo ảnh sản phẩm chuyên nghiệp nhanh',
                            icon: Icons.shopping_bag_outlined,
                            color: const Color(0xFFA855F7),
                          ),
                          _simpleToolCard(
                            title: 'Scenes Creator',
                            description: 'Phân tích kịch bản và tạo scene tự động',
                            icon: Icons.movie_creation_outlined,
                            color: const Color(0xFF22C55E),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),
                  const Center(
                    child: Text(
                      'Công cụ AI nổi bật',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      if (constraints.maxWidth < 900) crossAxisCount = 1;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.88,
                        children: [
                          _toolShowcaseCard(
                            title:
                            '✦ AI Thay Trang Phục – Tự Động Fit Chuẩn Dáng',
                            description:
                            'Tải lên ảnh người mẫu + ảnh trang phục, AI tự động tạo phiên bản người mẫu diện outfit mới chỉ trong tích tắc.',
                            assetPath: 'assets/images/fashion_selfie.jpg',
                            buttonText: 'Tạo Ảnh',
                            targetScreen: const ImageScreen(),
                          ),
                          _toolShowcaseCard(
                            title:
                            '✦ AI Tạo Ảnh Người Mẫu Giới Thiệu Sản Phẩm',
                            description:
                            'Tải lên ảnh người mẫu và ảnh sản phẩm, AI ghép bối cảnh giới thiệu sản phẩm theo style bán hàng.',
                            assetPath: 'assets/images/review_product.jpg',
                            buttonText: 'Tạo Ảnh',
                            targetScreen: const ImageScreen(),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}