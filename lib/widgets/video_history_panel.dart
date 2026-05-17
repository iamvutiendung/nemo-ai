import 'package:flutter/material.dart';

import '../models/video_job.dart';
import '../services/video_service.dart';
import 'hover_video_preview_card.dart';

class VideoHistoryPanel extends StatefulWidget {
  final Function(VideoJob job)? onTapJob;

  const VideoHistoryPanel({
    super.key,
    this.onTapJob,
  });

  @override
  State<VideoHistoryPanel> createState() => VideoHistoryPanelState();
}

class VideoHistoryPanelState extends State<VideoHistoryPanel> {
  late Future<List<VideoJob>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _reloadJobs();
  }

  void _reloadJobs() {
    _jobsFuture = VideoService.getJobs();
  }

  Future<void> refresh() async {
    setState(() {
      _reloadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          left: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '📁 Lịch sử tạo video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: refresh,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<VideoJob>>(
              future: _jobsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final jobs = snapshot.data ?? [];

                if (jobs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có video',
                      style: TextStyle(color: Colors.white38),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = jobs[index];

                      return HoverVideoPreviewCard(
                        job: job,
                        onTap: () {
                          widget.onTapJob?.call(job);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}