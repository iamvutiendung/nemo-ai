enum ResourceType {
  image,
  video,
  voice,
  upscale,
  upload,
}

class ResourceItem {
  final String id;
  final ResourceType type;
  final String title;
  final String path;
  final DateTime createdAt;
  final String? duration;
  final bool isFavorite;

  ResourceItem({
    required this.id,
    required this.type,
    required this.title,
    required this.path,
    required this.createdAt,
    this.duration,
    this.isFavorite = false,
  });
}