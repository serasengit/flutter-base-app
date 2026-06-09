import 'package:bloc/bloc.dart';
import 'package:flutter_base_app/core/debug/bloc_devtools/bloc_devtools_client.dart';
import 'package:flutter_base_app/core/debug/bloc_devtools/bloc_devtools_codec.dart';

/// Global observer that mirrors Bloc lifecycle and state changes to the viewer.
final class BlocDevToolsObserver extends BlocObserver {
  BlocDevToolsObserver({required BlocDevToolsSink sink}) : _sink = sink;

  final BlocDevToolsSink _sink;
  final Map<String, Map<String, dynamic>> _appState =
      <String, Map<String, dynamic>>{};
  int _sequence = 0;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _setBlocState(bloc, bloc.state);
    _send(<String, dynamic>{
      ..._basePayload(kind: 'create', bloc: bloc),
      'state': BlocDevToolsCodec.serializeObject(bloc.state),
    });
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _setBlocState(bloc, bloc.state);
    _send(<String, dynamic>{
      ..._basePayload(kind: 'event', bloc: bloc),
      'event': BlocDevToolsCodec.serializeObject(event),
      'state': BlocDevToolsCodec.serializeObject(bloc.state),
    });
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _setBlocState(bloc, change.nextState);
    _send(<String, dynamic>{
      ..._basePayload(kind: 'change', bloc: bloc),
      'currentState': BlocDevToolsCodec.serializeObject(change.currentState),
      'nextState': BlocDevToolsCodec.serializeObject(change.nextState),
    });
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _setBlocState(bloc, transition.currentState);
    _send(<String, dynamic>{
      ..._basePayload(kind: 'transition', bloc: bloc),
      'event': BlocDevToolsCodec.serializeObject(transition.event),
      'currentState': BlocDevToolsCodec.serializeObject(
        transition.currentState,
      ),
      'nextState': BlocDevToolsCodec.serializeObject(transition.nextState),
    });
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _setBlocState(bloc, bloc.state);
    _send(<String, dynamic>{
      ..._basePayload(kind: 'error', bloc: bloc),
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
    });
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _send(<String, dynamic>{
      ..._basePayload(kind: 'close', bloc: bloc),
      'state': BlocDevToolsCodec.serializeObject(bloc.state),
    });
    _appState.remove(_blocKey(bloc));
  }

  Map<String, dynamic> _basePayload({
    required String kind,
    required BlocBase<dynamic> bloc,
  }) {
    return <String, dynamic>{
      'sequence': ++_sequence,
      'kind': kind,
      'bloc': bloc.runtimeType.toString(),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'appState': Map<String, Map<String, dynamic>>.from(_appState),
    };
  }

  void _send(Map<String, dynamic> payload) {
    _sink.send(payload);
  }

  void _setBlocState(BlocBase<dynamic> bloc, Object? state) {
    _appState[_blocKey(bloc)] = <String, dynamic>{
      'bloc': bloc.runtimeType.toString(),
      'state': BlocDevToolsCodec.serializeObject(state),
    };
  }

  String _blocKey(BlocBase<dynamic> bloc) => bloc.runtimeType.toString();
}
