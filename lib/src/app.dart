import 'package:aspire_with_alina/src/screens/student_info_form.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
          home: const WelcomeScreen(),
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  default:
                    return const WelcomeScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _validateCode(BuildContext context) async {
    final String registrationCode = _codeController.text;

    if (registrationCode.isEmpty) {
      _showErrorDialog(context, AppLocalizations.of(context)!.registrationCodeIsEmpty);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8888/validate/registration'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'registration_code': registrationCode,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['registration_code'] == 'VALID') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentInfoFormScreen()),
          );
        } else {
          _showErrorDialog(context, AppLocalizations.of(context)!.registrationCodeIsInvalid);
        }
      } else {
        _showErrorDialog(context, AppLocalizations.of(context)!.registrationCodeServerError);
      }
    } catch (error) {
      _showErrorDialog(context, AppLocalizations.of(context)!.common_errorMessage(error.toString()));
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.common_errorTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.common_okayTitle),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0057B7), // Ukrainian flag blue
              Color(0xFFFFD700), // Ukrainian flag yellow
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.welcomeTitle,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                Text(
                  AppLocalizations.of(context)!.registrationCodeInputLabel,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.registrationCodeInputHint,
                  ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: _isLoading
                      ? null
                      : () => _validateCode(context), // Button action
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057B7), // Ukrainian flag blue
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                    ),
                    child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                        AppLocalizations.of(context)!.registrationCodeSubmitButton,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
