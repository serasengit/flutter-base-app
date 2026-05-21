// coverage:ignore-file

import 'package:flutter/material.dart';

class ViewLayout {
  const ViewLayout._();

  static const double _mobilePadding = 24;
  static const double _tabletPadding = 32;
  static const double _desktopPadding = 40;

  static EdgeInsets pagePadding(BuildContext context) {
    final device = ResponsiveDevice.of(context);

    return switch (device) {
      ResponsiveDeviceType.desktop => const EdgeInsets.all(_desktopPadding),
      ResponsiveDeviceType.tablet => const EdgeInsets.all(_tabletPadding),
      ResponsiveDeviceType.mobile => const EdgeInsets.all(_mobilePadding),
    };
  }
}

class FormLayout {
  const FormLayout._();

  static const double _mobileAuthFormMaxWidth = 420;
  static const double _tabletAuthFormMaxWidth = 460;
  static const double _desktopAuthFormMaxWidth = 520;

  static const double _mobileFieldSpacing = 28;
  static const double _tabletFieldSpacing = 32;
  static const double _desktopFieldSpacing = 36;

  static double formMaxWidth(BuildContext context) {
    final device = ResponsiveDevice.of(context);

    return switch (device) {
      ResponsiveDeviceType.desktop => _desktopAuthFormMaxWidth,
      ResponsiveDeviceType.tablet => _tabletAuthFormMaxWidth,
      ResponsiveDeviceType.mobile => _mobileAuthFormMaxWidth,
    };
  }

  static double fieldSpacing(BuildContext context) {
    final device = ResponsiveDevice.of(context);

    return switch (device) {
      ResponsiveDeviceType.desktop => _desktopFieldSpacing,
      ResponsiveDeviceType.tablet => _tabletFieldSpacing,
      ResponsiveDeviceType.mobile => _mobileFieldSpacing,
    };
  }
}

class ModuleLayout {
  const ModuleLayout._();

  static const double _mobileIconSize = 56;
  static const double _tabletIconSize = 64;
  static const double _desktopIconSize = 72;

  static const double _mobileContentMaxWidth = 420;
  static const double _tabletContentMaxWidth = 480;
  static const double _desktopContentMaxWidth = 520;

  static const double _mobileContentSpacing = 12;
  static const double _tabletContentSpacing = 16;
  static const double _desktopContentSpacing = 20;

  static double iconSize(BuildContext context) {
    final device = ResponsiveDevice.of(context);

    return switch (device) {
      ResponsiveDeviceType.desktop => _desktopIconSize,
      ResponsiveDeviceType.tablet => _tabletIconSize,
      ResponsiveDeviceType.mobile => _mobileIconSize,
    };
  }

  static double contentMaxWidth(BuildContext context) {
    final device = ResponsiveDevice.of(context);

    return switch (device) {
      ResponsiveDeviceType.desktop => _desktopContentMaxWidth,
      ResponsiveDeviceType.tablet => _tabletContentMaxWidth,
      ResponsiveDeviceType.mobile => _mobileContentMaxWidth,
    };
  }

  static double contentSpacing(BuildContext context) {
    final device = ResponsiveDevice.of(context);

    return switch (device) {
      ResponsiveDeviceType.desktop => _desktopContentSpacing,
      ResponsiveDeviceType.tablet => _tabletContentSpacing,
      ResponsiveDeviceType.mobile => _mobileContentSpacing,
    };
  }
}

enum ResponsiveDeviceType { mobile, tablet, desktop }

class ResponsiveDevice {
  const ResponsiveDevice._();

  static const double _tabletBreakpoint = 600;
  static const double _desktopBreakpoint = 1200;

  static ResponsiveDeviceType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= _desktopBreakpoint) {
      return ResponsiveDeviceType.desktop;
    }

    if (width >= _tabletBreakpoint) {
      return ResponsiveDeviceType.tablet;
    }

    return ResponsiveDeviceType.mobile;
  }
}
