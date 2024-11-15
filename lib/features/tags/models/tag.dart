import 'package:pocketbase/pocketbase.dart';

class Tag {
  final String id;
  final String name;
  final String? slug;
  final String? description;

  Tag({
    required this.id,
    required this.name,
    this.slug,
    this.description,
  });

  factory Tag.fromRecord(RecordModel record) {
    return Tag(
      id: record.id,
      name: record.data['name'] ?? '',
      slug: record.data['slug'],
      description: record.data['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
    };
  }
}
