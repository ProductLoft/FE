import 'package:flutter/material.dart';
import 'package:lang_fe/req/firebase_auth_methods.dart';
import 'package:provider/provider.dart';

class EmailPasswordSignup extends StatefulWidget {
  static String routeName = '/signup-email-password';

  const EmailPasswordSignup({Key? key}) : super(key: key);

  @override
  _EmailPasswordSignupState createState() => _EmailPasswordSignupState();
}

class _EmailPasswordSignupState extends State<EmailPasswordSignup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void signUpUser() async {
    await context.read<FirebaseAuthMethods>().signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
  }

  @override
  Widget build1(BuildContext context) {
    return  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Sign Up",
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: const Icon(Icons.verified_user),
                labelText: 'email',
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
            onPressed: signUpUser,
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
              "Sign Up",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return  Expanded(
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
                          signUpUser();
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
