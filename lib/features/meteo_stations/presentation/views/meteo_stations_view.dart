import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/theme/app_layout.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';

class MeteoStationsView extends StatelessWidget {
  const MeteoStationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: ViewLayout.pagePadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_outlined,
                size: ModuleLayout.iconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
              GapLayout.vSm,
              Text(
                l10n.meteo_stations,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              GapLayout.vXs,
              Text(
                l10n.meteo_stations_module_description,
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
