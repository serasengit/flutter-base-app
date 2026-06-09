import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Transport used by the observer to forward state changes to the viewer.
abstract interface class BlocDevToolsSink {
  Future<void> send(Map<String, dynamic> message);
}

/// Persistent WebSocket client used only during debug sessions.
final class BlocDevToolsClient implements BlocDevToolsSink {
  BlocDevToolsClient({
    required Logger logger,
    Duration reconnectInterval = const Duration(seconds: 3),
  }) : _logger = logger,
       _reconnectInterval = reconnectInterval;

  final Logger _logger;
  final Duration _reconnectInterval;

  WebSocket? _socket;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _started = false;

  static final bool enabled = kDebugMode;

  static final String url = (() {
    const configuredUrl = String.fromEnvironment('BLOC_DEVTOOLS_URL');

    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }

    if (Platform.isAndroid) {
      return 'ws://10.0.2.2:58987/events';
    }

    return 'ws://127.0.0.1:58987/events';
  })();

  void start() {
    if (!enabled || _started) {
      return;
    }

    _started = true;
    _logger.i('Starting Bloc devtools client: $url');
    unawaited(_connect());
    _reconnectTimer = Timer.periodic(_reconnectInterval, (_) {
      if (_socket == null) {
        unawaited(_connect());
      }
    });
  }

  Future<void> stop() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    final socket = _socket;
    _socket = null;

    await socket?.close();
  }

  @override
  Future<void> send(Map<String, dynamic> message) async {
    if (!enabled) {
      return;
    }

    final socket = _socket;

    if (socket == null) {
      return;
    }

    try {
      socket.add(jsonEncode(message));
    } catch (error, stackTrace) {
      _logger.w(
        'Failed to send Bloc devtools payload',
        error: error,
        stackTrace: stackTrace,
      );
      _socket = null;
    }
  }

  Future<void> _connect() async {
    if (_isConnecting || _socket != null) {
      return;
    }

    _isConnecting = true;

    try {
      _logger.d('Connecting Bloc devtools client to $url');
      final socket = await WebSocket.connect(url);
      _socket = socket;

      _logger.i('Connected Bloc devtools client to $url');

      socket.done.whenComplete(() {
        if (identical(_socket, socket)) {
          _socket = null;
          _logger.w('Bloc devtools connection closed');
        }
      });
    } catch (error, stackTrace) {
      _logger.w(
        'Unable to connect Bloc devtools client to $url',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isConnecting = false;
    }
  }
}
