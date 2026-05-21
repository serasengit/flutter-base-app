import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/bloc/app_event.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEvent', () {
    const module = AppModule(
      route: AppRoutes.users,
      labelKey: 'users',
      icon: Icons.people_outline,
      order: 1,
    );

    test('base AppEvent has empty props', () {
      const event = PurgeApp();

      expect(event.props, isEmpty);
    });

    test('SetModule supports equality through props', () {
      const event = SetModule(module: module);

      expect(event, const SetModule(module: module));
      expect(event.props, <Object?>[module]);
    });

    test('SetModules supports equality through props', () {
      const modules = <AppModule>[module];
      const event = SetModules(modules: modules);

      expect(event, const SetModules(modules: modules));
      expect(event.props, <Object?>[modules]);
    });

    test('PurgeApp supports equality through props', () {
      const event = PurgeApp();

      expect(event, const PurgeApp());
      expect(event.props, isEmpty);
    });
  });
}
