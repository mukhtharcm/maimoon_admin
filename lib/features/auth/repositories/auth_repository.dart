import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';

class AuthRepository {
  final pb = getIt<PocketBase>();

  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }

  Future<void> logout() async {
    pb.authStore.clear();
  }

  bool get isAuthenticated => pb.authStore.isValid;

  String? get token => pb.authStore.token;
}
