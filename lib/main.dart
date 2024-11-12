import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'package:maimoon_admin/core/router/router.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';

void main() {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<PostsBloc>()),
        BlocProvider(create: (_) => getIt<SeriesBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Maimoon Admin',
        routerConfig: router,
        theme: FlexThemeData.light(
          scheme: FlexScheme.espresso,
          useMaterial3: true,
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 1,
          subThemesData: const FlexSubThemesData(
            elevatedButtonRadius: 8,
            outlinedButtonRadius: 8,
            inputDecoratorRadius: 8,
            cardRadius: 12,
            popupMenuRadius: 8,
            dialogRadius: 16,
          ),
        ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.espresso,
          useMaterial3: true,
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 2,
          subThemesData: const FlexSubThemesData(
            elevatedButtonRadius: 8,
            outlinedButtonRadius: 8,
            inputDecoratorRadius: 8,
            cardRadius: 12,
            popupMenuRadius: 8,
            dialogRadius: 16,
          ),
        ),
        themeMode: ThemeMode.system,
      ),
    );
  }
}
