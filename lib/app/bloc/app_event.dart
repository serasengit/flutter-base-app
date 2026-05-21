import 'package:equatable/equatable.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';

/// Base class for shell-level application events.
sealed class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Replaces the available shell modules after login or permission refresh.
class SetModules extends AppEvent {
  final List<AppModule> modules;

  const SetModules({required this.modules});

  @override
  List<Object?> get props => <Object?>[modules];
}

/// Selects a new active top-level module inside the shell.
class SetModule extends AppEvent {
  final AppModule module;

  const SetModule({required this.module});

  @override
  List<Object?> get props => <Object?>[module];
}

/// Returns to the previous module in the shell history.
class PopModule extends AppEvent {
  const PopModule();
}

/// Restores the shell state to its initial configuration.
class PurgeApp extends AppEvent {
  const PurgeApp();
}
