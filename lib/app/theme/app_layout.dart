import 'package:flutter/material.dart';

///
/// Shared page layout values used by application views.
///
class ViewLayout {
  const ViewLayout._();

  static const EdgeInsets pagePadding = EdgeInsets.all(24);
}

///
/// Shared spacing scale used by current views.
///
class SpacingLayout {
  const SpacingLayout._();

  static const double xs = 12;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
}

class ModuleLayout {
  const ModuleLayout._();

  static const double iconSize = 56;
}

///
/// Shared gap widgets.
///
class GapLayout {
  const GapLayout._();

  static const vXs = SizedBox(height: SpacingLayout.xs);
  static const vSm = SizedBox(height: SpacingLayout.sm);
  static const vMd = SizedBox(height: SpacingLayout.md);
  static const vLg = SizedBox(height: SpacingLayout.lg);

  static const hXs = SizedBox(width: SpacingLayout.xs);
  static const hSm = SizedBox(width: SpacingLayout.sm);
  static const hMd = SizedBox(width: SpacingLayout.md);
  static const hLg = SizedBox(width: SpacingLayout.lg);
}

///
/// Shared form layout values.
///
class FormLayout {
  const FormLayout._();

  static const double authFormMaxWidth = 420;
}
