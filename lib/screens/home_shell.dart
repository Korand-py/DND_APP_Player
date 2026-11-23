import 'package:flutter/material.dart';

import '../screens/dice_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/specifications_screen.dart';
import '../theme/app_colors.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  String? _rollLabel;
  int? _rollModifier;

  void _openRoll({required String label, required int modifier}) {
    setState(() {
      _rollLabel = label;
      _rollModifier = modifier;
      _index = 1;
    });
  }

  void _clearRoll() {
    setState(() {
      _rollLabel = null;
      _rollModifier = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      SpecificationsScreen(onRollRequest: _openRoll),
      DiceScreen(
        embedded: true,
        rollLabel: _rollLabel,
        rollModifier: _rollModifier,
        onClearRollContext: _clearRoll,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (int value) => setState(() => _index = value),
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.person_add_outlined),
              selectedIcon: Icon(Icons.person_add),
              label: 'Создание персонажа',
            ),
            NavigationDestination(
              icon: Icon(Icons.casino_outlined),
              selectedIcon: Icon(Icons.casino),
              label: 'Броски кубов',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}
