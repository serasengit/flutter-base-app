// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get cities => 'Ciudades';

  @override
  String get cities_module_description => 'Gestiona catálogos de ciudades y flujos relacionados con ciudades.';

  @override
  String get close => 'Cerrar';

  @override
  String get home => 'Inicio';

  @override
  String get home_module_description => 'Selecciona un módulo del menú para empezar a trabajar con las secciones disponibles.';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logout_module_description => 'Cierra la sesión actual.';

  @override
  String max_length(Object maxLength) {
    return 'La longitud máxima es de $maxLength caracteres';
  }

  @override
  String get meteo_stations => 'Estaciones meteorológicas';

  @override
  String get meteo_stations_module_description => 'Gestiona estaciones meteorológicas y sus datos operativos relacionados.';

  @override
  String get modules => 'Módulos';

  @override
  String get operation_completed_successfully => 'La operación se ha completado correctamente.';

  @override
  String get password => 'Contraseña';

  @override
  String get request_failed => 'La solicitud ha fallado';

  @override
  String get required_field => 'Campo obligatorio';

  @override
  String get sign_in => 'Acceder';

  @override
  String get sign_in_description => 'Usa tu nombre de usuario y contraseña para continuar.';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get users => 'Usuarios';

  @override
  String get users_module_description => 'Gestiona los usuarios de la plataforma y su acceso.';
}
