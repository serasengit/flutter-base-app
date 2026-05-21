import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

///
/// Application module definition.
///
/// Represents one navigable section that can appear inside the shared drawer.
///
class AppModule extends Equatable {
  final String route;
  final String labelKey;
  final IconData icon;
  final int order;
  final List<String> permissionPrefixes;
  final bool alwaysVisible;

  const AppModule({
    required this.route,
    required this.labelKey,
    required this.icon,
    required this.order,
    this.permissionPrefixes = const <String>[],
    this.alwaysVisible = false,
  });

  @override
  List<Object?> get props => [
    route,
    labelKey,
    icon,
    order,
    permissionPrefixes,
    alwaysVisible,
  ];
}
