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
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          title: 'Aspire With Alina',
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
      _showErrorDialog(context, "Please enter a registration code.");
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
            MaterialPageRoute(builder: (context) => const UserFormScreen()),
          );
        } else {
          _showErrorDialog(context,
              "Oops! It looks like the registration code you entered is either expired or invalid. Please check to make sure you entered to code correctly and try again. If the registration code continues to fail, please contact Alina at alina.ranok@gmail.com.");
        }
      } else {
        _showErrorDialog(context, "Server error. Please try again later.");
      }
    } catch (error) {
      _showErrorDialog(context, "Error occurred. Please check your connection.");
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
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
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
                const Center(
                  child: Text(
                    'Welcome to Aspire With Alina!',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                const Text(
                  'Please input your registration code',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Registration code',
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
                      : const Text(
                        "Let's begin!",
                        style: TextStyle(
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

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  UserFormScreenState createState() => UserFormScreenState();
}

class UserFormScreenState extends State<UserFormScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _validateForm(BuildContext context) async {
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String email = _emailController.text;

    if (firstName.isEmpty) {
      _showErrorDialog(context, "Please enter your first name.");
      return;
    }

    if (lastName.isEmpty) {
      _showErrorDialog(context, "Please enter your last name.");
      return;
    }

    if (email.isEmpty) {
      _showErrorDialog(context, "Please enter your email address.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await http.post(
        Uri.parse('http://127.0.0.1:8888/students/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'first_name': firstName,
          'last_name': lastName,
          'email_address': email,
          'native_language': 'Русский язык',
        }),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      _showErrorDialog(context, "Error occurred. Please check your connection.");
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
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar menu
          Container(
            width: 250,
            color: const Color(0xFF0057B7),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 72),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: _isLoading
                        ? null
                        : () => _validateForm(context), // Button action
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0057B7), // Ukrainian flag blue
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                      ),
                      child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Submit',
                          style: TextStyle(
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
        ],
      ),
    );
  }
}
