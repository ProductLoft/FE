import 'dart:convert';
import 'dart:io';

import 'package:lang_fe/db/user_models.dart';
import 'package:lang_fe/pages/buttons_page.dart';
import 'package:lang_fe/pages/colors_page.dart';
import 'package:lang_fe/pages/dialogs_page.dart';
import 'package:lang_fe/pages/fields_page.dart';
import 'package:lang_fe/pages/indicators_page.dart';
import 'package:lang_fe/pages/recording_page.dart';
import 'package:lang_fe/pages/resizable_pane_page.dart';
import 'package:lang_fe/pages/selectors_page.dart';
import 'package:http/http.dart' as http;
import 'package:lang_fe/pages/sliver_toolbar_page.dart';
import 'package:lang_fe/pages/tabview_page.dart';
import 'package:lang_fe/pages/toolbar_page.dart';
import 'package:lang_fe/pages/typography_page.dart';
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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              // else {
              //   // Show a loading indicator
              //   // return CircularProgressIndicator();
              // }

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
  int pageIndex = 1;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


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
        SidebarItem(
          leading: MacosImageIcon(
            AssetImage('assets/sf_symbols/button_programmable_2x.png'),
          ),
          label: Text('Login'),
        ),
        SidebarItem(
          leading: MacosImageIcon(
            AssetImage('assets/sf_symbols/button_programmable_2x.png'),
          ),
          label: Text('Buttons'),
        ),
        SidebarItem(
          leading: MacosImageIcon(
            AssetImage(
              'assets/sf_symbols/lines_measurement_horizontal_2x.png',
            ),
          ),
          label: Text('Indicators'),
        ),
        SidebarItem(
          leading: MacosImageIcon(
            AssetImage(
              'assets/sf_symbols/character_cursor_ibeam_2x.png',
            ),
          ),
          label: Text('Fields'),
        ),
        SidebarItem(
          leading: MacosImageIcon(
            AssetImage('assets/sf_symbols/rectangle_3_group_2x.png'),
          ),
          label: Text('Colors'),
        ),
        SidebarItem(
          leading: MacosIcon(CupertinoIcons.square_on_square),
          label: Text('Dialogs & Sheets'),
        ),
        SidebarItem(
          leading: MacosImageIcon(
            AssetImage(
              'assets/sf_symbols/macwindow.on.rectangle_2x.png',
            ),
          ),
          label: Text('Layout'),
          disclosureItems: [
            SidebarItem(
              leading: MacosIcon(CupertinoIcons.macwindow),
              label: Text('Toolbar'),
            ),
            SidebarItem(
              leading: MacosImageIcon(
                AssetImage(
                  'assets/sf_symbols/menubar.rectangle_2x.png',
                ),
              ),
              label: Text('SliverToolbar'),
            ),
            SidebarItem(
              leading: MacosIcon(CupertinoIcons.uiwindow_split_2x1),
              label: Text('TabView'),
            ),
            SidebarItem(
              leading: MacosIcon(CupertinoIcons.rectangle_split_3x1),
              label: Text('ResizablePane'),
            ),
          ],
        ),
        SidebarItem(
          leading: MacosImageIcon(
            AssetImage('assets/sf_symbols/filemenu_and_selection_2x.png'),
          ),
          label: Text('Selectors'),
        ),
        SidebarItem(
          leading: MacosIcon(CupertinoIcons.textformat_size),
          label: Text('Typography'),
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

  MacosWindow getMacosWindow() {
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
              case 'Login':
                setState(() {
                  pageIndex = 1;
                  searchFieldController.clear();
                });
                break;
              case 'Buttons':
                setState(() {
                  pageIndex = 2;
                  searchFieldController.clear();
                });
                break;
              case 'Indicators':
                setState(() {
                  pageIndex = 3;
                  searchFieldController.clear();
                });
                break;
              case 'Fields':
                setState(() {
                  pageIndex = 4;
                  searchFieldController.clear();
                });
                break;
              case 'Colors':
                setState(() {
                  pageIndex = 5;
                  searchFieldController.clear();
                });
                break;
              case 'Dialogs and Sheets':
                setState(() {
                  pageIndex = 6;
                  searchFieldController.clear();
                });
                break;
              case 'Toolbar':
                setState(() {
                  pageIndex = 7;
                  searchFieldController.clear();
                });
                break;
              case 'ResizablePane':
                setState(() {
                  pageIndex = 8;
                  searchFieldController.clear();
                });
                break;
              case 'Selectors':
                setState(() {
                  pageIndex = 9;
                  searchFieldController.clear();
                });
                break;
              default:
                searchFieldController.clear();
            }
          },
          results: const [
            SearchResultItem('Recording'),
            SearchResultItem('Login'),
            SearchResultItem('Buttons'),
            SearchResultItem('Indicators'),
            SearchResultItem('Fields'),
            SearchResultItem('Colors'),
            SearchResultItem('Dialogs and Sheets'),
            SearchResultItem('Toolbar'),
            SearchResultItem('ResizablePane'),
            SearchResultItem('Selectors'),
          ],
        ),
        minWidth: 200,
        builder: getSidebarItems,
        bottom: const MacosListTile(
          leading: MacosIcon(CupertinoIcons.profile_circled),
          title: Text('Tim Apple'),
          subtitle: Text('tim@apple.com'),
        ),
      ),
      child: [
        CupertinoTabView(builder: (_) => const RecordingPage()),
        CupertinoTabView(builder: (_) => const RecordingPage()),
        CupertinoTabView(builder: (_) => const ButtonsPage()),
        const IndicatorsPage(),
        const FieldsPage(),
        const ColorsPage(),
        const DialogsPage(),
        const ToolbarPage(),
        const SliverToolbarPage(isVisible: !kIsWeb),
        const TabViewPage(),
        const ResizablePanePage(),
        const SelectorsPage(),
        const TypographyPage(),
      ][pageIndex],
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/auth/login/'),
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
          String? cookie = response.headers['set-cookie'];

          UserProvider up = UserProvider();
          User u = await up.createUser(name, username, cookie);

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

  MacosScaffold getLogin(){
    return MacosScaffold(
        toolBar: ToolBar(
          title: const Text('Login'),
          titleWidth: 150.0,
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
                        ))
                );
              }
          ),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: menuBarItems(),
      child: FutureBuilder(
        future: checkLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data == true
              ? getMacosWindow()
              : getLogin();
        }
        return getMacosWindow();
      }),
    );
  }
}
