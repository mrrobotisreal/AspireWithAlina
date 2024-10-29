import 'package:aspire_with_alina/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../navigation/side_navigation_menu.dart';
import '../games/space_shooter.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  static const routeName = '/games';

  @override
  GamesScreenState createState() => GamesScreenState();
}

class GamesScreenState extends State<GamesScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
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
                  AppLocalizations.of(context)!.common_games,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Bauhaus',
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.solid,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          drawer: const SideNavigationMenu(),
          body: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32.0,
                    horizontal: 128.0,
                  ),
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: Text(
                            'All Games',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Bauhaus',
                              fontWeight: FontWeight.bold,
                              fontSize: 40.0,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SpaceShooterScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Ukrainian flag blue
                              padding: const EdgeInsets.symmetric(
                                vertical: 24.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rocket_launch,
                                  color: Colors.deepOrange,
                                  size: 32.0,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Space Shooter',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Bauhaus',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
