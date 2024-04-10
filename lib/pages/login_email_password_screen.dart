import 'package:lang_fe/req/firebase_auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class EmailPasswordLogin extends StatefulWidget {
  static String routeName = '/login-email-password';

  const EmailPasswordLogin({super.key});

  @override
  State<EmailPasswordLogin> createState() => _EmailPasswordLoginState();
}

class _EmailPasswordLoginState extends State<EmailPasswordLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void loginUser() {
    context.read<FirebaseAuthMethods>().loginWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                prefixIcon: Icon(Icons.verified_user),
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
                prefixIcon: Icon(Icons.password),
                labelText: 'Filled',
                hintText: 'hint text',
                helperText: 'supporting text',
                filled: true,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: loginUser,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              textStyle: MaterialStateProperty.all(
                const TextStyle(color: Colors.white),
              ),
              minimumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 2.5, 50),
              ),
            ),
            child: const Text(
              "Login",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
