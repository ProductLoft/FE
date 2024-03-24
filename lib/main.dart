import 'dart:convert';
import 'dart:io';

import 'package:lang_fe/const/utils.dart';
import 'package:lang_fe/db/user_models.dart';
import 'package:lang_fe/pages/recording_page.dart';
import 'package:http/http.dart' as http;
import 'package:lang_fe/platform_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';

import 'theme.dart';

/// This method initializes macos_window_utils and styles the window.
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

Future<void> main() async {
  if (!kIsWeb) {
    if (Platform.isMacOS) {
      await _configureMacosWindowUtils();
    }
  }

  runApp(LanguageApp());
}

class LanguageApp extends StatelessWidget {
  LanguageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return MacosApp(
          title: 'macos_ui Widget Gallery',
          theme: MacosThemeData.light(),
          darkTheme: MacosThemeData.dark(),
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          home: const WidgetGallery(),
        );
      },
    );
  }
}

class WidgetGallery extends StatefulWidget {
  const WidgetGallery({super.key});

  @override
  State<WidgetGallery> createState() => _WidgetGalleryState();
}

class _WidgetGalleryState extends State<WidgetGallery> {
  int pageIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _myFocusNode = FocusNode();

  late final searchFieldController = TextEditingController();

  SidebarItems getSidebarItems(context, scrollController) {
    return SidebarItems(
      currentIndex: pageIndex,
      onChanged: (i) {
        if (kIsWeb && i == 10) {
          launchUrl(
            Uri.parse(
              'https://www.figma.com/file/IX6ph2VWrJiRoMTI1Byz0K/Apple-Design-Resources---macOS-(Community)?node-id=0%3A1745&mode=dev',
            ),
          );
        } else {
          setState(() => pageIndex = i);
        }
      },
      scrollController: scrollController,
      itemSize: SidebarItemSize.large,
      items: const [
        SidebarItem(
          leading: MacosImageIcon(
            AssetImage('assets/sf_symbols/button_programmable_2x.png'),
          ),
          label: Text('Recording'),
        ),
      ],
    );
  }

  Sidebar getEndSidebar() {
    return Sidebar(
      startWidth: 200,
      minWidth: 200,
      maxWidth: 300,
      shownByDefault: false,
      builder: (context, _) {
        return const Center(
          child: Text('End Sidebar'),
        );
      },
    );
  }

  // Function to check login state
  Future<bool> checkLoggedIn() async {
    // Replace with your actual authentication check logic
    return await UserProvider().isLoggedin();
  }

  Future<MacosWindow> getMacosWindow() async {
    User? user = await UserProvider().getUser();
    print('user: $user');
    String name = user?.name ?? 'Anon';
    String email = user?.email ?? 'Anon';

    return MacosWindow(
      sidebar: Sidebar(
        top: MacosSearchField(
          placeholder: 'Search',
          controller: searchFieldController,
          onResultSelected: (result) {
            switch (result.searchKey) {
              case 'Recording':
                setState(() {
                  pageIndex = 0;
                  searchFieldController.clear();
                });
                break;
              default:
                searchFieldController.clear();
            }
          },
          results: const [
            SearchResultItem('Record'),
          ],
        ),
        minWidth: 200,
        builder: getSidebarItems,
        bottom: MacosListTile(
          // User profile
          leading: MacosIcon(CupertinoIcons.profile_circled),
          title: Text(name),
          subtitle: Text(email),
        ),
      ),
      child: [
        CupertinoTabView(builder: (_) => const RecordingPage()),
      ][pageIndex],
    );
  }

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
          String name = body["user"]["name"];
          String username = body["user"]["username"];
          String email = body["user"]["email"];
          String? cookie = response.headers['set-cookie'];

          UserProvider up = UserProvider();
          // TODO save username
          User u = await up.createUser(name, username, email, cookie);

          // Success! Handle login
          print('Login successful!');
          setState(() {});
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
  void dispose() {
    // Dispose of the FocusNode when the widget is removed
    _myFocusNode.dispose();
    super.dispose();
  }


  // Handle user login
  MacosScaffold getLogin() {
    return MacosScaffold(
        toolBar: const ToolBar(
          title: Text('Login'),
          titleWidth: 150.0,
        ),
        children: [
          ContentArea(builder: (context, scrollController) {
            return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Form(

                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: MacosTextField(
                            controller: _emailController,
                            placeholder: 'Email',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: MacosTextField(
                            controller: _passwordController,
                            obscureText: true,
                            placeholder: 'Password',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16.0),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Navigate the user to the Home page
                                  _login();
                                  // setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please fill input')),
                                  );
                                }
                              },
                              child: const Text('Submit'),
                            ),
                          ),
                        ),
                      ],
                    )));
          }),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: menuBarItems(),
      child: FutureBuilder(
          future: checkLoggedIn(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            _myFocusNode.addListener(() {
              if (_myFocusNode.hasFocus &&
                  !_myFocusNode.hasPrimaryFocus &&
                  FocusManager.instance.primaryFocus!.context!.widget
                      is! TextFormField) {
                if (_formKey.currentState!.validate()) {
                  // Submit your form
                }
              }
            });

            if (snapshot.hasData && snapshot.data == true) {
              return FutureBuilder(
                future: getMacosWindow(), // Await the result here
                builder: (context, windowSnapshot) {
                  if (windowSnapshot.hasData) {
                    return windowSnapshot.data!; // Return the actual widget
                  } else {
                    return const Center(
                        child: CircularProgressIndicator()); // Show loading
                  }
                },
              );
            } else {
              return getLogin();
            }
          }),
    );
  }
}
