import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class RealHoverVideoCard extends StatefulWidget {
  final String videoAsset;
  final String title;
  final String subtitle;

  const RealHoverVideoCard({
    super.key,
    required this.videoAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  State<RealHoverVideoCard> createState() => _RealHoverVideoCardState();
}

class _RealHoverVideoCardState extends State<RealHoverVideoCard> {
  late VideoPlayerController _controller;

  bool isHovering = false;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() {
          isReady = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    setState(() {
      isHovering = true;
    });

    if (isReady) {
      _controller.play();
    }
  }

  void _stop() {
    setState(() {
      isHovering = false;
    });

    if (isReady) {
      _controller.pause();
      _controller.seekTo(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _play(),
      onExit: (_) => _stop(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 250,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
            isHovering
                ? const Color(0xFF8B5CF6)
                : Colors.white12,
          ),
          boxShadow:
          isHovering
              ? [
            BoxShadow(
              color: const Color(
                0xFF8B5CF6,
              ).withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child:
                isReady
                    ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
                    : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),

              if (!isHovering)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white70,
                        size: 70,
                      ),
                    ),
                  ),
                ),

              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        isHovering
                            ? 'Đang phát preview...'
                            : widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}