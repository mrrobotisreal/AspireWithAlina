import 'package:aspire_with_alina/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'navigation/side_navigation_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.settingsController,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final SettingsController settingsController;
  final String firstName;
  final String lastName;
  final String email;

  static const routeName = '/home';

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
                  AppLocalizations.of(context)!.common_home,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Bauhaus',
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.solid,
                    decorationColor: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
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
          body: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Text(
                        'Home page',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bauhaus',
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'This is just some filler text to go here on the home page underneath the title in order to take up space so this can be used as an example. I hope this works!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Bauhaus',
                        ),
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
