import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String? seriesId;
  final DateTime? date;
  final String? coverUrl;
  final String? coverFilename;
  final List<String> imageUrls;
  final int order;
  final String? authorId;
  final List<String> tagIds;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.seriesId,
    this.date,
    this.coverUrl,
    this.coverFilename,
    this.imageUrls = const [],
    this.order = 0,
    this.authorId,
    this.tagIds = const [],
  });

  factory Post.fromRecord(RecordModel record) {
    final pb = getIt<PocketBase>();
    final coverFilename = record.data['cover'];

    return Post(
      id: record.id,
      title: record.data['title'] ?? '',
      content: record.data['content'] ?? '',
      seriesId: record.data['series'],
      date: record.data['date'] != null
          ? DateTime.parse(record.data['date'])
          : null,
      coverFilename: coverFilename,
      coverUrl: coverFilename != null && coverFilename.isNotEmpty
          ? pb.files.getUrl(record, coverFilename).toString()
          : null,
      imageUrls: List<String>.from(record.data['images'] ?? [])
          .map((filename) => pb.files.getUrl(record, filename).toString())
          .toList(),
      order: record.data['order'] ?? 0,
      authorId: record.data['author'],
      tagIds: List<String>.from(record.data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'series': seriesId,
      'date': date?.toIso8601String(),
      'cover': coverFilename,
      'images': imageUrls,
      'order': order,
      'author': authorId,
      'tags': tagIds,
    };
  }
}
