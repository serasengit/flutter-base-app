import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/bloc/app_bloc.dart';
import 'package:flutter_base_app/app/bloc/app_event.dart';
import 'package:flutter_base_app/app/bloc/app_state.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_routes.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_base_app/features/cities/presentation/views/cities_view.dart';
import 'package:flutter_base_app/features/home/presentation/views/home_module_view.dart';
import 'package:flutter_base_app/features/meteo_stations/presentation/views/meteo_stations_view.dart';
import 'package:flutter_base_app/features/users/presentation/views/users_view.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final currentModule = state.module;

        return PopScope<Object?>(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              if (state.canGoBackModule) {
                context.read<AppBloc>().add(const PopModule());
                return;
              }

              context.read<AuthBloc>().add(const LogOut());
            }
          },
          child: Scaffold(
          appBar: AppBar(title: Text(_getModuleTitle(l10n, currentModule))),
          drawer: _HomeDrawer(
            title: l10n.modules,
            modules: state.modules,
            currentModule: currentModule,
          ),
          body: _buildModuleView(currentModule),
          ),
        );
      },
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({
    required this.title,
    required this.modules,
    required this.currentModule,
  });

  final String title;
  final List<AppModule> modules;
  final AppModule currentModule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryModules = modules
        .where((module) => module.route != AppRoutes.logout)
        .toList();
    final logoutModules = modules
        .where((module) => module.route == AppRoutes.logout)
        .toList();
    final logoutModule = logoutModules.isEmpty ? null : logoutModules.first;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: primaryModules
                    .map(
                      (module) => ListTile(
                        onTap: () {
                          Navigator.of(context).pop();

                          if (module.route == AppRoutes.logout) {
                            context.read<AuthBloc>().add(const LogOut());
                            return;
                          }

                          context.read<AppBloc>().add(
                            SetModule(module: module),
                          );
                        },
                        title: Text(_getModuleTitle(l10n, module)),
                        subtitle: Text(_getModuleDescription(l10n, module)),
                        leading: Icon(module.icon),
                        selected: currentModule == module,
                      ),
                    )
                    .toList(),
              ),
            ),
            if (logoutModule != null) ...[
              const Divider(),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(const LogOut());
                },
                title: Text(_getModuleTitle(l10n, logoutModule)),
                subtitle: Text(_getModuleDescription(l10n, logoutModule)),
                leading: Icon(logoutModule.icon),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _getModuleTitle(AppLocalizations l10n, AppModule module) {
  return switch (module.route) {
    AppRoutes.home => l10n.home,
    AppRoutes.users => l10n.users,
    AppRoutes.cities => l10n.cities,
    AppRoutes.meteoStations => l10n.meteo_stations,
    AppRoutes.logout => l10n.logout,
    _ => module.labelKey,
  };
}

String _getModuleDescription(AppLocalizations l10n, AppModule module) {
  return switch (module.route) {
    AppRoutes.home => l10n.home_module_description,
    AppRoutes.users => l10n.users_module_description,
    AppRoutes.cities => l10n.cities_module_description,
    AppRoutes.meteoStations => l10n.meteo_stations_module_description,
    AppRoutes.logout => l10n.logout_module_description,
    _ => module.labelKey,
  };
}

Widget _buildModuleView(AppModule module) {
  return switch (module.route) {
    AppRoutes.home => const HomeModuleView(),
    AppRoutes.users => const UsersView(),
    AppRoutes.cities => const CitiesView(),
    AppRoutes.meteoStations => const MeteoStationsView(),
    _ => const HomeModuleView(),
  };
}
