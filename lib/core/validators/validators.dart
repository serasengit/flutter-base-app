import 'package:flutter_base_app/core/utils/functions.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';

/// Utility class containing common form validation methods.
class Validators {
  /// Private constructor to prevent instantiation.
  const Validators._();

  /// Executes multiple validators sequentially.
  ///
  /// Returns the first validation error found.
  /// Returns `null` if all validations pass successfully.
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();

      if (result != null) {
        return result;
      }
    }

    return null;
  }

  /// Validates that a value is not null or empty.
  ///
  /// Returns a localized required field error message
  /// if the value is not set.
  static String? isRequired(String? value, AppLocalizations l10n) {
    if (!isSet(value)) {
      return l10n.required_field;
    }

    return null;
  }

  /// Validates that a value does not exceed the maximum length.
  ///
  /// Returns a localized validation error if the value length
  /// exceeds the specified maximum.
  static String? maxLength(
    String? value,
    int maxLength,
    AppLocalizations l10n,
  ) {
    if (isSet(value) && value!.length > maxLength) {
      return l10n.max_length(maxLength);
    }

    return null;
  }
}
