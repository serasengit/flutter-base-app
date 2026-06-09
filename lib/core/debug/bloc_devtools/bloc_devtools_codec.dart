import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Serializes Bloc events and states into JSON-safe payloads for the viewer.
final class BlocDevToolsCodec {
  const BlocDevToolsCodec._();

  static Map<String, dynamic> serializeObject(Object? value) {
    final serialized = _serialize(value);

    if (serialized is Map<String, dynamic>) {
      return serialized;
    }

    return <String, dynamic>{
      'type': value.runtimeType.toString(),
      'value': serialized,
    };
  }

  static Object? _serialize(Object? value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Duration) {
      return value.inMicroseconds;
    }

    if (value is Enum) {
      return value.name;
    }

    if (value is Uri) {
      return value.toString();
    }

    if (value is Equatable) {
      return <String, dynamic>{
        'type': value.runtimeType.toString(),
        'props': value.props.map(_serialize).toList(growable: false),
      };
    }

    if (value is Iterable<Object?>) {
      return value.map(_serialize).toList(growable: false);
    }

    if (value is Map<Object?, Object?>) {
      return value.map<String, Object?>(
        (key, item) => MapEntry<String, Object?>(
          key.toString(),
          _serialize(item),
        ),
      );
    }

    try {
      return jsonDecode(jsonEncode(value));
    } catch (_) {
      return value.toString();
    }
  }
}
