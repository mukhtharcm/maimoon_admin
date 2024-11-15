import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:maimoon_admin/features/posts/repositories/posts_repository.dart';
import 'package:maimoon_admin/features/series/repositories/series_repository.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:maimoon_admin/features/auth/repositories/auth_repository.dart';
import 'package:maimoon_admin/features/auth/bloc/auth_bloc.dart';
import 'package:maimoon_admin/features/tags/repositories/tags_repository.dart';
import 'package:maimoon_admin/features/tags/bloc/tags_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maimoon_admin/features/books/repositories/books_repository.dart';
import 'package:maimoon_admin/features/books/bloc/books_bloc.dart';
import 'package:maimoon_admin/features/auth/repositories/users_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  final authData = prefs.getString('pb_auth');

  final authStore = AsyncAuthStore(
    save: (String data) async => await prefs.setString('pb_auth', data),
    initial: authData,
  );

  const prodUrl = 'https://maimoon.pockethost.io';
  const devUrl = 'http://192.168.103.153:8090';
  // Core services
  getIt.registerLazySingleton<PocketBase>(
    () => PocketBase(kDebugMode ? devUrl : prodUrl, authStore: authStore),
    // use prodUrl for now
    // () => PocketBase(prodUrl, authStore: authStore),
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
  getIt.registerLazySingleton<TagsRepository>(
    () => TagsRepository(),
  );
  getIt.registerLazySingleton<BooksRepository>(
    () => BooksRepository(),
  );
  getIt.registerLazySingleton<UsersRepository>(
    () => UsersRepository(),
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
  getIt.registerFactory<TagsBloc>(
    () => TagsBloc(repository: getIt<TagsRepository>()),
  );
  getIt.registerFactory<BooksBloc>(
    () => BooksBloc(repository: getIt<BooksRepository>()),
  );
}
