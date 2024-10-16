import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class StudentInfoFormScreen extends StatefulWidget {
  const StudentInfoFormScreen({super.key});

  @override
  StudentInfoFormScreenState createState() => StudentInfoFormScreenState();
}

class StudentInfoFormScreenState extends State<StudentInfoFormScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _validateForm(BuildContext context) async {
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String email = _emailController.text;

    if (firstName.isEmpty) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_emptyFirstName);
      return;
    }

    if (lastName.isEmpty) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_emptyLastName);
      return;
    }

    if (email.isEmpty) {
      _showErrorDialog(context, AppLocalizations.of(context)!.studentInfoForm_emptyEmail);
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
      body: Row(
        children: [
          // Sidebar menu
          Container(
            width: 250,
            color: const Color(0xFF0057B7),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.common_menuTitle,
                  style: const TextStyle(
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
                  Text(
                    AppLocalizations.of(context)!.welcomeStudent('Mitchell'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.common_firstName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.common_lastName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.common_emailAddress,
                      border: const OutlineInputBorder(),
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
                        : Text(
                          AppLocalizations.of(context)!.common_submit,
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
        ],
      ),
    );
  }
}
