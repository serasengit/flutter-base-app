import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/theme/app_layout.dart';

class ModulePage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ModulePage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
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
                  icon,
                  size: ModuleLayout.iconSize(context),
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
