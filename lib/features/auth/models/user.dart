import 'package:pocketbase/pocketbase.dart';

class User {
  final String id;
  final String name;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory User.fromRecord(RecordModel record) {
    return User(
      id: record.id,
      name: record.data['name'] ?? 'Unknown User',
      avatarUrl: record.getStringValue('avatar'),
    );
  }
}
