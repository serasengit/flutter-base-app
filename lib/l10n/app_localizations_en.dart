// coverage:ignore-file
// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cities => 'Cities';

  @override
  String get cities_module_description =>
      'Manage city catalogs and city-related workflows.';

  @override
  String get close => 'Close';

  @override
  String get home => 'Home';

  @override
  String get home_module_description =>
      'Select a module from the drawer to start working with the available sections.';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get logout_module_description => 'Close the current session.';

  @override
  String max_length(Object maxLength) {
    return 'Maximum length is $maxLength characters';
  }

  @override
  String get meteo_stations => 'Meteo Stations';

  @override
  String get meteo_stations_module_description =>
      'Manage weather stations and related operational data.';

  @override
  String get modules => 'Modules';

  @override
  String get operation_completed_successfully =>
      'Operation completed successfully.';

  @override
  String get password => 'Password';

  @override
  String get request_failed => 'Request failed';

  @override
  String get required_field => 'Required field';

  @override
  String get sign_in => 'Sign in';

  @override
  String get sign_in_description =>
      'Use your username and password to continue.';

  @override
  String get username => 'Username';

  @override
  String get users => 'Users';

  @override
  String get users_module_description =>
      'Manage platform users and their account access.';
}
