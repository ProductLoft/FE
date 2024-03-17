import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';


import '../theme.dart';
import 'audio_player.dart';
import 'audio_recorder.dart';



class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {

  String popupValue = 'One';
  String languagePopupValue = 'English';
  bool switchValue = false;
  bool isDisclosureButtonPressed = false;
  bool showPlayer = false;
  String? audioPath;
  final _tabController = MacosTabController(initialIndex: 0, length: 3);


  @override
  Widget build(BuildContext context) {

    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Buttons'),
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
              child: showPlayer
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: AudioPlayer(
                  source: audioPath!,
                  onDelete: () {
                    setState(() => showPlayer = false);
                  },
                ),
              )
                  : Recorder(
                onStop: (path) {
                  if (kDebugMode) print('Recorded file path: $path');
                  setState(() {
                    audioPath = path;
                    showPlayer = true;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }
}



const languages = [
  'Mandarin Chinese',
  'Spanish',
  'English',
  'Hindi/Urdu',
  'Arabic',
  'Bengali',
  'Portuguese',
  'Russian',
  'Japanese',
  'German',
  'Thai',
  'Greek',
  'Nepali',
  'Punjabi',
  'Wu',
  'French',
  'Telugu',
  'Vietnamese',
  'Marathi',
  'Korean',
  'Tamil',
  'Italian',
  'Turkish',
  'Cantonese/Yue',
  'Urdu',
  'Javanese',
  'Egyptian Arabic',
  'Gujarati',
  'Iranian Persian',
  'Indonesian',
  'Polish',
  'Ukrainian',
  'Romanian',
  'Dutch'
];
