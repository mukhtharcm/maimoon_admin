import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maimoon_admin/features/home/presentation/pages/home_page.dart';
import 'package:maimoon_admin/features/posts/presentation/pages/posts_page.dart';
import 'package:maimoon_admin/features/series/presentation/pages/series_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/posts',
      builder: (context, state) => const PostsPage(),
    ),
    GoRoute(
      path: '/series',
      builder: (context, state) => const SeriesPage(),
    ),
  ],
);
