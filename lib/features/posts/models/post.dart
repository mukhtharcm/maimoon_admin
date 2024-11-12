import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';

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

  factory Post.fromRecord(RecordModel record) {
    final pb = getIt<PocketBase>();
    return Post(
      id: record.id,
      title: record.data['title'] ?? '',
      content: record.data['content'] ?? '',
      seriesId: record.data['series'],
      date: record.data['date'] != null
          ? DateTime.parse(record.data['date'])
          : null,
      coverUrl: record.data['cover'] != null
          ? pb.files.getUrl(record, record.data['cover']).toString()
          : null,
      imageUrls: List<String>.from(record.data['images'] ?? [])
          .map(
            (filename) => pb.files.getUrl(record, filename).toString(),
          )
          .toList(),
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
