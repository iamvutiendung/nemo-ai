import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class DownloadVideoScreen extends StatefulWidget {
  const DownloadVideoScreen({super.key});

  @override
  State<DownloadVideoScreen> createState() => _DownloadVideoScreenState();
}

class _DownloadVideoScreenState extends State<DownloadVideoScreen> {
  int selectedTab = 0;
  bool isDownloading = false;
  final Dio dio = Dio();

  final tiktokController = TextEditingController();
  final facebookController = TextEditingController();

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được trang tải video')),
      );
    }
  }

  Future<void> _downloadTikTok() async {
    await _downloadVideoFromBackend(
      url: tiktokController.text,
      platform: 'tiktok',
    );
  }

  Future<void> _downloadFacebook() async {
    await _downloadVideoFromBackend(
      url: facebookController.text,
      platform: 'facebook',
    );
  }

  @override
  void dispose() {
    tiktokController.dispose();
    facebookController.dispose();
    super.dispose();
  }

  Widget _tabButton({
    required String title,
    required int index,
  }) {
    final isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
              colors: [
                Color(0xFFEC4899),
                Color(0xFF8B5CF6),
              ],
            )
                : null,
            color: isActive ? null : const Color(0xFF1E2A3D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.white12,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _downloadBox({
    required String title,
    required String subtitle,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onDownload,
  }) {
    return Container(
      width: 760,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4658),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF556274)),
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(
                        Icons.link,
                        color: Colors.white38,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isDownloading ? null : onDownload,
                  icon: isDownloading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.download),
                  label: Text(
                    isDownloading ? 'Đang tải...' : 'Tải xuống',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _FeatureItem(text: 'Dán link video'),
              _FeatureItem(text: 'Mở trang tải'),
              _FeatureItem(text: 'Tải về máy'),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> _downloadVideoFromBackend({
    required String url,
    required String platform,
  }) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng dán link video')),
      );
      return;
    }

    setState(() {
      isDownloading = true;
    });

    try {
      final response = await dio.post(
        'https://nemo-ai-production.up.railway.app',
        data: {
          'url': url.trim(),
          'platform': platform,
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        final downloadUrl = data['downloadUrl'];

        await launchUrl(
          Uri.parse(downloadUrl),
          mode: LaunchMode.externalApplication,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo file tải xuống')),
        );
      } else {
        throw data['message'];
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải video: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTikTok = selectedTab == 0;

    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Text(
              'Tải video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Dán link video TikTok hoặc Facebook để tải về máy',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 32),

            Container(
              width: 760,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF111C2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  _tabButton(title: 'Tải video TikTok', index: 0),
                  const SizedBox(width: 8),
                  _tabButton(title: 'Tải video Facebook', index: 1),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (isTikTok)
              _downloadBox(
                title: 'Tải Video TikTok Không Logo',
                subtitle: 'Dán link video TikTok, sau đó bấm tải xuống',
                hint: 'Nhập link video TikTok',
                controller: tiktokController,
                onDownload: _downloadTikTok,
              )
            else
              _downloadBox(
                title: 'Download Facebook Video',
                subtitle: 'Dán link video Facebook, sau đó bấm tải xuống',
                hint: 'Nhập link video Facebook',
                controller: facebookController,
                onDownload: _downloadFacebook,
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_box,
          color: Color(0xFF22C55E),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}