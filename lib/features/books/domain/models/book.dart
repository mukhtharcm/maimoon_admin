import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';

class Book {
  final String id;
  final String title;
  final String? description;
  final String? coverFilename;
  final String? coverUrl;
  final String? authorId;
  final double? price;
  final int? pages;
  final DateTime? publishDate;

  Book({
    required this.id,
    required this.title,
    this.description,
    this.coverFilename,
    this.coverUrl,
    this.authorId,
    this.price,
    this.pages,
    this.publishDate,
  });

  factory Book.fromRecord(RecordModel record) {
    final pb = getIt<PocketBase>();
    final coverFilename = record.data['cover'];

    return Book(
      id: record.id,
      title: record.data['title'] ?? '',
      description: record.data['description'],
      coverFilename: coverFilename,
      coverUrl: coverFilename != null && coverFilename.isNotEmpty
          ? pb.files.getUrl(record, coverFilename).toString()
          : null,
      authorId: record.data['author'],
      price: record.data['price']?.toDouble(),
      pages: record.data['pages'],
      publishDate: record.data['publishDate'] != null
          ? DateTime.parse(record.data['publishDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'cover': coverFilename,
      'author': authorId,
      'price': price,
      'pages': pages,
      'publishDate': publishDate?.toIso8601String(),
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? description,
    String? coverFilename,
    String? coverUrl,
    String? authorId,
    double? price,
    int? pages,
    DateTime? publishDate,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverFilename: coverFilename ?? this.coverFilename,
      coverUrl: coverUrl ?? this.coverUrl,
      authorId: authorId ?? this.authorId,
      price: price ?? this.price,
      pages: pages ?? this.pages,
      publishDate: publishDate ?? this.publishDate,
    );
  }
}
