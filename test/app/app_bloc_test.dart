import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/bloc/app_bloc.dart';
import 'package:flutter_base_app/app/bloc/app_event.dart';
import 'package:flutter_base_app/app/bloc/app_state.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_modules.dart';
import 'package:flutter_base_app/app/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppState defaults to full module list and home module', () {
    const state = AppState();

    expect(state.modules, appModules);
    expect(state.module, homeModule);
  });

  test('AppState.copyWith replaces selected module', () {
    const usersModule = AppModule(
      route: AppRoutes.users,
      labelKey: 'users',
      icon: Icons.people_outline,
      order: 2,
    );

    const state = AppState();
    final updated = state.copyWith(module: usersModule);

    expect(updated.module, usersModule);
    expect(updated.modules, appModules);
  });

  test('AppBloc emits selected module and can purge back to initial state', () async {
    final bloc = AppBloc();

    final module = appModules.firstWhere(
      (item) => item.route == AppRoutes.cities,
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        predicate<AppState>((state) => state.module == module),
        equals(const AppState()),
      ]),
    );

    bloc.add(SetModule(module: module));
    bloc.add(const PurgeApp());

    await expectation;
    await bloc.close();
  });

  test('AppBloc SetModules replaces the available modules and resets current module', () async {
    final bloc = AppBloc();
    const modules = <AppModule>[homeModule, logoutModule];

    final expectation = expectLater(
      bloc.stream,
      emits(
        predicate<AppState>((state) {
          return state.modules == modules &&
              state.module == homeModule &&
              state.moduleHistory.isEmpty;
        }),
      ),
    );

    bloc.add(const SetModules(modules: modules));

    await expectation;
    await bloc.close();
  });

  test('AppModule equality includes route metadata', () {
    const left = AppModule(
      route: AppRoutes.users,
      labelKey: 'users',
      icon: Icons.people_outline,
      order: 2,
      permissionPrefixes: <String>['users:'],
    );
    const right = AppModule(
      route: AppRoutes.users,
      labelKey: 'users',
      icon: Icons.people_outline,
      order: 2,
      permissionPrefixes: <String>['users:'],
    );

    expect(left, right);
  });

  test('resolveModulesForPermissions keeps only always-visible and permitted modules', () {
    final modules = resolveModulesForPermissions(const <String>[
      'users:read',
      ' meteo_stations:edit ',
    ]);

    expect(
      modules.map((module) => module.route).toList(),
      <String>[
        AppRoutes.home,
        AppRoutes.users,
        AppRoutes.meteoStations,
        AppRoutes.logout,
      ],
    );
  });
}
