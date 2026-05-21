import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/bloc/app_bloc.dart';
import 'package:flutter_base_app/app/bloc/app_event.dart';
import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_base_app/app/theme/color_palette.dart';
import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_base_app/core/network/request_feedback_coordinator.dart';
import 'package:flutter_base_app/core/utils/functions.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_base_app/features/auth/presentation/views/auth_view.dart';
import 'package:flutter_base_app/features/home/presentation/home_page.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';

/// Root widget of the application.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppBloc _appBloc;
  late final AuthBloc _authBloc;
  late final RequestFeedbackCoordinator _requestFeedbackController;

  /// Global navigator key used to access navigation outside the widget tree.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Resolve application dependencies.
    _appBloc = locator<AppBloc>();
    _authBloc = locator<AuthBloc>();
    _requestFeedbackController = locator<RequestFeedbackCoordinator>();

    // Bind the navigator key to the request feedback coordinator.
    _requestFeedbackController.bind(_navigatorKey);
  }

  @override
  void dispose() {
    unawaited(_requestFeedbackController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide the application bloc instance.
        BlocProvider<AppBloc>.value(value: _appBloc),

        // Provide the authentication bloc instance.
        BlocProvider<AuthBloc>.value(value: _authBloc),
      ],
      child: GlobalLoaderOverlay(
        // Global loading indicator displayed over the current screen.
        overlayWidgetBuilder: (_) => const Center(
          child: CircularProgressIndicator(color: ColorPalette.primaryColor),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          // Listen only when the user changes from authenticated to unauthenticated.
          listenWhen: (previous, current) =>
              isSet(previous.auth) && !isSet(current.auth),
          listener: (context, state) {
            // Clear application state when the user logs out.
            context.read<AppBloc>().add(const PurgeApp());
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return MaterialApp(
                navigatorKey: _navigatorKey,
                debugShowCheckedModeBanner: false,
                title: AppConfig.appName,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: _getAppTheme(),

                // Display the authentication screen when there is no active user.
                home: !isSet(state.auth) ? const AuthView() : const HomePage(),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Builds the global Material theme used by the application.
ThemeData _getAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: ColorPalette.primaryColor,
    primary: ColorPalette.primaryColor,
    secondary: ColorPalette.secondaryColor,
    tertiary: ColorPalette.tertiaryColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,

    // App bar default styling.
    appBarTheme: AppBarTheme(
      backgroundColor: ColorPalette.primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    // Card default styling.
    cardTheme: CardThemeData(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ColorPalette.secondaryColor, width: 0.5),
      ),
    ),

    // Divider default styling.
    dividerTheme: const DividerThemeData(
      thickness: 1,
      space: 0,
      color: ColorPalette.secondaryColor,
    ),

    // Chip default styling.
    chipTheme: ChipThemeData(
      showCheckmark: true,
      selectedColor: ColorPalette.tertiaryColor.withValues(alpha: 0.2),
      secondarySelectedColor: ColorPalette.tertiaryColor.withValues(alpha: 0.2),
      side: const BorderSide(color: ColorPalette.secondaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    // Elevated button default styling.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: ColorPalette.primaryColor.withValues(
          alpha: 0.45,
        ),
        disabledForegroundColor: Colors.white70,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    // Floating action button default styling.
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ColorPalette.tertiaryColor,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),

    // Input fields default styling.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      prefixIconColor: ColorPalette.secondaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ColorPalette.primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    ),

    // Progress indicator default styling.
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ColorPalette.primaryColor,
    ),

    // Bottom app bar default styling.
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: ColorPalette.primaryColor,
    ),
  );
}
