import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/video_job.dart';

class VideoService {
  static final SupabaseClient _client = Supabase.instance.client;

  static final List<VideoJob> _localJobs = [];

  static Future<void> addJob(VideoJob job) async {
    _localJobs.insert(0, job);

    final user = _client.auth.currentUser;

    if (user == null) {
      return;
    }

    await _client.from('video_jobs').insert({
      'user_id': user.id,
      'title': job.title,
      'prompt': job.prompt,
      'video_url': job.videoUrl,
      'duration': job.duration,
      'resolution': job.resolution,
      'status': job.status,
    });
  }

  static Future<List<VideoJob>> getJobs() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return List<VideoJob>.from(_localJobs);
    }

    try {
      final List<dynamic> data = await _client
          .from('video_jobs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return data.map<VideoJob>((item) {
        return VideoJob(
          title: item['title']?.toString() ?? '',
          prompt: item['prompt']?.toString() ?? '',
          videoUrl: item['video_url']?.toString() ?? '',
          duration: item['duration']?.toString() ?? '',
          resolution: item['resolution']?.toString() ?? '',
          date: item['created_at']?.toString() ?? '',
          status: item['status']?.toString() ?? 'Done',
        );
      }).toList();
    } catch (_) {
      return List<VideoJob>.from(_localJobs);
    }
  }

  static List<VideoJob> getLocalJobs() {
    return List<VideoJob>.from(_localJobs);
  }

  static void clearLocalJobs() {
    _localJobs.clear();
  }
}