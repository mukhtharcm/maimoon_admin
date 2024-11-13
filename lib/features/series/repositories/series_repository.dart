import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/features/series/models/series.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class SeriesRepository {
  final pb = getIt<PocketBase>();

  Future<List<Series>> getAllSeries() async {
    final records = await pb.collection('series').getFullList();
    return records.map((record) => Series.fromRecord(record)).toList();
  }

  Future<Series> createSeries(Series series, {File? image}) async {
    if (image != null) {
      final bytes = await image.readAsBytes();
      final file = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'series_image.jpg',
      );
      final record = await pb.collection('series').create(
        body: series.toJson(),
        files: [file],
      );
      return Series.fromRecord(record);
    } else {
      final record =
          await pb.collection('series').create(body: series.toJson());
      return Series.fromRecord(record);
    }
  }

  Future<Series> updateSeries(String id, Series series, {File? image}) async {
    if (image != null) {
      final bytes = await image.readAsBytes();
      final file = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'series_image.jpg',
      );
      final record = await pb.collection('series').update(
        id,
        body: series.toJson(),
        files: [file],
      );
      return Series.fromRecord(record);
    } else {
      final record =
          await pb.collection('series').update(id, body: series.toJson());
      return Series.fromRecord(record);
    }
  }

  Future<void> deleteSeries(String id) async {
    await pb.collection('series').delete(id);
  }
}
