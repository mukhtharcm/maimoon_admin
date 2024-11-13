import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';

class Series {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? imageFilename;

  Series({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.imageFilename,
  });

  factory Series.fromRecord(RecordModel record) {
    final pb = getIt<PocketBase>();
    final imageFilename = record.data['image'];

    return Series(
      id: record.id,
      name: record.data['name'] ?? '',
      description: record.data['description'],
      imageFilename: imageFilename,
      imageUrl: imageFilename != null && imageFilename.isNotEmpty
          ? pb.files.getUrl(record, imageFilename).toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': imageFilename,
    };
  }
}
