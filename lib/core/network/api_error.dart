///
/// Normalized API error used across the application.
///
/// Infrastructure code converts backend failures into this typed exception so
/// repositories, blocs and shared UI can consume a stable error shape.
///
class ApiError implements Exception {
  final int statusCode;
  final String? code;
  final String message;
  final Map<String, dynamic>? raw;

  const ApiError({
    required this.statusCode,
    this.code,
    required this.message,
    this.raw,
  });

  ///
  /// Returns the most useful display string for UI and logs.
  ///
  String get displayMessage {
    return 'HTTP $statusCode: $message';
  }

  @override
  String toString() => displayMessage;
}
