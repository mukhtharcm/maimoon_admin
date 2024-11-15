import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/features/tags/models/tag.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';

class TagsRepository {
  final pb = getIt<PocketBase>();

  Future<List<Tag>> getAllTags() async {
    final records = await pb.collection('tags').getFullList();
    return records.map((record) => Tag.fromRecord(record)).toList();
  }

  Future<Tag> createTag(Tag tag) async {
    final record = await pb.collection('tags').create(body: tag.toJson());
    return Tag.fromRecord(record);
  }

  Future<Tag> updateTag(String id, Tag tag) async {
    final record = await pb.collection('tags').update(id, body: tag.toJson());
    return Tag.fromRecord(record);
  }

  Future<void> deleteTag(String id) async {
    await pb.collection('tags').delete(id);
  }
}
