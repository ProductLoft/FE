import 'package:flutter/material.dart';
import 'package:lang_fe/provider/app_basic_provider.dart';
import 'package:lang_fe/req/firebase_auth_methods.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class EmailPasswordSignup extends StatefulWidget {
  static String routeName = '/signup-email-password';
  final void Function() callback;

  const EmailPasswordSignup({Key? key, required this.callback})
      : super(key: key);

  @override
  _EmailPasswordSignupState createState() => _EmailPasswordSignupState();
}

class _EmailPasswordSignupState extends State<EmailPasswordSignup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  initState() {
    super.initState();

    final provider = Provider.of<AppBasicInfoProvider>(context, listen: false);
    provider.addPageTrack('signup-pwd-login-page');
  }

  void signUpUser() async {
    await FirebaseAuthMethods(auth).signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      context: context,
    );

    final provider = Provider.of<AppBasicInfoProvider>(context, listen: false);
    await provider.addUserSignUpLog();

    setState(() {
      widget.callback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Signup",
          style: TextStyle(fontSize: 30),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'email',
              filled: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'password',
              filled: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
          child: Center(
            child: ElevatedButton(
              onPressed: signUpUser,
              child: const Text('Submit'),
            ),
          ),
        ),
      ],
    );
  }
}
