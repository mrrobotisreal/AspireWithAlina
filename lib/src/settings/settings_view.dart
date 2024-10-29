import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../navigation/side_navigation_menu.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromARGB(150, 126, 126, 126),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            elevation: 24,
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              AppLocalizations.of(context)!.common_settingsTitle,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Bauhaus',
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.solid,
                decorationColor: Colors.white,
              ),
            ),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
        ),
      ),
      drawer: const SideNavigationMenu(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        // Glue the SettingsController to the theme selection DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        child: DropdownButton<ThemeMode>(
          // Read the selected themeMode from the controller
          value: controller.themeMode,
          // Call the updateThemeMode method any time the user selects a theme.
          onChanged: controller.updateThemeMode,
          items: [
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Text(
                AppLocalizations.of(context)!.settings_systemTheme,
                style: const TextStyle(
                  fontFamily: 'Bauhaus',
                ),
              ),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text(
                AppLocalizations.of(context)!.settings_lightTheme,
                style: const TextStyle(
                  fontFamily: 'Bauhaus',
                ),
              ),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Text(
                AppLocalizations.of(context)!.settings_darkTheme,
                style: const TextStyle(
                  fontFamily: 'Bauhaus',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
