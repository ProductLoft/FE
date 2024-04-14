import 'package:lang_fe/req/firebase_auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class EmailPasswordLogin extends StatefulWidget {
  static String routeName = '/login-email-password';
  final void Function() callback;

  const EmailPasswordLogin({super.key, required this.callback});

  @override
  State<EmailPasswordLogin> createState() => _EmailPasswordLoginState();
}

class _EmailPasswordLoginState extends State<EmailPasswordLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser() async {
    debugPrint(
        'Login user ${_emailController.text} ${_passwordController.text}');
    await FirebaseAuthMethods(auth).loginWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      context: context,
    );
    setState(() {
      widget.callback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Login",
          style: TextStyle(fontSize: 30),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.08),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'email',
              filled: true,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'password',
              filled: true,
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed:loginUser,
          child: const Text(
            'Login',
          ),
        ),
      ],
    );
  }
}
