import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(LucideIcons.clapperboard),
          label: '影视',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.radio),
          label: '直播',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.history),
          label: '历史',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.settings2),
          label: '设置',
        ),
      ],
      onDestinationSelected: (index) {
        if (index == 0) {
          context.go('/film');
          return;
        }

        if (index == 1) {
          context.go('/live');
          return;
        }

        if (index == 2) {
          context.go('/history');
          return;
        }

        context.go('/setting');
      },
    );
  }
}
