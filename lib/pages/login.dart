import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lang_fe/pages/buttons_page.dart';
import 'package:lang_fe/pages/colors_page.dart';
import 'package:lang_fe/pages/dialogs_page.dart';
import 'package:lang_fe/pages/fields_page.dart';
import 'package:lang_fe/pages/indicators_page.dart';
import 'package:lang_fe/pages/recording_page.dart';
import 'package:lang_fe/pages/resizable_pane_page.dart';
import 'package:lang_fe/pages/selectors_page.dart';
import 'package:lang_fe/pages/sliver_toolbar_page.dart';
import 'package:lang_fe/pages/tabview_page.dart';
import 'package:lang_fe/pages/toolbar_page.dart';
import 'package:lang_fe/pages/typography_page.dart';
import 'package:lang_fe/platform_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});

  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator

      try {
        final response = await http.post(
          Uri.parse('http://localhost:8000/auth/login'),
          body: {
            'email': _emailController.text,
            'password': _passwordController.text
          },
        );

        if (response.statusCode == 200) {
          // Success! Handle login
          print('Login successful!');
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
    return MacosScaffold(
        toolBar: ToolBar(
          title: const Text('Login'),
          titleWidth: 150.0,
          leading: MacosTooltip(
            message: 'Toggle Sidebar',
            useMousePosition: false,
            child: MacosIconButton(
              icon: MacosIcon(
                CupertinoIcons.sidebar_left,
                color: MacosTheme.brightnessOf(context).resolve(
                  const Color.fromRGBO(0, 0, 0, 0.5),
                  const Color.fromRGBO(255, 255, 255, 0.5),
                ),
                size: 20.0,
              ),
              boxConstraints: const BoxConstraints(
                minHeight: 20,
                minWidth: 20,
                maxWidth: 48,
                maxHeight: 38,
              ),
              onPressed: () => MacosWindowScope.of(context).toggleSidebar(),
            ),
          ),
          actions: [
            ToolBarIconButton(
              label: 'Toggle End Sidebar',
              tooltipMessage: 'Toggle End Sidebar',
              icon: const MacosIcon(
                CupertinoIcons.sidebar_right,
              ),
              onPressed: () => MacosWindowScope.of(context).toggleEndSidebar(),
              showLabel: false,
            ),
          ],
        ),
        children: [
        ContentArea(
        builder: (context, scrollController) {
      return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
    child:Form(
        key: _formKey,
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: MacosTextField(
                  controller: _emailController,
                  placeholder: 'Email',
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: MacosTextField(
                  controller: _passwordController,
                  obscureText: true,
                  placeholder: 'Password',
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Navigate the user to the Home page
                        _login();
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
          ))
      );
        }
    ),
    ]
    );
  }
}