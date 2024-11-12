import 'package:flutter/material.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'package:maimoon_admin/features/auth/repositories/auth_repository.dart';
import 'package:maimoon_admin/features/auth/presentation/pages/login_page.dart';
import 'package:maimoon_admin/features/home/presentation/pages/home_page.dart';
import 'package:maimoon_admin/features/posts/presentation/pages/posts_page.dart';
import 'package:maimoon_admin/features/series/presentation/pages/series_page.dart';
import 'package:maimoon_admin/features/posts/presentation/pages/post_form_page.dart';
import 'package:maimoon_admin/features/posts/models/post.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/posts':
        return MaterialPageRoute(builder: (_) => const PostsPage());
      case '/posts/new':
        final args = settings.arguments as Map<String, dynamic>?;
        final String? seriesId = args?['seriesId'];
        return MaterialPageRoute(
          builder: (_) => PostFormPage(initialSeriesId: seriesId),
        );
      case '/posts/edit':
        final post = settings.arguments as Post;
        return MaterialPageRoute(
          builder: (_) => PostFormPage(post: post),
        );
      case '/series':
        return MaterialPageRoute(builder: (_) => const SeriesPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Widget getInitialPage() {
    final isAuthenticated = getIt<AuthRepository>().isAuthenticated;
    return isAuthenticated ? const HomePage() : const LoginPage();
  }
}
