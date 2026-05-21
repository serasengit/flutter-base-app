import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_routes.dart';

const AppModule homeModule = AppModule(
  route: AppRoutes.home,
  labelKey: 'home',
  icon: Icons.home_outlined,
  order: 1,
  alwaysVisible: true,
);

const AppModule logoutModule = AppModule(
  route: AppRoutes.logout,
  labelKey: 'logout',
  icon: Icons.logout,
  order: 99,
  alwaysVisible: true,
);

const List<AppModule> appModules = <AppModule>[
  homeModule,
  AppModule(
    route: AppRoutes.users,
    labelKey: 'users',
    icon: Icons.people_outline,
    order: 2,
    permissionPrefixes: <String>['users:'],
  ),
  AppModule(
    route: AppRoutes.cities,
    labelKey: 'cities',
    icon: Icons.location_city_outlined,
    order: 3,
    permissionPrefixes: <String>['cities:'],
  ),
  AppModule(
    route: AppRoutes.meteoStations,
    labelKey: 'meteo_stations',
    icon: Icons.cloud_outlined,
    order: 4,
    permissionPrefixes: <String>['meteo_stations:'],
  ),
  logoutModule,
];
