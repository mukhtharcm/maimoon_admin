import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class PostsRepository {
  final pb = getIt<PocketBase>();

  Future<List<Post>> getPosts() async {
    final records = await pb.collection('posts').getFullList();
    return records.map((record) => Post.fromRecord(record)).toList();
  }

  Future<Post> createPost(Post post, {File? coverImage}) async {
    if (coverImage != null) {
      final bytes = await coverImage.readAsBytes();
      final file = http.MultipartFile.fromBytes(
        'cover',
        bytes,
        filename: 'cover_image.jpg',
      );
      final record = await pb.collection('posts').create(
        body: post.toJson(),
        files: [file],
      );
      return Post.fromRecord(record);
    } else {
      final record = await pb.collection('posts').create(body: post.toJson());
      return Post.fromRecord(record);
    }
  }

  Future<Post> updatePost(String id, Post post, {File? coverImage}) async {
    if (coverImage != null) {
      final bytes = await coverImage.readAsBytes();
      final file = http.MultipartFile.fromBytes(
        'cover',
        bytes,
        filename: 'cover_image.jpg',
      );
      final record = await pb.collection('posts').update(
        id,
        body: post.toJson(),
        files: [file],
      );
      return Post.fromRecord(record);
    } else {
      final record =
          await pb.collection('posts').update(id, body: post.toJson());
      return Post.fromRecord(record);
    }
  }

  Future<void> deletePost(String id) async {
    await pb.collection('posts').delete(id);
  }

  Future<void> updatePostOrder(String postId, int newOrder) async {
    await pb.collection('posts').update(
      postId,
      body: {'order': newOrder},
    );
  }
}
