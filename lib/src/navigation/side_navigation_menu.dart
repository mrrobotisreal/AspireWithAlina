import 'package:aspire_with_alina/src/settings/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SideNavigationMenu extends StatefulWidget {
  const SideNavigationMenu({
    super.key,
  });

  @override
  SideNavigationMenuState createState() => SideNavigationMenuState();
}

class SideNavigationMenuState extends State<SideNavigationMenu> {
  bool _isMenuExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: AnimatedContainer(
        width: _isMenuExpanded ? 250 : 70,
        duration: const Duration(milliseconds: 300),
        child: Column(
          children: [
            _isMenuExpanded
              ? DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppTheme.lightPrimaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 104),
                    child: Text(
                      AppLocalizations.of(context)!.common_menuTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Bauhaus',
                        color: AppTheme.darkHeaderTextColor,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    setState(() {
                      _isMenuExpanded = true;
                    });
                  },
                ),
            if (_isMenuExpanded)
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/');
                },
              ),
            if (_isMenuExpanded)
              ListTile(
                leading: const Icon(Icons.games),
                title: const Text('Games'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/games');
                },
              ),
            if (_isMenuExpanded)
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            const Spacer(),
            if (_isMenuExpanded)
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('Collapse'),
                onTap: () {
                  setState(() {
                    _isMenuExpanded = false;
                  });
                }
              ),
          ],
        ),
      ),
    );
  }
}
