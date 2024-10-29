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
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.common_menuTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Bauhaus',
                      color: AppTheme.darkHeaderTextColor,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              iconColor: AppTheme.lightBodyTextColor,
              leading: const Icon(Icons.home),
              title: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  AppLocalizations.of(context)!.common_home,
                  style: const TextStyle(
                    fontFamily: 'Bauhaus',
                    color: AppTheme.lightBodyTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.games),
              title: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  AppLocalizations.of(context)!.common_games,
                  style: const TextStyle(
                    fontFamily: 'Bauhaus',
                    color: AppTheme.lightBodyTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              children: [
                ListTile(
                  title: const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Icon(
                          Icons.games,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'All Games',
                          style: TextStyle(
                            fontFamily: 'Bauhaus',
                            color: AppTheme.lightBodyTextColor,
                            // fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/games');
                  },
                ),
                ListTile(
                  // iconColor: AppTheme.lightBodyTextColor,
                  // leading: const Icon(Icons.rocket_launch),
                  title: const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Icon(
                          Icons.rocket_launch,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Space Shooter',
                          style: TextStyle(
                            fontFamily: 'Bauhaus',
                            color: AppTheme.lightBodyTextColor,
                            // fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/games/space-shooter');
                  },
                ),
              ],
            ),
            ListTile(
              iconColor: AppTheme.lightBodyTextColor,
              leading: const Icon(Icons.settings),
              title: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  AppLocalizations.of(context)!.common_settingsTitle,
                  style: const TextStyle(
                    fontFamily: 'Bauhaus',
                    color: AppTheme.lightBodyTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              iconColor: AppTheme.lightBodyTextColor,
              leading: const Icon(Icons.arrow_back),
              title: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  AppLocalizations.of(context)!.common_logout,
                  style: const TextStyle(
                    fontFamily: 'Bauhaus',
                    color: AppTheme.lightBodyTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/welcome');
              }
            ),
          ],
        ),
    );
  }
}
