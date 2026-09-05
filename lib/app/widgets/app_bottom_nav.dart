import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Kept simple: each of Home/My Reports/Profile embeds this as its own
/// `bottomNavigationBar`, navigating via `context.go` on tap, rather than a
/// go_router StatefulShellRoute — fewer moving parts for three screens.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => switch (index) {
        0 => context.go('/home'),
        1 => context.go('/reports'),
        _ => context.go('/profile'),
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
          label: 'My Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
