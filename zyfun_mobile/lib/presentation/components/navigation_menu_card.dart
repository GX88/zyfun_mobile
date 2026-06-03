import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NavigationMenuItem {
  const NavigationMenuItem({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}

class NavigationMenuCard extends StatelessWidget {
  const NavigationMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<NavigationMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Text(title, style: theme.textTheme.h4),
      description: Text(description),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => ShadButton.outline(
                  onPressed: () => context.push(item.route),
                  leading: Icon(item.icon),
                  child: Text(item.label),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
