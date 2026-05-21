///
/// Check if value is set
///
bool isSet(dynamic value) =>
    value != null &&
    value != "" &&
    value.toString() != '{}' &&
    value.toString() != '[]' &&
    value.toString().trim().isNotEmpty;
