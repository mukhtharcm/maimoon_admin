class Post {
  final String id;
  final String title;
  final String content;
  final String? seriesId;
  final DateTime? date;
  final String? coverUrl;
  final List<String> imageUrls;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.seriesId,
    this.date,
    this.coverUrl,
    this.imageUrls = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      seriesId: json['series'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      coverUrl: json['cover'],
      imageUrls: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'series': seriesId,
      'date': date?.toIso8601String(),
      'cover': coverUrl,
      'images': imageUrls,
    };
  }
}
