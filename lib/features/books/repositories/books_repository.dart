import 'dart:typed_data';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'package:maimoon_admin/features/books/domain/models/book.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

class BooksRepository {
  final pb = getIt<PocketBase>();

  Future<List<Book>> getBooks() async {
    final records = await pb.collection('books').getFullList();
    return records.map((record) => Book.fromRecord(record)).toList();
  }

  Future<Book> createBook(
    String title,
    String? description,
    Uint8List? coverBytes,
    String? coverName,
    String? authorId,
    double? price,
    int? pages,
    DateTime? publishDate,
  ) async {
    final body = {
      'title': title,
      if (description != null) 'description': description,
      if (authorId != null) 'author': authorId,
      if (price != null) 'price': price,
      if (pages != null) 'pages': pages,
      if (publishDate != null) 'publishDate': publishDate.toIso8601String(),
    };

    final files = <http.MultipartFile>[];
    if (coverBytes != null && coverName != null) {
      files.add(
        http.MultipartFile.fromBytes(
          'cover',
          coverBytes,
          filename: coverName,
        ),
      );
    }

    final record = await pb.collection('books').create(
          body: body,
          files: files,
        );

    return Book.fromRecord(record);
  }

  Future<void> deleteBook(String id) async {
    await pb.collection('books').delete(id);
  }

  Future<Book> updateBook(
    String id, {
    String? title,
    String? description,
    Uint8List? coverBytes,
    String? coverName,
    String? authorId,
    double? price,
    int? pages,
    DateTime? publishDate,
  }) async {
    final body = {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (authorId != null) 'author': authorId,
      if (price != null) 'price': price,
      if (pages != null) 'pages': pages,
      if (publishDate != null) 'publishDate': publishDate.toIso8601String(),
    };

    final files = <http.MultipartFile>[];
    if (coverBytes != null && coverName != null) {
      files.add(
        http.MultipartFile.fromBytes(
          'cover',
          coverBytes,
          filename: coverName,
        ),
      );
    }

    final record = await pb.collection('books').update(
          id,
          body: body,
          files: files,
        );

    return Book.fromRecord(record);
  }
}
