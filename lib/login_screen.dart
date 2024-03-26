import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lang_fe/utils/misc.dart';

import 'db/user_models.dart';


class LoginScreen extends StatefulWidget {
  final void Function() callback;
  const LoginScreen({super.key, required this.callback});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator

      try {
        final response = await http.post(
          Uri.parse(getAuthUrl()),
          body: {
            'username': _emailController.text,
            'password': _passwordController.text
          },
        );

        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('Response: ${response.body}');
            print('cookie: ${response.headers['set-cookie']}');
          }
          response.headers.forEach((key, value) {
            if (kDebugMode) {
              print('$key: $value');
            }
          });

          final body = json.decode(response.body);
          String name = body["user"]["name"] as String;
          String username = body["user"]["username"] as String;
          String email = body["user"]["email"] as String;
          String? cookie = response.headers['set-cookie'] as String;

          UserProvider up = UserProvider();

          User u = await up.createUser(name, username, email, cookie);

          // Success! Handle login
          print('Login successful!');
          setState(() {
            widget.callback();
          });
          return;
        } else {
          // Failed! Handle error
          print('Login failed: ${response.body}');
        }
      } catch (e) {
        // Handle network errors
        print('Error: $e');
      } finally {
        // Hide loading indicator
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
    return Expanded(
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      prefixIcon: const Icon(Icons.verified_user),
                      labelText: 'email',
                      filled: true,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      labelText: 'Filled',
                      hintText: 'hint text',
                      helperText: 'supporting text',
                      filled: true,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          debugPrint('email: ${_emailController.text}');
                          // Navigate the user to the Home page
                          _login();
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill input')),
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ),
              ],
            )));
  }
}

class TextStyleExample extends StatelessWidget {
  const TextStyleExample({
    super.key,
    required this.name,
    required this.style,
  });

  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(name, style: style),
    );
  }
}
