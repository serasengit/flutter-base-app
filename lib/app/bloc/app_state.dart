import 'package:equatable/equatable.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_modules.dart';

/// Holds the authenticated shell state: available modules, current module and back history.
class AppState extends Equatable {
  final List<AppModule> modules;
  final AppModule module;
  final List<AppModule> moduleHistory;

  const AppState({
    this.modules = appModules,
    this.module = homeModule,
    this.moduleHistory = const <AppModule>[],
  });

  bool get canGoBackModule => moduleHistory.isNotEmpty;

  AppState copyWith({
    List<AppModule>? modules,
    AppModule? module,
    List<AppModule>? moduleHistory,
  }) {
    return AppState(
      modules: modules ?? this.modules,
      module: module ?? this.module,
      moduleHistory: moduleHistory ?? this.moduleHistory,
    );
  }

  @override
  List<Object?> get props => <Object?>[modules, module, moduleHistory];
}
