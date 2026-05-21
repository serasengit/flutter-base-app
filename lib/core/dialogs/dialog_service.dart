import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/theme/color_palette.dart';
import 'package:flutter_base_app/core/utils/functions.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';

/// Defines the available dialog styles.
enum DialogType { info, success, warning, error }

/// Service responsible for displaying application dialogs.
class DialogService {
  DialogService({GlobalKey<NavigatorState>? navigatorKey})
    : _navigatorKey = navigatorKey;

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isShowingDialog = false;

  GlobalKey<NavigatorState> get navigatorKey =>
      _navigatorKey ??= GlobalKey<NavigatorState>();

  void attachNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Displays a simple dialog with a title, optional description and icon.
  Future<void> openDialog(
    BuildContext context, {
    required String key,
    required String title,
    required DialogType type,
    String? description,
  }) {
    final color = _getColor(type);
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIcon(type), color: color, size: 56),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (isSet(description)) ...[
                const SizedBox(height: 12),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              key: Key(key),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog capable of showing one or multiple messages.
  Future<void> showMessagesDialog({
    required DialogType type,
    required String title,
    String? message,
    List<String>? messages,
    bool barrierDismissible = true,
  }) async {
    final context = _navigatorKey?.currentContext;
    if (context == null || _isShowingDialog) {
      return;
    }

    final normalizedMessage = message?.trim();
    final resolvedMessages = <String>{
      if (isSet(normalizedMessage)) normalizedMessage!,
      ...?messages?.map((item) => item.trim()).where(isSet),
    }.toList();

    _isShowingDialog = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        final color = _getColor(type);
        final l10n = AppLocalizations.of(dialogContext);
        final closeLabel =
            l10n?.close ??
            MaterialLocalizations.of(dialogContext).okButtonLabel;

        return AlertDialog(
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getIcon(type), color: color, size: 56),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                ),
                if (resolvedMessages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in resolvedMessages)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                resolvedMessages.length == 1 ? item : '- $item',
                                textAlign: resolvedMessages.length == 1
                                    ? TextAlign.center
                                    : TextAlign.start,
                                style: Theme.of(
                                  dialogContext,
                                ).textTheme.bodyMedium,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              key: const Key('requestErrorsDialog'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(closeLabel),
            ),
          ],
        );
      },
    );

    _isShowingDialog = false;
  }

  /// Returns the icon associated with the dialog type.
  IconData _getIcon(DialogType type) {
    return switch (type) {
      DialogType.info => Icons.info_outline,
      DialogType.success => Icons.check_circle_outline,
      DialogType.warning => Icons.warning_amber_rounded,
      DialogType.error => Icons.error_outline,
    };
  }

  /// Returns the color associated with the dialog type.
  Color _getColor(DialogType type) {
    return switch (type) {
      DialogType.info => ColorPalette.primaryColor,
      DialogType.success => ColorPalette.successColor,
      DialogType.warning => ColorPalette.warningColor,
      DialogType.error => ColorPalette.errorColor,
    };
  }
}
