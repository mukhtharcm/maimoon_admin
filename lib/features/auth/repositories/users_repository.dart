import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'package:maimoon_admin/features/auth/models/user.dart';

class UsersRepository {
  final pb = getIt<PocketBase>();

  Future<List<User>> getUsers() async {
    final records = await pb.collection('users').getFullList();
    return records.map((record) => User.fromRecord(record)).toList();
  }
}
