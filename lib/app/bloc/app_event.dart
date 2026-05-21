import 'package:equatable/equatable.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';

/// Base type for app shell events.
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

/// Selects the active module displayed in the shell.
class SetModule extends AppEvent {
  final AppModule module;

  const SetModule({required this.module});

  @override
  List<Object?> get props => [module];
}

/// Replaces the available shell modules.
class SetModules extends AppEvent {
  final List<AppModule> modules;

  const SetModules({required this.modules});

  @override
  List<Object?> get props => [modules];
}

/// Clears shell state after session end or global purge.
class PurgeApp extends AppEvent {
  const PurgeApp();
}
