import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/features/posts/repositories/posts_repository.dart';
import 'package:maimoon_admin/features/series/repositories/series_repository.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:maimoon_admin/features/auth/repositories/auth_repository.dart';
import 'package:maimoon_admin/features/auth/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  final authData = prefs.getString('pb_auth');

  final authStore = AsyncAuthStore(
    save: (String data) async => await prefs.setString('pb_auth', data),
    initial: authData,
  );
  // Core services
  getIt.registerLazySingleton<PocketBase>(
    () => PocketBase('http://192.168.136.153:8090', authStore: authStore),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(),
  );
  getIt.registerLazySingleton<PostsRepository>(
    () => PostsRepository(),
  );
  getIt.registerLazySingleton<SeriesRepository>(
    () => SeriesRepository(),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(repository: getIt<AuthRepository>())..add(CheckAuthEvent()),
  );
  getIt.registerFactory<PostsBloc>(
    () => PostsBloc(repository: getIt<PostsRepository>()),
  );
  getIt.registerFactory<SeriesBloc>(
    () => SeriesBloc(repository: getIt<SeriesRepository>()),
  );
}
