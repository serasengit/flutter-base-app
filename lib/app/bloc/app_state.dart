import 'package:equatable/equatable.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_modules.dart';

/// Holds the available modules and the currently selected shell module.
class AppState extends Equatable {
  final List<AppModule> modules;
  final AppModule module;

  const AppState({this.modules = appModules, this.module = homeModule});

  AppState copyWith({List<AppModule>? modules, AppModule? module}) {
    return AppState(
      modules: modules ?? this.modules,
      module: module ?? this.module,
    );
  }

  @override
  List<Object?> get props => [modules, module];
}
