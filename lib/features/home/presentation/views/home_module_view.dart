import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/theme/app_layout.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';

class HomeModuleView extends StatelessWidget {
  const HomeModuleView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: ViewLayout.pagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ModuleLayout.contentMaxWidth(context),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: ModuleLayout.contentSpacing(context),
            children: [
              Icon(
                Icons.home_outlined,
                size: ModuleLayout.iconSize(context),
                color: Theme.of(context).colorScheme.primary,
              ),
              Text(
                l10n.home,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                l10n.home_module_description,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
