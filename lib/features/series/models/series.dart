import 'package:pocketbase/pocketbase.dart';

class Series {
  final String id;
  final String name;

  Series({
    required this.id,
    required this.name,
  });

  factory Series.fromRecord(RecordModel record) {
    return Series(
      id: record.id,
      name: record.data['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
