import 'package:flutter_base_app/app/bloc/app_event.dart';
import 'package:flutter_base_app/app/bloc/app_state.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_modules.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Coordinates the authenticated shell modules and their back-stack history.
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<SetModules>(_setModules);
    on<SetModule>(_setModule);
    on<PopModule>(_popModule);
    on<PurgeApp>(_purgeApp);
  }

  void _setModules(SetModules event, Emitter<AppState> emit) {
    final modules = event.modules.isEmpty ? appModules : event.modules;

    emit(
      AppState(
        modules: modules,
        module: modules.first,
        moduleHistory: const <AppModule>[],
      ),
    );
  }

  void _setModule(SetModule event, Emitter<AppState> emit) {
    if (event.module == state.module) {
      return;
    }

    final history = List<AppModule>.from(state.moduleHistory)..add(state.module);

    emit(
      state.copyWith(
        module: event.module,
        moduleHistory: history,
      ),
    );
  }

  void _popModule(PopModule event, Emitter<AppState> emit) {
    if (!state.canGoBackModule) {
      return;
    }

    final history = List<AppModule>.from(state.moduleHistory);
    final previousModule = history.removeLast();

    emit(
      state.copyWith(
        module: previousModule,
        moduleHistory: history,
      ),
    );
  }

  void _purgeApp(PurgeApp event, Emitter<AppState> emit) {
    emit(const AppState());
  }
}
