import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maimoon_admin/core/di/service_locator.dart';
import 'package:maimoon_admin/features/posts/bloc/posts_bloc.dart';
import 'package:maimoon_admin/features/series/bloc/series_bloc.dart';
import 'package:maimoon_admin/features/auth/bloc/auth_bloc.dart';
import 'package:maimoon_admin/features/home/presentation/pages/home_page.dart';
import 'package:maimoon_admin/features/auth/presentation/pages/login_page.dart';
import 'package:maimoon_admin/features/tags/bloc/tags_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.notoSansTextTheme();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<PostsBloc>()),
        BlocProvider(create: (_) => getIt<SeriesBloc>()),
        BlocProvider(create: (_) => getIt<TagsBloc>()),
      ],
      child: MaterialApp(
        title: 'Maimoon Admin',
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const HomePage();
            }
            return const LoginPage();
          },
        ),
        theme: FlexThemeData.light(
          colors: const FlexSchemeColor(
            primary: Color(0xFF006A60),
            primaryContainer: Color(0xFF74F8E5),
            secondary: Color(0xFF4A6363),
            secondaryContainer: Color(0xFFCCE8E7),
            tertiary: Color(0xFF4B607C),
            tertiaryContainer: Color(0xFFD3E4FF),
            error: Color(0xFFBA1A1A),
            errorContainer: Color(0xFFFFDAD6),
          ),
          useMaterial3: true,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
          blendLevel: 1,
          appBarStyle: FlexAppBarStyle.surface,
          appBarOpacity: 0.95,
          appBarElevation: 0.5,
          transparentStatusBar: true,
          tabBarStyle: FlexTabBarStyle.forBackground,
          subThemesData: const FlexSubThemesData(
            interactionEffects: true,
            tintedDisabledControls: true,
            useTextTheme: true,
            elevatedButtonSchemeColor: SchemeColor.tertiary,
            elevatedButtonSecondarySchemeColor: SchemeColor.onTertiary,
            outlinedButtonOutlineSchemeColor: SchemeColor.tertiary,
            toggleButtonsBorderSchemeColor: SchemeColor.primary,
            segmentedButtonSchemeColor: SchemeColor.primary,
            defaultRadius: 8,
            inputDecoratorRadius: 8,
            cardRadius: 12,
            popupMenuRadius: 8,
            dialogRadius: 16,
            bottomSheetRadius: 16,
            timePickerDialogRadius: 16,
            datePickerDialogRadius: 16,
            bottomNavigationBarElevation: 2,
            navigationBarIndicatorSchemeColor: SchemeColor.tertiary,
            navigationBarIndicatorOpacity: 0.24,
            navigationBarMutedUnselectedLabel: false,
            navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
            navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
            navigationBarSelectedIconSchemeColor: SchemeColor.primary,
            navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
            navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
            navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
            navigationRailSelectedIconSchemeColor: SchemeColor.primary,
            navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
          ),
          keyColors: const FlexKeyColors(
            useSecondary: true,
            useTertiary: true,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          fontFamily: textTheme.bodyLarge?.fontFamily,
        ),
        darkTheme: FlexThemeData.dark(
          colors: const FlexSchemeColor(
            primary: Color(0xFF53DBc9),
            primaryContainer: Color(0xFF004E45),
            secondary: Color(0xFFB0CCCB),
            secondaryContainer: Color(0xFF334B4B),
            tertiary: Color(0xFFB4C8E9),
            tertiaryContainer: Color(0xFF334863),
            error: Color(0xFFFFB4AB),
            errorContainer: Color(0xFF93000A),
          ),
          useMaterial3: true,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
          blendLevel: 2,
          appBarStyle: FlexAppBarStyle.surface,
          appBarOpacity: 0.95,
          appBarElevation: 0.5,
          transparentStatusBar: true,
          tabBarStyle: FlexTabBarStyle.forBackground,
          subThemesData: const FlexSubThemesData(
            interactionEffects: true,
            tintedDisabledControls: true,
            useTextTheme: true,
            elevatedButtonSchemeColor: SchemeColor.tertiary,
            elevatedButtonSecondarySchemeColor: SchemeColor.onTertiary,
            outlinedButtonOutlineSchemeColor: SchemeColor.tertiary,
            toggleButtonsBorderSchemeColor: SchemeColor.primary,
            segmentedButtonSchemeColor: SchemeColor.primary,
            defaultRadius: 8,
            inputDecoratorRadius: 8,
            cardRadius: 12,
            popupMenuRadius: 8,
            dialogRadius: 16,
            bottomSheetRadius: 16,
            timePickerDialogRadius: 16,
            datePickerDialogRadius: 16,
            bottomNavigationBarElevation: 2,
            navigationBarIndicatorSchemeColor: SchemeColor.tertiary,
            navigationBarIndicatorOpacity: 0.24,
            navigationBarMutedUnselectedLabel: false,
            navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
            navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
            navigationBarSelectedIconSchemeColor: SchemeColor.primary,
            navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
            navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
            navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
            navigationRailSelectedIconSchemeColor: SchemeColor.primary,
            navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
          ),
          keyColors: const FlexKeyColors(
            useSecondary: true,
            useTertiary: true,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          fontFamily: textTheme.bodyLarge?.fontFamily,
        ),
        themeMode: ThemeMode.system,
      ),
    );
  }
}
