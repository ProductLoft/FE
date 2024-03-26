import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lang_fe/const/utils.dart';
import 'package:lang_fe/pages/audio_page.dart';

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
  bool showInsights = false;
  int showInsightsRecordId = -1;

  Future<List<Widget>> getAudioplayers() async {
    List<AudioRecord> previousrecordings = await AudioRecordingProvider().getAll();
    List<Widget> audioPlayers = [
      Recorder(
        onStop: (path) {
          if (kDebugMode) {
            print('Recorded file path: $path');
          }
          setState(() {
            _showCommentModal(context, path);
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
    ];

    for (AudioRecord previousRecording in previousrecordings) {
      debugPrint(previousRecording.comment);
      Widget customPlayer = Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Text(previousRecording.comment),
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  debugPrint('Card tapped.${previousRecording.id}');
                  setState(() {
                    showInsightsRecordId = previousRecording.id??-1;
                    showInsights = true;
                  });
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => AudioPageWidget(audioID: previousRecording.id??-1)),
                  // );
                },
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            // Example: 16 pixels on all sides
                            child: Column(
                                // mainAxisSize: MainAxisSize.max,
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Date: ${previousRecording.timestamp}"),
                                  Text(previousRecording.comment),
                                ])),
                      ])
                ])),
          ),
          // Container(
          //     width: double.infinity,
          //     child:
          //
          //
          //     InputChip(
          //       label: const Text('Input'),
          //       onPressed: () {},
          //       onDeleted: () {},
          //     )),
          // Your existing player widget
        ],
      );


      audioPlayers.add(customPlayer);
    }
    return audioPlayers;
  }

  Future<List<Widget>> getInsights() async {
    List<Widget> insights = [];


    return insights;
  }

  void _showCommentModal(BuildContext context, String path) {
    TextEditingController _controller =
        TextEditingController(); // Controller for input

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add context'),
          content: TextField(
            controller: _controller,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Don\'t save'),
              onPressed: () {
                Navigator.pop(context); // Close the modal
              },
            ),
            TextButton(
              child: const Text('Save audio'),
              onPressed: () {
                setState(() {
                  commentText = _controller.text;
                  AudioRecordingProvider()
                      .createRecording(path, commentText, "", getCurrentTime());
                });
                Navigator.pop(context); // Close the modal after submission
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      FutureBuilder<List<Widget>>(
          future: showInsights?getInsights(): getAudioplayers(),
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
  }
}
