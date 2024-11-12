import 'package:go_router/go_router.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'package:maimoon_admin/features/auth/repositories/auth_repository.dart';
import 'package:maimoon_admin/features/auth/presentation/pages/login_page.dart';
import 'package:maimoon_admin/features/home/presentation/pages/home_page.dart';
import 'package:maimoon_admin/features/posts/presentation/pages/posts_page.dart';
import 'package:maimoon_admin/features/series/presentation/pages/series_page.dart';
import 'package:maimoon_admin/features/posts/presentation/pages/post_form_page.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isAuthenticated = getIt<AuthRepository>().isAuthenticated;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isAuthenticated && !isLoginRoute) {
      return '/login';
    }
    if (isAuthenticated && isLoginRoute) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/posts',
      builder: (context, state) => const PostsPage(),
    ),
    GoRoute(
      path: '/posts/new',
      builder: (context, state) => const PostFormPage(),
    ),
    GoRoute(
      path: '/posts/edit/:id',
      builder: (context, state) {
        final post = (state.extra as Post);
        return PostFormPage(post: post);
      },
    ),
    GoRoute(
      path: '/series',
      builder: (context, state) => const SeriesPage(),
    ),
  ],
);
