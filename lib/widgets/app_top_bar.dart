import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/image_screen.dart';
import '../screens/video_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/resource_screen.dart';
import '../screens/pricing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/account_screen.dart';
import '../screens/history_screen.dart';
import '../services/auth_service.dart';
import '../services/user_credit_service.dart';

class AppTopBar extends StatelessWidget {
  final String activeMenu;
  final bool isLoggedIn;
  final String creditText;

  const AppTopBar({
    super.key,
    required this.activeMenu,
    required this.isLoggedIn,
    this.creditText = '0',
  });

  void _goTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1830),
        title: Text(title, style: const TextStyle(color: Colors.white)),
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

  void _openUserMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Stack(
          children: [
            Positioned(
              top: 82,
              right: 28,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202938),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Builder(
                          builder: (_) {
                            final user = AuthService.currentUser;
                            final avatarUrl =
                                user?.userMetadata?['avatar_url'] ??
                                    user?.userMetadata?['picture'];

                            if (avatarUrl != null &&
                                avatarUrl.toString().isNotEmpty) {
                              return CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFF8B5CF6),
                                backgroundImage:
                                NetworkImage(avatarUrl.toString()),
                              );
                            }

                            return const CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFF8B5CF6),
                              child: Text(
                                'V',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      FutureBuilder<Map<String, dynamic>?>(
                        future: AuthService.getCurrentProfile(),
                        builder: (context, snapshot) {
                          final profile = snapshot.data;
                          final user = AuthService.currentUser;

                          final name =
                              profile?['full_name'] ??
                                  user?.userMetadata?['full_name'] ??
                                  user?.email?.split('@').first ??
                                  'User';

                          final email =
                              profile?['email'] ??
                                  user?.email ??
                                  '';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      FutureBuilder<Map<String, dynamic>?>(
                        future: AuthService.getCurrentProfile(),
                        builder: (context, snapshot) {
                          final profile = snapshot.data;
                          final credits = profile?['credits'] ?? 0;
                          final plan = profile?['plan'] ?? 'free';

                          return Row(
                            children: [
                              _smallBadge(
                                '$credits Credits',
                                const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 8),
                              _smallBadge(
                                plan.toString().toUpperCase(),
                                const Color(0xFF4B5563),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      _workspaceButton(),

                      const SizedBox(height: 14),
                      const Divider(color: Colors.white12),

                      _userMenuItem(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _goTo(context, const ProfileScreen());
                        },
                      ),
                      _userMenuItem(
                        icon: Icons.manage_accounts_outlined,
                        title: 'Account',
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _goTo(context, const AccountScreen());
                        },
                      ),
                      _userMenuItem(
                        icon: Icons.grid_view_rounded,
                        title: 'My Workflows',
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showComingSoon(context, 'My Workflows');
                        },
                      ),
                      _userMenuItem(
                        icon: Icons.storefront_outlined,
                        title: 'Seller Dashboard',
                        iconColor: Colors.greenAccent,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showComingSoon(context, 'Seller Dashboard');
                        },
                      ),
                      _userMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Lịch sử mua',
                        iconColor: Colors.blueAccent,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showComingSoon(context, 'Lịch sử mua');
                        },
                      ),
                      _userMenuItem(
                        icon: Icons.history,
                        title: 'Lịch sử sử dụng',
                        iconColor: Colors.tealAccent,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _goTo(context, const HistoryScreen());
                        },
                      ),
                      _userMenuItem(
                        icon: Icons.card_giftcard,
                        title: 'Giới thiệu bạn bè',
                        iconColor: Colors.pinkAccent,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showComingSoon(context, 'Giới thiệu bạn bè');
                        },
                      ),
                      _userMenuItem(
                        icon: Icons.groups_2_outlined,
                        title: 'Team của Bạn',
                        iconColor: Colors.cyanAccent,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _showComingSoon(context, 'Team của Bạn');
                        },
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3748),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            FutureBuilder<Map<String, dynamic>?>(
                              future: AuthService.getCurrentProfile(),
                              builder: (context, snapshot) {
                                final profile = snapshot.data;
                                final credits = profile?['credits'] ?? 0;

                                return Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Credits',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      credits.toString(),
                                      style: const TextStyle(
                                        color: Color(0xFF22D3EE),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const LinearProgressIndicator(
                                value: 0.3,
                                minHeight: 7,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation(
                                  Color(0xFF22D3EE),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 34,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  _goTo(context, const PricingScreen());
                                },
                                icon: const Icon(Icons.diamond, size: 15),
                                label: const Text('Nạp thêm Credits'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF155E75),
                                  foregroundColor: Colors.cyanAccent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12),

                      _userMenuItem(
                        icon: Icons.logout,
                        title: 'Đăng xuất',
                        iconColor: Colors.redAccent,
                        textColor: Colors.redAccent,
                        onTap: () async {
                          Navigator.pop(dialogContext);

                          await AuthService.signOut();

                          if (!context.mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                                (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _smallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _workspaceButton() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF5B3A8E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: const Row(
        children: [
          Icon(Icons.business_center_outlined, color: Colors.white70, size: 17),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'My Workspace',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
        ],
      ),
    );
  }

  Widget _userMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.white70,
    Color textColor = Colors.white70,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 19),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topMenuItem(
      BuildContext context,
      String title,
      VoidCallback onTap, {
        bool active = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: active ? null : onTap,
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

  Widget _topButton(
      BuildContext context,
      String title, {
        IconData? icon,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap ?? () => _showComingSoon(context, title),
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
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _creditBox(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PricingScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF071F35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF0EA5E9)),
        ),
        child: FutureBuilder<int>(
          future: UserCreditService.getCredits(),
          builder: (context, snapshot) {
            final credits = snapshot.data ?? 0;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.diamond_outlined,
                  color: Color(0xFF22D3EE),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  credits.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _userButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isLoggedIn || AuthService.isLoggedIn) {
          _openUserMenu(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (_) {
                final user = AuthService.currentUser;
                final avatarUrl =
                    user?.userMetadata?['avatar_url'] ??
                        user?.userMetadata?['picture'];

                if (avatarUrl != null && avatarUrl.toString().isNotEmpty) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF8B5CF6),
                    backgroundImage: NetworkImage(avatarUrl.toString()),
                  );
                }

                return const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF8B5CF6),
                  child: Text(
                    'V',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 10),

            FutureBuilder<Map<String, dynamic>?>(
              future: AuthService.getCurrentProfile(),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final user = AuthService.currentUser;

                final name =
                    profile?['full_name'] ??
                        user?.userMetadata?['full_name'] ??
                        user?.email?.split('@').first ??
                        'User';

                final email =
                    profile?['email'] ??
                        user?.email ??
                        '';

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn || AuthService.isLoggedIn
                          ? name
                          : 'Đăng nhập',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isLoggedIn || AuthService.isLoggedIn
                          ? email
                          : 'Nhấn để mở hồ sơ',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(width: 10),

            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => _goHome(context),
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
          onTap: () => _goHome(context),
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
                _topMenuItem(
                  context,
                  'Image',
                      () => _goTo(context, const ImageScreen()),
                  active: activeMenu == 'image',
                ),
                _topMenuItem(
                  context,
                  'Video',
                      () => _goTo(context, const VideoScreen()),
                  active: activeMenu == 'video',
                ),
                _topMenuItem(
                  context,
                  'Voices',
                      () => _showComingSoon(context, 'Voices'),
                  active: activeMenu == 'voices',
                ),
                _topMenuItem(
                  context,
                  'Apps',
                      () => _showComingSoon(context, 'Apps'),
                  active: activeMenu == 'apps',
                ),
                _topMenuItem(
                  context,
                  'Workflow',
                      () => _showComingSoon(context, 'Workflow'),
                  active: activeMenu == 'workflow',
                ),
                _topMenuItem(
                  context,
                  'Khám phá',
                      () => _showComingSoon(context, 'Khám phá'),
                  active: activeMenu == 'discover',
                ),
                _topMenuItem(
                  context,
                  'Khóa Học',
                      () => _showComingSoon(context, 'Khóa Học'),
                  active: activeMenu == 'course',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        _topButton(
          context,
          'Tài nguyên',
          icon: Icons.folder_open_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResourceScreen()),
            );
          },
        ),

        const SizedBox(width: 10),

        _topButton(
          context,
          'Bảng giá',
          icon: Icons.menu,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PricingScreen()),
            );
          },
        ),

        const SizedBox(width: 10),

        _creditBox(context),

        const SizedBox(width: 10),

        IconButton(
          onPressed: () => _showComingSoon(context, 'Thông báo'),
          icon: const Icon(Icons.notifications_none, color: Colors.white70),
        ),

        const SizedBox(width: 8),

        _userButton(context),
      ],
    );
  }
}