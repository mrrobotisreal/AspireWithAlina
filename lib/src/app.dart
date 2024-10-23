import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'home.dart';
import 'games/space_shooter.dart';
import 'screens/games_screen.dart';
import 'screens/welcome_screen.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class AspireWithAlinaApp extends StatelessWidget {
  const AspireWithAlinaApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'aspire_with_alina_app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [ // Add more supported locales later
            Locale('en', 'US'),
            Locale('uk', 'UA'),
            Locale('ru', 'RU'),
            Locale('de', 'DE'),
            Locale('es', 'ES'),
            Locale('pt', 'PT'),
            Locale('pt', 'BR'),
          ],
          onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
          title: 'Aspire With Alina',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData.light(),
          themeMode: settingsController.themeMode,
          home: WelcomeScreen(
            settingsController: settingsController,
          ),
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case WelcomeScreen.routeName:
                    return WelcomeScreen(
                      settingsController: settingsController,
                    );
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case HomeScreen.routeName:
                    return HomeScreen(
                      settingsController: settingsController,
                      firstName: "",
                      lastName: "",
                      email: "",
                    );
                  case GamesScreen.routeName:
                    return GamesScreen(
                      settingsController: settingsController,
                    );
                  case SpaceShooterScreen.routeName:
                    return SpaceShooterScreen();
                  default:
                    return WelcomeScreen(
                      settingsController: settingsController,
                    );
                }
              },
            );
          },
        );
      },
    );
  }
}
