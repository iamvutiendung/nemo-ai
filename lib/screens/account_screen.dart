import 'package:flutter/material.dart';

import 'home_screen.dart';
import '../services/auth_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final email = user?.email ?? '';
    final provider = user?.appMetadata['provider'] ?? 'email';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Text(
          'Account',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: AuthService.getCurrentProfile(),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final plan = profile?['plan'] ?? 'free';
          final credits = profile?['credits'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _sectionCard(
                  title: 'Thông tin tài khoản',
                  children: [
                    _rowItem('Email', email),
                    _rowItem('Provider', provider.toString()),
                    _rowItem('Plan', plan.toString().toUpperCase()),
                    _rowItem('Credits', credits.toString()),
                  ],
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: 'Bảo mật',
                  children: [
                    _actionItem(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      subtitle: provider == 'google'
                          ? 'Tài khoản Google không cần đổi mật khẩu trong Nemo'
                          : 'Cập nhật mật khẩu đăng nhập',
                      onTap: () {
                        _showComingSoon(context, 'Đổi mật khẩu');
                      },
                    ),
                    _actionItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Xác minh tài khoản',
                      subtitle: 'Kiểm tra trạng thái bảo mật',
                      onTap: () {
                        _showComingSoon(context, 'Xác minh tài khoản');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _sectionCard(
                  title: 'Thanh toán',
                  children: [
                    _actionItem(
                      icon: Icons.diamond_outlined,
                      title: 'Nạp thêm Credits',
                      subtitle: 'Mua thêm lượt tạo ảnh/video AI',
                      onTap: () {
                        _showComingSoon(context, 'Nạp thêm Credits');
                      },
                    ),
                    _actionItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Lịch sử mua',
                      subtitle: 'Xem các giao dịch đã thanh toán',
                      onTap: () {
                        _showComingSoon(context, 'Lịch sử mua');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
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
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
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
}