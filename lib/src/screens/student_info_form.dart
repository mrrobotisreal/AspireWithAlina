import 'package:aspire_with_alina/src/home.dart';
import 'package:aspire_with_alina/src/navigation/side_navigation_menu.dart';
import 'package:aspire_with_alina/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crypt/crypt.dart';

class StudentInfoFormScreen extends StatefulWidget {
  const StudentInfoFormScreen({
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

  @override
  StudentInfoFormScreenState createState() => StudentInfoFormScreenState();
}

class StudentInfoFormScreenState extends State<StudentInfoFormScreen> {
  final List<String> _nativeLanguageOptions = ['Русский язык', 'Українська мова', 'Deutsche', 'Español', 'Português', 'Português (Brasil)', 'Tiếng Việt'];
  String _selectedNativeLanguage = 'Русский язык';

  final TextEditingController _emailController = TextEditingController();
  final RegExp emailRegex = RegExp(r'(^[A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+)\.([A-Za-z]{2,3}$)');
  String? _emailErrorMessage;

  final TextEditingController _passwordController = TextEditingController();
  String? _passwordErrorMessage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    String emailText = _emailController.text;

    setState(() {
      if (emailText.isEmpty) {
        _emailErrorMessage = AppLocalizations.of(context)!.studentInfoForm_emailErrorText_empty;
      } else if (!emailRegex.hasMatch(emailText)) {
        _emailErrorMessage = AppLocalizations.of(context)!.studentInfoForm_emailErrorText_invalid;
      } else {
        _emailErrorMessage = null;
      }
    });
  }

  void _validatePassword() {
    String passwordText = _passwordController.text;

    setState(() {
      if (passwordText.isEmpty) {
        _passwordErrorMessage = AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_empty;
      } else if (passwordText.length < 8) {
        _passwordErrorMessage = AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_length;
      } else if (!passwordText.contains(RegExp(r'[A-Z]'))) {
        _passwordErrorMessage = AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_uppercase;
      } else if (!passwordText.contains(RegExp(r'[a-z]'))) {
        _passwordErrorMessage = AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_lowercase;
      } else if (!passwordText.contains(RegExp(r'[0-9]'))) {
        _passwordErrorMessage = AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_number;
      } else if (!passwordText.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        _passwordErrorMessage = AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_specialCharacter;
      } else {
        _passwordErrorMessage = null;
      }
    });
  }

  Future<void> _validateForm(BuildContext context, String firstName, String lastName, SettingsController settingsController) async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_emailErrorText_empty);
      return;
    } else if (!emailRegex.hasMatch(email)) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_emailErrorText_invalid);
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_empty);
      return;
    } else if (password.length < 8) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_length);
      return;
    } else if (!password.contains(RegExp(r'[A-Z]'))) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_uppercase);
      return;
    } else if (!password.contains(RegExp(r'[a-z]'))) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_lowercase);
      return;
    } else if (!password.contains(RegExp(r'[0-9]'))) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_number);
      return;
    } else if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_passwordErrorText_specialCharacter);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var hashedPassword = Crypt.sha256(password, salt: '').toString(); // Salt is added in the backend

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8888/students/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'first_name': firstName,
          'last_name': lastName,
          'email_address': email,
          'native_language': _selectedNativeLanguage,
          'password': hashedPassword,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _emailController.clear();
          _passwordController.clear();
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              settingsController: settingsController,
              firstName: firstName,
              lastName: lastName,
              email: email,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        _showErrorDialog(context, 'The submitted form data is invalid. Please check your input and try again.');
      } else if (response.statusCode >= 500) {
        _showErrorDialog(context, 'A server error occurred while processing your request. Please try again later.');
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
          title: Text(
            AppLocalizations.of(context)!.common_errorTitle,
            style: const TextStyle(
              fontFamily: 'Bauhaus',
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Bauhaus',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.common_okayTitle,
                style: const TextStyle(
                  fontFamily: 'Bauhaus',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
            title: const Text(
              'Student Info Form',
              style: TextStyle(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.studentInfoForm_welcomeStudent(widget.firstName),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Bauhaus',
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.studentInfoForm_description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Bauhaus',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      '${AppLocalizations.of(context)!.studentInfoForm_nativeLanguageLabel}:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Bauhaus',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedNativeLanguage,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontFamily: 'Bauhaus',
                      fontSize: 16,
                    ),
                    underline: Container(
                      height: 2,
                      color: Colors.indigoAccent,
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedNativeLanguage = value!;
                      });
                    },
                    items: _nativeLanguageOptions
                      .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontFamily: 'Bauhaus',
                              fontWeight: _selectedNativeLanguage == value ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      '${AppLocalizations.of(context)!.studentInfoForm_emailInputLabel}:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Bauhaus',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.common_emailAddress,
                      labelStyle: const TextStyle(
                        fontFamily: 'Bauhaus',
                      ),
                      errorText: _emailErrorMessage,
                      border: const OutlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Bauhaus',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      '${AppLocalizations.of(context)!.studentInfoForm_passwordInputLabel}:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Bauhaus',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                    child: Text(
                      AppLocalizations.of(context)!.studentInfoForm_passwordInputRequirements,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Bauhaus',
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.common_passwordTitle,
                      labelStyle: const TextStyle(
                        fontFamily: 'Bauhaus',
                      ),
                      errorText: _passwordErrorMessage,
                      border: const OutlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Bauhaus',
                    ),
                  ),
                  const SizedBox(height: 72),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: _isLoading
                        ? null
                        : () => _validateForm(context, widget.firstName, widget.lastName, widget.settingsController), // Button action
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Ukrainian flag blue
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                      ),
                      child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          AppLocalizations.of(context)!.common_submit,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontFamily: 'Bauhaus',
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
