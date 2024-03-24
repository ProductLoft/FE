import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lang_fe/const/utils.dart';

import '../db/recording_models.dart';
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
  bool refreshRecordings = false;
  String? audioPath;
  String commentText = '';

  Future<List<Widget>> getAudioplayers() async {
    List<Recording> previousrecordings = await RecordingProvider().getAll();
    List<Widget> audioPlayers = [];

    for (Recording previousrecording in previousrecordings) {
      audioPlayers.add(Text(previousrecording.comment));
      audioPlayers.add(AudioPlayer(
        source: previousrecording.path,
        onDelete: () {},
      ));
    }
    return audioPlayers;
  }

  Widget getRecorder() {
    return Column(children: [

    ]);
  }

  @override
  Widget build(BuildContext context) {
    // return const Text("data");

    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Recording Page'),
    //     leading: IconButton(
    //         icon: const Icon(
    //           CupertinoIcons.sidebar_left,
    //           size: 20.0,
    //         ),
    //         onPressed: () {
    //           // MacosWindowScope.of(context).toggleSidebar();
    //         },
    //         // onPressed: () => MacosWindowScope.of(context).toggleSidebar(),
    //       ),
    //     ),

    // children: [
    //   return ContentArea(
    //     builder: (context, ScrollController scrollController) {

    // return       Recorder(
    //   onStop: (path) {
    //     if (kDebugMode) {
    //       print('Recorded file path: $path');
    //     }
    //     setState(() {
    //       // _showCommentModal(context);
    //       RecordingProvider()
    //           .createRecording(path, commentText, "", getCurrentTime());
    //       audioPath = path;
    //       showPlayer = true;
    //     });
    //   },
    // );
    return Column( children: [
      Recorder(
        onStop: (path) {
          if (kDebugMode) {
            print('Recorded file path: $path');
          }
          setState(() {
            // _showCommentModal(context);
            RecordingProvider()
                .createRecording(path, commentText, "", getCurrentTime());
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
          FutureBuilder<List<Widget>>(
              future: getAudioplayers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
              }),
        ]);

    //               ]));
    //     },
    //   ),
    // ],
    // );
  }
}
