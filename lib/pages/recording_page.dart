import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/single_child_widget.dart';
import 'package:record/record.dart';

import '../db/recording_models.dart';
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

  Future<List<AudioPlayer>> getAudioplayers() async {
    List<Recording> previousrecordings = await RecordingProvider().getAll();
    List<AudioPlayer> audioPlayers = [];

    // for (Recording previousrecording in previousrecordings) {
    //   audioPlayers.add(AudioPlayer(
    //     source: previousrecording.path,
    //     onDelete: () {},
    //   ));
    // }
    return audioPlayers;
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Recording Page'),
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
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      showPlayer
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: AudioPlayer(
                                source: audioPath!,
                                onDelete: () {
                                  setState(() => showPlayer = false);
                                },
                              ),
                            )
                          : Recorder(
                              onStop: (path) {
                                if (kDebugMode)
                                  print('Recorded file path: $path');
                                setState(() {
                                  audioPath = path;
                                  showPlayer = true;
                                });
                              },
                            ),
                      const SizedBox(height: 20),
                      const Text(
                        'Previous Recordings:',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),

                      // Expanded to make the content take remaining space
                      Container(
                        child: FutureBuilder<List<AudioPlayer>>(
                          future: getAudioplayers(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Column(
                                children: snapshot.data!,
                              );
                            }
                          },
                        ),
                        // return Column(
                        //   children: [
                        //     AudioPlayer(
                        //       source: 'path',
                        //       onDelete: () {},
                        //     ),
                        //     AudioPlayer(
                        //       source: 'path',
                        //       onDelete: () {},
                        //     ),
                        //     AudioPlayer(
                        //       source: 'path',
                        //       onDelete: () {},
                        //     ),
                        //   ],
                        // );
                      ),
                    ]));
          },
        ),
      ],
    );
  }
}
