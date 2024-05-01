import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:speaksharp/main.dart';
import 'package:speaksharp/pages/login_email_password_screen.dart';
import 'package:speaksharp/pages/signup_email_password_screen.dart';

typedef OAuthSignIn = void Function();

// If set to true, the app will request notification permissions to use
// silent verification for SMS MFA instead of Recaptcha.
const withSilentVerificationSMSMFA = true;

/// Helper class to show a snackbar using the passed context.
class ScaffoldSnackbar {
  // ignore: public_member_api_docs
  ScaffoldSnackbar(this._context);

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/// The mode of the current auth session, either [AuthMode.login] or [AuthMode.register].
// ignore: public_member_api_docs
enum AuthMode { login, register }

extension on AuthMode {
  String get label => this == AuthMode.login ? 'Sign in' : 'Register';
}

/// Entrypoint example for various sign-in flows with Firebase.
class AuthGate extends StatefulWidget {
  // ignore: public_member_api_docs
  final void Function() callback;

  const AuthGate({super.key, required this.callback});

  static String? appleAuthorizationCode;

  @override
  State<StatefulWidget> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();

    if (withSilentVerificationSMSMFA && !kIsWeb) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      messaging.requestPermission();
    }

    if (!kIsWeb && Platform.isMacOS) {
      authButtons = {
        Buttons.Apple: () => _handleMultiFactorException(
              _signInWithApple,
            ),
      };
    } else {
      authButtons = {
        Buttons.Apple: () => _handleMultiFactorException(
              _signInWithApple,
            ),
        Buttons.Google: () => _handleMultiFactorException(
              _signInWithGoogle,
            ),
        Buttons.GitHub: () => _handleMultiFactorException(
              _signInWithGitHub,
            ),
        Buttons.Microsoft: () => _handleMultiFactorException(
              _signInWithMicrosoft,
            ),
        Buttons.Twitter: () => _handleMultiFactorException(
              _signInWithTwitter,
            ),
        Buttons.Yahoo: () => _handleMultiFactorException(
              _signInWithYahoo,
            ),
        Buttons.Facebook: () => _handleMultiFactorException(
              _signInWithFacebook,
            ),
      };
    }
  }

  void authRenderCallback() {
    debugPrint("auth render callback");
    widget.callback();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(children: [
              mode == AuthMode.login
                  ? EmailPasswordLogin(callback: authRenderCallback)
                  : EmailPasswordSignup(
                      callback: authRenderCallback,
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // TODO: Suriya Clean this mess
                      mode = mode == AuthMode.register ? AuthMode.login : AuthMode.register;
                    });
                  },
                  child: mode == AuthMode.login
                      ? const Text("Signup"):const Text("login"))
            ]),
          ),
        ),
      ),
    )));
  }

  Future<void> _handleMultiFactorException(
    Future<void> Function() authFunction,
  ) async {
    setIsLoading();
    try {
      await authFunction();
    } on FirebaseAuthMultiFactorException catch (e) {
      setState(() {
        error = '${e.message}';
      });
      final firstTotpHint = e.resolver.hints
          .firstWhereOrNull((element) => element is TotpMultiFactorInfo);
      if (firstTotpHint != null) {
        final code = await getSmsCodeFromUser(context);
        final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
          firstTotpHint.uid,
          code!,
        );
        await e.resolver.resolveSignIn(assertion);
        return;
      }

      final firstPhoneHint = e.resolver.hints
          .firstWhereOrNull((element) => element is PhoneMultiFactorInfo);

      if (firstPhoneHint is! PhoneMultiFactorInfo) {
        return;
      }
      await auth.verifyPhoneNumber(
        multiFactorSession: e.resolver.session,
        multiFactorInfo: firstPhoneHint,
        verificationCompleted: (_) {},
        verificationFailed: print,
        codeSent: (String verificationId, int? resendToken) async {
          final smsCode = await getSmsCodeFromUser(context);

          if (smsCode != null) {
            // Create a PhoneAuthCredential with the code
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            try {
              await e.resolver.resolveSignIn(
                PhoneMultiFactorGenerator.getAssertion(
                  credential,
                ),
              );
            } on FirebaseAuthException catch (e) {
              print(e.message);
            }
          }
        },
        codeAutoRetrievalTimeout: print,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    }
    setIsLoading();
  }

  Future<void> _signInWithGoogle() async {
    // Trigger the authentication flow
    final googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final googleAuth = await googleUser?.authentication;

    if (googleAuth != null) {
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await auth.signInWithCredential(credential);
    }
  }

  Future<void> _signInWithFacebook() async {
    // Trigger the authentication flow
    // by default we request the email and the public profile
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      // Get access token
      final AccessToken accessToken = result.accessToken!;

      // Login with token
      await auth.signInWithCredential(
        FacebookAuthProvider.credential(accessToken.token),
      );
    } else {
      print('Facebook login did not succeed');
      print(result.status);
      print(result.message);
    }
  }
}

Future<void> _signInWithTwitter() async {
  TwitterAuthProvider twitterProvider = TwitterAuthProvider();

  if (kIsWeb) {
    await auth.signInWithPopup(twitterProvider);
  } else {
    await auth.signInWithProvider(twitterProvider);
  }
}

Future<void> _signInWithApple() async {
  final appleProvider = AppleAuthProvider();
  appleProvider.addScope('email');

  if (kIsWeb) {
    // Once signed in, return the UserCredential
    await auth.signInWithPopup(appleProvider);
  } else {
    final userCred = await auth.signInWithProvider(appleProvider);
    AuthGate.appleAuthorizationCode =
        userCred.additionalUserInfo?.authorizationCode;
  }
}

Future<void> _signInWithYahoo() async {
  final yahooProvider = YahooAuthProvider();

  if (kIsWeb) {
    // Once signed in, return the UserCredential
    await auth.signInWithPopup(yahooProvider);
  } else {
    await auth.signInWithProvider(yahooProvider);
  }
}

Future<void> _signInWithGitHub() async {
  final githubProvider = GithubAuthProvider();

  if (kIsWeb) {
    await auth.signInWithPopup(githubProvider);
  } else {
    await auth.signInWithProvider(githubProvider);
  }
}

Future<void> _signInWithMicrosoft() async {
  final microsoftProvider = MicrosoftAuthProvider();

  if (kIsWeb) {
    await auth.signInWithPopup(microsoftProvider);
  } else {
    await auth.signInWithProvider(microsoftProvider);
  }
}

Future<String?> getSmsCodeFromUser(BuildContext context) async {
  String? smsCode;

  // Update the UI - wait for the user to enter the SMS code
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('SMS code:'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Sign in'),
          ),
          OutlinedButton(
            onPressed: () {
              smsCode = null;
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
        content: Container(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (value) {
              smsCode = value;
            },
            textAlign: TextAlign.center,
            autofocus: true,
          ),
        ),
      );
    },
  );

  return smsCode;
}

Future<String?> getTotpFromUser(
  BuildContext context,
  TotpSecret totpSecret,
) async {
  String? smsCode;

  final qrCodeUrl = await totpSecret.generateQrCodeUrl(
    accountName: FirebaseAuth.instance.currentUser!.email,
    issuer: 'Firebase',
  );

  // Update the UI - wait for the user to enter the SMS code
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('TOTP code:'),
        content: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BarcodeWidget(
                barcode: Barcode.qrCode(),
                data: qrCodeUrl,
                width: 150,
                height: 150,
              ),
              TextField(
                onChanged: (value) {
                  smsCode = value;
                },
                textAlign: TextAlign.center,
                autofocus: true,
              ),
              ElevatedButton(
                onPressed: () {
                  totpSecret.openInOtpApp(qrCodeUrl);
                },
                child: const Text('Open in OTP App'),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Sign in'),
          ),
          OutlinedButton(
            onPressed: () {
              smsCode = null;
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );

  return smsCode;
}
