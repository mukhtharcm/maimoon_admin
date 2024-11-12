import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/features/series/models/series.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';

class SeriesRepository {
  final pb = getIt<PocketBase>();

  Future<List<Series>> getAllSeries() async {
    final records = await pb.collection('series').getFullList();
    return records.map((record) => Series.fromRecord(record)).toList();
  }

  Future<Series> createSeries(Series series) async {
    final record = await pb.collection('series').create(body: series.toJson());
    return Series.fromRecord(record);
  }

  Future<Series> updateSeries(String id, Series series) async {
    final record =
        await pb.collection('series').update(id, body: series.toJson());
    return Series.fromRecord(record);
  }

  Future<void> deleteSeries(String id) async {
    await pb.collection('series').delete(id);
  }
}
