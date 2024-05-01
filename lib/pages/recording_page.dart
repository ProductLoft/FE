import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lang_fe/provider/app_basic_provider.dart';
import 'package:lang_fe/req/get_speakers.dart';
import 'package:lang_fe/req/status_check.dart';
import 'package:lang_fe/req/upload_audio.dart';
import 'package:lang_fe/utils/misc.dart';
import 'package:provider/provider.dart';

import '../const/consts.dart';
import '../db/recording_models.dart';
import '../db/sample_recording_models.dart';
import '../req/reqest_utils.dart';
import 'audio_player.dart';
import 'audio_recorder.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  // TODO: Why are these here
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

  @override
  initState() {
    super.initState();

    final provider = Provider.of<AppBasicInfoProvider>(context, listen: false);
    provider.addPageTrack('recording-page');
  }

  Future<List<Widget>> getAudioplayers(bool isBright) async {
    // AudioSampleRecordingProvider.getAll();
    // List<AudioSampleRecord> sampleRecords =
    //     await AudioSampleRecordingProvider().getAll();
    // debugPrint('isBright111:$isBright');
    // debugPrint('sampleRecords:${sampleRecords.length}');
    // if (sampleRecords.isNotEmpty) {
    List<AudioRecord> previousrecordings =
        await AudioRecordingProvider().getAll();
    debugPrint("previousrecordings:!!!!1${previousrecordings.length}");
    List<Widget> audioPlayers = [
      Recorder(
        waitToText: 'Waiting to record',
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
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          height: 1.5, // 设置分割线的高度
          width: 100.0, // 设置分割线的宽度为100逻辑像素
          color: Colors.black.withOpacity(0.1), // 设置分割线的颜色
        ),
        SizedBox(width: 8),
        Container(
          height: 2, // 设置分割线的高度
          width: 2, // 设置分割线的宽度为100逻辑像素
          color: Colors.black.withOpacity(0.1), // 设置分割线的颜色
        ),
        SizedBox(width: 8),
        Container(
          height: 1.5, // 设置分割线的高度
          width: 100.0, // 设置分割线的宽度为100逻辑像素
          color: Colors.black.withOpacity(0.1), // 设置分割线的颜色
        ),
      ]),
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
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            const Text("COMMENT: ",
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                previousRecording.comment != ''
                                                    ? previousRecording.comment
                                                    : "Audio_${previousRecording.id}",
                                                style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ])),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text("DATE-TIME: ",
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: isBright
                                                    ? Colors.black
                                                        .withOpacity(0.5)
                                                    : Colors.white
                                                        .withOpacity(0.8))),
                                        Text(_time,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: isBright
                                                    ? Colors.black
                                                        .withOpacity(0.5)
                                                    : Colors.white
                                                        .withOpacity(0.8)))
                                      ])
                                ])),
                      ])
                ])),
          ),
        ],
      );

      audioPlayers.add(customPlayer);
    }
    return audioPlayers;
    // } else {
    //   List<Widget> audioPlayers = [
    //     Recorder(
    //       waitToText: "HERE'S A RECORDING SAMPLE",
    //       onStop: (path) async {
    //         if (kDebugMode) {
    //           print('Recorded file path: $path');
    //         }
    //
    //         setState(() {
    //           _showCommentModal(context, path);
    //           audioPath = path;
    //           showPlayer = true;
    //         });
    //       },
    //     ),
    //   ];
    //
    //   return audioPlayers;
    // }
  }

  Future<List<Widget>> getAllInsights() async {
    //  TODO: Suriya, This should just be links in aws that download audio once clicked.

    List<dynamic> speakerTurns;
    String insightsDirPath = '';

    List<Widget> insights = [];
    debugPrint('showInsightsRecordId!!:$showInsightsRecordId');
    if (kIsWeb) {
      bool audioStatus = await checkAudioIdStatus(showInsightsRecordId);

      speakerTurns =
          audioStatus ? await GetAudioIDJson(showInsightsRecordId) : [];
    } else {
      String insightsDirPath =
          await checkAudioAndDownload(showInsightsRecordId);

      speakerTurns = insightsDirPath.isNotEmpty
          ? jsonDecode(await rootBundle.loadString(
              '$insightsDirPath/$speakerTurnsJson')) as List<dynamic>
          : [];
    }
    debugPrint('speakerTurns!!@!:${speakerTurns.length}');
    for (dynamic speakerTurn in speakerTurns) {
      Map<String, dynamic> speakerTurnStart =
          speakerTurn as Map<String, dynamic>;
      debugPrint('speakerTurnStart!!@!:$speakerTurnStart');
      insights.add(
        Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {},
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                        spacing: 8.0, // Space between text widgets
                        runSpacing: 4.0,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text("Speaker: ",
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                    child: Text(
                                        "${speakerTurnStart['speaker']}",
                                        style: const TextStyle(fontSize: 12.0)))
                              ]),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('You said:   ',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                    child: Text(
                                        "${speakerTurnStart['original_sentence']}",
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                        ))),
                              ]),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('You can say: ',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                    child: Text(
                                        "${speakerTurnStart['improved_sentence']}",
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                        ))),
                              ]),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('Reason: ',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                    child: Text(
                                        "${speakerTurnStart['improve_reason']}",
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                        ))),
                              ]),
                          // TODO: Suriya Why is it not in web?
                            Container(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomAudioPlayer(
                                      source: kIsWeb
                                          ? await getAudioUrl(
                                              speakerTurnStart[
                                                  "audio_record_id"] as int,
                                              speakerTurnStart["index"] as int)
                                          : '$insightsDirPath/${speakerTurnStart['file_name']}',
                                      onDelete: () {},
                                    )
                                  ]),
                            ),
                        ]),
                  ),
                ),
              ])),
        ),
      );
    }
    debugPrint("Done with audio players");
    debugPrint('insights:${insights.length}');

    return insights;
  }

  Future<List<Widget>> getInsightsPage() async {
    debugPrint('Audio Record!!!');
    AudioRecord? audioRecord =
        await AudioRecordingProvider().getRecording(showInsightsRecordId);
    debugPrint('Audio Record high level: ${audioRecord?.toMap()}');
    List<Widget> insights = [
      const Center(
        child: Text(
          'Conversation Insights',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
      Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Suriya Why is it not in web?
            if (!kIsWeb)
              CustomAudioPlayer(
                source: audioRecord?.path ?? 'Audio Not Found',
                onDelete: () {
                  // TODO modal confirmation on Delete
                  AudioRecordingProvider()
                      .deleteRecording(showInsightsRecordId);
                  setState(() {
                    refreshRecordings = true;
                    showInsights = false;
                  });
                },
              ),
          ]),
      Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Widget>>(
              future: getAllInsights(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error123!: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  debugPrint('Snapshot data: ${snapshot.data!.length}');
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: snapshot.data!,
                  );
                } else {
                  return const Text('No insights found');
                }
              })),
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
          title: const Text('Save audio with a comment'),
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
                debugPrint(_controller.text);
                int? audioRecordId = await uploadAudio(path);
                // debugPrint('Audio record id: $audioRecordId');

                await AudioRecordingProvider().createRecording(
                    path,
                    _controller.text,
                    "",
                    getCurrentTime(),
                    audioRecordId ?? -1);

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
    final isBright = Theme.of(context).brightness == Brightness.light;
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
              return Text('Error!45!: ${snapshot.error}');
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
