import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crypt/crypt.dart';

import '../settings/settings_view.dart';
import 'student_info_form.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _codeEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showLogin = false;

  Future<void> _validateCode(BuildContext context) async {
    final String registrationCodeEmailAddress = _codeEmailController.text;

    if (registrationCodeEmailAddress.isEmpty) {
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.registrationCodeIsEmpty,
      );
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
          'registration_code': registrationCodeEmailAddress,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['is_valid']) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentInfoFormScreen(
              firstName: responseBody['first_name'],
              lastName: responseBody['last_name'],
              email: responseBody['email_address'],
            )),
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

  Future<void> _submitLogin(BuildContext context) async {
    final String registrationCodeEmailAddress = _codeEmailController.text;
    final String password = _passwordController.text;

    if (registrationCodeEmailAddress.isEmpty) {
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.welcomeScreen_inputEmail,
      );
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.welcomeScreen_inputPassword,
      );
      return;
    }

    var hashedPassword = Crypt.sha256(password, salt: '').toString();
    print('Hashed password: $hashedPassword');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8888/validate/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email_address': registrationCodeEmailAddress,
          'password': hashedPassword,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['is_valid'] && responseBody['student_info']['email_address'] == registrationCodeEmailAddress) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentInfoFormScreen(
              firstName: responseBody['student_info']['first_name'],
              lastName: responseBody['student_info']['last_name'],
              email: responseBody['student_info']['email_address'],
            )),
          );
        } else {
          _showErrorDialog(context, AppLocalizations.of(context)!.welcomeScreen_invalidEmailOrPassword);
        }
      } else if (response.statusCode == 400) {
        _showErrorDialog(context, AppLocalizations.of(context)!.welcomeScreen_invalidEmailOrPassword);
      } else if (response.statusCode >= 500) {
        _showErrorDialog(context, AppLocalizations.of(context)!.welcomeScreen_serverError);
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
          title: Text(AppLocalizations.of(context)!.common_errorTitle, style: const TextStyle(fontFamily: 'Bauhaus'),),
          content: Text(message, style: const TextStyle(fontFamily: 'Bauhaus'),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.common_okayTitle, style: const TextStyle(fontFamily: 'Bauhaus'),),
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
                    _showLogin
                      ? AppLocalizations.of(context)!.welcomeScreen_loginTitle
                      : AppLocalizations.of(context)!.welcomeScreen_welcomeTitle
                    ,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontFamily: 'Bauhaus',
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${AppLocalizations.of(context)!.appTitle}!',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Bauhaus',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _showLogin
                      ? AppLocalizations.of(context)!.welcomeScreen_inputEmail
                      : AppLocalizations.of(context)!.registrationCodeInputLabel
                    ,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Bauhaus',
                    ),
                  ),
                ),
                TextField(
                  controller: _codeEmailController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: _showLogin
                      ? AppLocalizations.of(context)!.common_emailAddress
                      : AppLocalizations.of(context)!.registrationCodeInputHint
                    ,
                    hintStyle: const TextStyle(
                      fontFamily: 'Bauhaus',
                    ),
                    labelStyle: const TextStyle(
                      fontFamily: 'Bauhaus',
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Bauhaus',
                  ),
                ),
                _showLogin
                  ? const SizedBox(
                      height: 24.0,
                    )
                  : const SizedBox.shrink()
                ,
                _showLogin
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        AppLocalizations.of(context)!.welcomeScreen_inputPassword,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Bauhaus',
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
                ,
                _showLogin
                  ? TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.common_passwordTitle,
                        hintStyle: const TextStyle(
                          fontFamily: 'Bauhaus',
                        ),
                        labelStyle: const TextStyle(
                          fontFamily: 'Bauhaus',
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Bauhaus',
                      ),
                    )
                  : const SizedBox.shrink()
                ,
                const SizedBox(
                  height: 24.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => setState(() {
                        _showLogin = !_showLogin;
                      }),
                      child: Text(
                        _showLogin
                          ? AppLocalizations.of(context)!.welcomeScreen_notRegisteredYetButton
                          : AppLocalizations.of(context)!.welcomeScreen_alreadyRegisteredButton
                        ,
                        style: const TextStyle(
                          fontFamily: 'Bauhaus',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading
                        ? null
                        : () {
                          if (_showLogin) {
                            _submitLogin(context);
                          } else {
                            _validateCode(context);
                          }
                        },
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
                              fontFamily: 'Bauhaus',
                            ),
                        ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, SettingsView.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}

