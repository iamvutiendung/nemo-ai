import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/video_job.dart';

class HoverVideoPreviewCard extends StatefulWidget {
  final VideoJob job;
  final VoidCallback? onTap;

  const HoverVideoPreviewCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  State<HoverVideoPreviewCard> createState() =>
      _HoverVideoPreviewCardState();
}

class _HoverVideoPreviewCardState
    extends State<HoverVideoPreviewCard> {
  VideoPlayerController? controller;

  bool isHovering = false;
  bool isReady = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _startPreview() async {
    if (widget.job.videoUrl.isEmpty) return;

    setState(() {
      isHovering = true;
    });

    if (controller != null) {
      if (isReady) {
        await controller!.play();
      }
      return;
    }

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.job.videoUrl),
    );

    await controller!.initialize();

    await controller!.setLooping(true);
    await controller!.setVolume(0);
    await controller!.play();

    if (!mounted) return;

    setState(() {
      isReady = true;
    });
  }

  Future<void> _stopPreview() async {
    setState(() {
      isHovering = false;
    });

    if (controller != null && isReady) {
      await controller!.pause();
      await controller!.seekTo(Duration.zero);
    }
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    return '$day/$month $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _startPreview(),
      onExit: (_) => _stopPreview(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovering
                  ? const Color(0xFF8B5CF6)
                  : Colors.white12,
            ),
            boxShadow: isHovering
                ? [
              BoxShadow(
                color: const Color(0xFF8B5CF6)
                    .withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _previewContent(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.job.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.job.prompt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _miniTag(widget.job.duration),
                  const SizedBox(width: 6),
                  _miniTag(widget.job.resolution),
                  const Spacer(),
                  Text(
                    _formatDate(widget.job.date),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewContent() {
    if (widget.job.videoUrl.isEmpty) {
      return _placeholder('Chưa có video URL');
    }

    if (controller != null &&
        controller!.value.isInitialized &&
        isHovering) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller!.value.size.width,
          height: controller!.value.size.height,
          child: VideoPlayer(controller!),
        ),
      );
    }

    return _placeholder('Rê chuột để xem');
  }

  Widget _placeholder(String text) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_fill,
              color: Colors.white54,
              size: 40,
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTag(String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}