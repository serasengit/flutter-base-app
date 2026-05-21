import 'package:flutter_base_app/app/bloc/app_event.dart';
import 'package:flutter_base_app/app/bloc/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Controls the authenticated app shell state.
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<SetModule>(setModule);
    on<PurgeApp>(_purge);
  }

  /// Updates the currently selected shell module.
  void setModule(SetModule event, Emitter<AppState> emit) {
    emit(state.copyWith(module: event.module));
  }

  /// Resets the app shell state to its initial configuration.
  void _purge(PurgeApp event, Emitter<AppState> emit) {
    emit(const AppState());
  }
}
