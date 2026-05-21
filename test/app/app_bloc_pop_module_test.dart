import 'package:flutter_base_app/app/bloc/app_bloc.dart';
import 'package:flutter_base_app/app/bloc/app_event.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_modules.dart';
import 'package:flutter_base_app/app/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

AppModule _moduleByRoute(String route) {
  return appModules.firstWhere((module) => module.route == route);
}

void main() {
  group('AppBloc PopModule', () {
    test('returns to previous modules in reverse order', () async {
      final bloc = AppBloc();
      final usersModule = _moduleByRoute(AppRoutes.users);
      final citiesModule = _moduleByRoute(AppRoutes.cities);

      bloc
        ..add(SetModule(module: usersModule))
        ..add(SetModule(module: citiesModule));

      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.module, citiesModule);
      expect(bloc.state.moduleHistory, <Object>[homeModule, usersModule]);
      expect(bloc.state.canGoBackModule, isTrue);

      bloc.add(const PopModule());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.module, usersModule);
      expect(bloc.state.moduleHistory, <Object>[homeModule]);
      expect(bloc.state.canGoBackModule, isTrue);

      bloc.add(const PopModule());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.module, homeModule);
      expect(bloc.state.moduleHistory, isEmpty);
      expect(bloc.state.canGoBackModule, isFalse);

      await bloc.close();
    });

    test('does nothing when there is no previous module', () async {
      final bloc = AppBloc();

      bloc.add(const PopModule());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.module, homeModule);
      expect(bloc.state.moduleHistory, isEmpty);
      expect(bloc.state.canGoBackModule, isFalse);

      await bloc.close();
    });
  });
}
