import 'package:flutter/material.dart';

import 'home_screen.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    final avatarUrl =
        user?.userMetadata?['avatar_url'] ??
            user?.userMetadata?['picture'];

    final name =
        user?.userMetadata?['full_name'] ??
            user?.email?.split('@').first ??
            'User';

    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: AuthService.getCurrentProfile(),
        builder: (context, snapshot) {
          final profile = snapshot.data;

          final credits = profile?['credits'] ?? 0;
          final plan = profile?['plan'] ?? 'free';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                if (avatarUrl != null && avatarUrl.toString().isNotEmpty)
                  CircleAvatar(
                    radius: 52,
                    backgroundImage: NetworkImage(avatarUrl.toString()),
                  )
                else
                  const CircleAvatar(
                    radius: 52,
                    backgroundColor: Color(0xFF8B5CF6),
                    child: Text(
                      'V',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 18),

                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                _infoCard(
                  title: 'Credits',
                  value: '$credits',
                  icon: Icons.bolt,
                  color: Colors.amber,
                ),

                const SizedBox(height: 16),

                _infoCard(
                  title: 'Current Plan',
                  value: plan.toString().toUpperCase(),
                  icon: Icons.workspace_premium,
                  color: Colors.greenAccent,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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
                    label: const Text(
                      'Đăng xuất',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}