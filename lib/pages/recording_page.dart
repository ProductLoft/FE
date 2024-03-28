import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lang_fe/req/status_check.dart';
import 'package:lang_fe/req/upload_audio.dart';
import 'package:lang_fe/utils/misc.dart';

import '../const/consts.dart';
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
    List<AudioRecord> previousrecordings =
        await AudioRecordingProvider().getAll();
    List<Widget> audioPlayers = [
      Recorder(
        onStop: (path) async {
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
                    showInsightsRecordId = previousRecording.id ?? -1;
                    showInsights = true;
                  });
                },
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            // Example: 16 pixels on all sides
                            child: Column(children: [
                              Text("Date: ${previousRecording.timestamp}"),
                              Text(previousRecording.comment),
                            ])),
                      ])
                ])),
          ),
        ],
      );

      audioPlayers.add(customPlayer);
    }
    return audioPlayers;
  }

  // Future<String> getInsightsDirPath(int audioRecordId) async {
  //       return  checkAudioIdStatus(audioRecordId);
  // }

  Future<List<Widget>> getAllInsights() async {
    String insightsDirPath = await checkAudioIdStatus(showInsightsRecordId);
    List<Widget> insights = [Text("Insights: $insightsDirPath")];

    List<dynamic> speakerTurns = jsonDecode(
            await rootBundle.loadString('$insightsDirPath/$speakerTurnsJson')) as List<dynamic>;

    for (dynamic speakerTurn in speakerTurns) {
      Map<String, dynamic> speakerTurnStart = speakerTurn as Map<String, dynamic>;
      insights.add(
        Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                // debugPrint('Card tapped.${previousRecording.id}');
                // setState(() {
                //   showInsightsRecordId = previousRecording.id ?? -1;
                //   showInsights = true;
                // });
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children:[
                            Text("You said: ${speakerTurnStart['original_sentence']}"),
                            Text("Improved Sentence: ${speakerTurnStart['improved_sentence']}"),
                            Container(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  CustomAudioPlayer(
                                    source: '$insightsDirPath/${speakerTurnStart['file_name']}',
                                    onDelete: () {},
                                  )
                                ]
                              ),
                            )
                          ]
                        )
                      ),
                    ),
                  ),
                ]
              )
          ),
        ),
      );
      // insights.add(Text('Speaker Turn: $speakerTurn'));

      // debugPrint('Speaker Turn: $speakerTurn');
    }


    return insights;
  }

  Future<List<Widget>> getInsightsPage() async {
    AudioRecord? audioRecord =
        await AudioRecordingProvider().getRecording(showInsightsRecordId);
    debugPrint('Audio Record high level: ${audioRecord?.toMap()}');
    List<Widget> insights = [
      const Center(
        child: Text(
          // TODO, this should be in the appbar
          'Conversation Insights',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          CustomAudioPlayer(
            source: audioRecord?.path ?? 'Audio Not Found',
            onDelete: () {
              // TODO modal confirmation on Delete
              AudioRecordingProvider().deleteRecording(showInsightsRecordId);
              setState(() {
                refreshRecordings = true;
                showInsights = false;
              });
            },
          ),
        ]
      ),
      Column(children: [
        FutureBuilder<List<Widget>>(
            future: getAllInsights(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: snapshot.data!,
                    ));
              }
            })
      ]),
    ];

    // insights.add();

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
              onPressed: () async {
                int? audioRecordId = await uploadAudio(path);
                debugPrint('Audio record id: $audioRecordId');
                await AudioRecordingProvider().createRecording(path,
                    commentText, "", getCurrentTime(), audioRecordId ?? -1);
                setState(() {
                  commentText = _controller.text;
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
          future: showInsights ? getInsightsPage() : getAudioplayers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: snapshot.data!,
                  ));
            }
          }),
    ]);
  }
}
