class VideoJob {
  final String title;
  final String prompt;
  final String duration;
  final String resolution;
  final String date;
  String status;
  final String videoUrl; // 🔥 THÊM DÒNG NÀY

  VideoJob({
    required this.title,
    required this.prompt,
    required this.duration,
    required this.resolution,
    required this.date,
    required this.status,
    required this.videoUrl, // 🔥 THÊM DÒNG NÀY
  });
}