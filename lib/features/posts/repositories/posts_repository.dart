import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';

class PostsRepository {
  final pb = getIt<PocketBase>();

  Future<List<Post>> getPosts() async {
    final records = await pb.collection('posts').getFullList();
    return records.map((record) => Post.fromRecord(record)).toList();
  }

  Future<Post> createPost(Post post) async {
    final record = await pb.collection('posts').create(body: post.toJson());
    return Post.fromRecord(record);
  }

  Future<Post> updatePost(String id, Post post) async {
    final record = await pb.collection('posts').update(id, body: post.toJson());
    return Post.fromRecord(record);
  }

  Future<void> deletePost(String id) async {
    await pb.collection('posts').delete(id);
  }
}
