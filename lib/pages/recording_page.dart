import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lang_fe/req/status_check.dart';
import 'package:lang_fe/req/upload_audio.dart';
import 'package:lang_fe/utils/misc.dart';
import 'package:intl/intl.dart';

import '../const/consts.dart';
import '../db/recording_models.dart';
import '../db/sample_recording_models.dart';
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
  bool isSampleRecord = false;


  Future<List<Widget>> getAudioplayers(bool isBright) async {
    // AudioSampleRecordingProvider.getAll();
    List<AudioSampleRecord> sampleRecords = await AudioSampleRecordingProvider().getAll();
    debugPrint('isBright111:$isBright');
    if(sampleRecords.length > 0){
      List<AudioRecord> previousrecordings =
        await AudioRecordingProvider().getAll();
      List<Widget> audioPlayers = [
        Recorder(
          isSampleRecord: false,
          waitToText: 'Waiting to record',
          onStop: (path) async {
            if (kDebugMode) {
              print('Recorded file path: $path');
            }

            setState(() {
              isSampleRecord = false;
              _showCommentModal(context, path);
              audioPath = path;
              showPlayer = true;
            });
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Previous Recordings:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
      ];

      // debugPrint('previousrecordings:$previousrecordings');
      for (AudioRecord previousRecording in previousrecordings) {
        debugPrint(previousRecording.comment);

        var _time = '';

        try {
          // 将字符串转换为DateTime对象
          DateTime dateTime = DateTime.parse(previousRecording.timestamp);

          // 创建一个格式化器
          var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

          // 使用格式化器来格式化日期和时间
          _time = formatter.format(dateTime);
        } catch (e) {
          // 处理解析错误
          _time = previousRecording.timestamp;
        }

        // debugPrint(themeMode);

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children:[
                                      Text("COMMENT: ", style: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold)),
                                      Text(previousRecording.comment != '' ? previousRecording.comment : "Audio_${previousRecording.id}", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                                    ]
                                  )
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children:[
                                    Text("DATE-TIME: ", style: TextStyle(fontSize: 12.0, color: isBright ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8))),
                                    Text(_time, style: TextStyle(fontSize: 12.0,color: isBright ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8)))
                                  ]
                                )
                              ]
                            )
                          ),
                        ])
                  ])),
            ),
          ],
        );

        audioPlayers.add(customPlayer);
      }
      return audioPlayers;
    }else{
      List<Widget> audioPlayers = [
        Recorder(
          isSampleRecord: true,
          waitToText: "HERE'S A RECORDING SAMPLE",
          onStop: (path) async {
            if (kDebugMode) {
              print('Recorded file path: $path');
            }

            setState(() {
              isSampleRecord = true;
              _showCommentModal(context, path);
              audioPath = path;
              showPlayer = true;
            });
          },
        ),
      ];

      return audioPlayers;
    }
  }

  // Future<String> getInsightsDirPath(int audioRecordId) async {
  //       return  checkAudioIdStatus(audioRecordId);
  // }

  Future<List<Widget>> getAllInsights() async {
    String insightsDirPath = await checkAudioIdStatus(showInsightsRecordId);
    List<Widget> insights = [];

    List<dynamic> speakerTurns = jsonDecode(
            await rootBundle.loadString('$insightsDirPath/$speakerTurnsJson'))
        as List<dynamic>;
//80% of screen width
    double c_width = MediaQuery.of(context).size.width * 0.8;
    for (dynamic speakerTurn in speakerTurns) {
      Map<String, dynamic> speakerTurnStart =
          speakerTurn as Map<String, dynamic>;
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
      Padding(
          padding: const EdgeInsets.all(16.0),
      child:FutureBuilder<List<Widget>>(
            future: getAllInsights(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: snapshot.data!,
                    );
              }
            })
      ),
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
                setState(() {
                  commentText = _controller.text;
                });

                debugPrint('commentText:$commentText');
                int? audioRecordId = await uploadAudio(path, isSampleRecord ? 'True' : '');
                // debugPrint('Audio record id: $audioRecordId');

                if(isSampleRecord){
                  await AudioSampleRecordingProvider().createRecording(path,
                    commentText, "", getCurrentTime(), audioRecordId ?? -1);
                }else{
                  await AudioRecordingProvider().createRecording(path,
                    commentText, "", getCurrentTime(), audioRecordId ?? -1);
                }
                
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
    final isBright = Theme
        .of(context)
        .brightness == Brightness.light;
    debugPrint('isBright:$isBright');

    return Column(children: [
      FutureBuilder<List<Widget>>(
          future: showInsights ? getInsightsPage() : getAudioplayers(isBright),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    children: snapshot.data!,
                  ));
            }
          }),
    ]);
  }
}
